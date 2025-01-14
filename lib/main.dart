import 'package:accompaneo/pages/playlists_page.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const AccompaneoApp());
}

class AccompaneoApp extends StatelessWidget {
  const AccompaneoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accompaneo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const PlaylistsPage(title: 'Accompaneo'),
    );
  }
}