import 'package:accompaneo/models/playlist.dart';
import 'package:accompaneo/models/playlists.dart';
import 'package:accompaneo/models/simple_playlist.dart';
import 'package:accompaneo/models/song/song.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:accompaneo/utils/helpers/snackbar_helper.dart';
import 'package:accompaneo/widgets/browsable_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../values/app_strings.dart';
import '../values/app_theme.dart';

class SelectPlaylistWidget extends StatefulWidget {

  final Function addSongToPlaylist;

  final Song song;

  const SelectPlaylistWidget({super.key, required this.addSongToPlaylist, required this.song});

  @override
  _SelectPlaylistWidgetState createState() => _SelectPlaylistWidgetState();
}

class _SelectPlaylistWidgetState extends State<SelectPlaylistWidget> {

  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                    visualDensity: VisualDensity(vertical: 0),
                    title: Text('Create new playlist'),
                    leading: BrowsableImage(icon: Icons.add),
                    onTap: () =>  {
                      

                    }
                  ),
                  Divider(),

                  Consumer<PlaylistsModel>(
                    builder: (context, playlists, child) {
                        return ListView.builder(
                          itemCount: playlists.items.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (playlists.items[index].latestPlayed) {
                                return Container();
                            }
                            return ListTile(
                                    visualDensity: VisualDensity(vertical: 0),
                                    leading: BrowsableImage(icon: playlists.items[index].favourites ? Icons.favorite : Icons.music_note, backgroundColor: playlists.items[index].favourites ? Colors.red : Theme.of(context).colorScheme.primary),
                                    title: Text(playlists.items[index].name),
                                    subtitle: Text('${playlists.items[index].firstPageSongs.totalElements} songs'),
                                    onTap: ()  {
                                        final result = ApiService.addSongToPlaylist(widget.song.code, playlists.items[index].code);
                                        result.then((response) {
                                          if (response.statusCode == 200) {
                                            widget.addSongToPlaylist();
                                            Provider.of<PlaylistsModel>(context, listen: false).addSongToPlaylist(playlists.items[index].code, widget.song);
                                            SnackbarHelper.showSnackBar('Song was added to playlist');
                                          } else {
                                            if (response.data != null && response.data['message'] != null) {
                                              SnackbarHelper.showSnackBar(response.data['message'], isError: true);
                                            } else {
                                              SnackbarHelper.showSnackBar('Failed to fetch post: ${response.statusCode}', isError: true);
                                            }
                                          }
                                        });                                        
                                    }
                            );
                          },
                        );
                    }
                  )
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}