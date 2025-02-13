import 'package:accompaneo/models/applied_facet.dart';
import 'package:accompaneo/models/facet.dart';
import 'package:accompaneo/models/page.dart';
import 'package:accompaneo/models/song/search_song.dart';

class SearchPage extends PageDto {

  SearchPage({required super.totalPages, required super.totalElements, required super.size, required super.number, required super.content, super.facets, super.appliedFacets});

  static SearchPage fromJson(Map<String, dynamic> json) => SearchPage(
        totalPages: json['totalPages'] ?? 0,
        totalElements: json['totalElements'] ?? 0,
        size: json['size'] ?? 0,
        number: json['number'] ?? 0,
        content: (json['content'] as List).map((e) => SearchSong.fromJson(e['properties'])).toList(),
        facets: json['facets'] != null ? (json['facets'] as Map).entries.map((e) => FacetDto.fromJson(e.key, e.value)).toList() : [],
        appliedFacets: json['appliedFacets'] != null ? (json['appliedFacets'] as List).map((e) => AppliedFacetDto.fromJson(e)).toList() : [],
      );

}