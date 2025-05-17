import 'dart:async';
import 'package:accompaneo/models/playlists.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:accompaneo/models/song/song.dart';
import 'package:accompaneo/pages/position_data.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:accompaneo/values/app_colors.dart';
import 'package:accompaneo/widgets/click_player.dart';
import 'package:accompaneo/widgets/music_player_screen.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guitar_chord_library/guitar_chord_library.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/song/audio_stream.dart';

class PlayerPage extends StatefulWidget {
  final Song song;

  const PlayerPage({super.key, required this.song});

  @override
  State<PlayerPage> createState() => _PlayerPageState(song: song);
}

T? ambiguate<T>(T? value) => value;

enum PracticeType { BandNoVocals, BandFull, PracticeFull, Click }

// double _tempo = 93.88489208633094;

class _PlayerPageState extends State<PlayerPage> with WidgetsBindingObserver {
  final Song song;

  Set<PracticeType> _segmentedButtonSelection = {};

  _PlayerPageState({required this.song});

  int audioMargin = 0;
  bool _animationEnded = false;
  final _player = AudioPlayer();
  final _metronomePlayer = AudioPlayer(handleAudioSessionActivation: false);
  final PublishSubject<bool> _playerPlaySubject = PublishSubject<bool>();
  final PublishSubject<int> _playSeekSubject = PublishSubject<int>();

