import 'package:accompaneo/models/browseable.dart';

class Artist extends Browseable{

  // Constructor
  Artist({
    required super.code,
    required super.name,
    required super.picture
  });

  static Artist fromJson(Map<String, dynamic> json) => Artist(
        code: json['code'],
        name: json['name'],
        picture: json['picture'] ?? ''
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'picture' : picture
      };
}