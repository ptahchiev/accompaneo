import 'package:accompaneo/models/playlist.dart';
import 'package:accompaneo/pages/player_page.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:accompaneo/widgets/placeholders.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../values/app_theme.dart';
import 'package:accompaneo/widgets/select_playlist_widget.dart';
import 'package:shimmer/shimmer.dart';

class PlaylistPage extends StatefulWidget {

  final String playlistUrl;

  const PlaylistPage({super.key, required this.playlistUrl});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState(playlistUrl: playlistUrl);
}

class _PlaylistPageState extends State<PlaylistPage> {

  PanelController pc = PanelController();

  final String playlistUrl;

  late Future<Playlist> futurePlaylist;

  _PlaylistPageState({required this.playlistUrl});


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futurePlaylist = ApiService.getPlaylistByUrl(playlistUrl);
  }


  @override
  Widget build(BuildContext context) {
    final TextEditingController _searchController = TextEditingController();

    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    return Scaffold(
      resizeToAvoidBottomInset:false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search for songs, artists...',
            hintStyle: TextStyle(color: Colors.grey),
            contentPadding: EdgeInsets.all(15),
            prefixIcon: Icon(Icons.search),
            border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width:12)),
          ),
          onChanged: (value) {
            // Perform search functionality here
          },
        ),
      ),
      body: SlidingUpPanel(backdropEnabled: true, 
                           body: createPopUpContent(), 
                           controller: pc, 
                           panel: SelectPlaylistWidget(),
                           borderRadius: radius,
                           maxHeight: MediaQuery.of(context).size.height - 300,
                           minHeight: 0
      ),
      
            );
  }

  Widget createPopUpContent() {
    return FutureBuilder<Playlist>(
      future: futurePlaylist, 
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          return ListView(
                children: [
                  Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.all(10),
                        child: 
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  snapshot.data!.name,
                                  style: AppTheme.sectionTitle,
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade500)),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('${snapshot.data!.songs.totalElements} songs')),
                              )
                            ],
                          ),
                  ),                  
                  ListView.builder(
                          itemCount: snapshot.data?.songs.size,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ListTile(
                              //leading: HeroLayoutCard(imageInfo: ImageData(title: '', subtitle: '', url: songs[index].image)),
                                    leading: CircleAvatar(radius: 28, backgroundColor: Theme.of(context).colorScheme.primary, child: snapshot.data?.songs.content[index].image != '' ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Image(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                      'https://flutter.github.io/assets-for-api-docs/assets/material/${snapshot.data!.songs.content[index].image}'),
                                                )) : Icon(Icons.music_note, color: Colors.white, size: 28)),
                                    
                                    
                                    onTap: () => {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerPage(song: snapshot.data!.songs.content[index])))
                                    },
                                    
                                    // // songs[index].image != '' ? Image(
                                    // //               fit: BoxFit.cover,
                                    // //               image: NetworkImage(
                                    // //                   'https://flutter.github.io/assets-for-api-docs/assets/material/${songs[index].image}'),
                                    // //             ) : 
                                    // //             FittedBox(child: Icon(Icons.music_note, color: Colors.white, size: 35), fit: BoxFit.fill),
                                            
                                    
                                    
                                    
                                    //CircleAvatar(radius: 28, backgroundColor: Theme.of(context).colorScheme.primary, child: Icon(Icons.music_note, color: Colors.white, size: 28)),
                                    title: Text(snapshot.data!.songs.content[index].title, style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black)),
                                    subtitle: Text(snapshot.data!.songs.content[index].artist.name),
                                    trailing: Wrap(
                                      children: [
                                        IconButton(icon: snapshot.data!.songs.content[index].favourite ? Icon(Icons.favorite, color: Colors.red) : Icon(Icons.favorite_outline_outlined), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(duration: Duration(seconds: 1), content: Text('Song added to favourites')));}),
                                        IconButton(onPressed: () => _dialogBuilder(context, snapshot.data!.songs.content[index].artist.code), icon: Icon(Icons.more_horiz))
                                      ],
                                    )
                                    
                                    
                                    
                                    //onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => screens[index]))
                            );
                          },
                    )
                ]
              );
        } else if(snapshot.hasError) {
          return Text('ERROR ${snapshot.error}');
        }
        return 
            Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      loop: 0,
                      enabled: true,
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child:
                          Column(
                            children: [
                              PLaylistHeaderPlaceholder(),
                              ListView.builder(
                                itemCount: 50,
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return PlaylistElementPlaceholder();
                                }),
                            ]
                          )
                      ));
    }));
  }  

  Future<void> _dialogBuilder(BuildContext context, String artistCode) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
                children: [
                  ListTile(
                    title: Text('Add to playlist'),
                    leading: Icon(Icons.add, color: Colors.black, size: 28),
                    onTap: () =>  {
                      Navigator.pop(context, true),
                      pc.open()
                    }
                  ),
                  Divider(),
                  ListTile(
                    title: Text('View All Songs By Artist'),
                    leading: Icon(Icons.search, color: Colors.black, size: 28),
                    onTap: () => {
                      Navigator.pop(context, true),
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistPage(playlistUrl:'/artist/$artistCode')))
                    }
                  ),
                ],
        );
      },
    );
  }

}