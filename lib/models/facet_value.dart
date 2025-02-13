class FacetValueDto {

  String code;

  String name;

  String? mediaUrl;

  int? count;

  bool selected;

  String currentQueryUrl;

  FacetValueDto({
    required this.code,
    required this.name,
    this.mediaUrl = '',
    this.count = 0,
    this.selected = false,
    this.currentQueryUrl = ''
  });

  static FacetValueDto fromJson(Map<String, dynamic> json) => FacetValueDto(
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        mediaUrl: json['mediaUrl'] ?? '',
        count: json['count'] ?? 0,
        selected: json['selected'] ?? false,
        currentQueryUrl: (json['currentQuery'] as Map)['url']
      );  
}