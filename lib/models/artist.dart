import 'package:accompaneo/models/browseable.dart';
import 'package:accompaneo/models/image.dart';

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
        picture: json['picture'] != null ? ImageData.fromJson(json['picture']) : ImageData(code: '', url: '')
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'picture' : picture
      };
}