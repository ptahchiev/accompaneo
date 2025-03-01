class TimeSignature {
  
  final String name;

  final int numberOfBeats;

  final int numberOfSubBeats;

  final bool Function(int index) isBeat;

  TimeSignature({
    required this.name,
    required this.numberOfBeats,
    required this.numberOfSubBeats,
    required this.isBeat
  });

  static TimeSignature empty() {
    return TimeSignature(name: '1/1', numberOfBeats: 1, numberOfSubBeats: 1, isBeat: (index) => false);
  }
}