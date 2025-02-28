import 'package:accompaneo/models/artist.dart';
import 'package:accompaneo/models/browseable.dart';
import 'package:accompaneo/models/song/audio_stream.dart';

class Song extends Browseable {
  Artist artist;
  double bpm;
  bool favoured;
  List<String>? chords;
  String? structureUrl;
  List<AudioStream>? audioStreams;

  // Constructor
  Song({
    required super.code, required super.name, required super.picture,
    required this.artist,
    required this.bpm,
    required this.favoured,
    this.chords,
    this.structureUrl,
    this.audioStreams
  });

  static Song fromJson(Map<String, dynamic> json) => Song(
    code: json['code'] ?? '',
    name: json['name'] ?? '',
    picture: json['picture'] ?? '',
    artist: json['artist'] != null ? Artist.fromJson(json['artist']) : Artist(code: '', name: '', picture: ''),
    chords: (json['chords'] as List).map((e) => e as String).toList(),
    bpm: json['tempo'] ?? 0.0,
    favoured: json['favoured'] ?? false,
    structureUrl: json['structureUrl'],
    audioStreams: json['audioStreams'] != null ? (json['audioStreams'] as List).map((e) => AudioStream.fromJson(e)).toList() : [],
  );

  Map<String, dynamic> toJson() => {
    'code' : code,
    'name': name,
    'picture': picture,
    'artist': artist,
    'bpm': bpm,
    'favoured': favoured
  };
}