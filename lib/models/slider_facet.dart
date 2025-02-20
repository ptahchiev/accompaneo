import 'package:accompaneo/models/facet.dart';
import 'package:accompaneo/models/facet_value.dart';

class SliderFacetDto extends FacetDto {

  double initialMinValue;
  double initialMaxValue;
  double userSelectionMin;
  double userSelectionMax;
  String unit;

  static SliderFacetDto missing = SliderFacetDto(
    code: '', 
    name: '', 
    initialMinValue: -1, 
    initialMaxValue: -1, 
    userSelectionMin: -1, 
    userSelectionMax: -1, 
    unit: ''
  );

  SliderFacetDto({
    required super.code,
    required super.name,
    super.values,
    required this.initialMinValue,
    required this.initialMaxValue,
    required this.userSelectionMin,
    required this.userSelectionMax,
    required this.unit,
  });

  static SliderFacetDto fromJson(Map<String, dynamic> json) => SliderFacetDto(
    code: json['code'] ?? '',
    name: json['name'] ?? '',
    values: json['values'] != null ? (json['values'] as List).map((v) => FacetValueDto.fromJson(v)).toList() : List.empty(),
    initialMinValue: json['initialMinValue'] != null ? double.parse(json['initialMinValue']) : 0.0,
    initialMaxValue: json['initialMaxValue'] != null ? double.parse(json['initialMaxValue']) : 0.0,
    userSelectionMin: json['userSelectionMin'] != null ? double.parse (json['userSelectionMin']) : 0.0,
    userSelectionMax: json['userSelectionMax'] != null ? double.parse(json['userSelectionMax']) : 0.0,
    unit: json['unit'] ?? ''
  );
}