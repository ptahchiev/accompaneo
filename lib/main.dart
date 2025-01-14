import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/playlists_page.dart';
import 'pages/playlist_page.dart';

void main() {
  runApp(Accompaneo());
}

class _AccompaneoState extends State<AccompaneoApp> {

  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(title: 'Home'),
    ProfilePage(title: 'Profile'),
    SettingsPage(title: 'Settings'),
    PlaylistsPage(title: 'Playlists')
  ];


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return 
        Scaffold(
          appBar: AppBar(
            title: const Text('Accompaneo'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistPage(songs:[])));
                },
              )],
          ),
          
          body: IndexedStack(index: _selectedIndex,children: _pages),
          bottomNavigationBar: 
          NavigationBar(
            elevation: 0,
            selectedIndex: _selectedIndex,
            //iconSize: 20,
            // selectedFontSize: 20,
            // selectedIconTheme: IconThemeData(color: Colors.amberAccent, size: 40),
            // selectedItemColor: Colors.red,
            // selectedItemColor: Colors.amberAccent,
            // selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            // showSelectedLabels: false,
            // showUnselectedLabels: false,
            //type: BottomNavigationBarType.fixed,
            //backgroundColor: Colors.white,
            onDestinationSelected: _onItemTapped,
            animationDuration: Duration(milliseconds: 400),
            destinations: <NavigationDestination>[
              NavigationDestination(
                icon: Container(padding: EdgeInsets.symmetric(vertical: 10),child: Icon(Icons.home)),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
              NavigationDestination(
                icon: Icon(Icons.headphones),
                label: 'Playlists',
              )
            ],
          ));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class Accompaneo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accompaneo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: AccompaneoApp()
    );
  }
}


class AccompaneoApp extends StatefulWidget {

  @override
  State<AccompaneoApp> createState() => _AccompaneoState();

  const AccompaneoApp({super.key});
}