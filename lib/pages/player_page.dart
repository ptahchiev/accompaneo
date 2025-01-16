import 'package:accompaneo/pages/a.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:accompaneo/widgets/section_widget.dart';
import 'package:accompaneo/values/app_theme.dart';
import 'package:accompaneo/values/app_colors.dart';
import 'package:flutter/services.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.title});

  final String title;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

enum PracticeType { simple, band, bandVocals, click }

const List<(PracticeType, String)> practiceTypeOptions = <(PracticeType, String)>[
  (PracticeType.simple, 'Practice'),
  (PracticeType.band, 'Band'),
  (PracticeType.bandVocals, '+Vocals'),
  (PracticeType.click, 'Click')
];

class _PlayerPageState extends State<PlayerPage> {
  
  Set<PracticeType> _segmentedButtonSelection = <PracticeType>{PracticeType.simple};
  PlayerState _playerState = PlayerState.stopped;

  late AudioPlayer _audioPlayer;
  late AudioCache _audioCache;

  bool get _isPlaying => _playerState == PlayerState.playing;

  @override
  void initState() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    _audioCache = AudioCache();

    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  _playPause() async {
    if (_playerState == PlayerState.playing) {
      _audioPlayer.pause().then((value) => {
        setState(() {
          _playerState = PlayerState.paused;
        })
      });
    } else if (_playerState == PlayerState.paused) {
      _audioPlayer.resume().then((value)=> {
        setState(() {
          _playerState = PlayerState.playing;
        })
      });
    } else {
      _audioPlayer.play(UrlSource('https://musopia-assets-static-v2.web.app/NN1N8hcKCjkAERGyHLFHgX0LjU2ycypWVs5Nu9oZJ6yK6K40fwMoTzBC5XArqhzf/Audio/107/band/no_voc/speed_100/stream/128k/stream.m4a')).then((value) => {
        setState(() {
          _playerState = PlayerState.playing;
        })
      });
    }
  }
  _stop() async {
    _audioPlayer.stop().then((value) => {
      setState(() {
        _playerState = PlayerState.stopped;
      })
    });
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
                onTap: () => {_playPause()},
                child: 
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height / 25, horizontal: MediaQuery.of(context).size.width / 25),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 75,
                          child: Container(
                              decoration: BoxDecoration(borderRadius: radius, color: AppColors.primaryColor),
                            ),
                          ),
                        Expanded(
                          flex: 25,
                          child: Container(
                            color: Colors.transparent
                          ),
                        ),
                      ],
                    ),
                  ),
            )
            ),
            Visibility(
              visible: !_isPlaying,
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
                            child: IconButton(onPressed: ()=> {_playPause()}, icon: Icon(Icons.play_arrow_outlined, color: Colors.white, size: 150))
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
                                    child: 
                                      ProgressBar(
                                        progress: Duration(milliseconds: 4000),
                                        buffered: Duration(milliseconds: 0),
                                        total: Duration(milliseconds: 50000),
                                        thumbColor: AppColors.primaryColor,
                                        baseBarColor: Colors.white,
                                        timeLabelTextStyle: TextStyle(color: Colors.white),
                                        onSeek: (duration) {
                                          print('User selected a new time: $duration');
                                        },
                                      ),
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