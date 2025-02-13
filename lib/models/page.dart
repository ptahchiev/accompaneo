import 'package:accompaneo/models/applied_facet.dart';
import 'package:accompaneo/models/facet.dart';
import 'package:accompaneo/models/song/song.dart';

class PageDto {

  int totalPages;

  int totalElements;

  int size;

  int number;

  List<Song> content;

  List<FacetDto>? facets;

  List<AppliedFacetDto>? appliedFacets;

  // Constructor
  PageDto({
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
    required this.content,
    List<FacetDto>? facets,
    List<AppliedFacetDto>? appliedFacets
  }) : facets = facets ?? [], appliedFacets = appliedFacets ?? [];

  PageDto copy({
    int? totalPages,
    int? totalElements,
    int? size,
    int? number,
    List<Song>? content
  }) =>
      PageDto(
        totalPages: totalPages ?? this.totalPages,
        totalElements: totalElements ?? this.totalElements,
        size: size ?? this.size,
        number: number ?? this.number,
        content: content ?? this.content
      );

  static PageDto fromJson(Map<String, dynamic> json) => PageDto(
        totalPages: json['totalPages'] ?? 0,
        totalElements: json['totalElements'] ?? 0,
        size: json['size'] ?? 0,
        number: json['number'] ?? 0,
        content: (json['content'] as List).map((e) => Song.fromJson(e)).toList(),
        facets: json['facets'] != null ? (json['facets'] as Map).entries.map((e) => FacetDto.fromJson(e.key, e.value)).toList() : [],
        appliedFacets: json['appliedFacets'] != null ? (json['appliedFacets'] as List).map((e) => AppliedFacetDto.fromJson(e)).toList() : [],
      );

  Map<String, dynamic> toJson() => {
        'totalPages': totalPages,
        'totalElements': totalElements,
        'size': size,
        'number': number,
        'content': content
      };
}