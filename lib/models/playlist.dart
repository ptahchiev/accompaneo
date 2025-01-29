import 'package:accompaneo/models/browseable.dart';
import 'package:accompaneo/models/image.dart';
import 'package:accompaneo/models/page.dart';

class Playlist extends Browseable{

  bool favourites;

  Page firstPageSongs;

  // Constructor
  Playlist({
    required super.code,
    required super.name,
    required super.picture,
    required this.favourites,
    required this.firstPageSongs
  });

  static Playlist fromJson(Map<String, dynamic> json) => Playlist(
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        picture: json['picture'] != null ? Image.fromJson(json['picture']) : Image(code: '', url: ''),
        favourites:  json['favourites'] ?? false,
        firstPageSongs: json['firstPageSongs'] != null ? Page.fromJson(json['firstPageSongs']) : Page(number: 0, size: 0, totalElements: 0, totalPages: 0, content: [])
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'picture': picture != null ? picture!.toJson() : '',
        'songs': firstPageSongs,
      };
}