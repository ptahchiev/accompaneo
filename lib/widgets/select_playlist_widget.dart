import 'package:accompaneo/models/simple_playlist.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:flutter/material.dart';
import '../values/app_strings.dart';
import '../values/app_theme.dart';

class SelectPlaylistWidget extends StatefulWidget {

  final Function addSongToPlaylist;

  const SelectPlaylistWidget({super.key, required this.addSongToPlaylist});

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
                    title: Text('Create new playlist'),
                    leading: CircleAvatar(radius: 28, backgroundColor: Theme.of(context).colorScheme.primary, child: Icon(Icons.add, color: Colors.white, size: 28)),
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
                                    leading: CircleAvatar(radius: 28, backgroundColor: snapshot.data![index].favourites ? Colors.red : Theme.of(context).colorScheme.primary, child: snapshot.data![index].favourites ? Icon(Icons.favorite, color: Colors.white, size: 28) : Icon(Icons.music_note, color: Colors.white, size: 28)),
                                    title: Text(snapshot.data![index].name),
                                    subtitle: Text('${snapshot.data![index].totalSongs} songs'),
                                    onTap: () =>  {
                                        ApiService.addSongToPlaylist('', snapshot.data![index].code)
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