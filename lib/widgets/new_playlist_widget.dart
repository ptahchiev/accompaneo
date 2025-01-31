import 'package:accompaneo/models/playlist.dart';
import 'package:accompaneo/models/playlists.dart';
import 'package:accompaneo/models/simple_playlist.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../utils/helpers/snackbar_helper.dart';
import '../widgets/app_text_form_field.dart';
import '../values/app_strings.dart';
import '../values/app_theme.dart';


class NewPlaylistWidget extends StatefulWidget {

  final PanelController panelController;

  const NewPlaylistWidget({super.key, required this.panelController});

  @override
  _NewPlaylistWidgetState createState() => _NewPlaylistWidgetState();
}

class _NewPlaylistWidgetState extends State<NewPlaylistWidget> {

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
    fieldValidNotifier.value = name.length >= 4;
  }

  @override
  void initState() {
    initializeControllers();
    super.initState();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

    @override
    Widget build(BuildContext context) {

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
                        child: Text(AppStrings.newPlaylist, style: AppTheme.sectionTitle,
                      ))
                    ),
                    AppTextFormField(
                      autofocus: true,
                      labelText: AppStrings.playlistName,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      onChanged: (value) => _formKey.currentState?.validate(),
                      validator: (value) {
                        return value!.isEmpty
                            ? AppStrings.pleaseEnterPlaylistName
                            : value.length < 4
                                ? AppStrings.invalidPlaylistName
                                : null;
                      },
                      controller: nameController,
                    ),
                    ValueListenableBuilder(
                      valueListenable: fieldValidNotifier,
                      builder: (_, isValid, __) {
                        return FilledButton(
                          onPressed: isValid
                              ? () {
                                  final result = ApiService.createPlaylist(nameController.text);
                                  result.then((response) {
                                    if (response.statusCode == 200) {
                                      Provider.of<PlaylistsModel>(context, listen: false).add(SimplePlaylist.fromJson(response.data));
                                      SnackbarHelper.showSnackBar(
                                        AppStrings.playlistCreated,
                                      );
                                      
                                      nameController.clear();
                                      widget.panelController.close();
                                    } else {
                                      SnackbarHelper.showSnackBar('Failed to create a playlist: ${response.statusCode}', isError: true);
                                    }
                                  });                                  
                                }
                              : null,
                          child: const Text(AppStrings.submit),
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