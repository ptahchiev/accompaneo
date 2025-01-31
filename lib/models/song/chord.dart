class MusicChord {

  String code;

  String name;

  MusicChord({
    required this.code,
    required this.name
  });

  static MusicChord fromJson(Map<String, dynamic> json) => MusicChord(
    code: json['code'] ?? '',
    name: json['name'] ?? '',
  );
}