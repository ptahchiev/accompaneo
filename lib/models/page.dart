import 'package:accompaneo/models/song/song.dart';

class Page {

  int totalPages;

  int totalElements;

  int size;

  int number;

  List<Song> content;

  // Constructor
  Page({
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
    required this.content
  });

  Page copy({
    int? totalPages,
    int? totalElements,
    int? size,
    int? number,
    List<Song>? content
  }) =>
      Page(
        totalPages: totalPages ?? this.totalPages,
        totalElements: totalElements ?? this.totalElements,
        size: size ?? this.size,
        number: number ?? this.number,
        content: content ?? this.content
      );

  static Page fromJson(Map<String, dynamic> json) => Page(
        totalPages: json['totalPages'] ?? 0,
        totalElements: json['totalElements'] ?? 0,
        size: json['size'] ?? 0,
        number: json['number'] ?? 0,
        content: (json['content'] as List).map((e) => Song.fromJson(e)).toList()
      );

  Map<String, dynamic> toJson() => {
        'totalPages': totalPages,
        'totalElements': totalElements,
        'size': size,
        'number': number,
        'content': content
      };
}