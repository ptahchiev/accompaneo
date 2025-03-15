import 'dart:async';
import 'dart:math';

import 'package:accompaneo/models/music_data.dart';
import 'package:accompaneo/models/playlists.dart';
import 'package:accompaneo/models/song/time_signature.dart';
import 'package:accompaneo/utils/helpers/chords_helper.dart';
import 'package:accompaneo/values/app_dimensions.dart';
import 'package:accompaneo/widgets/click_player.dart';
import 'package:accompaneo/widgets/pulsating_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guitar_chord/flutter_guitar_chord.dart';
import 'package:guitar_chord_library/guitar_chord_library.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../values/app_colors.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key, 
    required this.clickPlayer,
    required this.musicData,
    required this.playStream,
    required this.playSeekStream,
    required this.animationEnded,
  });

  final ClickPlayer clickPlayer;
  final MusicData musicData;
  final Stream<bool> playStream;
  final Stream<int> playSeekStream;
  final VoidCallback animationEnded;

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with TickerProviderStateMixin {
  int _currentSegmentIndex = 0;
  double _segmentProgress = -0.2;

  TimeSignature _globalTimeSignature = TimeSignature.empty();
  final double _circleSize = 30;
  bool _animationEnded = false;
  int beat = 0;
  String spent = "0:0";
  StreamSubscription? streamSubscription;
  StreamSubscription? _playSubscription;
  StreamSubscription? _playSeekSubscription;
  double _wholeSongTime = 0;

  double animationDuration = 0.5; //milliseconds
  //this is the margin of the song source??

  double leftRightPaddingSeconds = 0.2; //milliseconds
  bool _playing = false;
  late AudioPlayer metronomePlayer = AudioPlayer();

  final Map<String, TimeSignature> _timeSignatures = {
    '2/4': TimeSignature(
        name: '2/4',
        numberOfBeats: 2,
        numberOfSubBeats: 2,
        isBeat: (index) => (index + 1) % 2 == 1),
    '3/4': TimeSignature(
        name: '3/4',
        numberOfBeats: 3,
        numberOfSubBeats: 3,
        isBeat: (index) => (index + 1) % 2 == 1),
    '4/4': TimeSignature(
        name: '4/4',
        numberOfBeats: 4,
        numberOfSubBeats: 4,
        isBeat: (index) => (index + 1) % 2 == 1),
    '6/8': TimeSignature(
        name: '6/8',
        numberOfBeats: 2,
        numberOfSubBeats: 4,
        isBeat: (index) => (index + 1) % 3 == 1),
    '12/8': TimeSignature(
        name: '12/8',
        numberOfBeats: 4,
        numberOfSubBeats: 8,
        isBeat: (index) => (index + 1) % 3 == 1),
  };

  @override
  void initState() {
    super.initState();
    metronomePlayer.setVolume(1);
    metronomePlayer.setAsset('assets/effects/metronome.mp3');
    _computeTimeSignature();

    _playSubscription = widget.playStream.listen((play) {
      if (mounted) {
        setState(() {
          _playing = play;
          if (play) {
            if (streamSubscription != null) {
              streamSubscription?.resume();
            } else {
              streamSubscription = widget.clickPlayer.stream.listen((event) {
                setState(() {
                  beat = event + 1;
                  int seconds = widget.clickPlayer.totalDuration().inSeconds -
                      widget.clickPlayer.remainingDuration().inSeconds;
                  spent = "${seconds ~/ 60}:${seconds % 60}";
                });
              });
            }
          } else {
            _stopSong();
            streamSubscription?.pause();
          }
        });
      }
    });

    _playSubscription = widget.playSeekStream.listen((playSeek) {
      if (mounted) {
        setState(() {
          _animationEnded = false;
          _wholeSongTime = (playSeek.toDouble()) / 1000;
        });
      }
    });
  }

  TimeSignature _computeTimeSignature({Bar? bar}) {
    if (bar != null) {
      TimeSignature? signature;
      Event? metaEvent =
          bar.events.firstWhereOrNull((t) => t.type == EventType.meta);
      if (metaEvent != null && metaEvent.content != null) {
        if (metaEvent.content!.type == 'timeSignature') {
          signature = _timeSignatures[metaEvent.content!.meter] ??
              TimeSignature.empty();
        }
      }
      return signature ?? _globalTimeSignature;
    } else {
      widget.musicData.bars.firstWhereOrNull((bar) {
        Event? metaEvent =
            bar.events.firstWhereOrNull((t) => t.type == EventType.meta);
        if (metaEvent != null && metaEvent.content != null) {
          if (metaEvent.content!.type == 'timeSignature') {
            _globalTimeSignature = _timeSignatures[metaEvent.content!.meter] ??
                TimeSignature.empty();
            return true;
          }
        }
        return false;
      });
      return _globalTimeSignature;
    }
  }

  void _stopSong() {}

  @override
  void dispose() {
    _playSubscription?.cancel();
    _playSeekSubscription?.cancel();
    metronomePlayer.dispose();
    widget.clickPlayer.dispose();
    super.dispose();
  }

  int? _currentSegmentIndexBasedOnElapsedTime() {
    int? result;
    widget.musicData.clock.forEachIndexed((index, c) {
      // if (c <= _wholeSongTime &&
      //     (widget.musicData.clock.safeIndex(index + 1) ?? 0) >=
      //         _wholeSongTime) {
      //   result = index;
      // }
      if (index == 0) {
        if (c >= _wholeSongTime) {
          result = index;
        }
      } else {
        if (c >= _wholeSongTime &&
            (widget.musicData.clock.safeIndex(index - 1) ?? 0) <=
                _wholeSongTime) {
          result = index;
        }
      }
    });
    if (_wholeSongTime < 0) {
      result = 0;
    }

    return result;
  }

  double endSideOfClock(int index) {
    return widget.musicData.clock.safeIndex(index)?.toDouble() ?? 0;
  }

  double startSideOfClock(int index) {
    if (index == 0) {
      return 0;
    }
    return widget.musicData.clock.safeIndex(index - 1)?.toDouble() ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    // _wholeSongTime = 28.063;
    int? currentSegmentIndex = _currentSegmentIndexBasedOnElapsedTime();
    if (currentSegmentIndex == null ||
        _currentSegmentIndex >= widget.musicData.bars.length) {
      if (!_animationEnded) {
        _animationEnded = true;
        widget.animationEnded();
      }

      return Container();
    }
    _currentSegmentIndex = currentSegmentIndex;
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

    var selection = Provider.of<PlaylistsModel>(context, listen: true).getSettings().instrumentType;
    var useFlat = false;

    var instrument = (selection == null || selection == 'GUITAR')
        ? GuitarChordLibrary.instrument(InstrumentType.guitar)
        : GuitarChordLibrary.instrument(InstrumentType.ukulele);

    ChordType chordType = nextChord != null
        ? ChordsHelper.stringToChord(nextChord.name!)
        : ChordType.UNKNOWN;

    AccompaneoChord accompaneoChord = ChordsHelper.accompaneoChords[chordType] ?? AccompaneoChord("", "", Colors.black);
    ChordPosition c = instrument.getChordPositions(accompaneoChord.prefix, accompaneoChord.suffix)![0];

    return Column(
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
                  color: accompaneoChord.color,
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
            horizontal: portrait ? MediaQuery.of(context).size.height / 10 : 0,
          ),
          child: FlutterGuitarChord(
            baseFret: c.baseFret,
            chordName: chordType.name,
            fingers: c.fingers,
            frets: c.frets,
            totalString: instrument.stringCount,
            stringStroke: 0.4,
            tabForegroundColor: Colors.white,
            tabBackgroundColor: accompaneoChord.color,
            firstFrameStroke: 10,
            barStroke: 0.5,
            showLabel: false,
            barColor: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _songMainContent({
    required bool portrait,
  }) {
    return Container(
      height: (portrait ? 60 : 80) / 100 * MediaQuery.of(context).size.height,
      width: portrait
          ? double.infinity
          : (portrait ? 90 : 70) / 100 * MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
          horizontal: Dimensions.padding, vertical: Dimensions.padding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          List<Widget> elements =
              widget.musicData.bars.mapIndexed((index, bar) {
            if (index < _currentSegmentIndex - 2 ||
                index > _currentSegmentIndex + 2) {
              return Container();
            }
            TimeSignature timeSignature = _computeTimeSignature(bar: bar);
            return _segmentWidget(
              segmentIndex: index,
              key: Key(index.toString()),
              bar: bar,
              portrait: portrait,
              timeSignature: timeSignature,
              constraints: constraints,
            );
          }).toList();
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
              child: Stack(children: elements),
            ),
          );
        },
      ),
    );
  }

  Widget _segmentWidget({
    required int segmentIndex,
    required TimeSignature timeSignature,
    required Bar bar,
    required Key key,
    required BoxConstraints constraints,
    required bool portrait,
  }) {
    double segmentProgress = -1;

    double leftSide = startSideOfClock(segmentIndex) - leftRightPaddingSeconds;
    leftSide = max(leftSide, 0);
    double rightSide = leftRightPaddingSeconds + endSideOfClock(segmentIndex);

    if (_wholeSongTime >= leftSide && _wholeSongTime <= rightSide) {
      double currentSegmentProgress = _wholeSongTime - leftSide;
      double fullSegmentTime = rightSide - leftSide;

      segmentProgress = currentSegmentProgress / fullSegmentTime;
      if (segmentIndex == _currentSegmentIndex) {
        _segmentProgress = segmentProgress;
        _segmentProgress = _interpolate(
          _segmentProgress,
          0,
          1,
          leftSide,
          rightSide,
        );
      }

      fullSegmentTime = endSideOfClock(segmentIndex) - leftSide;

      segmentProgress = currentSegmentProgress / fullSegmentTime;
    } else if (_wholeSongTime > rightSide) {
      segmentProgress = 1;
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
      portrait: portrait,
      constraints: constraints,
    );

    List<Event> metronomeBeats = [];
    List<Event> countInEvents =
        bar.events.where((e) => e.type == EventType.countIn).toList();
    if (countInEvents.isNotEmpty) {
      metronomeBeats.addAll(List.generate(timeSignature.numberOfBeats, (index) {
        return Event(
          type: EventType.countIn,
          position: index * (1 / timeSignature.numberOfBeats),
          start: 0,
          duration: 0,
          name: "${index + 1}",
        );
      }));
    }

    return Positioned(
      key: key,
      top: topOffset,
      left: 0,
      right: 0,
      height: (portrait ? 60 : 90) / 100 * MediaQuery.of(context).size.height,
      child: _segmentContentWidget(
        segmentIndex: segmentIndex,
        metronomeBeats: metronomeBeats,
        lyrics: lyrics,
        chords: chords,
        segmentProgress: segmentProgress,
        timeSignature: timeSignature,
        segmentWidth: segmentWidth,
        padding: padding,
      ),
    );
  }

  double _interpolate(
    double value,
    double fromMin,
    double fromMax,
    double toMin,
    double toMax,
  ) {
    if ((fromMax - fromMin) == 0) {
      return 0;
    }
    return toMin + ((value - fromMin) / (fromMax - fromMin)) * (toMax - toMin);
  }

  double _getOffsetForSegment({
    required int segmentIndex,
    required Bar bar,
    required BoxConstraints constraints,
    required bool portrait,
    required double segmentProgress,
  }) {
    double topOffset = 0;
    double topOffScreen = -300;
    double startOffset = 0;
    double endOffset = 0;

    //compute offset of the segment based on index
    int differenceIndex = segmentIndex - _currentSegmentIndex;
    //maybe add the offset based on the player height
    double yOffsetPerSegment = portrait ? 200 : 180;

    endOffset = (differenceIndex - 1) * yOffsetPerSegment;

    startOffset = segmentIndex * yOffsetPerSegment;

    double leftSide = startSideOfClock(segmentIndex);
    double leftSideAnimation = animationDuration + leftSide;
    double rightSide = endSideOfClock(segmentIndex);
    double rightSideAnimation = animationDuration + rightSide;

    double previousLeftSide = startSideOfClock(segmentIndex - 1);
    double previousLeftSideAnimation = animationDuration + previousLeftSide;
    double previousRightSide = endSideOfClock(segmentIndex - 1);

    if (segmentIndex > 1 &&
        _wholeSongTime != 0 &&
        _wholeSongTime >= previousLeftSide &&
        _wholeSongTime <= previousLeftSideAnimation) {
      startOffset = yOffsetPerSegment * 2;
      endOffset = yOffsetPerSegment;
      topOffset = _interpolate(
        _wholeSongTime,
        previousLeftSide,
        previousLeftSideAnimation,
        startOffset,
        endOffset,
      );
    } else if (segmentIndex > 0 &&
        _wholeSongTime != 0 &&
        _wholeSongTime >= previousLeftSideAnimation &&
        _wholeSongTime <= previousRightSide) {
      startOffset = yOffsetPerSegment;
      endOffset = yOffsetPerSegment;
      topOffset = startOffset;
    } else if (segmentIndex > 0 &&
        _wholeSongTime >= leftSide &&
        _wholeSongTime <= leftSideAnimation) {
      startOffset = yOffsetPerSegment;

      endOffset = 0;
      topOffset = _interpolate(
        _wholeSongTime,
        leftSide,
        leftSideAnimation,
        startOffset,
        endOffset,
      );
    } else {
      if (_wholeSongTime >= leftSide - leftSideAnimation &&
          _wholeSongTime < leftSide) {
        startOffset = differenceIndex * yOffsetPerSegment;
        topOffset = startOffset;
      } else if (_wholeSongTime >= leftSide &&
          _wholeSongTime <= leftSideAnimation) {
        startOffset = segmentIndex * yOffsetPerSegment;
        endOffset = 0;
        topOffset = _interpolate(
          _wholeSongTime,
          leftSide,
          leftSideAnimation,
          startOffset,
          endOffset,
        );
      } else if (_wholeSongTime >= leftSide && _wholeSongTime <= rightSide) {
        startOffset = 0;
        endOffset = 0;
        topOffset = 0;
      } else if (_wholeSongTime > rightSide &&
          _wholeSongTime <= rightSideAnimation) {
        startOffset = 0;
        endOffset = topOffScreen;
        topOffset = _interpolate(
          _wholeSongTime,
          rightSide,
          rightSideAnimation,
          startOffset,
          endOffset,
        );
      } else if (_wholeSongTime >= rightSideAnimation) {
        startOffset = topOffScreen;
        endOffset = topOffScreen;
        topOffset = topOffScreen;
      } else {
        topOffset = startOffset;
      }
    }
    if (!portrait) {
      topOffset = topOffset - 70;
    }
    return topOffset;
  }

  Widget _segmentContentWidget({
    required int segmentIndex,
    required List<Event> metronomeBeats,
    required TimeSignature timeSignature,
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
            timeSignature: timeSignature,
            segmentWidth: segmentWidth,
            padding: padding,
          ),
          _countInWidget(
            segmentIndex: segmentIndex,
            metronomeBeats: metronomeBeats,
            segmentProgress: segmentProgress,
            timeSignature: timeSignature,
            segmentWidth: segmentWidth,
            padding: padding,
          ),
          _chordsWidgets(
            chords: chords,
            segmentProgress: segmentProgress,
            timeSignature: timeSignature,
            segmentWidth: segmentWidth,
            padding: padding,
          ),
          _progressIndicator(segmentProgress),
        ],
      ),
    );
  }

  Widget _countInWidget({
    required int segmentIndex,
    required List<Event> metronomeBeats,
    required double segmentProgress,
    required TimeSignature timeSignature,
    required double segmentWidth,
    required double padding,
  }) {
    double size = 50;

    return Positioned(
      top: 0,
      left: padding,
      right: padding,
      height: 50,
      child: Stack(
          clipBehavior: Clip.none,
          children: metronomeBeats.map((event) {
            var left = (segmentWidth * event.position) -
                (size - (size / 20)); //size/20 is 2.5 because our border is 5
            return Positioned(
              left: left,
              top: -120,
              child: PulsatingWidget(
                key: ValueKey(event.position),
                title: '${event.name}',
                isActive: segmentProgress >= event.position &&
                    (_playing || segmentProgress > event.position),
                whenActive: () {
                  metronomePlayer.setAsset(
                      'assets/effects/${Provider.of<PlaylistsModel>(context, listen: true).getSettings().countInEffect.toLowerCase()}.mp3');
                  metronomePlayer.play();
                },
              ),
            );
          }).toList()),
    );
  }

  Widget _chordsWidgets({
    required List<Event> chords,
    required double segmentProgress,
    required TimeSignature timeSignature,
    required double segmentWidth,
    required double padding,
  }) {
    double size = 50;
    return Positioned(
      top: 0,
      left: padding,
      right: padding,
      height: 50,
      child: Stack(clipBehavior: Clip.none, children: [
        ...chords.map((event) {
          var left = (segmentWidth * event.position) -
              (size - (size / 20)); //size/20 is 2.5 because our border is 5

          return Positioned(
            left: left,
            top: -120,
            child: PulsatingWidget(
              title: event.name ?? '',
              isActive: segmentProgress >= (event.position),
            ),
          );
        }),
      ]),
    );
  }

  Widget _mainSecondaryChordsWidget({
    required double segmentProgress,
    required TimeSignature timeSignature,
    required double segmentWidth,
    required double padding,
  }) {
    int totalBeats =
        timeSignature.numberOfBeats + timeSignature.numberOfSubBeats;
    return Positioned.fill(
      top: -70,
      left: padding,
      right: padding,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(totalBeats, (index) {
          return Positioned(
            left: (segmentWidth * (index / totalBeats)),
            child: SizedBox(
              height: _circleSize,
              width: _circleSize,
              child: Center(
                child: Container(
                  height: timeSignature.isBeat(index)
                      ? Dimensions.bigChordSize
                      : Dimensions.smallChordSize,
                  width: timeSignature.isBeat(index)
                      ? Dimensions.bigChordSize
                      : Dimensions.smallChordSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: segmentProgress >= (index / totalBeats)
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
