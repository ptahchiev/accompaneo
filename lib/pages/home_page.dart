import 'package:accompaneo/widgets/app_navigationbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:accompaneo/widgets/section_widget.dart';
import 'playlist_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset:false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistPage(songs:[])));
            },
          )],
      ),
      body:  ListView(children: [
        const Section(title: 'Genres', viewAll: false),
        const Section(title: 'Artists', viewAll: false),
        const Section(title: 'Latest', viewAll: true),
        const Section(title: 'Jump back in', viewAll: true),
        const Section(title: 'Most Popular', viewAll: true),
        const Section(title: 'Your favourites', viewAll: true)
      ]),
      //bottomNavigationBar: buildAppNavigationBar(context, 0)
    );
  }
}