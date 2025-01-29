import 'package:accompaneo/models/artist.dart';
import 'package:accompaneo/models/image.dart';

class Song {
  String code;
  Image picture;
  String title;
  Artist artist;
  double bpm;
  bool favoured;

  // Constructor
  Song({
    required this.code,
    required this.picture,
    required this.title,
    required this.artist,
    required this.bpm,
    required this.favoured
  });

  Song copy({
    String? code,
    Image? picture,
    String? title,
    Artist? artist,
    double? bpm,
    bool? favourite
  }) =>
      Song(
        code: code ?? this.code,
        picture: picture ?? this.picture,
        title: title ?? this.title,
        artist: artist ?? this.artist,
        bpm: bpm ?? this.bpm,
        favoured: favourite ?? this.favoured
      );

  static Song fromJson(Map<String, dynamic> json) => Song(
        code: json['code'] ?? '',
        picture: json['picture'] != null ? Image.fromJson(json['picture']) : Image(code: '', url: ''),
        title: json['title'] ?? '',
        artist: json['artist'] != null ? Artist.fromJson(json['artist']) : Artist(code: '', name: '', picture: Image(code: '', url: '')),
        bpm: json['bpm'] ?? 0.0,
        favoured: json['favoured'] ?? false
      );

  Map<String, dynamic> toJson() => {
        'code' : code,
        'picture': picture,
        'title': title,
        'artist': artist,
        'bpm': bpm,
        'favoured': favoured
      };
}