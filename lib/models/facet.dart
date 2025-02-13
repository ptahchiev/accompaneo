import 'package:accompaneo/models/facet_value.dart';

class FacetDto {

  String type;

  String code;

  String name;

  bool multiSelect;

  List<FacetValueDto> values;

  FacetDto({
    required this.type,
    required this.code,
    required this.name,
    this.multiSelect = false,
    List<FacetValueDto>? values
  }): values = values ?? [];

static FacetDto fromJson(String facetKey, Map<String, dynamic> json) => FacetDto(
      type: json['@class'] == 'io.nemesis.platform.module.search.facade.dto.TermsFacetDto' ? 'terms' : 'slider',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      multiSelect: json['multiSelect'] ?? false,
      values: json['values'] != null ? (json['values'] as List).map((v) => FacetValueDto.fromJson(v)).toList() : List.empty(),
    );
}