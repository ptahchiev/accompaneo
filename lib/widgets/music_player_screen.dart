import 'dart:async';
import 'dart:math';

import 'package:accompaneo/models/music_data.dart';
import 'package:accompaneo/utils/helpers/chords_helper.dart';
import 'package:accompaneo/values/app_dimensions.dart';
import 'package:accompaneo/widgets/pulsating_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guitar_chord/flutter_guitar_chord.dart';
import 'package:guitar_chord_library/guitar_chord_library.dart';

import '../values/app_colors.dart';

class MusicPlayerScreen extends StatefulWidget {
  MusicPlayerScreen({
    required this.musicData,
    required this.playStream,
    required this.playSeekStream,
    required this.audioMargin,
  });

  final MusicData musicData;
  final Stream<bool> playStream;
  final Stream<int> playSeekStream;
  final double audioMargin;

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with TickerProviderStateMixin {
  int _currentSegmentIndex = 0;
  double _segmentProgress = -0.2;
  String _timeSignature = '1/1';
  double _circleSize = 30;
  double? _pausedAnimationValue;
  late AnimationController _controller;
  late AnimationController _wholeSongController;
  StreamSubscription? _playSubscription;
  StreamSubscription? _playSeekSubscription;
  double _wholeSongTime = 0;
  bool _songPlaying = false;
  double _margin = 0;
  double _segmentDuration = 0;

  @override
  void initState() {
    super.initState();

    _computeTimeSignature();

    _controller = AnimationController(
      vsync: this,
      lowerBound: -0.8,
      upperBound: 1.2,
      duration: const Duration(seconds: 0),
    );
    _wholeSongController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: widget.musicData.clock.last.toDouble(),
      duration:
          Duration(milliseconds: (widget.musicData.clock.last * 1000).toInt()),
    );
    _wholeSongController.addListener(() {
      setState(() {
        _wholeSongTime = _margin + _wholeSongController.value;
      });
    });
    _controller.addListener(() {
      // setState(() {
      //   _segmentProgress = _controller.value;
      //   if (_controller.status == AnimationStatus.completed) {
      //     _segmentProgress = 1.0;
      //
      //     // _nextSegment();
      //   }
      // });
    });
    _playSubscription = widget.playStream.listen((play) {
      if (mounted) {
        setState(() {
          if (play) {
            if (_pausedAnimationValue != null) {
              _wholeSongController.forward(from: _pausedAnimationValue);
              _pausedAnimationValue = null;
            } else {
              _wholeSongController.forward(from: 0);
            }
            _songPlaying = true;
            _startSegmentTimer();
          } else {
            _pausedAnimationValue = _wholeSongController.value;
            _stopSong();
          }
        });
      }
    });
    _playSubscription = widget.playSeekStream.listen((playSeek) {
      if (mounted) {
        setState(() {
          _wholeSongTime = _margin + playSeek.toDouble();
          _pausedAnimationValue = playSeek.toDouble();
        });
      }
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
    _margin = (widget.musicData.clock[_currentSegmentIndex] as int).toDouble();
    print('_margin: ${_margin}');
    double segmentDuration = 0;

    double previousSegmentDuration = 0;
    if (widget.musicData.clock[_currentSegmentIndex] is int) {
      segmentDuration =
          (widget.musicData.clock[_currentSegmentIndex] as int).toDouble();
    } else if (widget.musicData.clock[_currentSegmentIndex] is double) {
      segmentDuration = widget.musicData.clock[_currentSegmentIndex] as double;
    }
    _segmentDuration = segmentDuration;
    if (_currentSegmentIndex > 0) {
      if (widget.musicData.clock[_currentSegmentIndex - 1] is int) {
        previousSegmentDuration =
            (widget.musicData.clock[_currentSegmentIndex - 1] as int)
                .toDouble();
      } else if (widget.musicData.clock[_currentSegmentIndex - 1] is double) {
        previousSegmentDuration =
            widget.musicData.clock[_currentSegmentIndex - 1] as double;
      }
      segmentDuration = segmentDuration - previousSegmentDuration + 0.6;
    }

    _controller.duration = Duration(
      milliseconds:
          segmentDuration == 0 ? 100 : (segmentDuration * 1000).toInt(),
    );

    if (_pausedAnimationValue != null) {
      _controller.forward(from: _pausedAnimationValue);
      _wholeSongController.forward(from: _pausedAnimationValue);

      _pausedAnimationValue = null;
    } else {
      _controller.forward(from: 0);
    }
  }

  void _nextSegment() {
    if (_currentSegmentIndex < widget.musicData.clock.length - 1) {
      setState(() {
        // _currentSegmentIndex++;
        if (_currentSegmentIndex == widget.musicData.bars.length) {
          _songFinished();
        }
        // _segmentProgress = -0.8;
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
    _wholeSongController.stop();

    _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    _playSubscription?.cancel();
    _playSeekSubscription?.cancel();

    _wholeSongController.dispose();
    super.dispose();
  }

  int _currentSegmentIndexBasedOnElapsedTime() {
    int result = 0;
    widget.musicData.clock.forEachIndexed((index, c) {
      if (index > 0 && _wholeSongTime != 0) {
        if (c <= _wholeSongTime &&
            (widget.musicData.clock.safeIndex(index + 1) ?? 0) >=
                _wholeSongTime) {
          result = index;
        }
      }
    });
    if (result == 0) {
      // return 1;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    _currentSegmentIndex = _currentSegmentIndexBasedOnElapsedTime();
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
                  _songMainContent(
                    portrait: true,
                  ),
                  _nextChordWidget(
                    bar,
                    portrait: true,
                  ),
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
                    Expanded(
                        flex: 2,
                        child: _nextChordWidget(
                          bar,
                          portrait: false,
                        )),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _nextChordWidget(Bar bar, {required bool portrait}) {
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
    ChordType chord = nextChord != null
        ? ChordsHelper.stringToChord(nextChord!.name!)
        : ChordType.UNKNOWN;
    FlutterGuitarChord position =
        ChordsHelper.chordTypeOptions[chord] ?? ChordsHelper.UNKNOWN;

    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
            ],
          ),
          Container(
            height: 200,
            padding: EdgeInsets.symmetric(
              horizontal:
                  portrait ? MediaQuery.of(context).size.height / 10 : 0,
            ),
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
              tabForegroundColor: Colors.white,
              tabBackgroundColor:
                  ChordsHelper.chordTypeColors[chord] ?? Colors.black,
              firstFrameStroke: 10,
              barStroke: 0.5,
              showLabel: false,
              //firstFrameColor: Colors.red,
              barColor: Colors.grey,
              // labelOpenStrings: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _songMainContent({required bool portrait}) {
    final Bar bar = widget.musicData.bars[_currentSegmentIndex];

    Bar? nextBar = widget.musicData.bars.safeIndex(_currentSegmentIndex + 1);

    Bar? nextNextBar =
        widget.musicData.bars.safeIndex(_currentSegmentIndex + 2);
    return Container(
      height: (portrait ? 60 : 80) / 100 * MediaQuery.of(context).size.height,
      width: portrait
          ? double.infinity
          : (portrait ? 90 : 70) / 100 * MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
          horizontal: Dimensions.padding, vertical: Dimensions.padding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(80),
              bottomLeft: Radius.circular(80),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.darkerBlue,
              ),
              child: Stack(
                children: [
                  _segmentWidget(
                    segmentIndex: _currentSegmentIndex,
                    key: Key(_currentSegmentIndex.toString()),
                    bar: bar,
                    mainSegment: true,
                    portrait: portrait,
                    constraints: constraints,
                  ),
                  if (nextBar != null)
                    _segmentWidget(
                      segmentIndex: _currentSegmentIndex + 1,
                      key: Key((_currentSegmentIndex + 1).toString()),
                      bar: nextBar,
                      mainSegment: false,
                      portrait: portrait,
                      constraints: constraints,
                    ),
                  if (nextNextBar != null)
                    _segmentWidget(
                      segmentIndex: _currentSegmentIndex + 2,
                      key: Key((_currentSegmentIndex + 2).toString()),
                      bar: nextNextBar,
                      mainSegment: false,
                      lastSegment: true,
                      portrait: portrait,
                      constraints: constraints,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _segmentWidget({
    required int segmentIndex,
    required Bar bar,
    required bool mainSegment,
    required Key key,
    required BoxConstraints constraints,
    required bool portrait,
    bool lastSegment = false,
  }) {
    double currentSegmentProgress = _wholeSongTime -
        (widget.musicData.clock.safeIndex(_currentSegmentIndex)?.toDouble() ??
            0);
    double fullSegmentTime = (widget.musicData.clock
                .safeIndex(_currentSegmentIndex + 1)
                ?.toDouble() ??
            currentSegmentProgress) -
        (widget.musicData.clock.safeIndex(_currentSegmentIndex)?.toDouble() ??
            currentSegmentProgress);
    double segmentProgress = -1;
    if (mainSegment) {
      if (fullSegmentTime == 0) {
        segmentProgress = 0;
      } else {
        segmentProgress = currentSegmentProgress / fullSegmentTime;
      }
    }

    if (mainSegment) {
      _segmentProgress = interpolate(
        segmentProgress,
        0,
        1,
        -0.2,
        1.2,
      );
      segmentProgress = interpolate(
        segmentProgress,
        0,
        1,
        _songPlaying ? 0.1 : 0,
        1.2,
      );

      _segmentProgress = segmentProgress;
    } else if (!lastSegment && _segmentProgress >= 0.8) {
      segmentProgress = interpolate(
        _segmentProgress,
        0.8,
        1.2,
        0,
        0.1,
      );
    }

    List<Event> lyrics =
        bar.events.where((e) => e.type == EventType.lyric).toList();
    List<Event> chords =
        bar.events.where((e) => e.type == EventType.chord).toList();
    double padding = Dimensions.padding;
    double segmentWidth = constraints.maxWidth - 2 * padding;

    double topOffset = _getOffsetForSegment(
      segmentIndex: segmentIndex,
      segmentProgress: segmentProgress,
      bar: bar,
      mainSegment: mainSegment,
      lastSegment: lastSegment,
      portrait: portrait,
      constraints: constraints,
    );
    return Positioned(
      key: key,
      top: topOffset,
      left: 0,
      right: 0,
      height: (portrait ? 60 : 90) / 100 * MediaQuery.of(context).size.height,
      child: _segmentContentWidget(
        lyrics: lyrics,
        chords: chords,
        segmentProgress: segmentProgress,
        segmentWidth: segmentWidth,
        padding: padding,
      ),
    );
  }

  double mapPercentageToRange(double min, double max, double percentage) {
    return min + (percentage * (max - min));
  }

  double interpolate(
    double value,
    double fromMin,
    double fromMax,
    double toMin,
    double toMax,
  ) {
    return toMin + ((value - fromMin) / (fromMax - fromMin)) * (toMax - toMin);
  }

  double _getOffsetForSegment({
    required int segmentIndex,
    required Bar bar,
    required bool mainSegment,
    required BoxConstraints constraints,
    required bool portrait,
    required double segmentProgress,
    bool? lastSegment = false,
  }) {
    double topOffset = 0;
    double threshold = 1;
    double startOffset = 0;
    double endOffset = 0;
    if (mainSegment) {
      startOffset = portrait ? 0 : -100;

      endOffset = -400;
    } else if (lastSegment == true) {
      startOffset = 400;
      endOffset = portrait ? 150 : 50;
    } else {
      startOffset = portrait ? 150 : 50;
      endOffset = portrait ? 0 : -100;
    }

    if (mainSegment) {
      if (_segmentProgress >= threshold) {
        double segmentProgressPercentage = interpolate(
          _segmentProgress,
          threshold,
          1.2,
          0,
          1,
        );

        topOffset =
            startOffset - segmentProgressPercentage * (startOffset - endOffset);
      } else {
        topOffset = startOffset;
      }
    } else if (lastSegment == true) {
      if (_segmentProgress >= threshold) {
        double segmentProgressPercentage = interpolate(
          _segmentProgress,
          threshold,
          1.2,
          0,
          1,
        );

        topOffset =
            startOffset - segmentProgressPercentage * (startOffset - endOffset);
      } else {
        topOffset = startOffset;
      }
    } else {
      if (_segmentProgress >= threshold) {
        double segmentProgressPercentage =
            (_segmentProgress - threshold) / (1 - threshold) * 100;
        segmentProgressPercentage = interpolate(
          _segmentProgress,
          threshold,
          1.2,
          0,
          1,
        );

        topOffset =
            startOffset - segmentProgressPercentage * (startOffset - endOffset);
      } else {
        topOffset = startOffset;
      }
    }
    return topOffset;
  }

  Widget _segmentContentWidget({
    required List<Event> lyrics,
    required List<Event> chords,
    required double segmentProgress,
    required double segmentWidth,
    required double padding,
  }) {
    return Center(
      child: Container(
        color: Colors.red,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Text(
              _segmentDuration.toString() ?? '',
            ),
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
      ),
    );
  }

  Widget _chordsWidgets({
    required List<Event> chords,
    required double segmentProgress,
    required double segmentWidth,
    required double padding,
  }) {
    return Positioned(
      top: 0,
      left: padding,
      right: padding,
      height: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: chords.map((event) {
          return Positioned(
            left: (event.position * segmentWidth) - 47,
            top: -115,
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
              textAlign: TextAlign.left,
              maxLines: 1,
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
    return LinearProgressIndicator(
      value: segmentProgress,
      color: Colors.orange,
      backgroundColor: Colors.transparent,
      valueColor: const AlwaysStoppedAnimation<Color>(
        Colors.orange,
      ),
    );
  }
}
