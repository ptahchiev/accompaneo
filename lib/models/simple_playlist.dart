import 'package:accompaneo/models/browseable.dart';

class SimplePlaylist extends Browseable {

  final bool favourites;

  final bool latestPlayed;

  final bool searchable;

  final String? url;

  // Constructor
  const SimplePlaylist({
    required super.code,
    required super.name,
    super.picture,
    this.favourites = false,
    this.latestPlayed = false,
    this.searchable = false,
    this.url
  });


  SimplePlaylist copy({
    String? code,
    String? name,
    String? picture,
    String? url,
    bool? favourites,
    bool? latestPlayed,
    bool? searchable
  }) =>
      SimplePlaylist(
        code: code ?? this.code,
        name: name ?? this.name,
        picture: picture ?? this.picture,
        url: url ?? this.url,
        favourites: favourites ?? this.favourites,
        latestPlayed: latestPlayed ?? this.latestPlayed,
        searchable: searchable ?? this.searchable
      );  

  static SimplePlaylist fromJson(Map<String, dynamic> json) => SimplePlaylist(
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        picture: json['picture'] ?? '',
        favourites: json['favourites'] ?? false,
        latestPlayed: json['latestPlayed'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'picture': picture,
        'favourites' : favourites
      };
}