import 'dart:async';

import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

///This class provides a stream that handles the click noise.
///
///The listener gets an event every click to visualize the current beat.
class ClickPlayer {
  ///The amount of beats in one bar.
  final int clicksPerBar;

  ///The amount of bars to be played in the same tempo.
  final int barsPerStep;

  ///The tempo for the first step.
  final double startBPM;

  ///The tempo gets increased every step by its value.
  final double stepBPM;

  ///The session will consist out of [stepAmount] steps, each with
  ///[barsPerStep] bars with [clicksPerBar] beats
  final int stepAmount;

  late Duration period;
  final StreamController _controller = StreamController(sync: true);
  final Soundpool _pool = Soundpool.fromOptions();

  int? _up;
  int? _down;

  int beatAmount = 0;
  int steps = 0;
  double bpm = 0;
  late Timer _timer;
  bool disposed = false;

  ClickPlayer(
    this.clicksPerBar,
    this.barsPerStep,
    this.startBPM,
    this.stepBPM,
    this.stepAmount,
  ) {
    _controller.onListen = () {
      beatAmount = -1;

      bpm = startBPM;
      Duration period = Duration(milliseconds: 60000 ~/ bpm);

      Future<void> click(_) async {
        if (_up == null || _down == null) {
          return; // skip if sounds are not yet cached
        }

        beatAmount++;
        if (beatAmount * (steps + 1) >=
            stepAmount * clicksPerBar * barsPerStep) {
          dispose();
          return;
        }

        if (beatAmount % clicksPerBar == 0) {
          await _pool.play(_up!);
        } else {
          await _pool.play(_down!);
        }

        _controller.add(beatAmount % clicksPerBar);

        if (beatAmount >= barsPerStep * clicksPerBar) {
          steps++;
          bpm += stepBPM;
          beatAmount = 0;
          period = Duration(milliseconds: 60000 ~/ bpm);
          _timer.cancel();
          _timer = Timer.periodic(period, click);
        }
      }

      _timer = Timer.periodic(period, click);
      click(0);
      _controller
        ..onCancel = () {
          _timer.cancel();
        }
        ..onPause = () {
          _timer.cancel();
        }
        ..onResume = () {
          _timer = Timer.periodic(period, click);
        };
    };

    _loadSounds();
  }

  Future<void> _loadSounds() async {
    _up = await rootBundle
        .load("assets/effects/sfx_up.wav")
        .then((ByteData soundData) {
      return _pool.load(soundData);
    });

    _down = await rootBundle
        .load("assets/effects/sfx_down.wav")
        .then((ByteData soundData) {
      return _pool.load(soundData);
    });
  }

  Stream get stream => _controller.stream;

  void dispose() {
    if (disposed) return;
    _controller.close();
    _pool.dispose();
    _timer.cancel();
    disposed = true;
  }

  Duration totalDuration() {
    double mSeconds = 0;
    double pBPM = startBPM;
    for (int i = 0; i < stepAmount; i++) {
      mSeconds += clicksPerBar * barsPerStep * 60000 / pBPM;
      pBPM += stepBPM;
    }
    return Duration(milliseconds: mSeconds.toInt());
  }

  Duration remainingDuration() {
    if (beatAmount < 1 || bpm == startBPM) return totalDuration();
    double mSeconds = 0;
    double pBPM = bpm;
    for (int i = steps * clicksPerBar * barsPerStep + beatAmount;
        i < stepAmount * barsPerStep * clicksPerBar;
        i++) {
      mSeconds += 60000 / pBPM;
      if (i % (barsPerStep * clicksPerBar) == 0 && i != 0) pBPM += stepBPM;
    }
    return Duration(milliseconds: mSeconds.toInt());
  }
}
