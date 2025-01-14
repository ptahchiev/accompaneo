import 'package:flutter/material.dart';
import 'package:accompaneo/widgets/section_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:  Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Section(title: 'Jump back in', viewAll: false),
            const Section(title: 'Most Popular', viewAll: false),
            const Section(title: 'Your favourites', viewAll: false),
          ],
        )
    );
  }
}