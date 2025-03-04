import 'package:just_audio/just_audio.dart';

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  final PlayerState playerState;
  final ProcessingState processingState;

  PositionData(this.position, this.bufferedPosition, this.duration, this.playerState, this.processingState);
}