import 'package:accompaneo/models/homepage_sections.dart';
import 'package:accompaneo/models/page.dart';
import 'package:accompaneo/models/playlist.dart';
import 'package:accompaneo/models/search_page.dart';
import 'package:accompaneo/models/user/registration.dart';
import 'package:accompaneo/utils/helpers/navigation_helper.dart';
import 'package:accompaneo/values/app_constants.dart';
import 'package:accompaneo/values/app_routes.dart';
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

    try {
      final response = await dio.get('$baseUrl/homepage', options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));

      if (response.statusCode == 200) {
        return HomepageSections.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch playlists: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        prefs.remove(AppConstants.nemesisTokenHeader).then((b){
          NavigationHelper.pushNamed(AppRoutes.login);
        });
      }
      return Future.value(HomepageSections(artists: [], favourites: [], genres: [], latestAdded: [], latestPlayed: [], mostPopular: []));
    }
  }

  static Future<List<Playlist>> getPlaylistsForCurrentUser() async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await dio.get('$baseUrl/playlist', options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));

    try {
        if (response.statusCode == 200) {
          return List.from(response.data).map((e) => Playlist.fromJson(e)).toList();
        } else {
          throw Exception('Failed to fetch playlists: ${response.statusCode}');
        }
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        prefs.remove(AppConstants.nemesisTokenHeader).then((b){
          NavigationHelper.pushNamed(AppRoutes.login);
        });
      }
      return Future.value([]);
    }
  }

  static Future<Response> createPlaylist(String playlistName) async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      return await dio.post('$baseUrl/playlist', data: {'name' : playlistName}, options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        prefs.remove(AppConstants.nemesisTokenHeader).then((b){
          NavigationHelper.pushNamed(AppRoutes.login);
        });
      }
      return Future.value(e.response);
    }      
  }

  static Future<Response> deletePlaylist(String playlistCode) async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      return await dio.delete('$baseUrl/playlist/$playlistCode', options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        prefs.remove(AppConstants.nemesisTokenHeader).then((b){
          NavigationHelper.pushNamed(AppRoutes.login);
        });
      }
      return Future.value(e.response);
    }    
  }  


  static Future<PageDto> getPlaylistByUrl(String playlistUrl, {String query = '', int page = 0, size = 50}) async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await dio.get('$baseUrl/playlist$playlistUrl', queryParameters: {'query' : query, 'size' : size, 'page': page}, options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));

      if (response.statusCode == 200) {
        return PageDto.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch playlist: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        prefs.remove(AppConstants.nemesisTokenHeader).then((b){
          NavigationHelper.pushNamed(AppRoutes.login);
        });
      }
      return Future.value(PageDto(totalPages: 0, totalElements: 0, size: 0, number: 0, content: []));
    }
  }

  static Future<Response> addSongToPlaylist(String songCode, String playlistCode) async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      return await dio.post('$baseUrl/playlist/$playlistCode/add/$songCode', options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        prefs.remove(AppConstants.nemesisTokenHeader).then((b){
          NavigationHelper.pushNamed(AppRoutes.login);
        });
      }
      return Future.value(e.response);
    }
  }  

  static Future<Response> removeSongFromPlaylist(String songCode, String playlistCode) async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      return await dio.post('$baseUrl/playlist/$playlistCode/remove/$songCode', options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        prefs.remove(AppConstants.nemesisTokenHeader).then((b){
          NavigationHelper.pushNamed(AppRoutes.login);
        });
      }
      return Future.value(e.response);
    }      
  }

  static Future<Response> addSongToFavouritesPlaylist(String songCode) async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      return await dio.post('$baseUrl/playlist/favourites/add/$songCode', options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));

    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        prefs.remove(AppConstants.nemesisTokenHeader).then((b){
          NavigationHelper.pushNamed(AppRoutes.login);
        });
      }
      return Future.value(e.response);
    }
  }  

  static Future<Response> removeSongFromFavouritesPlaylist(String songCode) async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      return await dio.post('$baseUrl/playlist/favourites/remove/$songCode', options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        prefs.remove(AppConstants.nemesisTokenHeader).then((b){
          NavigationHelper.pushNamed(AppRoutes.login);
        });
      }
      return Future.value(e.response);
    }
  }

  static Future<Response> markSongAsPlayed(String songCode) async {
    final dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      return await dio.post('$baseUrl/song/$songCode/play', options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        prefs.remove(AppConstants.nemesisTokenHeader).then((b){
          NavigationHelper.pushNamed(AppRoutes.login);
        });
      }
      return Future.value(e.response);
    }
  }

  static Future<SearchPage> search({int page = 0, int size = 50, String sort = '_score,DESC', String queryTerm = '', String queryName = 'default'}) async {
    final dio = Dio();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await dio.get('$baseUrl/search', 
        queryParameters: {
          'size' : size, 
          'page': page,
          'q' : queryTerm,
          'sort': sort,
          'projection': 'io.accompaneo.backend.module.search.dto.SongFacetSearchPageDtoDefinition',
          'queryName': queryName,
          'type': 'song'
        }, 
        options: Options(headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')}));

      if (response.statusCode == 200) {
        return SearchPage.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch playlist: ${response.statusCode}');
      }


    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        prefs.remove(AppConstants.nemesisTokenHeader).then((b){
          NavigationHelper.pushNamed(AppRoutes.login);
        });
      }
      return Future.value(SearchPage(totalPages: 0, totalElements: 0, size: 0, number: 0, content:[]));
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