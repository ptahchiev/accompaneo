import 'package:accompaneo/models/homepage_sections.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:accompaneo/widgets/section_widget.dart';

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
            return ListView(children: [
                  Section(title: 'Genres', sectionData: snapshot.data?.genres, playlistUrl: null),
                  Section(title: 'Artists', sectionData: snapshot.data?.artists, playlistUrl: null),
                  Section(title: 'Latest', sectionData: snapshot.data?.latestAdded, playlistUrl: '/latestAdded'),
                  Section(title: 'Jump back in', sectionData: snapshot.data?.latestPlayed, playlistUrl: '/latestPlayed'),
                  Section(title: 'Most Popular', sectionData: snapshot.data?.mostPopular, playlistUrl: '/mostPopular'),
                  Section(title: 'Your favourites', sectionData: snapshot.data?.favourites, playlistUrl: '/favourites')
                ]);
          } else if (snapshot.hasError) {
            return Text('ERROR ${snapshot.error}');
          }

          return const CircularProgressIndicator();
        }
      )));
  }
}