import 'package:accompaneo/models/artist.dart';
import 'package:accompaneo/models/browseable.dart';
import 'package:accompaneo/models/image.dart';
import 'package:accompaneo/models/song/chord.dart';

class Song extends Browseable{
  Artist artist;
  double bpm;
  bool favoured;
  List<MusicChord>? chords;
  String? structureUrl;
  Map<String, dynamic>? audioStreamUrls;

  // Constructor
  Song({
    required super.code, required super.name, required super.picture,
    required this.artist,
    required this.bpm,
    required this.favoured,
    this.chords,
    this.structureUrl,
    this.audioStreamUrls
  });

  static Song fromJson(Map<String, dynamic> json) => Song(
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        picture: json['picture'] != null ? ImageData.fromJson(json['picture']) : ImageData(code: '', url: ''),
        artist: json['artist'] != null ? Artist.fromJson(json['artist']) : Artist(code: '', name: '', picture: ImageData(code: '', url: '')),
        chords: (json['chords'] as List).map((e) => MusicChord.fromJson(e)).toList(),
        bpm: json['bpm'] ?? 0.0,
        favoured: json['favoured'] ?? false,
        structureUrl: json['structureUrl'],
        audioStreamUrls: json['audioStreamUrls'] ?? {}
      );

  Map<String, dynamic> toJson() => {
        'code' : code,
        'name': name,
        'picture': picture != null ? picture!.toJson() : '',
        'artist': artist,
        'bpm': bpm,
        'favoured': favoured
      };
}