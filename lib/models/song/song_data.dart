import 'dart:convert';

import 'package:accompaneo/models/artist.dart';

import 'song.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongData {
  static late SharedPreferences _preferences;
  static const _keySong = 'song';

  static Song mySong = Song(
    image:
        "https://upload.wikimedia.org/wikipedia/en/0/0b/Darth_Vader_in_The_Empire_Strikes_Back.jpg",
    title: 'Test Test',
    artist: Artist(code: 'code', name: 'test.test@gmail.com'),
    bpm: 120,
    favourite: true
  );

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setUser(Song user) async {
    final json = jsonEncode(user.toJson());

    await _preferences.setString(_keySong, json);
  }

  static Song getUser() {
    final json = _preferences.getString(_keySong);

    return json == null ? mySong : Song.fromJson(jsonDecode(json));
  }
}