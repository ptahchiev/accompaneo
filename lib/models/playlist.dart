import 'package:accompaneo/models/page.dart';

class Playlist {

  String code;

  String name;

  Page songs;

  // Constructor
  Playlist({
    required this.code,
    required this.name,
    required this.songs
  });

  Playlist copy({
    String? code,
    String? name,
    Page? songs
  }) =>
      Playlist(
        code: code ?? this.code,
        name: name ?? this.name,
        songs: songs ?? this.songs
      );

  static Playlist fromJson(Map<String, dynamic> json) => Playlist(
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        songs: Page.fromJson(json['songs'])
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'songs': songs
      };
}