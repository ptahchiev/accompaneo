import 'package:accompaneo/models/homepage_sections.dart';
import 'package:accompaneo/models/playlist.dart';
import 'package:accompaneo/models/simple_playlist.dart';
import 'package:accompaneo/models/user/registration.dart';
import 'package:accompaneo/values/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static const String baseUrl = AppConstants.urlEndpoint;


  static Future<Response> login(String username, String password) async {
    try {
      final dio = Dio();
      final response = await dio.get('$baseUrl/auth', options: Options(headers: {'X-Nemesis-Username' : username, 'X-Nemesis-Password' : password}));
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', response.data['token']);

        return await dio.post('$baseUrl/user/login/success');
      } else {
        throw Exception('Failed to fetch playlists: ${response.statusCode}');
      }
    } on DioException catch (e) {
        return Future.value(e.response);
    }
  }

  static Future<Response> register(Registration registration) async {
    try {
      final dio = Dio();
      return await dio.post('$baseUrl/account/register', data: registration.toJson());
    } on DioException catch (e) {
        return Future.value(e.response);
    }
  }

  static Future<Response> recoverPassword(String loginEmail) async {
    final dio = Dio();
    return await dio.post('$baseUrl/account/forgottenPassword/$loginEmail?relativeUrl=/password', data: {});
  }


  static Future<HomepageSections> getHomepageSections() async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await dio.get('$baseUrl/homepage', options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));

    if (response.statusCode == 200) {
      return HomepageSections.fromJson(response.data);
    } else {
      throw Exception('Failed to fetch playlists: ${response.statusCode}');
    }

  }


  static Future<List<SimplePlaylist>> getPlaylistsForCurrentUser() async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await dio.get('$baseUrl/playlist', options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));

    if (response.statusCode == 200) {
      return List.from(response.data).map((e) => SimplePlaylist.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch playlists: ${response.statusCode}');
    }

  }

  static Future<Response> createPlaylist(String playlistName) async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await dio.post('$baseUrl/playlist', data: {'name' : playlistName}, options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));
  }

  static Future<Response> deletePlaylist(String playlistCode) async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await dio.delete('$baseUrl/playlist/$playlistCode', options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));
  }  


  static Future<Playlist> getPlaylistByUrl(String playlistUrl) async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await dio.get('$baseUrl/playlist$playlistUrl', queryParameters: {'size' : 50}, options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));

    if (response.statusCode == 200) {
      return Playlist.fromJson(response.data);
    } else {
      throw Exception('Failed to fetch playlist: ${response.statusCode}');
    }
  }

  static Future<Response> addSongToPlaylist(String songCode, String playlistCode) async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await dio.post('$baseUrl/playlist/$playlistCode/add/$songCode', options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));
  }  

  static Future<Response> removeSongFromPlaylist(String songCode, String playlistCode) async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await dio.post('$baseUrl/playlist/$playlistCode/remove/$songCode', options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));
  }

  static Future<Response> addSongToFavouritesPlaylist(String songCode) async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await dio.post('$baseUrl/playlist/favourites/add/$songCode', options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));
  }  

  static Future<Response> removeSongFromFavouritesPlaylist(String songCode) async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await dio.post('$baseUrl/playlist/favourites/remove/$songCode', options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));
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