import 'package:accompaneo/models/browseable.dart';
import 'package:accompaneo/models/image.dart';

class SimplePlaylist extends Browseable {

  bool favourites;

  bool latestPlayed;

  int totalSongs;

  String? url;

  // Constructor
  SimplePlaylist({
    required super.code,
    required super.name,
    required super.picture,
    required this.favourites,
    required this.latestPlayed,
    required this.totalSongs,
    this.url
  });

  static SimplePlaylist fromJson(Map<String, dynamic> json) => SimplePlaylist(
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        picture: json['picture'] ?? '',
        favourites: json['favourites'] ?? false,
        latestPlayed: json['latestPlayed'] ?? false,
        totalSongs: json['totalSongs'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'picture': picture,
        'favourites' : favourites,
        'totalSongs': totalSongs
      };
}