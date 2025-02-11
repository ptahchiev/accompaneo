import 'package:accompaneo/models/artist.dart';
import 'package:accompaneo/models/song/song.dart';

class SearchSong extends Song {
  SearchSong({required super.code, required super.name, required super.picture, required super.artist, required super.bpm, required super.favoured, super.chords, super.structureUrl, super.audioStreamUrls});

  static SearchSong fromJson(Map<String, dynamic> json) => SearchSong(
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        picture: json['picture'] ?? '',
        artist: json['artist'] != null ? Artist.fromJson(json['artist']) : Artist(code: '', name: '', picture: ''),
        chords: (json['chords'] as List).map((e) => e as String).toList(),
        bpm: json['tempo'] ?? 0.0,
        favoured: json['favoured'] ?? false,
        structureUrl: json['structureUrl'],
        audioStreamUrls: json['audioStreamUrls'] ?? {}
      );

}