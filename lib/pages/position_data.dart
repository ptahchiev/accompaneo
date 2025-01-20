class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  final bool playing;

  PositionData(this.position, this.bufferedPosition, this.duration, this.playing);
}