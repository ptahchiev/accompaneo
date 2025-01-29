class Image {
  final String code;
  final String url;

  // Constructor
  Image({
    required this.code,
    required this.url
  });

  Image copy({
    String? code,
    String? url
  }) =>
      Image(
        code: code ?? this.code,
        url: url ?? this.url
      );

  static Image fromJson(Map<String, dynamic> json) => Image(
        code: json['code'] ?? '',
        url: json['url'] ?? ''
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'url': url
      };
}