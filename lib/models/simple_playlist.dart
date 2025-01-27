import 'package:accompaneo/models/page.dart';

class SimplePlaylist {

  String code;

  String name;

  bool favourites;

  int totalSongs;

  // Constructor
  SimplePlaylist({
    required this.code,
    required this.name,
    required this.favourites,
    required this.totalSongs
  });

  SimplePlaylist copy({
    String? code,
    String? name,
    bool? favourites,
    int? totalSongs
  }) =>
      SimplePlaylist(
        code: code ?? this.code,
        name: name ?? this.name,
        favourites: favourites ?? this.favourites,
        totalSongs: totalSongs ?? this.totalSongs
      );

  static SimplePlaylist fromJson(Map<String, dynamic> json) => SimplePlaylist(
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        favourites: json['favourites'] ?? false,
        totalSongs: json['totalSongs'] ?? 0
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'favourites' : favourites,
        'songs': totalSongs
      };
}