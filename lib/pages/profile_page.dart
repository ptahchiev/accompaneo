import 'dart:async';

import 'package:accompaneo/widgets/app_navigationbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:accompaneo/pages/edit_description.dart';
import 'package:accompaneo/pages/edit_email.dart';
import 'package:accompaneo/pages/edit_image.dart';
import 'package:accompaneo/pages/edit_name.dart';
import 'package:accompaneo/pages/edit_phone.dart';
import '../user/user.dart';
import '../widgets/display_image_widget.dart';
import '../user/user_data.dart';

// This class handles the Page to dispaly the user's info on the "Edit Profile" Screen
class ProfilePage extends StatefulWidget {

  final String title;

  const ProfilePage({super.key, required this.title});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final user = UserData.myUser;

    return Scaffold(
      resizeToAvoidBottomInset:false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: buildUserInfoDisplay(),
    );
  
  }

  // Widget builds the display item with the proper formatting to display the user's info
  Widget buildUserInfoDisplay() =>
      Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Text(
              'Profile',
              style: Theme.of(context).textTheme.headlineSmall,
            )),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                child: TextFormField(decoration: InputDecoration(border: UnderlineInputBorder(), labelText: 'Email'))
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                child: TextFormField(
                  decoration: InputDecoration(border: UnderlineInputBorder(), labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  })
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                child: TextFormField(decoration: InputDecoration(border: UnderlineInputBorder(), labelText: 'Password'), obscureText: true, enableSuggestions: false, autocorrect: false)
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                child: TextFormField(decoration: InputDecoration(border: UnderlineInputBorder(), labelText: 'Server'))
            ),                                       
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
                minimumSize: const Size(200, 50),
              ),
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ]
    );

  // Refrshes the Page after updating user info.
  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  // Handles navigation and prompts refresh.
  void navigateSecondPage(Widget editForm) {
    Route route = MaterialPageRoute(builder: (context) => editForm);
    Navigator.push(context, route).then(onGoBack);
  }
}