  MusicPlayerScreen? musicPlayerScreen;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _segmentedButtonSelection = {
      PracticeType.values.firstWhere(
          (e) => e.toString() == 'PracticeType.${song.audioStreams![0].type}')
    };
    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    WakelockPlus.enable();
    _init();
  }

  Future<void> setAudioSource(String audioSource, Duration? duration) async {
    try {
      print("position: ${_player.position}");

      await _player
          .setAudioSource(AudioSource.uri(Uri.parse(audioSource)),
              initialIndex: 0, initialPosition: duration, preload: true)
          .then((dur) {
        _player.pause();
        _playerPlaySubject.add(false);
      });

      await _player.setClip(
        start: Duration(milliseconds: audioMargin),
        end: Duration(
            milliseconds:
                (_player.duration?.inMilliseconds ?? 0 - audioMargin)),
      );

      if (duration != null) {
        await _player.seek(duration);
      }

      //_player.setClip(start: Duration(milliseconds: 5120));
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

    _player
        .createPositionStream(
      steps: 1,
      minPeriod: Duration(
        milliseconds: 5,
      ),
      maxPeriod: Duration(
        milliseconds: 5,
      ),
    )
        .listen((p) {
      _playSeekSubject.add(p.inMilliseconds);
    });

    ApiService.getSongStructure(song.structureUrl).then((res) async {
      audioMargin = (song.audioStreams![0].margin * 1000).round();

      if (res.clock.first == 0) {
        audioMargin += (res.clock[1].toDouble() * 1000).toInt();

        res.bars.removeAt(0);
        res.clock.removeAt(0);
      } else if (res.bars.first.events.isEmpty) {
        audioMargin += (res.clock[1].toDouble() * 1000).toInt();
        res.bars.removeAt(0);
        res.clock.removeAt(0);
      }

      setState(() {
        musicPlayerScreen = MusicPlayerScreen(
          clickPlayer: ClickPlayer(4, 1, 58.968058968058, 0, 10000),
          musicData: res,
          playStream: _playerPlaySubject.stream,
          playSeekStream: _playSeekSubject,
          animationEnded: () {
            _animationEnded = true;
            _player.pause();
            _playerPlaySubject.add(false);
          },
        );

        //_audioUrl = song.audioStreamUrls![newSelection.first.name];
      });

      await setAudioSource(song.audioStreams![0].url, null);
    });
  }

  @override
  void dispose() {
    ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    _player.dispose();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
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

  StreamBuilder<PositionData> _overlayPanel({required bool portrait}) {
    return StreamBuilder<PositionData>(
      stream: Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position,
              bufferedPosition,
              duration ?? Duration.zero,
              _player.playerState,
              _player.processingState)),
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final playing = playerState?.playerState.playing;
        final completed =
            playerState?.processingState == ProcessingState.completed;
        final durationState = snapshot.data;
        final progress = durationState?.position ?? Duration.zero;
        final buffered = durationState?.bufferedPosition ?? Duration.zero;
        final total = durationState?.duration ?? Duration.zero;
        return playing != true || playing == null || completed
            ? Scaffold(
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
                        <WidgetStatesConstraint,
                            Color>{WidgetState.any: Colors.transparent}),
                    labelStyle: TextStyle(
                        backgroundColor: Colors.transparent, fontSize: 20),
                    unselectedLabelStyle: TextStyle(
                      backgroundColor: Colors.transparent,
                      fontSize: 20,
                    ),
                    tabs: [
                      Tab(text: AppLocalizations.of(context)!.play),
                      Tab(text: AppLocalizations.of(context)!.about),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height / 100),
                            child: SegmentedButton<PracticeType>(
                                style: ButtonStyle(
                                  foregroundColor: WidgetStateProperty<
                                      Color>.fromMap(<WidgetStatesConstraint, Color>{
                                    WidgetState.focused: Colors.white,
                                    WidgetState.selected: Colors.white,
                                    WidgetState.disabled: Colors.black,
                                    WidgetState.any: AppColors.primaryColor,
                                  }),
                                  backgroundColor: WidgetStateProperty<
                                      Color>.fromMap(<WidgetStatesConstraint, Color>{
                                    WidgetState.focused: Colors.white,
                                    WidgetState.disabled: Colors.grey.shade400,
                                    WidgetState.selected:
                                        AppColors.primaryColor,
                                    WidgetState.any: Colors.white,
                                  }),
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
                                onSelectionChanged:
                                    (Set<PracticeType> newSelection) {
                                  final String clickUrl = '';
                                  if (newSelection.first.name !=
                                      PracticeType.Click.name) {
                                    AudioStream as = song.audioStreams!
                                        .firstWhere((as) =>
                                            as.type == newSelection.first.name);
                                    setAudioSource(
                                            newSelection.first ==
                                                    PracticeType.Click
                                                ? clickUrl
                                                : as.url,
                                            _player.position)
                                        .then((v) {
                                      setState(() {
                                        _segmentedButtonSelection =
                                            newSelection;
                                        //_audioUrl = song.audioStreamUrls![newSelection.first.name];
                                      });
                                    });
                                  } else {
                                    setState(() {
                                      _segmentedButtonSelection = newSelection;
                                    });
                                  }
                                },
                                // SegmentedButton uses a List<ButtonSegment<T>> to build its children
                                // instead of a List<Widget> like ToggleButtons.
                                segments: [
                                  ButtonSegment<PracticeType>(
                                      label: Text(AppLocalizations.of(context)!.practice),
                                      value: PracticeType.PracticeFull,
                                      enabled: song.audioStreams!
                                              .firstWhereOrNull((as) =>
                                                  as.type == 'PracticeFull') !=
                                          null),
                                  ButtonSegment<PracticeType>(
                                      label: Text(AppLocalizations.of(context)!.band),
                                      value: PracticeType.BandNoVocals,
                                      enabled: song.audioStreams!
                                              .firstWhereOrNull((as) =>
                                                  as.type == 'BandNoVocals') !=
                                          null),
                                  ButtonSegment<PracticeType>(
                                      label: Text(AppLocalizations.of(context)!.plusVocals),
                                      value: PracticeType.BandFull,
                                      enabled: song.audioStreams!
                                              .firstWhereOrNull((as) =>
                                                  as.type == 'BandFull') !=
                                          null),
                                  ButtonSegment<PracticeType>(
                                      label: Text(AppLocalizations.of(context)!.click),
                                      value: PracticeType.Click),
                                ])),
                        Align(
                          alignment: Alignment.center,
                          child: _playButton(
                            snapshot,
                            portrait: portrait,
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom:
                                            MediaQuery.of(context).size.height /
                                                20),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          song.favoured
                                              ? Icon(Icons.favorite,
                                                  color: Colors.white)
                                              : Icon(
                                                  Icons
                                                      .favorite_outline_outlined,
                                                  color: Colors.white),
                                          Text(song.name,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                      color: Colors.white)),
                                          Text(song.artist.name,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium!
                                                  .copyWith(
                                                      color: Colors.white))
                                        ]),
                                  ),
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              8,
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              40),
                                      child: ProgressBar(
                                        progress: progress,
                                        buffered: buffered,
                                        total: total,
                                        onSeek: _player.seek,
                                        onDragUpdate: (details) {
                                          setState(() {
                                            _animationEnded = false;
                                            _playSeekSubject.add(details
                                                .timeStamp.inMilliseconds);
                                          });
                                        },
                                        thumbColor: AppColors.primaryColor,
                                        baseBarColor: Colors.white,
                                        bufferedBarColor: Colors.amber,
                                        timeLabelTextStyle:
                                            TextStyle(color: Colors.white),
                                      ))
                                ]))
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            children: [
                              Text("Title: ", style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(song.name,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(color: Colors.white)),
                            ],
                          ),
                          Wrap(
                            children: [
                              Text("Artist: ", style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(song.artist.name,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(color: Colors.white)),
                            ],
                          ),
                          // Wrap(
                          //   children: [
                          //     Text("Key: ", style: Theme.of(context)
                          //         .textTheme
                          //         .headlineMedium!
                          //         .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          //     Text(song.key ?? '',
                          //     textAlign: TextAlign.center,
                          //     style: Theme.of(context)
                          //         .textTheme
                          //         .headlineSmall!
                          //         .copyWith(color: Colors.white)),
                          //   ],
                          // ),
                          Wrap(
                            children: [
                              Text("Tempo: ", style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text("${song.bpm.roundToDouble()}",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(color: Colors.white)),
                            ],
                          ), 
                          Wrap(
                            children: [
                              Text("Chords: ", style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(song.chords!.join(","),
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(color: Colors.white)
                              )
                            ],
                          ),
                        ]
                      ),
                    )
                  ],
                ))
            : Container();
      },
    );
  }

  Widget _playButton(
    AsyncSnapshot<PositionData> snapshot, {
    required bool portrait,
  }) {
    double iconSize = portrait ? 150 : 90;
    final playerState = snapshot.data;
    final processingState = playerState?.playerState.processingState;
    final playing = playerState?.playerState.playing;
    _animationEnded = false;

    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        margin: const EdgeInsets.all(8.0),
        width: iconSize,
        height: iconSize,
        child: const CircularProgressIndicator(color: Colors.white),
      );
    } else if (playing == false && _animationEnded) {
      return IconButton(
        icon: const Icon(Icons.replay_outlined),
        iconSize: iconSize,
        color: Colors.white,
        onPressed: () async {
          await _player.seek(Duration(milliseconds: 0));
          _player.play();
          _playerPlaySubject.add(true);
          _animationEnded = false;
        },
      );
    } else if (playing != true) {
      return Container(
        child: IconButton(
            icon: const Icon(Icons.play_arrow_outlined),
            iconSize: iconSize,
            color: Colors.white,
            onPressed: () async {
              _player.play();
              _playerPlaySubject.add(true);
            }),
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        icon: const Icon(Icons.pause_outlined),
        iconSize: iconSize,
        color: Colors.white,
        onPressed: () {
          _player.pause();
          _playerPlaySubject.add(false);
        },
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.replay_outlined),
        iconSize: iconSize,
        color: Colors.white,
        onPressed: () {
          _player.seek(Duration(milliseconds: 0));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var selection = Provider.of<PlaylistsModel>(context, listen: true).getSettings().instrumentType;
    var useFlat = false;

    var instrument = (selection == 'GUITAR')
        ? GuitarChordLibrary.instrument(InstrumentType.guitar)
        : GuitarChordLibrary.instrument(InstrumentType.ukulele);

    List<String> keys = instrument.getKeys(useFlat);

    List<Chord>? chords = instrument.getChordsByKey('A', useFlat);

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
        child: OrientationBuilder(builder: (context, orientation) {
          return Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  GestureDetector(
                      onTap: () {
                        if (_player.playing) {
                          _player.pause();
                          _playerPlaySubject.add(false);
                        }
                      },
                      child: musicPlayerScreen ?? Container()),
                  _overlayPanel(portrait: orientation == Orientation.portrait),
                ],
              ));
        }));
  }
}
