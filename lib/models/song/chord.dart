class MusicChord {
  String name;

  MusicChord({
    required this.name
  });

  static MusicChord fromJson(Map<String, dynamic> json) => MusicChord(
    name: json['name'] ?? '',
  );
}