import 'package:accompaneo/song/image_data.dart';
import 'package:accompaneo/widgets/hero_layout_card.dart';
import 'package:flutter/material.dart';
import 'playlist_page.dart';
import 'package:accompaneo/widgets/new_playlist_widget.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key, required this.title});

  final String title;

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class CardList extends StatelessWidget {
  final List<String> listData;

  const CardList({super.key, required this.listData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Column(
        children: [
          ListTile(
            title: Text('Your favourites'),
            leading: CircleAvatar(radius: 28, backgroundColor: Colors.red, child: Icon(Icons.favorite, color: Colors.white, size: 28)),
            subtitle: Text('6 songs'),
            onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistPage(songs:[])))
          ),
          Divider(),
          ListView.builder(
            itemCount: listData.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ListTile(
                      leading: CircleAvatar(radius: 28, backgroundColor: Theme.of(context).colorScheme.primary, child: Icon(Icons.music_note, color: Colors.white, size: 28)),
                      title: Text(listData[index]),
                      subtitle: Text('6 songs'),
                      onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistPage(songs:[])))
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  
  PanelController pc = PanelController();

  bool _isCreatePlaylistOpen = false;

  void __toggleCreatePlaylistOpen() {
    setState(() {
      _isCreatePlaylistOpen = !_isCreatePlaylistOpen;
    });
  }

  @override
  Widget build(BuildContext context) {

    final List<String> entries = <String>['guitar', 'piano', 'wedding'];

    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    return Scaffold(
      body: SlidingUpPanel(backdropEnabled: true, 
                           body: createPlaylist(entries), 
                           controller: pc, 
                           panel: NewPlaylistWidget(),
                           borderRadius: radius,
                           maxHeight: MediaQuery.of(context).size.height - 300,
                           minHeight: 0
      ),
      //bottomNavigationBar: buildAppNavigationBar(context, 3),
      floatingActionButton: Visibility(visible: true, child:FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          //tooltip: 'Add  playlist',
          shape: const CircleBorder(),
          onPressed: () {
            pc.open();
            __toggleCreatePlaylistOpen();
          },
          child: _isCreatePlaylistOpen ? const Icon(Icons.close, color: Colors.white, size: 28) : const Icon(Icons.add, color: Colors.white, size: 28),
      )),
    );
  }

  Widget createPlaylist(List<String> entries) {
    return CardList(listData: entries);
  }
}