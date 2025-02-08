import 'package:accompaneo/models/artist.dart';
import 'package:accompaneo/models/browseable.dart';
import 'package:accompaneo/models/category.dart';
import 'package:accompaneo/models/song/song.dart';

class HomepageSections {

  List<Browseable> genres;

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
    List<Browseable>? genres,
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
        genres: (json['genres'] as List).map((e) => Category.fromJson(e)).toList(),
        artists: (json['artists'] as List).map((e) => Artist.fromJson(e)).toList(),
        latestAdded: (json['latestAdded'] as List).map((e) => Song.fromJson(e)).toList(),
        latestPlayed: (json['latestPlayed'] as List).map((e) => Song.fromJson(e)).toList(),
        mostPopular: (json['mostPopular'] as List).map((e) => Song.fromJson(e)).toList(),
        favourites: (json['favourites'] as List).map((e) => Song.fromJson(e)).toList()
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