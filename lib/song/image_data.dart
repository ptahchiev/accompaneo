class ImageData {
  final String title;
  final String subtitle;
  final String url;

  // Constructor
  ImageData({
    required this.title,
    required this.subtitle,
    required this.url
  });

  ImageData copy({
    String? title,
    String? subtitle,
    String? url
  }) =>
      ImageData(
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        url: url ?? this.url
      );

  static ImageData fromJson(Map<String, dynamic> json) => ImageData(
        title: json['title'],
        subtitle: json['subtitle'],
        url: json['url']
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'url': url
      };
}