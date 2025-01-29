import 'package:accompaneo/models/image.dart';

class Browseable {
  final String code;
  final String name;
  final Image? picture;

  // Constructor
  Browseable({
    required this.code,
    required this.name,
    required this.picture
  });

  Browseable copy({
    String? code,
    String? name,
    Image? picture
  }) =>
      Browseable(
        code: code ?? this.code,
        name: name ?? this.name,
        picture: picture ?? this.picture
      );

  static Browseable fromJson(Map<String, dynamic> json) => Browseable(
        code: json['code'],
        name: json['subtitle'],
        picture: json['url']
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'picture': picture != null ? picture!.toJson() : '',
      };
}