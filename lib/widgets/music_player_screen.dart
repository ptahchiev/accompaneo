import 'dart:math';

import 'package:accompaneo/models/music_data.dart';
import 'package:accompaneo/utils/helpers/chords_helper.dart';
import 'package:accompaneo/values/app_colors.dart';
import 'package:accompaneo/values/app_dimensions.dart';
import 'package:accompaneo/widgets/pulsating_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guitar_chord/flutter_guitar_chord.dart';
import 'package:guitar_chord_library/guitar_chord_library.dart';

class MusicPlayerScreen extends StatefulWidget {
  MusicPlayerScreen({
    required this.musicData,
    required this.playStream,
  });

  final MusicData musicData;
  final Stream<bool> playStream;

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with SingleTickerProviderStateMixin {
  int _currentSegmentIndex = 1;
  double _segmentProgress = -0.2;
  String _timeSignature = '1/1';
  double _circleSize = 30;
  double? _pausedAnimationValue;
  late AnimationController _controller;
  bool _songPlaying = false;

  @override
  void initState() {
    super.initState();
    _computeTimeSignature();
    _controller = AnimationController(
      vsync: this,
      lowerBound: -0.2,
      upperBound: 1.2,
      duration: const Duration(seconds: 0),
    );
    _controller.addListener(() {
      setState(() {
        _segmentProgress = _controller.value;
        if (_controller.status == AnimationStatus.completed) {
          _segmentProgress = 1.0;

          _nextSegment();
        }
      });
    });
    widget.playStream.listen((play) {
      setState(() {
        if (play) {
          _songPlaying = true;
          _startSegmentTimer();
        } else {
          _pausedAnimationValue = _controller.value;
          _stopSong();
        }
      });
    });
  }

  void _computeTimeSignature() {
    widget.musicData.bars.forEach((bar) {
      bar.events.where((t) => t.type == EventType.meta).forEach((metaEvent) {
        if (metaEvent.content != null) {
          if (metaEvent.content!.type == 'timeSignature') {
            _timeSignature = metaEvent.content!.meter ?? '1/1';
          }
        }
      });
    });
  }

  void _startSegmentTimer() {
    if (_currentSegmentIndex >= widget.musicData.clock.length) return;

    double segmentDuration = 0;
    double previousSegmentDuration = 0;
    if (widget.musicData.clock[_currentSegmentIndex] is int) {
      segmentDuration =
          (widget.musicData.clock[_currentSegmentIndex] as int).toDouble();
    } else if (widget.musicData.clock[_currentSegmentIndex] is double) {
      segmentDuration = widget.musicData.clock[_currentSegmentIndex] as double;
    }
    if (_currentSegmentIndex > 0) {
      if (widget.musicData.clock[_currentSegmentIndex - 1] is int) {
        previousSegmentDuration =
            (widget.musicData.clock[_currentSegmentIndex - 1] as int)
                .toDouble();
      } else if (widget.musicData.clock[_currentSegmentIndex - 1] is double) {
        previousSegmentDuration =
        widget.musicData.clock[_currentSegmentIndex - 1] as double;
      }
      segmentDuration = segmentDuration - previousSegmentDuration;
    }

    _controller.duration = Duration(
      milliseconds:
      segmentDuration == 0 ? 100 : (segmentDuration * 1000).toInt(),
    );
    if (_pausedAnimationValue != null) {
      _controller.forward(from: _pausedAnimationValue);
      _pausedAnimationValue = null;
    } else {
      _controller.forward(from: 0);
    }
  }

  void _nextSegment() {
    if (_currentSegmentIndex < widget.musicData.clock.length - 1) {
      setState(() {
        _currentSegmentIndex++;
        if (_currentSegmentIndex == widget.musicData.bars.length) {
          _songFinished();
        }
        _segmentProgress = -0.2;
      });
      if (_songPlaying) {
        _startSegmentTimer();
      }
    }
  }

  void _songFinished() {
//TODO - add song finished logic
    _currentSegmentIndex = widget.musicData.bars.length - 1;
    _stopSong();
  }

  void _stopSong() {
    _songPlaying = false;
    _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentSegmentIndex >= widget.musicData.bars.length) {
      return Container();
    }
    final Bar bar = widget.musicData.bars[_currentSegmentIndex];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.portrait) {
              return Column(
                children: [
                  Expanded(
                    flex: 65,
                    child: _songMainContent(
                      portrait: true,
                    ),
                  ),
                  Expanded(flex: 35, child: _nextChordWidget(bar)),
                ],
              );
            }

