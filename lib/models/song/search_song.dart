import 'package:accompaneo/models/artist.dart';
import 'package:accompaneo/models/song/audio_stream.dart';
import 'package:accompaneo/models/song/song.dart';

class SearchSong extends Song {
  SearchSong({required super.code, required super.name, required super.picture, required super.artist, required super.bpm, required super.favoured, super.key, super.chords, super.structureUrl, super.audioStreams});

  static SearchSong fromJson(Map<String, dynamic> json) => SearchSong(
    code: json['code'] ?? '',
    name: json['name'] ?? '',
    picture: json['picture'] ?? '',
    artist: json['artist'] != null ? Artist.fromJson(json['artist']) : Artist(code: '', name: '', picture: ''),
    chords: (json['chords'] as List).map((e) => e as String).toList(),
    bpm: json['tempo'] ?? 0.0,
    key: json['key'] ?? '',
    favoured: json['favoured'] ?? false,
    structureUrl: json['structureUrl'],
    audioStreams: json['audioStreams'] != null ? (json['audioStreams'] as List).map((e) => AudioStream.fromJson(e)).toList() : []
  );

}