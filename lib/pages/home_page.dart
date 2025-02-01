import 'package:accompaneo/models/homepage_sections.dart';
import 'package:accompaneo/models/playlists.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:accompaneo/widgets/placeholders.dart';
import 'package:flutter/material.dart';
import 'package:accompaneo/widgets/section_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late Future<HomepageSections> futureHomepageSections;

  @override
  void initState() {
    super.initState();
    futureHomepageSections = ApiService.getHomepageSections();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:false,
      body: FutureBuilder<HomepageSections>(
        future: futureHomepageSections,
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return Consumer<PlaylistsModel>(
              builder: (context, playlists, child) {
                return ListView(children: [
                  Section(title: 'Genres', sectionData: snapshot.data?.genres, playlistUrl: null),
                  Section(title: 'Artists', sectionData: snapshot.data?.artists, playlistUrl: null),
                  Section(title: 'Latest', sectionData: snapshot.data?.latestAdded, playlistUrl: '/latestAdded'),
                  Section(title: 'Jump back in', sectionData: snapshot.data?.latestPlayed, playlistUrl: '/latestPlayed'),
                  Consumer<PlaylistsModel>(
                      builder: (context, playlists, child) {
                        return Section(title: 'Most Popular', sectionData: playlists.getMostPopularPlaylist().firstPageSongs.content, playlistUrl: '/mostPopular');
                      }
                  ),
                  Consumer<PlaylistsModel>(
                      builder: (context, playlists, child) {
                        return Section(title: 'Your favourites', sectionData: playlists.getMostPopularPlaylist().firstPageSongs.content, playlistUrl: '/favourites');
                      }
                  )
                ]);
              }
            );
          } else if (snapshot.hasError) {
            return Text('ERROR ${snapshot.error}');
          }
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            loop: 0,
            enabled: true,
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                children: [ 
                  HomepageSectionsSectionPlaceholder(),
                  HomepageSectionsSectionPlaceholder(),
                  HomepageSectionsSectionPlaceholder(),
                  HomepageSectionsSectionPlaceholder(),
                  HomepageSectionsSectionPlaceholder(),
                ]
              )
            )
          );
        }
      )));
  }
}