            return Column(
              children: [
                Container(
                  height: 20,
                ),
                Row(
                  children: [
                    _songMainContent(
                      portrait: false,
                    ),
                    Column(
                      children: [
                        _nextChordWidget(bar),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _nextChordWidget(Bar bar) {
    List<Event> chords =
    bar.events.where((e) => e.type == EventType.chord).toList();
    Event? nextChord =
    chords.firstWhereOrNull((t) => (t.position) >= _segmentProgress);

    if (nextChord == null) {
      List<Event> nextChords = widget.musicData.bars
          .safeIndex(_currentSegmentIndex + 1)
          ?.events
          .where((e) => e.type == EventType.chord)
          .toList() ??
          [];
      nextChord = nextChords.isNotEmpty ? nextChords.first : null;
    }
    var instrument = GuitarChordLibrary.instrument(InstrumentType.guitar);
    ChordType chord = ChordsHelper.stringToChord(nextChord!.name!);
    FlutterGuitarChord position =
        ChordsHelper.chordTypeOptions[chord] ?? ChordsHelper.UNKNOWN;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.height / 10),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text(
            'Next: ',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (nextChord != null)
            Container(
              padding: const EdgeInsets.all(Dimensions.smallMargin),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ChordsHelper.chordTypeColors[chord],
                border: Border.all(color: Colors.white),
              ),
              child: Text(
                '${nextChord.name}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
        ]),
        Expanded(
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
      ]),
    );
  }

  Widget _songMainContent({required bool portrait}) {
    final Bar bar = widget.musicData.bars[_currentSegmentIndex];
    Bar? previousBar =
    widget.musicData.bars.safeIndex(_currentSegmentIndex - 1);

    Bar? nextBar = widget.musicData.bars.safeIndex(_currentSegmentIndex + 1);

    Bar? nextNextBar =
    widget.musicData.bars.safeIndex(_currentSegmentIndex + 2);
    return Container(
      height: (portrait ? 60 : 90) / 100 * MediaQuery.of(context).size.height,
      width: portrait
          ? double.infinity
          : (portrait ? 90 : 70) / 100 * MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
          horizontal: Dimensions.padding, vertical: Dimensions.padding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.darkerBlue,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(80),
                    bottomLeft: Radius.circular(80),
                  ),
                ),
              ),
              if (previousBar != null)
                _segmentWidget(
                  key: Key((_currentSegmentIndex - 1).toString()),
                  bar: previousBar,
                  mainSegment: false,
                  previousSegment: true,
                  portrait: portrait,
                  constraints: constraints,
                ),
              _segmentWidget(
                key: Key(_currentSegmentIndex.toString()),
                bar: bar,
                mainSegment: true,
                portrait: portrait,
                constraints: constraints,
              ),
              if (nextBar != null)
                _segmentWidget(
                  key: Key((_currentSegmentIndex + 1).toString()),
                  bar: nextBar,
                  mainSegment: false,
                  portrait: portrait,
                  constraints: constraints,
                ),
              if (nextNextBar != null)
                _segmentWidget(
                  key: Key((_currentSegmentIndex + 2).toString()),
                  bar: nextNextBar,
                  mainSegment: false,
                  lastSegment: true,
                  portrait: portrait,
                  constraints: constraints,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _segmentWidget({
    required Bar bar,
    required bool mainSegment,
    required Key key,
    required BoxConstraints constraints,
    required bool portrait,
    bool? lastSegment = false,
    bool? previousSegment = false,
  }) {
    double segmentProgress = mainSegment ? _segmentProgress : -1;

    List<Event> lyrics =
    bar.events.where((e) => e.type == EventType.lyric).toList();
    List<Event> chords =
    bar.events.where((e) => e.type == EventType.chord).toList();
    double padding = Dimensions.padding;
    double segmentWidth = constraints.maxWidth - 2 * padding;

    double topOffset = 0;

    double threshold = 11;
    if (mainSegment) {
      topOffset = segmentProgress >= threshold
          ? -700
          : portrait
          ? 0
          : -140;
    } else if (lastSegment == true) {
      topOffset = _segmentProgress >= threshold ? 300 : 1000;
    } else if (previousSegment == true) {
      topOffset =
      segmentProgress >= 0 && _segmentProgress <= 0.2 ? -1000 : -1000;
    } else {
      topOffset = _segmentProgress >= 0 && _segmentProgress >= threshold
          ? 0
          : portrait
          ? 300
          : 200;
    }
    return AnimatedPositioned(
      key: key,
      top: topOffset,
      left: 0,
      right: 0,
      bottom: 0,
      duration: const Duration(milliseconds: 600),
      child: _segmentContentWidget(
        lyrics: lyrics,
        chords: chords,
        segmentProgress: segmentProgress,
        segmentWidth: segmentWidth,
        padding: padding,
      ),
    );
  }

  Widget _segmentContentWidget({
    required List<Event> lyrics,
    required List<Event> chords,
    required double segmentProgress,
    required double segmentWidth,
    required double padding,
  }) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: -38,
            height: 44,
            child: Container(
              color: Colors.white,
            ),
          ),
          _lyricsWidget(
            lyrics: lyrics,
            segmentProgress: segmentProgress,
            segmentWidth: segmentWidth,
            padding: padding,
          ),
          _mainSecondaryChordsWidget(
            segmentProgress: segmentProgress,
            segmentWidth: segmentWidth,
            padding: padding,
          ),
          _chordsWidgets(
            chords: chords,
            segmentProgress: segmentProgress,
            segmentWidth: segmentWidth,
            padding: padding,
          ),
          _progressIndicator(segmentProgress),
        ],
      ),
    );
  }

  Widget _chordsWidgets({
    required List<Event> chords,
    required double segmentProgress,
    required double segmentWidth,
    required double padding,
  }) {
    return Positioned.fill(
      top: -80,
      left: padding,
      right: padding,
      child: Stack(
        clipBehavior: Clip.none,
        children: chords.map((event) {
          return Positioned(
            left: event.position * segmentWidth,
            top: 0,
            child: PulsatingWidget(
              title: event.name ?? '',
              isActive: segmentProgress >= (event.position),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _mainSecondaryChordsWidget({
    required double segmentProgress,
    required double segmentWidth,
    required double padding,
  }) {
    int mainChordsCount = int.tryParse(_timeSignature.split('/').first) ?? 0;
    int secondaryChordsCount =
        int.tryParse(_timeSignature.split('/').last) ?? 0;
    int totalChords = mainChordsCount + secondaryChordsCount;

    double startPosition = (segmentWidth - _circleSize) / (totalChords - 1);
    return Positioned.fill(
      top: -70,
      left: padding,
      right: padding,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(totalChords, (index) {
          return Positioned(
            left: index * startPosition,
            child: Container(
              height: _circleSize,
              width: _circleSize,
              child: Center(
                child: Container(
                  height: index.isEven
                      ? Dimensions.bigChordSize
                      : Dimensions.smallChordSize,
                  width: index.isEven
                      ? Dimensions.bigChordSize
                      : Dimensions.smallChordSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                    segmentProgress >= index * startPosition / segmentWidth
                        ? Colors.white
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _lyricsWidget({
    required List<Event> lyrics,
    required double segmentProgress,
    required double segmentWidth,
    required double padding,
  }) {
    return Positioned(
      left: padding,
      right: padding,
      top: -30,
      height: 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: lyrics.mapIndexed((index, event) {
          double dashSpace = 10;
          Event? nextLyric = lyrics.safeIndex(index + 1);
          Bar? nextBar =
          widget.musicData.bars.safeIndex(_currentSegmentIndex + 1);
          if (nextLyric == null && nextBar != null) {
            nextLyric = nextBar.events
                .where((e) => e.type == EventType.lyric)
                .toList()
                .safeIndex(0);
          }
          bool wordSplit = nextLyric?.wordId == event.wordId;
          double currentWidth =
              (event.duration) * segmentWidth + (wordSplit ? dashSpace : 0);
          double currentStartX = event.start * segmentWidth -
              event.duration * segmentWidth / 2 -
              (wordSplit ? dashSpace : 0);

          currentStartX =
              event.start * segmentWidth - (wordSplit ? dashSpace : 0);
          currentStartX = max(currentStartX, 0);
          currentStartX = min(segmentWidth - currentWidth, currentStartX);
          bool overlap = false;

          double previousEndX = 0;
          double previousStartX = 0;
          if (index > 0) {
            Event previousEvent = lyrics[index - 1];
            bool previousWordSplit = previousEvent.wordId == event.wordId;
            previousStartX = (previousEvent.start) * segmentWidth -
                (previousWordSplit ? dashSpace : 0);
            double previousWidth = previousEvent.duration * segmentWidth +
                (previousWordSplit ? dashSpace : 0);

            previousWidth = _getTextWidth(
              previousEvent.text ?? '',
              TextStyle(
                fontSize: 14,
                fontFeatures: [const FontFeature.tabularFigures()],
                fontWeight: segmentProgress >= event.start
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            );
            previousEndX = previousStartX + previousWidth;
            if (currentStartX < previousEndX) {
              overlap = true;
            }
          }

          return Positioned(
            left: overlap ? previousEndX + dashSpace : currentStartX,
            top: 0,
            child: Container(
              child: Text(
                wordSplit ? '${event.text} -' : event.text ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontFeatures: [const FontFeature.tabularFigures()],
                  fontWeight: segmentProgress >= (event.start)
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: segmentProgress >= (event.start)
                      ? Colors.black
                      : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  double _getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  Widget _progressIndicator(double segmentProgress) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: segmentProgress,
          color: Colors.orange,
          backgroundColor: Colors.transparent,
          valueColor: const AlwaysStoppedAnimation<Color>(
            Colors.orange,
          ),
        );
      },
    );
  }
}
