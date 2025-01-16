import 'package:flutter/material.dart';
import 'package:accompaneo/song/song.dart';
import 'package:accompaneo/song/image_data.dart';
import 'package:accompaneo/widgets/hero_layout_card.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../values/app_theme.dart';
import 'package:accompaneo/widgets/select_playlist_widget.dart';

class PlaylistPage extends StatefulWidget {

  final List<Song> songs;

  const PlaylistPage({super.key, required this.songs});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {

  PanelController pc = PanelController();

  final List<Song> songs = [
                              Song(image: 'content_based_color_scheme_1.png', name: 'Helpless', artist: 'Neil Young', bpm: 120, favourite: true),
                              Song(image: '', name: 'Hurt', artist: 'Johny Cash', bpm: 120, favourite: false), 
                              Song(image: '', name: 'Drivers License', artist: 'Olivia Rodrigo', bpm: 120, favourite: true), 
                              Song(image: '', name: 'Greatest Love Story', artist: 'LANCO', bpm: 120, favourite: true), 
                              Song(image: '', name: 'Perfect', artist: 'Ed Sheeran', bpm: 120, favourite: true), 
                              Song(image: '', name: 'Snowman', artist: 'SIA', bpm: 120, favourite: false), 
                              Song(image: '', name: 'High Hopes', artist: 'Kodaline', bpm: 120, favourite: false), 
                              Song(image: '', name: 'Be Alright', artist: 'Dean Lewis', bpm: 120, favourite: false), 
                              Song(image: '', name: 'Let It Be', artist: 'Beatles', bpm: 120, favourite: true), 
                              Song(image: '', name: 'Older', artist: 'Sasha Sloan', bpm: 120, favourite: false), 
                              Song(image: '', name: 'Lewis Capaldi', artist: 'Before You Go', bpm: 120, favourite: true), 
                              Song(image: '', name: 'Lady Gaga', artist: 'Million Reasons', bpm: 120, favourite: false), 
                              Song(image: '', name: 'Bruises', artist: 'Lewis Capaldi', bpm: 120, favourite: true), 
                              Song(image: '', name: 'Foolish Games', artist: 'Jewel', bpm: 120, favourite: false), 
                              Song(image: '', name: 'With Or Without You', artist: 'U2', bpm: 120, favourite: false), 
                              Song(image: '', name: 'Heart Of Gold', artist: 'Neil Young', bpm: 120, favourite: true), 
                              Song(image: '', name: 'Iris', artist: 'The Goo Goo DOlls', bpm: 120, favourite: false), 
                              Song(image: '', name: 'Wonderwall', artist: 'Oasis', bpm: 120, favourite: true), 
                            ];


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
                           body: createPopUpContent(entries), 
                           controller: pc, 
                           panel: SelectPlaylistWidget(),
                           borderRadius: radius,
                           maxHeight: MediaQuery.of(context).size.height - 300,
                           minHeight: 0
      ),
      
            );
  }

  Widget createPopUpContent(List<String> entries) {
    return ListView(
      children: [
        Container(
              color: Colors.transparent,
              padding: EdgeInsets.all(15),
              child: 
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Your Favourites',
                        style: AppTheme.sectionTitle,
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade500)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('${songs.length} songs')),
                    )
                  ],
                ),
        ),                  
        ListView.builder(
                itemCount: songs.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    //leading: HeroLayoutCard(imageInfo: ImageData(title: '', subtitle: '', url: songs[index].image)),
                          leading: CircleAvatar(radius: 28, backgroundColor: Theme.of(context).colorScheme.primary, child: songs[index].image != '' ? ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Image(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            'https://flutter.github.io/assets-for-api-docs/assets/material/${songs[index].image}'),
                                      )) : Icon(Icons.music_note, color: Colors.white, size: 28)),
                          
                          
                          
                          
                          // // songs[index].image != '' ? Image(
                          // //               fit: BoxFit.cover,
                          // //               image: NetworkImage(
                          // //                   'https://flutter.github.io/assets-for-api-docs/assets/material/${songs[index].image}'),
                          // //             ) : 
                          // //             FittedBox(child: Icon(Icons.music_note, color: Colors.white, size: 35), fit: BoxFit.fill),
                                  
                          
                          
                          
                          //CircleAvatar(radius: 28, backgroundColor: Theme.of(context).colorScheme.primary, child: Icon(Icons.music_note, color: Colors.white, size: 28)),
                          title: Text(songs[index].name, style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black)),
                          subtitle: Text(songs[index].artist),
                          trailing: Wrap(
                            children: [
                              IconButton(icon: songs[index].favourite ? Icon(Icons.favorite, color: Colors.red) : Icon(Icons.favorite_outline_outlined), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(duration: Duration(seconds: 1), content: Text('Song added to favourites')));}),
                              IconButton(onPressed: () => _dialogBuilder(context), icon: Icon(Icons.more_horiz))
                            ],
                          )
                          
                          
                          
                          //onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => screens[index]))
                  );
                },
          )



      ]
    );
  }  

  Future<void> _dialogBuilder(BuildContext context) {
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
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistPage(songs:[])))
                  ),
                ],
        );
      },
    );
  }

}