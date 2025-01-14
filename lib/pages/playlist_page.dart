import 'package:flutter/material.dart';
import 'package:accompaneo/song/song.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PlaylistPage extends StatefulWidget {

  final List<Song> songs;

  const PlaylistPage({super.key, required this.songs});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {

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
      body:  ListView(
                children: [
                  Center(child: Text('Your favourites', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black))),
                  Center(child: Text('${songs.length} songs', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black))),
                  Divider(),
                      ListView.builder(
                              itemCount: songs.length,
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return ListTile(
                                        leading: CircleAvatar(radius: 28, backgroundColor: Theme.of(context).colorScheme.primary, child: songs[index].image != '' ? ClipRRect(
                                          borderRadius: BorderRadius.circular(50.0),
                                          child: Image(
                                                      fit: BoxFit.cover,
                                                      
                                                      image: NetworkImage(
                                                          'https://flutter.github.io/assets-for-api-docs/assets/material/${songs[index].image}'),
                                                    )) : Icon(Icons.music_note, color: Colors.white, size: 28)),
                                        
                                        
                                        
                                        
                                        // songs[index].image != '' ? Image(
                                        //               fit: BoxFit.cover,
                                        //               image: NetworkImage(
                                        //                   'https://flutter.github.io/assets-for-api-docs/assets/material/${songs[index].image}'),
                                        //             ) : 
                                        //             FittedBox(child: Icon(Icons.music_note, color: Colors.white, size: 35), fit: BoxFit.fill),
                                                
                                        
                                        
                                        
                                        //CircleAvatar(radius: 28, backgroundColor: Theme.of(context).colorScheme.primary, child: Icon(Icons.music_note, color: Colors.white, size: 28)),
                                        title: Text(songs[index].name, style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black)),
                                        subtitle: Text(songs[index].artist),
                                        trailing: IconButton(icon: songs[index].favourite ? Icon(Icons.favorite, color: Colors.red) : Icon(Icons.favorite_outline_outlined), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Song added to favourites')));})
                                        //onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => screens[index]))
                                );
                              },
                        )



                ]
    ));
  }
}