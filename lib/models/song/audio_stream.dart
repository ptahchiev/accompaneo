class AudioStream {

  final String url;
  final String type;
  final double margin;

  AudioStream({
    required this.url,
    required this.type,
    required this.margin
  });

  static AudioStream fromJson(Map<String, dynamic> json) => AudioStream(
    url: json['url'] ?? '',
    type: json['type'] ?? '',
    margin: double.parse(json['margin'] ?? "0.0")
  );
}