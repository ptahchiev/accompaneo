import 'package:accompaneo/models/song/image_data.dart';

class HomepageSections {

  List<ImageData> genres;

  List<ImageData> artists;

  List<ImageData> latestAdded;

  List<ImageData> latestPlayed;

  List<ImageData> mostPopular;

  List<ImageData> favourites;

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
    List<ImageData>? genres,
    List<ImageData>? artists,
    List<ImageData>? latestAdded,
    List<ImageData>? latestPlayed,
    List<ImageData>? mostPopular,
    List<ImageData>? favourites
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
        genres: List.from(json['genres']).map((e) => ImageData(title: e['name'], subtitle: e['description'], url: '', imageUrl: '')).toList(),
        artists: List.from(json['artists']).map((e)=> ImageData(title: e['name'], subtitle: '', url: '', imageUrl: e['picture']?['url'])).toList(),
        latestAdded: List.from(json['latestAdded']).map((e)=> ImageData(title: e['title'], subtitle: e['artist']?['name'], url: '', imageUrl: e['picture']?['url'])).toList(),
        latestPlayed: List.from(json['latestPlayed']).map((e)=> ImageData(title: e['title'], subtitle: e['artist']?['name'], url: '', imageUrl: e['picture']?['url'])).toList(),
        mostPopular: List.from(json['mostPopular']).map((e)=> ImageData(title: e['title'], subtitle: e['artist']?['name'], url: '', imageUrl: e['picture']?['url'])).toList(),
        favourites: List.from(json['favourites']).map((e)=> ImageData(title: e['title'], subtitle: e['artist']?['name'], url: '', imageUrl: e['picture']?['url'])).toList()
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