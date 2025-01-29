import 'package:accompaneo/models/artist.dart';
import 'package:accompaneo/models/simple_playlist.dart';
import 'package:accompaneo/models/song/song.dart';

class HomepageSections {

  List<SimplePlaylist> genres;

  List<Artist> artists;

  List<Song> latestAdded;

  List<Song> latestPlayed;

  List<Song> mostPopular;

  List<Song> favourites;

  // Constructor
  HomepageSections({
    required this.genres,
    required this.artists,
    required this.latestAdded,
    required this.latestPlayed,
    required this.mostPopular,
    required this.favourites
  });

  HomepageSections copy({
    List<SimplePlaylist>? genres,
    List<Artist>? artists,
    List<Song>? latestAdded,
    List<Song>? latestPlayed,
    List<Song>? mostPopular,
    List<Song>? favourites
  }) =>
      HomepageSections(
        genres: genres ?? this.genres,
        artists: artists ?? this.artists,
        latestAdded: latestAdded ?? this.latestAdded,
        latestPlayed: latestPlayed ?? this.latestPlayed,
        mostPopular: mostPopular ?? this.mostPopular,
        favourites: favourites ?? this.favourites,
      );

  static HomepageSections fromJson(Map<String, dynamic> json) => HomepageSections(
        genres: (json['genres'] as List).map((e) => SimplePlaylist.fromJson(e)).toList(), //List.from(json['genres']).map((e) => BannerData(title: e['name'], subtitle: e['description'], url: '', imageUrl: '')).toList(),
        artists: (json['artists'] as List).map((e) => Artist.fromJson(e)).toList(), //List.from(json['artists']).map((e)=> BannerData(title: e['name'], subtitle: '', url: '/artist/${e["code"]}', imageUrl: e['picture']?['url'])).toList(),
        latestAdded: (json['latestAdded'] as List).map((e) => Song.fromJson(e)).toList(), //List.from(json['latestAdded']).map((e)=> BannerData(title: e['title'], subtitle: e['artist']?['name'], url: '', imageUrl: e['picture']?['url'])).toList(),
        latestPlayed: (json['latestPlayed'] as List).map((e) => Song.fromJson(e)).toList(), //List.from(json['latestPlayed']).map((e)=> BannerData(title: e['title'], subtitle: e['artist']?['name'], url: '', imageUrl: e['picture']?['url'])).toList(),
        mostPopular: (json['mostPopular'] as List).map((e) => Song.fromJson(e)).toList(), //List.from(json['mostPopular']).map((e)=> BannerData(title: e['title'], subtitle: e['artist']?['name'], url: '', imageUrl: e['picture']?['url'])).toList(),
        favourites: (json['favourites'] as List).map((e) => Song.fromJson(e)).toList() //List.from(json['favourites']).map((e)=> BannerData(title: e['title'], subtitle: e['artist']?['name'], url: '', imageUrl: e['picture']?['url'])).toList()
  );

  Map<String, dynamic> toJson() => {
        'genres': genres,
        'artists': artists,
        'latestAdded': latestAdded,
        'latestPlayed': latestPlayed,
        'mostPopular': mostPopular,
        'favourites': favourites
  };
}