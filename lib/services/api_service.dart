import 'dart:convert';

import 'package:accompaneo/models/homepage_sections.dart';
import 'package:accompaneo/models/music_data.dart';
import 'package:accompaneo/models/page.dart';
import 'package:accompaneo/models/playlist.dart';
import 'package:accompaneo/models/playlists.dart';
import 'package:accompaneo/models/search_page.dart';
import 'package:accompaneo/models/settings_data.dart';
import 'package:accompaneo/models/user/registration.dart';
import 'package:accompaneo/utils/helpers/navigation_helper.dart';
import 'package:accompaneo/utils/helpers/url_helpers.dart';
import 'package:accompaneo/values/app_constants.dart';
import 'package:accompaneo/values/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class ApiService {

  static const String baseUrl = AppConstants.urlEndpoint;

  static final _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> loginWithGoogle() => _googleSignIn.signIn();

  static Future<GoogleSignInAccount?> logoutWithGoogle() => _googleSignIn.signOut();

  static Future<Response> loginWithFacebook(String accessToken, String state) async {
    print('ac: $accessToken');

    final response = await http.get(UrlHelper.buildUrlWithQueryParams('$baseUrl/oauth2/callback/facebook', queryParams: {'code' : accessToken, 'state' : state}));

    var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      SettingsData settingsData = SettingsData.fromJson(jsonResponse['settings']);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', jsonResponse['token']);
      prefs.setString("settingsData", jsonEncode(jsonResponse['settings']));

      //Provider.of<PlaylistsModel>(context, listen: false).setSettingsData(settingsData);

      return response;
      //return await http.post(UrlHelper.buildUrlWithQueryParams('$baseUrl/user/login/success'), headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', AppConstants.nemesisTokenHeader : jsonResponse['token']});
    } else {
      return response;
    }
  }


  static Future<Response> login(BuildContext context, String username, String password) async {
    final response = await http.get(UrlHelper.buildUrlWithQueryParams('$baseUrl/auth'), headers: {'X-Nemesis-Username' : username, 'X-Nemesis-Password' : password});

    var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      SettingsData settingsData = SettingsData.fromJson(jsonResponse['settings']);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', jsonResponse['token']);
      prefs.setString("settingsData", jsonEncode(jsonResponse['settings']));

      Provider.of<PlaylistsModel>(context, listen: false).setSettingsData(settingsData);

      return await http.post(UrlHelper.buildUrlWithQueryParams('$baseUrl/user/login/success'), headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', AppConstants.nemesisTokenHeader : jsonResponse['token']});
    } else {
      return response;
    }
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
  }


  static Future<Response> register(Registration registration) async {
    return await http.post(UrlHelper.buildUrlWithQueryParams('$baseUrl/account/register'), headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'}, body: jsonEncode(registration.toJson()));
  }

  static Future<Response> recoverPassword(String loginEmail) async {
    return await http.post(UrlHelper.buildUrlWithQueryParams('$baseUrl/account/forgottenPassword/$loginEmail', queryParams: {'relativeUrl':"/password"}), headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'}, body: jsonEncode(<String, String>{}));
  }

  static Future<HomepageSections> getHomepageSections() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

      var url = UrlHelper.buildUrlWithQueryParams('$baseUrl/homepage');

      final response = await http.get(url, headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')!});
      if (response.statusCode == 401) {
        prefs.remove(AppConstants.nemesisTokenHeader).then((b){
          NavigationHelper.pushNamed(AppRoutes.login);
        });
        return Future.value(HomepageSections(genres: [], artists: [], latestAdded: [], latestPlayed: [], mostPopular: [], favourites: []));
      }

      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return HomepageSections.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to fetch playlists: ${response.statusCode}');
      }
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var url = UrlHelper.buildUrlWithQueryParams('$baseUrl/profile');

      final response = await http.get(url, headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')!});
      if (response.statusCode == 401) {
        prefs.remove(AppConstants.nemesisTokenHeader).then((b){
          NavigationHelper.pushNamed(AppRoutes.login);
        });
        return Future.value({});
      }

      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return jsonResponse;
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } on Exception catch (e) {
      print("Error loading audio source: $e");
      return Future.value({});
    }    
  }

  static Future<Response> updateUserProfile(Map<String, dynamic> params) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await http.post(UrlHelper.buildUrlWithQueryParams('$baseUrl/profile'), body: jsonEncode(params), headers: {'Content-Type': 'application/json; charset=UTF-8', AppConstants.nemesisTokenHeader : prefs.getString('token')!});
    if (response.statusCode == 401) {
      prefs.remove(AppConstants.nemesisTokenHeader).then((b){
        NavigationHelper.pushNamed(AppRoutes.login);
      });
      return Future.value(response);
    }
    return response;
  }

  static Future<List<Playlist>> getPlaylistsForCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = UrlHelper.buildUrlWithQueryParams('$baseUrl/playlist');

    try {
      final response = await http.get(url, headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')!});

      if (response.statusCode == 401) {
        prefs.remove(AppConstants.nemesisTokenHeader).then((b){
          NavigationHelper.pushNamed(AppRoutes.login);
        });
        return Future.value([]);
      }

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as List<dynamic>;
        return List.from(jsonResponse).map((e) => Playlist.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch playlists: ${response.statusCode}');
      }
    } on Exception catch (e) {
      print("Error loading audio source: $e");
      return Future.value([]);
    }
  }

  static Future<Response> createPlaylist(String playlistName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await http.post(UrlHelper.buildUrlWithQueryParams('$baseUrl/playlist'), body: jsonEncode(<String, String>{'name' : playlistName}), headers: {'Content-Type': 'application/json; charset=UTF-8', AppConstants.nemesisTokenHeader : prefs.getString('token')!});
    if (response.statusCode == 401) {
      prefs.remove(AppConstants.nemesisTokenHeader).then((b){
        NavigationHelper.pushNamed(AppRoutes.login);
      });
      return Future.value(response);
    }
    return response;

  }

  static Future<Response> deletePlaylist(String playlistCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await http.delete(UrlHelper.buildUrlWithQueryParams('$baseUrl/playlist/$playlistCode'), headers: {'Content-Type': 'application/json; charset=UTF-8', AppConstants.nemesisTokenHeader : prefs.getString('token')!});
    if (response.statusCode == 401) {
      prefs.remove(AppConstants.nemesisTokenHeader).then((b){
        NavigationHelper.pushNamed(AppRoutes.login);
      });
    }

    return response;
  }  


  static Future<PageDto> getPlaylistByUrl(String playlistUrl, {String query = '', int page = 0, size = 50}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = UrlHelper.buildUrlWithQueryParams('$baseUrl/playlist$playlistUrl');

    final response = await http.get(url, headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')!});
    if (response.statusCode == 401) {
      prefs.remove(AppConstants.nemesisTokenHeader).then((b){
        NavigationHelper.pushNamed(AppRoutes.login);
      });
      return Future.value(PageDto(totalPages: 0, totalElements: 0, size: 0, number: 0, first: false, last: false, content: []));
    }

    var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return PageDto.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to fetch playlist: ${response.statusCode}');
    }
  }

  static Future<Response> addSongToPlaylist(String songCode, String playlistCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await http.post(UrlHelper.buildUrlWithQueryParams('$baseUrl/playlist/$playlistCode/add/$songCode'), headers: {'Content-Type': 'application/json; charset=UTF-8', AppConstants.nemesisTokenHeader : prefs.getString('token')!});
    if (response.statusCode == 401) {
      prefs.remove(AppConstants.nemesisTokenHeader).then((b){
        NavigationHelper.pushNamed(AppRoutes.login);
      });
    }
    return response;
  }  

  static Future<Response> removeSongFromPlaylist(String songCode, String playlistCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await http.post(UrlHelper.buildUrlWithQueryParams('$baseUrl/playlist/$playlistCode/remove/$songCode'), headers: {'Content-Type': 'application/json; charset=UTF-8', AppConstants.nemesisTokenHeader : prefs.getString('token')!});
    if (response.statusCode == 401) {
      prefs.remove(AppConstants.nemesisTokenHeader).then((b){
        NavigationHelper.pushNamed(AppRoutes.login);
      });
    }
    return response;    
  }

  static Future<Response> addSongToFavouritesPlaylist(String songCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await http.post(UrlHelper.buildUrlWithQueryParams('$baseUrl/playlist/favourites/add/$songCode'), headers: {'Content-Type': 'application/json; charset=UTF-8', AppConstants.nemesisTokenHeader : prefs.getString('token')!});
    if (response.statusCode == 401) {      prefs.remove(AppConstants.nemesisTokenHeader).then((b){
        NavigationHelper.pushNamed(AppRoutes.login);
      });
    }
    return response;
  }  

  static Future<Response> removeSongFromFavouritesPlaylist(String songCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await http.post(UrlHelper.buildUrlWithQueryParams('$baseUrl/playlist/favourites/remove/$songCode'), headers: {'Content-Type': 'application/json; charset=UTF-8', AppConstants.nemesisTokenHeader : prefs.getString('token')!});
    if (response.statusCode == 401) {
      prefs.remove(AppConstants.nemesisTokenHeader).then((b){
        NavigationHelper.pushNamed(AppRoutes.login);
      });
    }
    return response;
  }

  static Future<Response> markSongAsPlayed(String songCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await http.post(UrlHelper.buildUrlWithQueryParams('$baseUrl/song/$songCode/play'), headers: {'Content-Type': 'application/json; charset=UTF-8', AppConstants.nemesisTokenHeader : prefs.getString('token')!});
    if (response.statusCode == 401) {
      prefs.remove(AppConstants.nemesisTokenHeader).then((b){
        NavigationHelper.pushNamed(AppRoutes.login);
      });
    }
    return response;
  }

  static Future<SearchPage> search({int page = 0, int size = 24, String sort = '_score,DESC', String? queryTerm = '', String queryName = 'default'}) async {
    
    //await Future.delayed(const Duration(seconds: 2));
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = UrlHelper.buildUrlWithQueryParams('$baseUrl/search', queryParams: {'size': size.toString(), 'page': page.toString(), 'q': queryTerm ?? '', 'sort': sort, 'projection': 'io.accompaneo.backend.module.search.dto.SongFacetSearchPageDtoDefinition', 'queryName': queryName, 'type' : 'song'});

    final response = await http.get(url, headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')!});
    if (response.statusCode == 401) {
      prefs.remove(AppConstants.nemesisTokenHeader).then((b){
        NavigationHelper.pushNamed(AppRoutes.login);
      });
      return Future.value(SearchPage(totalPages: 0, totalElements: 0, size: 0, number: 0, first: false, last: false, content:[]));
    }
    var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return SearchPage.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to fetch playlist: ${response.statusCode}');
    }
  }

  static Future<MusicData> getSongStructure(String? structureUrl) async {
    Response response = await http.get(UrlHelper.buildUrlWithQueryParams(structureUrl!));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      return MusicData.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to fetch playlist: ${response.statusCode}');
    }
  }

  static Future<SettingsData> getSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await http.get(UrlHelper.buildUrlWithQueryParams('$baseUrl/settings'), headers: {AppConstants.nemesisTokenHeader : prefs.getString('token')!});
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      return SettingsData.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to fetch playlist: ${response.statusCode}');
    }
  }

  static Future<Response> updateSettings(SettingsData settingsData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("settingsData", jsonEncode(settingsData.toJson()));

    Response response = await http.post(UrlHelper.buildUrlWithQueryParams('$baseUrl/settings'), headers: {'Content-Type': 'application/json; charset=UTF-8', AppConstants.nemesisTokenHeader : prefs.getString('token')!}, body: jsonEncode(settingsData.toJson()));
    if (response.statusCode == 401) {
      prefs.remove(AppConstants.nemesisTokenHeader).then((b){
        NavigationHelper.pushNamed(AppRoutes.login);
      });
    }
    return response;
  }

}