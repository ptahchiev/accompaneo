class AppliedFacetDto {

    String facetCode;

    String facetName;

    String facetValueCode;

    String facetValueName;

    String removeQueryUrl;

    String? truncateQueryUrl;

  AppliedFacetDto({
    required this.facetCode,
    required this.facetName,
    required this.facetValueCode,
    required this.facetValueName,
    required this.removeQueryUrl,
    this.truncateQueryUrl
  });

  static AppliedFacetDto fromJson(Map<String, dynamic> json) => AppliedFacetDto(
    facetCode: json['facetCode'] ?? '',
    facetName: json['facetName'] ?? '',
    facetValueCode: json['facetValueCode'] ?? '',
    facetValueName: json['facetValueName'] ?? '',
    removeQueryUrl: (json['removeQuery'] as Map)['url'],
    //truncateQueryUrl: (json['truncateQuery'] as Map)['url']
  );

}