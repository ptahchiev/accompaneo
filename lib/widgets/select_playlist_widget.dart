import 'dart:convert' as convert;
import 'package:accompaneo/models/playlist.dart';
import 'package:accompaneo/models/playlists.dart';
import 'package:accompaneo/models/song/song.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:accompaneo/utils/helpers/snackbar_helper.dart';
import 'package:accompaneo/widgets/browsable_image.dart';
import 'package:accompaneo/widgets/new_playlist_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectPlaylistWidget extends StatefulWidget {

  final PanelController panelController;

  final Song song;

  const SelectPlaylistWidget({super.key, required this.song, required this.panelController});

  @override
  _SelectPlaylistWidgetState createState() => _SelectPlaylistWidgetState();
}

class _SelectPlaylistWidgetState extends State<SelectPlaylistWidget> {

  PanelController pc = PanelController();

  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    return Scaffold(
      appBar: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Icon(Icons.drag_handle),
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: radius
      )),
      backgroundColor: Colors.transparent,    
      body: SlidingUpPanel(backdropEnabled: true, 
        body: selectPlaylist(), 
        controller: pc, 
        panel: NewPlaylistWidget(panelController : pc, createCallback: (Playlist playlist) {
          addSongToPlaylist(playlist.code);
        },),
        borderRadius: radius,
        maxHeight: MediaQuery.of(context).size.height - 300,
        minHeight: 0
      ),
    );
  }

  Widget selectPlaylist() {
    return ListView(
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
                    child: Text(AppLocalizations.of(context)!.selectPlaylist, style: Theme.of(context).textTheme.headlineMedium,
                  ))
                ),
                ListTile(
                  visualDensity: VisualDensity(vertical: 0),
                  title: Text(AppLocalizations.of(context)!.createNewPlaylist),
                  leading: BrowsableImage(icon: Icons.add),
                  onTap: () =>  {
                    //widget.panelController.close(),
                    pc.open()
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
                          onTap: () => addSongToPlaylist(playlists.items[index].code)
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
    );
  }

  void addSongToPlaylist(String playlistCode) {
    final result = ApiService.addSongToPlaylist(widget.song.code, playlistCode);
    result.then((response) {
      if (response.statusCode == 200) {
        widget.panelController.close();
        Provider.of<PlaylistsModel>(context, listen: false).addSongToPlaylist(playlistCode, widget.song);
        SnackbarHelper.showSnackBar(AppLocalizations.of(context)!.songAddedToPlaylist);
      } else {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonResponse['message'] != null) {
          SnackbarHelper.showSnackBar(jsonResponse['message'], isError: true);
        } else {
          SnackbarHelper.showSnackBar('Failed to fetch post: ${response.statusCode}', isError: true);
        }
      }
    });


  }
}