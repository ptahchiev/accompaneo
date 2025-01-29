import 'package:accompaneo/models/image.dart';

class Artist {

  String code;

  String name;

  Image picture;

  // Constructor
  Artist({
    required this.code,
    required this.name,
    required this.picture
  });

  Artist copy({
    String? code,
    String? name,
    Image? picture
  }) =>
      Artist(
        code: code ?? this.code,
        name: name ?? this.name,
        picture: picture ?? this.picture
      );

  static Artist fromJson(Map<String, dynamic> json) => Artist(
        code: json['code'],
        name: json['name'],
        picture: json['picture'] != null ? Image.fromJson(json['picture']) : Image(code: '', url: '')
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'picture' : picture
      };
}