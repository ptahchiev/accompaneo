import 'package:accompaneo/models/artist.dart';

class Song {
  String code;
  String image;
  String title;
  Artist artist;
  double bpm;
  bool favoured;

  // Constructor
  Song({
    required this.code,
    required this.image,
    required this.title,
    required this.artist,
    required this.bpm,
    required this.favoured
  });

  Song copy({
    String? code,
    String? imagePath,
    String? title,
    Artist? artist,
    double? bpm,
    bool? favourite
  }) =>
      Song(
        code: code ?? this.code,
        image: imagePath ?? this.image,
        title: title ?? this.title,
        artist: artist ?? this.artist,
        bpm: bpm ?? this.bpm,
        favoured: favourite ?? this.favoured
      );

  static Song fromJson(Map<String, dynamic> json) => Song(
        code: json['code'] ?? '',
        image: json['imagePath'] ?? '',
        title: json['title'] ?? '',
        artist: Artist.fromJson(json['artist']),
        bpm: json['bpm'] ?? 0.0,
        favoured: json['favoured'] ?? false
      );

  Map<String, dynamic> toJson() => {
        'code' : code,
        'imagePath': image,
        'title': title,
        'artist': artist,
        'bpm': bpm,
        'favoured': favoured
      };
}