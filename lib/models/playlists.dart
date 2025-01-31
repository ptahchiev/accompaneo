import 'package:accompaneo/models/simple_playlist.dart';
import 'package:collection/collection.dart';
import 'package:accompaneo/models/song/song.dart';
import 'package:flutter/material.dart';

class PlaylistsModel extends ChangeNotifier {

  final List<SimplePlaylist> _playlists = [];

  UnmodifiableListView<SimplePlaylist> get items => UnmodifiableListView(_playlists);

  void add(SimplePlaylist item) {
    _playlists.add(item);
    notifyListeners();
  }

  void addAll(List<SimplePlaylist> items) {
    for (SimplePlaylist item in items ) {
      if (!_playlists.any((pi) => pi.code == item.code)) {
        _playlists.add(item);
      }
    }

    notifyListeners();
  }

  void addSongToPlaylist(String playlistCode, Song song) {
    SimplePlaylist? playlist = _playlists.firstWhereOrNull((p) => p.code == playlistCode);
    if (playlist != null) {
      // playlist.firstPageSongs.content.add(song);
      playlist.totalSongs = playlist.totalSongs + 1;
      notifyListeners();
    }
  }

  void removeSongFromPlaylist(String playlistCode, Song song) {
    SimplePlaylist? playlist = _playlists.firstWhereOrNull((p) => p.code == playlistCode);
    if (playlist != null) {
      // playlist.firstPageSongs.content.remove(song);
      playlist.totalSongs = playlist.totalSongs - 1;
      notifyListeners();
    }
  }

  void addSongToFavourites(Song song) {
    SimplePlaylist? playlist = _playlists.firstWhereOrNull((p) => p.favourites);
    if (playlist != null) {
      // playlist.firstPageSongs.content.add(song);
      playlist.totalSongs = playlist.totalSongs + 1;
      notifyListeners();
    }
  }

  void removeSongFromFavourites(Song song) {
    SimplePlaylist? playlist = _playlists.firstWhereOrNull((p) => p.favourites);
    if (playlist != null) {
      // playlist.firstPageSongs.content.remove(song);
      playlist.totalSongs = playlist.totalSongs - 1;
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