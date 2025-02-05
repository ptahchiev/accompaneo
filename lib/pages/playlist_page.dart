import 'dart:async';

import 'package:accompaneo/models/playlist.dart';
import 'package:accompaneo/models/playlists.dart';
import 'package:accompaneo/models/song/song.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:accompaneo/utils/helpers/navigation_helper.dart';
import 'package:accompaneo/utils/helpers/snackbar_helper.dart';
import 'package:accompaneo/values/app_routes.dart';
import 'package:accompaneo/values/app_strings.dart';
import 'package:accompaneo/widgets/browsable_image.dart';
import 'package:accompaneo/widgets/placeholders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../values/app_theme.dart';
import 'package:accompaneo/widgets/select_playlist_widget.dart';
import 'package:shimmer/shimmer.dart';

class PlaylistPage extends StatefulWidget {

  final String playlistUrl;

  final String playlistCode;

  const PlaylistPage({super.key, required this.playlistUrl, required this.playlistCode});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {

  StreamController<Song?> songController = StreamController<Song?>.broadcast();

  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 0;

  PanelController pc = PanelController();
  final _scrollController = ScrollController();
  late Future<Playlist> futurePlaylist;
  bool isLoadingVertical = false;
  List<Song> filteredItems = [];
  String _query = '';

  void _handleSearch(String input) {
    // _results.clear();
    // for (var str in myCoolStrings){
    //   if(str.toLowerCase().contains(input.toLowerCase())) {
    //     setState(() {
    //       futurePlaylist.asStream().add(str);
    //     });
    //   }
    // }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {

      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        //_loadMoreItems();
        print('load more');
      }
    });
    futurePlaylist = ApiService.getPlaylistByUrl(this.widget.playlistUrl);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }



  Future _loadMoreVertical() async {
    setState(() {
      isLoadingVertical = true;
    });

    // // Add in an artificial delay
    // await new Future.delayed(const Duration(seconds: 2));

    // verticalData.addAll(List.generate(increment, (index) => verticalData.length + index));

    setState(() {
      isLoadingVertical = false;
    });
  }


  // // Triggers fecth() and then add new items or change _hasMore flag
  // void _loadMore() {
  //   _isLoading = true;
  //   ApiService.getPlaylistByUrl(this.widget.playlistUrl, page: _currentPage).then((res) {
  //     if (res.firstPageSongs.content.isEmpty) {
  //       setState(() {
  //         _isLoading = false;
  //         _hasMore = false;
  //       });
  //     } else {
  //       setState(() {
  //         _isLoading = false;
  //         _pairList.addAll(fetchedList);
  //       });
  //     }
  //   });

  // }


  // void _loadMore() {
  //   if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
  //     _currentPage++;
  //     // setState(() {
  //     //   futurePlaylist.addAll(List<String>.from(json.decode(response.body)));
  //     // });
  //   }
  // }

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
          onChanged: _handleSearch,
        ),
        actions: [
          Visibility(
            visible: widget.playlistCode.isNotEmpty,
            child: IconButton(onPressed: () { _playlistDialogBuilder(context, widget.playlistCode);}, icon: Icon(Icons.more_vert))
          )
          
        ],
      ),
      body: SlidingUpPanel(backdropEnabled: true, 
                           body: createPopUpContent(), 
                           controller: pc, 
                           borderRadius: radius,
                           maxHeight: MediaQuery.of(context).size.height - 300,
                           minHeight: 0,
                           panel: StreamBuilder(
                            stream: songController.stream,
                            builder: (context, snapshot) {
                              if (snapshot.data == null) return const SizedBox.shrink();
                              return SelectPlaylistWidget(addSongToPlaylist: () {pc.close();}, song: snapshot.data!);
                            },
                           )
                          
      ),
    );
  }

  Widget createPopUpContent() {
    return FutureBuilder<Playlist>(
      future: futurePlaylist, 
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          return ListView(
                controller: _scrollController,
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
                                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('${snapshot.data!.firstPageSongs.totalElements} songs')),
                              )
                            ],
                          ),
                  ),                  
                  ListView.builder(
                          itemCount: snapshot.data?.firstPageSongs.content.length,
                          shrinkWrap: true,
                          // controller: _scrollController,
                          //physics: ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ListTile(
                                    leading: BrowsableImage(imageUrl: snapshot.data!.firstPageSongs.content[index].picture!.url),
                                    visualDensity: VisualDensity(vertical: 1),
                                    isThreeLine: true,
                                    titleAlignment: ListTileTitleAlignment.center,
                                    onTap: () {
                                      ApiService.markSongAsPlayed(snapshot.data!.firstPageSongs.content[index].code).then((v) {
                                        Provider.of<PlaylistsModel>(context, listen: false).addSongToLatestPlayed(snapshot.data!.firstPageSongs.content[index]);
                                        NavigationHelper.pushNamed(AppRoutes.player, arguments: {'song' : snapshot.data!.firstPageSongs.content[index]});
                                      });
                                    },
                                    title: Text(snapshot.data!.firstPageSongs.content[index].name, style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(snapshot.data!.firstPageSongs.content[index].artist.name),
                                        Wrap(
                                          spacing: 10,
                                          children: snapshot.data!.firstPageSongs.content[index].chords!.map<Widget>((ch) => Container(padding: EdgeInsets.all(3), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(5)), child: Text(ch.name))).toList(),
                                        )
                                      ]
                                    ),
                                    trailing: Wrap(
                                      
                                      children: [
                                        IconButton(
                                          icon: snapshot.data!.firstPageSongs.content[index].favoured ? Icon(Icons.favorite, color: Colors.red) : Icon(Icons.favorite_outline_outlined),
                                          onPressed: () {
                                            if(snapshot.data!.firstPageSongs.content[index].favoured) {
                                              ApiService.removeSongFromFavouritesPlaylist(snapshot.data!.firstPageSongs.content[index].code).then((v) {
                                                Provider.of<PlaylistsModel>(context, listen: false).removeSongFromFavourites(snapshot.data!.firstPageSongs.content[index]);
                                                SnackbarHelper.showSnackBar('Song removed favourites');
                                                snapshot.data!.firstPageSongs.content[index].favoured = false;
                                                setState(() {
                                                  futurePlaylist = Future.value(snapshot.data);
                                                });

                                              });
                                            } else {
                                              ApiService.addSongToFavouritesPlaylist(snapshot.data!.firstPageSongs.content[index].code).then((v) {
                                                Provider.of<PlaylistsModel>(context, listen: false).addSongToFavourites(snapshot.data!.firstPageSongs.content[index]);
                                                SnackbarHelper.showSnackBar('Song added to favourites');
                                                snapshot.data!.firstPageSongs.content[index].favoured = true;
                                                setState(() {
                                                  futurePlaylist = Future.value(snapshot.data);
                                                });
                                              });
                                       
                                            }
                                          }),
                                        IconButton(
                                          icon: Icon(Icons.more_horiz),
                                          onPressed: () => _songDialogBuilder(context, snapshot.data!.firstPageSongs.content[index])
                                        )
                                      ],
                                    )
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
                        }
                      ),
                    ]
                  )
              )
            );
    }));
  }  

  Future<void> _songDialogBuilder(BuildContext context, Song song) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
                children: [
                  Visibility(
                    visible: widget.playlistCode.isNotEmpty,
                    child: ListTile(
                      title: Text('Remove from playlist'),
                      leading: Icon(Icons.remove, color: Colors.black, size: 28),
                      onTap: () {
                        Navigator.pop(context, true);
                        
                        final result = ApiService.removeSongFromPlaylist(song.code, widget.playlistCode);
                        result.then((response) {
                          if (response.statusCode == 200) {
                            Provider.of<PlaylistsModel>(context, listen: false).removeSongFromPlaylist(widget.playlistCode, song);
                            SnackbarHelper.showSnackBar('Song removed from playlist');
                          } else {
                            if (response.data != null && response.data['message'] != null) {
                              SnackbarHelper.showSnackBar(response.data['message'], isError: true);
                            } else {
                              SnackbarHelper.showSnackBar('Failed to fetch post: ${response.statusCode}', isError: true);
                            }
                          }
                        });                         

                      }
                    ),
                  ),                  
                  ListTile(
                    title: Text('Add to playlist'),
                    leading: Icon(Icons.add, color: Colors.black, size: 28),
                    onTap: () {
                      Navigator.pop(context, true);
                      pc.open();
                      songController.sink.add(song);
                    }
                  ),
                  Divider(),
                  ListTile(
                    title: Text('View All Songs By Artist'),
                    leading: Icon(Icons.search, color: Colors.black, size: 28),
                    onTap: () {
                      Navigator.pop(context, true);
                      NavigationHelper.pushNamed(AppRoutes.playlist, arguments: {'playlistUrl':'/artist/${song.artist.code}', 'playlistCode' : ''});
                    }
                  ),
                ],
        );
      },
    );
  }

  Future<void> _playlistDialogBuilder(BuildContext context, String playlistCode) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
                children: [
                  ListTile(
                    title: Text('Delete playlist'),
                    leading: Icon(Icons.add, color: Colors.black, size: 28),
                    onTap: () {
                      final result = ApiService.deletePlaylist(playlistCode);
                      result.then((response) {
                        if (response.statusCode == 200) {
                          Navigator.pop(context, true);
                          NavigationHelper.pushNamed(AppRoutes.playlists);
                          Provider.of<PlaylistsModel>(context, listen: false).removePlaylist(playlistCode);
                          
                          //widget.onPlaylistDelete();
                          SnackbarHelper.showSnackBar(
                            AppStrings.playlistDeleted,
                          );                        
                        } else {
                          SnackbarHelper.showSnackBar('Failed to create a playlist: ${response.statusCode}', isError: true);
                        }
                      });
                    }
                  )
                ]
        );
      },
    );
  }  

}