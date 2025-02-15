import 'package:accompaneo/models/page.dart';
import 'package:accompaneo/models/simple_playlist.dart';

class Playlist extends SimplePlaylist {

  PageDto firstPageSongs;

  // Constructor
  Playlist({
    required super.code,
    required super.name,
    super.picture,
    required super.favourites,
    required super.latestPlayed,
    super.searchable,
    super.url,
    required this.firstPageSongs
  });

  static Playlist fromJson(Map<String, dynamic> json) => Playlist(
    code: json['code'] ?? '',
    name: json['name'] ?? '',
    picture: json['picture'] ?? '',
    favourites:  json['favourites'] ?? false,
    latestPlayed:  json['latestPlayed'] ?? false,
    firstPageSongs: json['firstPageSongs'] != null ? PageDto.fromJson(json['firstPageSongs']) : PageDto(number: 0, size: 0, totalElements: 0, totalPages: 0, content: [])
  );


  Playlist copy({
    String? code,
    String? name,
    String? picture,
    String? url,
    bool? favourites,
    bool? latestPlayed,
    bool? searchable,
    PageDto? firstPageSongs

  }) =>
      Playlist(
        code: code ?? this.code,
        name: name ?? this.name,
        picture: picture ?? this.picture,
        url: url ?? this.url,
        favourites: favourites ?? this.favourites,
        latestPlayed: latestPlayed ?? this.latestPlayed,
        searchable: searchable ?? this.searchable,
        firstPageSongs: firstPageSongs ?? this.firstPageSongs
      );  


  @override
  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'picture': picture,
        'songs': firstPageSongs,
      };
}