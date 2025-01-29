class BannerData {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String url;

  // Constructor
  BannerData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.url
  });

  BannerData copy({
    String? title,
    String? subtitle,
    String? imageUrl,
    String? url
  }) =>
      BannerData(
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        imageUrl: imageUrl ?? this.imageUrl,
        url: url ?? this.url
      );

  static BannerData fromJson(Map<String, dynamic> json) => BannerData(
        title: json['title'],
        subtitle: json['subtitle'],
        imageUrl: json['url'],
        url: json['url']
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'url': url
      };
}