import 'package:accompaneo/models/artist.dart';

class Song {
  String image;
  String title;
  Artist artist;
  double bpm;
  bool favourite;

  // Constructor
  Song({
    required this.image,
    required this.title,
    required this.artist,
    required this.bpm,
    required this.favourite
  });

  Song copy({
    String? imagePath,
    String? title,
    Artist? artist,
    double? bpm,
    bool? favourite
  }) =>
      Song(
        image: imagePath ?? this.image,
        title: title ?? this.title,
        artist: artist ?? this.artist,
        bpm: bpm ?? this.bpm,
        favourite: favourite ?? this.favourite
      );

  static Song fromJson(Map<String, dynamic> json) => Song(
        image: json['imagePath'] ?? '',
        title: json['title'] ?? '',
        artist: Artist.fromJson(json['artist']),
        bpm: json['bpm'] ?? 0.0,
        favourite: json['favourite'] ?? true
      );

  Map<String, dynamic> toJson() => {
        'imagePath': image,
        'title': title,
        'artist': artist,
        'bpm': bpm,
        'favourite': favourite
      };
}