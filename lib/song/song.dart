import 'package:flutter/material.dart';

class Song {
  String image;
  String name;
  String artist;
  int bpm;
  bool favourite;

  // Constructor
  Song({
    required this.image,
    required this.name,
    required this.artist,
    required this.bpm,
    required this.favourite
  });

  Song copy({
    String? imagePath,
    String? name,
    String? artist,
    int? bpm,
    bool? favourite
  }) =>
      Song(
        image: imagePath ?? this.image,
        name: name ?? this.name,
        artist: artist ?? this.artist,
        bpm: bpm ?? this.bpm,
        favourite: favourite ?? this.favourite
      );

  static Song fromJson(Map<String, dynamic> json) => Song(
        image: json['imagePath'],
        name: json['name'],
        artist: json['artist'],
        bpm: json['bpm'],
        favourite: json['favourite']
      );

  Map<String, dynamic> toJson() => {
        'imagePath': image,
        'name': name,
        'artist': artist,
        'bpm': bpm,
        'favourite': favourite
      };
}