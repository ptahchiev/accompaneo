import 'package:accompaneo/models/homepage_sections.dart';
import 'package:accompaneo/models/playlist.dart';
import 'package:accompaneo/models/user/registration.dart';
import 'package:accompaneo/values/app_constants.dart';
import 'package:dio/dio.dart';

class ApiService {

  static const String baseUrl = AppConstants.urlEndpoint;

  static Future<Response> register(Registration registration) async {
    final dio = Dio();
    return await dio.post('$baseUrl/account/register', data: registration.toJson());
  }

  static Future<Response> recoverPassword(String loginEmail) async {
    final dio = Dio();
    return await dio.post('$baseUrl/account/forgottenPassword/$loginEmail?relativeUrl=/password', data: {});
  }


  static Future<HomepageSections> getHomepageSections() async {
    final dio = Dio();
    final response = await dio.get('$baseUrl/homepage');

    if (response.statusCode == 200) {
      return HomepageSections.fromJson(response.data);
    } else {
      throw Exception('Failed to fetch playlists: ${response.statusCode}');
    }

  }


  static Future<List<Playlist>> getPlaylistsForCurrentUser() async {
    final dio = Dio();
    final response = await dio.get('$baseUrl/playlist');

    if (response.statusCode == 200) {
      return List.from(response.data).map((e) => Playlist.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch playlists: ${response.statusCode}');
    }

  }

  static Future<Response> createPlaylist(String playlistName) async {
    final dio = Dio();
    return await dio.post('$baseUrl/playlist', data: {'name' : playlistName});
  }


  static Future<Playlist> getPlaylistByUrl(String playlistUrl) async {
    final dio = Dio();
    final response = await dio.get('$baseUrl/playlist$playlistUrl', queryParameters: {'size' : 500});

    if (response.statusCode == 200) {
      return Playlist.fromJson(response.data);
    } else {
      throw Exception('Failed to fetch playlist: ${response.statusCode}');
    }
  }

  // static Future<Post> authenticate(int postId) async {
  //   final dio = Dio();
  //   final response = await dio.get('$baseUrl/posts/$postId');
  //   if (response.statusCode == 200) {
  //     return Post.fromJson(response.data);
  //   } else {
  //     throw Exception('Failed to fetch post: ${response.statusCode}');
  //   }
  // }
}