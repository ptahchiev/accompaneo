import 'package:accompaneo/pages/position_data.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:accompaneo/widgets/section_widget.dart';
import 'package:accompaneo/values/app_theme.dart';
import 'package:accompaneo/values/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import '../utils/helpers/audio_player_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_guitar_chord/flutter_guitar_chord.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.title});

  final String title;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

T? ambiguate<T>(T? value) => value;

enum PracticeType { simple, band, bandVocals, click }

const List<(PracticeType, String)> practiceTypeOptions = <(PracticeType, String)>[
  (PracticeType.simple, 'Practice'),
  (PracticeType.band, 'Band'),
  (PracticeType.bandVocals, '+Vocals'),
  (PracticeType.click, 'Click')
];

class _PlayerPageState extends State<PlayerPage> with WidgetsBindingObserver {
  
  Set<PracticeType> _segmentedButtonSelection = <PracticeType>{PracticeType.simple};

  //late AudioPlayerManager audioPlayerManager;
  final _player = AudioPlayer();

  late PlayerState _playerState;

  @override
  void initState() {
    // audioPlayerManager = AudioPlayerManager();
    // audioPlayerManager.init();

    super.initState();
    _playerState = _player.playerState;
    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _init();
  }

  Future<void> _init() async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    // Try to load audio from a source and catch any errors.
    try {
      // AAC example: https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.aac
      await _player.setAudioSource(AudioSource.uri(Uri.parse(
          "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3")));
    } on PlayerException catch (e) {
      print("Error loading audio source: $e");
    }
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

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  _playPause() {
    if (_playerState.playing) {
      _player.pause().then((value) => {
        setState(() {
          _playerState = _player.playerState;
        })
      });
    } else {
      _player.play().then((value)=> {
        setState(() {
          _playerState = _player.playerState;
        })
      });
    }
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8.0),
            width: 32.0,
            height: 32.0,
            child: const CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return IconButton(
            icon: const Icon(Icons.play_arrow),
            iconSize: 32.0,
            onPressed: _player.play,
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            icon: const Icon(Icons.pause),
            iconSize: 32.0,
            onPressed: _player.pause,
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.replay),
            iconSize: 32.0,
            onPressed: () =>
                _player.seek(Duration.zero),
          );
        }
      },
    );  
  }

  StreamBuilder<PositionData> _progressBar() {
    return StreamBuilder<PositionData>(
      stream: _positionDataStream,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.position ?? Duration.zero;
        final buffered = durationState?.bufferedPosition ?? Duration.zero;
        final total = durationState?.duration ?? Duration.zero;
        return ProgressBar(
          progress: progress,
          buffered: buffered,
          total: total,
          onSeek: _player.seek,
          onDragUpdate: (details) {
            debugPrint('${details.timeStamp}, ${details.localPosition}');
          },
          thumbColor: AppColors.primaryColor,
          baseBarColor: Colors.white,
          timeLabelTextStyle: TextStyle(color: Colors.white),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    BorderRadiusGeometry radius = BorderRadius.only(
      topRight: Radius.circular(75.0),
      bottomLeft: Radius.circular(75.0),
    );

    return DefaultTabController(
      length: 2,
      child: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: <Widget>[
            Scaffold(
              backgroundColor: Colors.white,
              body: GestureDetector(
                onTap: () =>_playPause(),
                child: 
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height / 25, horizontal: MediaQuery.of(context).size.width / 25),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 70,
                          child: Container(
                              decoration: BoxDecoration(borderRadius: radius, color: AppColors.primaryColor),
                            ),
                          ),
                        Expanded(
                          flex: 30,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height / 6),
                            child: Column(
                              children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: 
                                      [
                                        Text('Next', style: AppTheme.titleLarge.copyWith(color: Colors.black)),
                                        CircleAvatar(backgroundColor: Colors.red,
                                        
                                          child: Text('C', style: AppTheme.bodySmall.copyWith(color: Colors.white)))
                                      ]
                                    ),
                                  ),
                                  Expanded(
                                    child: 
                                      FlutterGuitarChord(
                                                                  
                                        baseFret: 1,
                                        chordName: 'Cmajor',
                                        fingers: '0 3 2 0 1 0',
                                        frets: '-1 3 2 0 1 0',
                                        totalString: 6,
                                        
                                        labelColor: AppColors.primaryColor,
                                        showLabel: false,
                                        tabForegroundColor: Colors.white,
                                        tabBackgroundColor: Colors.red,
                                        // tabForegroundColor: Colors.white,
                                        // tabBackgroundColor: Colors.deepOrange,
                                        // barColor: Colors.black,
                                        // stringColor: Colors.red,
                                      )
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
            Visibility(
              visible: !_playerState.playing,
              child: Scaffold(
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
                                        WidgetState.any: AppColors.primaryColor,
                                      }
                                    ),
                                    backgroundColor: WidgetStateProperty<Color>.fromMap(
                                        <WidgetStatesConstraint, Color>{
                                          WidgetState.focused: Colors.white,
                                          WidgetState.selected : AppColors.primaryColor,
                                          WidgetState.any: Colors.white,
                                        }
                                    )
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
                                    setState(() {
                                      _segmentedButtonSelection = newSelection;
                                    });
                                  },
                                  // SegmentedButton uses a List<ButtonSegment<T>> to build its children
                                  // instead of a List<Widget> like ToggleButtons.
                                  segments: practiceTypeOptions
                                      .map<ButtonSegment<PracticeType>>(((PracticeType, String) practiceType) {
                                    return ButtonSegment<PracticeType>(
                                        value: practiceType.$1, label: Text(practiceType.$2));
                                  }).toList(),
                              )
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: IconButton(onPressed: () =>_playPause(), icon: Icon(Icons.play_arrow_outlined, color: Colors.white, size: 150))
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                                children: [
                                  IconButton(onPressed: ()=> {}, icon: Icon(Icons.favorite_outline, color: Colors.white, size: 30)),
                                  Text('You Look Wonderful Tonight', style: AppTheme.titleLarge.copyWith(color: Colors.white)),
                                  Text('Eric Clapton', style: AppTheme.sectionTitle.copyWith(color: Colors.white)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 25, vertical: MediaQuery.of(context).size.height / 25),
                                    child: _progressBar()
                                  )
                                ]
                            )
                          )
                        ],
              
                      ),
                      Icon(Icons.directions_transit)
                    ],
                  )
              ),
            )])
        
    );
  }
}