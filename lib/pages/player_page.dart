import 'dart:async';

import 'package:accompaneo/models/playlists.dart';
import 'package:accompaneo/models/song/song.dart';
import 'package:accompaneo/pages/position_data.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:accompaneo/values/app_theme.dart';
import 'package:accompaneo/values/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_guitar_chord/flutter_guitar_chord.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../utils/helpers/chords_helper.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'package:reliable_interval_timer/reliable_interval_timer.dart';
import 'package:guitar_chord_library/guitar_chord_library.dart';

class PlayerPage extends StatefulWidget {

  final Song song;

  const PlayerPage({super.key, required this.song});

  @override
  State<PlayerPage> createState() => _PlayerPageState(song: this.song);
}

T? ambiguate<T>(T? value) => value;

enum PracticeType { BandNoVocals, BandFull, PracticeFull, Click }

// double _tempo = 93.88489208633094;

class _PlayerPageState extends State<PlayerPage> with WidgetsBindingObserver {

  final Song song;

  Set<PracticeType> _segmentedButtonSelection = {};


  _PlayerPageState({required this.song});
  
  //late AudioPlayerManager audioPlayerManager;
  final _player = AudioPlayer();
  final _metronomePlayer = AudioPlayer(handleAudioSessionActivation : false);

  //String _audioUrl = '';

  @override
  void initState() {
    super.initState();
    _segmentedButtonSelection = {PracticeType.values.firstWhere((e) => e.toString() == 'PracticeType.${song.audioStreamUrls!.keys.toList()[0]}')};
    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _init();
  }

  Future<void> setAudioSource(String audioSource) async {
    try {
      print("position: ${_player.position}");
      _player.setAudioSource(AudioSource.uri(Uri.parse(audioSource)), initialPosition: _player.position, preload: true).then((dur) {
        //_player.pause();
      });
    } on PlayerException catch (e) {
      print("Error loading audio source: $audioSource $e");
    }
  }

