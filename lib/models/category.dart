import 'package:accompaneo/models/browseable.dart';
import 'package:accompaneo/models/image.dart';

class Category extends Browseable {

  // Constructor
  Category({
    required super.code,
    required super.name,
    required super.picture
  });

  static Category fromJson(Map<String, dynamic> json) => Category(
    code: json['code'] ?? '',
    name: json['name'] ?? '',
    picture: json['picture'] != null ? ImageData.fromJson(json['picture']) : ImageData(code: '', url: '')
  );  
}