import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
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

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: <Widget>[
            Scaffold(
              backgroundColor: Colors.white,
              body: Text('Player'),
            ),
            Scaffold(
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
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: SegmentedButton<PracticeType>(
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
                          child: IconButton(onPressed: ()=> {}, icon: Icon(Icons.play_arrow_outlined, color: Colors.white, size: 150))
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                              children: [
                                IconButton(onPressed: ()=> {}, icon: Icon(Icons.favorite_outline, color: Colors.white, size: 30)),
                                Text('House of the rising sun', style: AppTheme.titleLarge.copyWith(color: Colors.white)),
                                Text('Neil Young', style: AppTheme.sectionTitle.copyWith(color: Colors.white)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 130, vertical: 50),
                                  child: 
                                    ProgressBar(
                                      progress: Duration(milliseconds: 0),
                                      buffered: Duration(milliseconds: 0),
                                      total: Duration(milliseconds: 5000),
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
            )])
        
    );
  }
}