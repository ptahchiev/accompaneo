import 'package:accompaneo/models/playlist.dart';
import 'package:accompaneo/models/settings_data.dart';
import 'package:accompaneo/utils/fixed_size_fifo_queue.dart';
import 'package:collection/collection.dart';
import 'package:accompaneo/models/song/song.dart';
import 'package:flutter/material.dart';

class PlaylistsModel extends ChangeNotifier {

  final FixedSizeFIFOQueue<Song> latestPlayed = FixedSizeFIFOQueue(capacity: 50);

  final List<Playlist> _playlists = [];

  Locale locale = Locale('en');

  SettingsData? _settingsData;

  UnmodifiableListView<Playlist> get items => UnmodifiableListView(_playlists);

  Playlist? getFavouritesPlaylist() {
    return _playlists.firstWhereOrNull((p) => p.favourites);
  }

  List<Song> getLatestPlayedPlaylistSongs() {
    return latestPlayed.queue.toList();
  }

  ThemeMode getThemeMode() {
    return _settingsData != null ? ThemeMode.values.firstWhere((tm) => tm.name == _settingsData!.themeMode.toLowerCase()) : ThemeMode.light;
  }

  SettingsData getSettings() {
    return _settingsData ?? SettingsData.empty();
  }

  void setSettingsData(SettingsData settingsData) {
    _settingsData = settingsData;
    notifyListeners();
  }

  void add(Playlist item) {
    _playlists.add(item);
    notifyListeners();
  }

  void addAll(List<Playlist> items) {
    for (Playlist item in items ) {
      if (item.latestPlayed) {
        latestPlayed.enqueueAll(item.firstPageSongs.content);
      } else {
        if (!_playlists.any((pi) => pi.code == item.code)) {
          _playlists.add(item);
        }
      }
    }

    notifyListeners();
  }

  void addSongToPlaylist(String playlistCode, Song song) {
    Playlist? playlist = _playlists.firstWhereOrNull((p) => p.code == playlistCode);
    if (playlist != null) {
      // playlist.firstPageSongs.content.add(song);
      playlist.firstPageSongs.totalElements = playlist.firstPageSongs.totalElements + 1;
      notifyListeners();
    }
  }

  void removeSongFromPlaylist(String playlistCode, Song song) {
    Playlist? playlist = _playlists.firstWhereOrNull((p) => p.code == playlistCode);
    if (playlist != null) {
      // playlist.firstPageSongs.content.remove(song);
      playlist.firstPageSongs.totalElements = playlist.firstPageSongs.totalElements - 1;
      notifyListeners();
    }
  }

  void addSongToLatestPlayed(Song song) {
    latestPlayed.enqueue(song);
    notifyListeners();
  }

  void addSongToFavourites(Song song) {
    Playlist? playlist = _playlists.firstWhereOrNull((p) => p.favourites);
    if (playlist != null) {
      playlist.firstPageSongs.content.insert(0, song);
      playlist.firstPageSongs.totalElements = playlist.firstPageSongs.totalElements + 1;
      notifyListeners();
    }
  }

  void removeSongFromFavourites(Song song) {
    Playlist? playlist = _playlists.firstWhereOrNull((p) => p.favourites);
    if (playlist != null) {
      playlist.firstPageSongs.content.remove(song);
      playlist.firstPageSongs.totalElements = playlist.firstPageSongs.totalElements - 1;
      notifyListeners();
    }
  }

  void removePlaylist(String playlistCode) {
    _playlists.removeWhere((p) => p.code == playlistCode);
    notifyListeners();
  }

  void removeAll() {
    _playlists.clear();
    notifyListeners();
  }
}