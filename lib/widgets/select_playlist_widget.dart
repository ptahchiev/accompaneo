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
  
  late Future<List<SimplePlaylist>> futurePlaylists;

  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futurePlaylists = ApiService.getPlaylistsForCurrentUser();
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

                  FutureBuilder<List<SimplePlaylist>>(
                    future: futurePlaylists, 
                    builder: ((context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ListTile(
                                    visualDensity: VisualDensity(vertical: 0),
                                    leading: BrowsableImage(icon: snapshot.data![index].favourites ? Icons.favorite : Icons.music_note, backgroundColor: snapshot.data![index].favourites ? Colors.red : Theme.of(context).colorScheme.primary), //CircleAvatar(radius: 28, backgroundColor: snapshot.data![index].favourites ? Colors.red : Theme.of(context).colorScheme.primary, child: snapshot.data![index].favourites ? Icon(Icons.favorite, color: Colors.white, size: 28) : Icon(Icons.music_note, color: Colors.white, size: 28)),
                                    title: Text(snapshot.data![index].name),
                                    subtitle: Text('${snapshot.data![index].totalSongs} songs'),
                                    onTap: ()  {
                                        final result = ApiService.addSongToPlaylist(widget.song.code, snapshot.data![index].code);
                                        result.then((response) {
                                          if (response.statusCode == 200) {
                                            widget.addSongToPlaylist();
                                            Provider.of<PlaylistsModel>(context, listen: false).addSongToPlaylist(snapshot.data![index].code, widget.song);
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
                      } else if (snapshot.hasError) {
                        return Text('ERROR ${snapshot.error}');
                      }

                      return const CircularProgressIndicator();
                    }))
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}