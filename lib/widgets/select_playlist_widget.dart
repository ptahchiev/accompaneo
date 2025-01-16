import 'package:flutter/material.dart';
import '../utils/helpers/snackbar_helper.dart';
import '../widgets/app_text_form_field.dart';
import '../values/app_strings.dart';
import '../values/app_theme.dart';
import './new_playlist_widget.dart';

final List<String> entries = <String>['guitar', 'piano', 'wedding'];

class SelectPlaylistWidget extends StatefulWidget {

  const SelectPlaylistWidget({super.key});

  @override
  _SelectPlaylistWidgetState createState() => _SelectPlaylistWidgetState();
}

class _SelectPlaylistWidgetState extends State<SelectPlaylistWidget> {

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  void initializeControllers() {
    nameController = TextEditingController()..addListener(controllerListener);
  }

  void disposeControllers() {
    nameController.dispose();
  }

  void controllerListener() {
    final name = nameController.text;

    if (name.isEmpty) return;
  }

  @override
  void initState() {
    initializeControllers();
  }

  @override
  void dispose() {
    disposeControllers();
  }

  @override
  Widget build(BuildContext context) {

    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    return Scaffold(appBar: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Icon(Icons.drag_handle),
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: radius
      )),
      backgroundColor: Colors.transparent,    
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(AppStrings.selectPlaylist, style: AppTheme.sectionTitle,
                    ))
                  ),
                  ListTile(
                    title: Text('Create new playlist'),
                    leading: CircleAvatar(radius: 28, backgroundColor: Theme.of(context).colorScheme.primary, child: Icon(Icons.add, color: Colors.white, size: 28)),
                    onTap: () =>  {
                      

                    }
                  ),
                  Divider(),
                  ListView.builder(
                    itemCount: entries.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ListTile(
                              leading: CircleAvatar(radius: 28, backgroundColor: Theme.of(context).colorScheme.primary, child: Icon(Icons.music_note, color: Colors.white, size: 28)),
                              title: Text(entries[index]),
                              subtitle: Text('6 songs'),
                              onTap: () =>  {}
                      );
                    },
                  ),


                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}