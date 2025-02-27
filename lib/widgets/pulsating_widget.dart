import 'package:accompaneo/models/music_data.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class PulsatingWidget extends StatefulWidget {
  const PulsatingWidget({required this.isActive, required this.title, Key? key})
      : super(key: key);
  final bool isActive;
  final String title;

  @override
  _PulsatingWidgetState createState() => _PulsatingWidgetState();
}

class _PulsatingWidgetState extends State<PulsatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 1.0,
      upperBound: 1.2,
    )..addListener(() {});

    if (widget.isActive) {
      _controller.forward(
        from: 0,
      );
    }
  }

  @override
  void didUpdateWidget(covariant PulsatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(
        from: 0,
      );
    } else {
      if (!widget.isActive) {
        _controller.stop();
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GuitarChord? chord = stringToChord(widget.title);
    return ScaleTransition(
      scale: _controller,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: chord?.getChordColor ?? Colors.red,
          border: Border.all(color: Colors.white, width: 2),
        ),
        width: 50,
        height: 50,
        child: Center(
          child: AutoSizeText(
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
              color: Colors.white,
              height: 1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
