class ImageData {
  final String code;
  final String url;

  // Constructor
  ImageData({
    required this.code,
    required this.url
  });

  ImageData copy({
    String? code,
    String? url
  }) =>
      ImageData(
        code: code ?? this.code,
        url: url ?? this.url
      );

  static ImageData fromJson(Map<String, dynamic> json) => ImageData(
        code: json['code'] ?? '',
        url: json['url'] ?? ''
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'url': url
      };
}