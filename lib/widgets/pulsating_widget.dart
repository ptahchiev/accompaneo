import 'package:accompaneo/utils/helpers/chords_helper.dart';
import 'package:accompaneo/values/app_colors.dart';
import 'package:accompaneo/values/app_dimensions.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class PulsatingWidget extends StatefulWidget {
  const PulsatingWidget({
    required this.isActive,
    required this.title,
    this.whenActive,
    Key? key,
  }) : super(key: key);
  final bool isActive;
  final String title;
  final Function? whenActive;

  @override
  _PulsatingWidgetState createState() => _PulsatingWidgetState();
}

class _PulsatingWidgetState extends State<PulsatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  final double size = 50;
  bool played = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1.2).animate(_controller);
    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant PulsatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(
        from: 0,
      );
      if (widget.whenActive != null) {
        played = true;
        widget.whenActive!();
      }
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
    ChordType chord = ChordsHelper.stringToChord(widget.title);
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: size * 2.5,
              height: size * 2.5,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.primaryColor),
            ),
          ),
        ),
        Center(
          child: Container(
            padding: EdgeInsets.all(Dimensions.smallMargin),
            decoration: BoxDecoration(
              color: chord == ChordType.UNKNOWN
                  ? Colors.white
                  : ChordsHelper.chordTypeColors[chord],
              border: Border.all(
                  color:
                      chord == ChordType.UNKNOWN ? Colors.orange : Colors.white,
                  width: 5),
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
            width: size,
            height: size,
            child: Center(
              child: AutoSizeText(
                widget.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color:
                      chord == ChordType.UNKNOWN ? Colors.orange : Colors.white,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
