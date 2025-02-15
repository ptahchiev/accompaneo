import 'package:accompaneo/models/facet_value.dart';

class FacetDto {

  String code;

  String name;

  bool multiSelect;

  List<FacetValueDto> values;

  FacetDto({
    required this.code,
    required this.name,
    this.multiSelect = false,
    List<FacetValueDto>? values
  }): values = values ?? [];

  static FacetDto fromJson(Map<String, dynamic> json) => FacetDto(
    code: json['code'] ?? '',
    name: json['name'] ?? '',
    multiSelect: json['multiSelect'] ?? false,
    values: json['values'] != null ? (json['values'] as List).map((v) => FacetValueDto.fromJson(v)).toList() : List.empty(),
  );
}