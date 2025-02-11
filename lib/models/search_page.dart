import 'package:accompaneo/models/page.dart';
import 'package:accompaneo/models/song/search_song.dart';

class SearchPage extends PageDto{
  SearchPage({required super.totalPages, required super.totalElements, required super.size, required super.number, required super.content});

  static SearchPage fromJson(Map<String, dynamic> json) => SearchPage(
        totalPages: json['totalPages'] ?? 0,
        totalElements: json['totalElements'] ?? 0,
        size: json['size'] ?? 0,
        number: json['number'] ?? 0,
        content: (json['content'] as List).map((e) => SearchSong.fromJson(e['properties'])).toList()
      );

}