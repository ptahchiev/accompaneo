import 'package:accompaneo/models/applied_facet.dart';
import 'package:accompaneo/models/facet.dart';
import 'package:accompaneo/models/facet_value.dart';
import 'package:accompaneo/models/slider_facet.dart';
import 'package:accompaneo/models/song/song.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class PageDto {

  int totalPages;

  int totalElements;

  int size;

  int number;

  List<Song> content;

  bool first;

  bool last;

  List<FacetDto>? facets;

  List<AppliedFacetDto>? appliedFacets;

  // Constructor
  PageDto({
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
    required this.content,
    required this.first,
    required this.last,
    List<FacetDto>? facets,
    List<AppliedFacetDto>? appliedFacets
  }) : facets = facets ?? [], appliedFacets = appliedFacets ?? [];

  PageDto copy({
    int? totalPages,
    int? totalElements,
    int? size,
    int? number,
    bool? first,
    bool? last,
    List<Song>? content
  }) =>
      PageDto(
        totalPages: totalPages ?? this.totalPages,
        totalElements: totalElements ?? this.totalElements,
        size: size ?? this.size,
        number: number ?? this.number,
        first: first ?? this.first,
        last: last ?? this.last,
        content: content ?? this.content
      );

  static PageDto fromJson(Map<String, dynamic> json) => PageDto(
    totalPages: json['totalPages'] ?? 0,
    totalElements: json['totalElements'] ?? 0,
    size: json['size'] ?? 0,
    number: json['number'] ?? 0,
    first: json['first'] ?? false,
    last: json['last'] ?? false,
    content: (json['content'] as List).map((e) => Song.fromJson(e)).toList(),
    facets: json['facets'] != null ? (json['facets'] as Map).entries.map((e) => e.value['@class'] == 'io.nemesis.platform.module.search.facade.dto.TermsFacetDto' ? FacetDto.fromJson(e.value) : SliderFacetDto.fromJson(e.value)).toList() : [],
    appliedFacets: json['appliedFacets'] != null ? (json['appliedFacets'] as List).map((e) => AppliedFacetDto.fromJson(e)).toList() : [],
  );

  Map<String, dynamic> toJson() => {
    'totalPages': totalPages,
    'totalElements': totalElements,
    'size': size,
    'number': number,
    'content': content
  };

  bool isFacetValueApplied(FacetValueDto facetValue) {
    return appliedFacets != null && (appliedFacets!.where((af) => af.facetValueName == facetValue.name)).firstOrNull != null;
  }

  RangeValues getTempoRangeValues() {
    SliderFacetDto tempoFacet = (facets!.firstWhere((f) => f.code == 'tempo', orElse: () => SliderFacetDto.missing) as SliderFacetDto);
    return RangeValues(tempoFacet.userSelectionMin.ceilToDouble(), tempoFacet.userSelectionMax.ceilToDouble());
  }
}