  Future<void> _init() async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Listen toerrors during playback.
    
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
          // completed show next song screen
      }
    });


    setAudioSource(song.audioStreamUrls!.values.toList()[0]);
  }

  @override
  void dispose() {
    ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    _player.dispose();
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      _player.stop();
    }
  }

  // void onTimerTick(int elapsedMilliseconds) {
  //   _metronomePlayer.play();
  // }

  // playMetronome() {
  //   double bps = _tempo/60;
  //   int tickInterval = 1000~/bps;
  //   var counter = 4;


  //   // var timer = ReliableIntervalTimer(
  //   //   interval: Duration(milliseconds: tickInterval),
  //   //   callback: (ms) => {
  //   //       counter --,
  //   //       _metronomePlayer.play()
  //   //   },
  //   // );

  //   // timer.start().then((_) {
  //   //   print('Timer started');
  //   //   timer.stop();
  //   // });

  //   Timer.periodic(Duration(milliseconds: 1000), (timer) {
  //     counter--;
  //     if (counter == 0) {
  //       timer.cancel();
  //     }
  //     //SystemSound.play(SystemSoundType.alert);
  //     //_metronomePlayer.play();
  //   });
  // }




  StreamBuilder<PositionData> _overlayPanel() {

    return StreamBuilder<PositionData>(
      stream: Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero, _player.playerState)),
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final playing = playerState?.playerState.playing;
        final durationState = snapshot.data;
        final progress = durationState?.position ?? Duration.zero;
        final buffered = durationState?.bufferedPosition ?? Duration.zero;
        final total = durationState?.duration ?? Duration.zero;        
        return playing != true || playing == null ? Scaffold(
          backgroundColor: Colors.transparent.withOpacity(0.7), //yes
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            backgroundColor: Colors.transparent, //yes
            elevation: 0.0,
            title: TabBar(
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
              indicatorColor: AppColors.primaryColor,
              overlayColor: WidgetStateProperty.fromMap(
                <WidgetStatesConstraint, Color>{
                  WidgetState.any: Colors.transparent
                }
              ),
              labelStyle: TextStyle(
                backgroundColor: Colors.transparent,
                fontSize: 20
              ),
              unselectedLabelStyle: TextStyle(
                backgroundColor: Colors.transparent,
                fontSize: 20,
              ),
              tabs: [
                Tab(text: 'PLAY'),
                Tab(text: 'ABOUT'),
              ],
            ),
          ),
        body:
            TabBarView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height / 100),
                      child: 
                        SegmentedButton<PracticeType>(
                            style: ButtonStyle(
                              foregroundColor: WidgetStateProperty<Color>.fromMap(
                                <WidgetStatesConstraint, Color>{
                                  WidgetState.focused: Colors.white,
                                  WidgetState.selected : Colors.white,
                                  WidgetState.disabled: Colors.black,
                                  WidgetState.any: AppColors.primaryColor,
                                }
                              ),
                              backgroundColor: WidgetStateProperty<Color>.fromMap(
                                  <WidgetStatesConstraint, Color>{
                                    WidgetState.focused: Colors.white,
                                    WidgetState.disabled: Colors.grey.shade400,
                                    WidgetState.selected : AppColors.primaryColor,
                                    WidgetState.any: Colors.white,
                                  }
                              ),

                              
                            ),
                            // ToggleButtons above allows multiple or no selection.
                            // Set `multiSelectionEnabled` and `emptySelectionAllowed` to true
                            // to match the behavior of ToggleButtons.
                            multiSelectionEnabled: false,
                            emptySelectionAllowed: false,
                            
                            // Hide the selected icon to match the behavior of ToggleButtons.
                            showSelectedIcon: false,
                            // SegmentedButton uses a Set<T> to track its selection state.
                            selected: _segmentedButtonSelection,
                            // This callback updates the set of selected segment values.
                            onSelectionChanged: (Set<PracticeType> newSelection) {
                              //SystemSound.play(SystemSoundType.click);
                              final String clickUrl = '';
                              setAudioSource(newSelection.first == PracticeType.Click ? clickUrl : song.audioStreamUrls![newSelection.first.name]).then((v) {
                                setState(() {
                                  _segmentedButtonSelection = newSelection;
                                  //_audioUrl = song.audioStreamUrls![newSelection.first.name];
                                });
                              });

                            },
                            // SegmentedButton uses a List<ButtonSegment<T>> to build its children
                            // instead of a List<Widget> like ToggleButtons.
                            segments: [
                                ButtonSegment<PracticeType>(label: Text('Practice'), value: PracticeType.PracticeFull, enabled: song.audioStreamUrls!.keys.contains('PracticeFull')),
                                ButtonSegment<PracticeType>(label: Text('Band'), value: PracticeType.BandNoVocals, enabled: song.audioStreamUrls!.keys.contains('BandNoVocals')),
                                ButtonSegment<PracticeType>(label: Text('+Vocals'), value: PracticeType.BandFull, enabled: song.audioStreamUrls!.keys.contains('BandFull')),
                                ButtonSegment<PracticeType>(label: Text('Click'), value: PracticeType.Click),
                            ]
                        )
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: _playButton(snapshot)
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  song.favoured ? Icon(Icons.favorite, color: Colors.white) : Icon(Icons.favorite_outline_outlined, color: Colors.white),
                                  Text(song.name, textAlign: TextAlign.center, style: AppTheme.titleLarge.copyWith(color: Colors.white)),
                                  Text(song.artist.name, textAlign: TextAlign.center, style: AppTheme.sectionTitle.copyWith(color: Colors.white))
                                ]),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 8, vertical: MediaQuery.of(context).size.height / 40),
                              child: 
                                ProgressBar(
                                  progress: progress,
                                  buffered: buffered,
                                  total: total,
                                  onSeek: _player.seek,
                                  onDragUpdate: (details) {
                                    debugPrint('${details.timeStamp}, ${details.localPosition}');
                                  },
                                  thumbColor: AppColors.primaryColor,
                                  baseBarColor: Colors.white,
                                  bufferedBarColor: Colors.amber,
                                  timeLabelTextStyle: TextStyle(color: Colors.white),
                                )
                            )
                          ]
                      )
                    )
                  ],
                ),
                Icon(Icons.directions_transit)
              ],
            )
        ) : Container();
      },
    );  
  }


  Widget _playButton(AsyncSnapshot<PositionData> snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.playerState.processingState;
        final playing = playerState?.playerState.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8.0),
            width: 150,
            height: 150,
            child: const CircularProgressIndicator(color: Colors.white),
          );
        } else if (playing != true) {
          return IconButton(
            icon: const Icon(Icons.play_arrow_outlined),
            iconSize: 150,
            color: Colors.white,
            onPressed: () => _player.play(),
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            icon: const Icon(Icons.pause_outlined),
            iconSize: 150,
            color: Colors.white,
            onPressed: _player.pause,
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.replay_outlined),
            iconSize: 150,
            color: Colors.white,
            onPressed: () =>
                _player.seek(Duration.zero),
          );
        }
  }

  @override
  Widget build(BuildContext context) {

    var _selection = 'Guitar';
    var _useFlat = false;

    var instrument = (_selection == null || _selection == 'Guitar')
        ? GuitarChordLibrary.instrument()
        : GuitarChordLibrary.instrument(InstrumentType.ukulele);

    List<String> keys = instrument.getKeys(_useFlat);

    List<Chord>? chords = instrument.getChordsByKey('A', _useFlat);

    var index = 0;
    Chord chord = chords![index];
    var position = chord.chordPositions[0]; //I 

    //FlutterGuitarChord nextChord = ChordsHelper.chordTypeOptions[ChordType.A] ?? ChordsHelper.MISSING;

    BorderRadiusGeometry radius = BorderRadius.only(
      topRight: Radius.circular(75.0),
      bottomLeft: Radius.circular(75.0),
    );

    return DefaultTabController(
      length: 2,
      child: OrientationBuilder(
        builder: (context, orientation) {
          return Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: <Widget>[
                Scaffold(
                  backgroundColor: Colors.white,
                  body: GestureDetector(
                    onTap: () { 
                      if (_player.playing) {
                        _player.pause();
                      }
                    },
                    child: 
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height / 25, horizontal: MediaQuery.of(context).size.width / 25),
                        child: Column(
                          //crossAxisCount: orientation == Orientation.portrait ? 1 : 2,
                          children: <Widget>[
                            Expanded(
                              flex: 65,
                              child: Container(
                                  decoration: BoxDecoration(borderRadius: radius, color: AppColors.primaryColor),
                                ),
                              ),
                            Expanded(
                              flex: 35,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height / 10),
                                child: Column(
                                  children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 20),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: 
                                          [
                                            Text('Next', style: AppTheme.titleMedium.copyWith(color: Colors.black)),
                                            CircleAvatar(backgroundColor: ChordsHelper.chordTypeColors[chord],
                                              child: Text(chord.name, style: AppTheme.bodySmall.copyWith(color: Colors.white)))
                                          ]
                                        ),
                                      ),
                                      Expanded(
                                        child: Flexible(
                                          child: FlutterGuitarChord(
                                            baseFret: position.baseFret,
                                            chordName: chord.name,
                                            fingers: position.fingers,
                                            frets: position.frets,
                                            totalString: instrument.stringCount,
                                            stringStroke: 0.4,
                                            //differentStringStrokes: _useStringThickness,
                                            // stringColor: Colors.red,
                                            // labelColor: Colors.teal,
                                            // tabForegroundColor: Colors.white,
                                            // tabBackgroundColor: Colors.deepOrange,
                                            firstFrameStroke: 10,
                                            barStroke: 0.5,
                                            //firstFrameColor: Colors.red,
                                            barColor: Colors.grey,
                                            // labelOpenStrings: true,                          
                                          ),
                                        ),
                                      )
                                  ]
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  )
                ),
                _overlayPanel()
                ]);
        }
      )
        
    );
  }
}