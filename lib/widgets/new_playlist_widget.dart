import 'package:flutter/material.dart';

final _formKey = GlobalKey<FormState>();

Widget buildNewPlaylistWidget(BuildContext context, int selectedIndex) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    return Scaffold(appBar: AppBar(
      backgroundColor: Colors.white,
      title: Icon(Icons.drag_handle),
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: radius
      )),
      backgroundColor: Colors.transparent,
      body:   ClipRRect(
      borderRadius: radius, child: Form(
                      key: _formKey,
                      
                      child: Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                            'New playlist',
                            style: Theme.of(context).textTheme.headlineSmall,
                          )),
                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                              child: TextField(decoration: InputDecoration(border: UnderlineInputBorder(), labelText: 'Enter playlist name'))
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
                        ],
                      ),
                  ))
      );
}