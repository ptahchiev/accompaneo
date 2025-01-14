import 'package:flutter/material.dart';
import 'package:accompaneo/pages/settings_page.dart';
import 'package:accompaneo/pages/profile_page.dart';
import 'package:accompaneo/pages/playlists_page.dart';
import 'package:accompaneo/pages/home_page.dart';

NavigationBar buildAppNavigationBar(BuildContext context, int selectedIndex) {
  return NavigationBar(destinations: [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        NavigationDestination(icon: Icon(Icons.headphones), label: 'Playlists')
      ], selectedIndex: selectedIndex, onDestinationSelected: (value) {
          if (selectedIndex != value) {
            if (value == 0) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(title: 'Home')));
            }
            if (value == 1) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfilePage(title: 'Profile')));
            }
            if (value == 2) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsPage(title: 'Settings')));
            }
            if (value == 3) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PlaylistsPage(title: 'Playlists')));
            }            
          }
      });
}