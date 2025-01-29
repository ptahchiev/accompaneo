import 'package:accompaneo/models/browseable.dart';
import 'package:accompaneo/models/image.dart';

class SimplePlaylist extends Browseable{

  bool favourites;

  int totalSongs;

  String? url;

  // Constructor
  SimplePlaylist({
    required super.code,
    required super.name,
    required super.picture,
    required this.favourites,
    required this.totalSongs,
    this.url
  });

  static SimplePlaylist fromJson(Map<String, dynamic> json) => SimplePlaylist(
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        picture: json['picture'] != null ? Image.fromJson(json['picture']) : Image(code: '', url: ''),
        favourites: json['favourites'] ?? false,
        totalSongs: json['totalSongs'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'picture': picture != null ? picture!.toJson() : '',
        'favourites' : favourites,
        'totalSongs': totalSongs
      };
}