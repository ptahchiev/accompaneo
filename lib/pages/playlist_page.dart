import 'dart:async';
import 'dart:convert' as convert;
import 'package:accompaneo/models/facet_value.dart';
import 'package:accompaneo/models/page.dart';
import 'package:accompaneo/models/playlists.dart';
import 'package:accompaneo/models/simple_playlist.dart';
import 'package:accompaneo/models/song/song.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:accompaneo/utils/helpers/navigation_helper.dart';
import 'package:accompaneo/utils/helpers/snackbar_helper.dart';
import 'package:accompaneo/values/app_routes.dart';
import 'package:accompaneo/values/app_strings.dart';
import 'package:accompaneo/widgets/browsable_image.dart';
import 'package:accompaneo/widgets/chord_chip.dart';
import 'package:accompaneo/widgets/genre_chip.dart';
import 'package:accompaneo/widgets/placeholders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../values/app_theme.dart';
import 'package:accompaneo/widgets/select_playlist_widget.dart';
import 'package:shimmer/shimmer.dart';

class PlaylistPage extends StatefulWidget {

  final String? queryTerm;

  final SimplePlaylist playlist;

  const PlaylistPage({super.key, this.queryTerm, required this.playlist});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {

  StreamController<Song?> songController = StreamController<Song?>.broadcast();

  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 0;
  int _selectedFacetTile = -1; 
  // Map<String, List<FacetValueDto>> selectedFacets = Map.of({'allCategories' : [], 'chords': [], 'tempo': []});

  List<FacetValueDto> selectedFacets = [];

  PanelController pc = PanelController();
  final _scrollController = ScrollController();
  late Future<PageDto> futurePage;

  bool isLoadingVertical = false;
  List<Song> filteredItems = [];

  Map<Function, Timer> _timeouts = {};

  void debounce(Duration timeout, Function target, [List arguments = const []]) {
    if (_timeouts.containsKey(target)) {
      _timeouts[target]!.cancel();
    }

    Timer timer = Timer(timeout, () {
      Function.apply(target, arguments);
    });

    _timeouts[target] = timer;
  }

  void _handleSearch(String input) {
    setState(() {
      //futurePage = ApiService.getPlaylistByUrl(widget.playlistUrl, query: input);
      if (widget.playlist.url != null && widget.playlist.url!.isNotEmpty) {
        futurePage = ApiService.getPlaylistByUrl(widget.playlist.url!);
      } else {
        futurePage = ApiService.search(queryTerm: input);
      }
    });
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
    //futurePage = ApiService.getPlaylistByUrl(widget.playlistUrl);
    if (widget.playlist.url != null && widget.playlist.url!.isNotEmpty) {
      futurePage = ApiService.getPlaylistByUrl(widget.playlist.url!);
    } else {
      futurePage = ApiService.search(queryTerm: widget.queryTerm ?? '');
    }
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
  //   //futurePage = ApiService.getPlaylistByUrl(widget.playlistUrl, page: _currentPage);//.then((res) {
  //   //   if (res.firstPageSongs.content.isEmpty) {
  //   //     setState(() {
  //   //       _isLoading = false;
  //   //       _hasMore = false;
  //   //     });
  //   //   } else {
  //   //     setState(() {
  //   //       _isLoading = false;
  //   //       _pairList.addAll(fetchedList);
  //   //     });
  //   //   }
  //   // });
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
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    return Scaffold(
      resizeToAvoidBottomInset:false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: widget.playlist.searchable ?
          TextField(
            //controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search for songs, artists...',
              hintStyle: TextStyle(color: Colors.grey),
              contentPadding: EdgeInsets.all(15),
              prefixIcon: Icon(Icons.search),
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width:12)),
            ),
            onChanged: (val) => debounce(const Duration(milliseconds: 300), _handleSearch, ['$val${widget.queryTerm ?? ""}']),
          )
          :
          Container(),
        actions: [
          Visibility(
            visible: widget.playlist.code.isNotEmpty,
            child: IconButton(onPressed: () { _playlistDialogBuilder(context, widget.playlist.code);}, icon: Icon(Icons.more_vert))
          ),
          Visibility(
            visible: widget.playlist.searchable,
            child: FutureBuilder(future: futurePage, builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(padding: EdgeInsets.only(right: 25), child: IconButton(onPressed: () { _filtersDialogBuilder(context, () => futurePage);}, icon: Icon(Icons.tune_rounded)));
              } else {
                return Padding(padding: EdgeInsets.only(right: 25), child: Icon(Icons.tune_rounded));
              }
            }))
        ],
      ),
      body: SlidingUpPanel(
              backdropEnabled: true, 
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
    return FutureBuilder<PageDto>(
      future: futurePage, 
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
                            widget.playlist.name,
                            style: AppTheme.sectionTitle,
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade500)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('${snapshot.data!.totalElements} songs')),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [ 
                          Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 10.0,
                            runSpacing: 10.0,
                            children: [
                              ...snapshot.data!.appliedFacets!.map((af) {
                                return GenreChip(selected: true, facetValueName: af.facetValueName, onDeleted: () {
                                  _handleSearch(af.removeQueryUrl);
                                });
                              }),



                              // ...selectedFacets['allCategories']!.map((e) {
                              //   return GenreChip(selected: true, facetValue: e, onDeleted: () {
                              //     setState(() {
                              //       selectedFacets['allCategories']!.remove(e);
                              //     });
                              //   });
                              // }),
                              // ...selectedFacets['chords']!.map((e) {
                              //   return ChordChip(selected: true, facetValue: e, onDeleted: () {
                              //     //add remove search
                              //     setState(() {
                              //       selectedFacets['chords']!.remove(e);
                              //     });
                              //   },);
                              // }),
                              // ...selectedFacets['tempo']!.map((e) {
                              //   return InputChip(
                              //     label: Text(e.code),
                              //     onDeleted: () => {},
                              //   );
                              // }),
                            ]
                          )
                        ]
                      ),
                    ),
                  ),
                  ListView.builder(
                          itemCount: snapshot.data?.content.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ListTile(
                                    leading: BrowsableImage(imageUrl: snapshot.data!.content[index].picture),
                                    visualDensity: VisualDensity(vertical: 1),
                                    isThreeLine: true,
                                    titleAlignment: ListTileTitleAlignment.center,
                                    onTap: () {
                                      ApiService.markSongAsPlayed(snapshot.data!.content[index].code).then((v) {
                                        if (v.statusCode == 200) {
                                          Provider.of<PlaylistsModel>(context, listen: false).addSongToLatestPlayed(snapshot.data!.content[index]);
                                          NavigationHelper.pushNamed(AppRoutes.player, arguments: {'song' : snapshot.data!.content[index]});
                                        }
                                      });
                                    },
                                    title: Text(snapshot.data!.content[index].name, style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(snapshot.data!.content[index].artist.name),
                                        Wrap(
                                          spacing: 10,
                                          children: snapshot.data!.content[index].chords!.map<Widget>((ch) => Container(padding: EdgeInsets.all(3), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(5)), child: Text(ch))).toList(),
                                        )
                                      ]
                                    ),
                                    trailing: Wrap(
                                      
                                      children: [
                                        IconButton(
                                          icon: snapshot.data!.content[index].favoured ? Icon(Icons.favorite, color: Colors.red) : Icon(Icons.favorite_outline_outlined),
                                          onPressed: () {
                                            if(snapshot.data!.content[index].favoured) {
                                              ApiService.removeSongFromFavouritesPlaylist(snapshot.data!.content[index].code).then((v) {
                                                Provider.of<PlaylistsModel>(context, listen: false).removeSongFromFavourites(snapshot.data!.content[index]);
                                                SnackbarHelper.showSnackBar('Song removed favourites');
                                                snapshot.data!.content[index].favoured = false;
                                                setState(() {
                                                  //futurePlaylist = Future.value(snapshot.data);
                                                });
                                              });
                                            } else {
                                              ApiService.addSongToFavouritesPlaylist(snapshot.data!.content[index].code).then((v) {
                                                Provider.of<PlaylistsModel>(context, listen: false).addSongToFavourites(snapshot.data!.content[index]);
                                                SnackbarHelper.showSnackBar('Song added to favourites');
                                                snapshot.data!.content[index].favoured = true;
                                                setState(() {
                                                  //futurePlaylist = Future.value(snapshot.data);
                                                });
                                              });
                                            }
                                          }),
                                        IconButton(
                                          icon: Icon(Icons.more_horiz),
                                          onPressed: () => _songDialogBuilder(context, snapshot.data!.content[index])
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
                    visible: widget.playlist.code.isNotEmpty,
                    child: ListTile(
                      title: Text('Remove from playlist'),
                      leading: Icon(Icons.remove, color: Colors.black, size: 28),
                      onTap: () {
                        Navigator.pop(context, true);
                        final result = ApiService.removeSongFromPlaylist(song.code, widget.playlist.code);
                        result.then((response) {
                          if (response.statusCode == 200) {
                            Provider.of<PlaylistsModel>(context, listen: false).removeSongFromPlaylist(widget.playlist.code, song);
                            SnackbarHelper.showSnackBar('Song removed from playlist');
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
                      NavigationHelper.pushNamed(AppRoutes.playlist, arguments: {'playlist': SimplePlaylist(code: '', name: 'Songs by ${song.artist.name}', searchable: true), 'queryTerm' : ':artistCode:${song.artist.code}'});
                    }
                  ),
                ],
        );
      },
    );
  }

  List<Widget> _getGenreChips(String facetCode, List<FacetValueDto> facetValues, Function setDialogState) {
    return facetValues.where((fv) => fv.code != '001').map((fv) {
      bool selected = selectedFacets.contains(fv);
      return GenreChip(selected: selected, facetValueName: fv.name, facetValueCount: fv.count, onSelected: (bool selected) {
        setDialogState(() {
          _handleSearch(fv.currentQueryUrl);
          // setState(() {
          //   if (selected) {
          //     selectedFacets.add(fv);
          //   } else {
          //     selectedFacets.remove(fv);
          //   }
          // });
        });
      });
    }).toList();
  }

  List<Widget> _getChordsChips(String facetCode, List<FacetValueDto> facetValues, Function setDialogState) {
    return facetValues.map((fv) {
      bool selected = selectedFacets.contains(fv);
      return ChordChip(selected: selected, facetValue: fv, onSelected: (bool selected) {
        setDialogState(() {
          _handleSearch(fv.currentQueryUrl);
          setState(() {
            if (selected) {
              selectedFacets.add(fv);
            } else {
              selectedFacets.remove(fv);
            }
          });
        });
      });
    }).toList();
  }

  List<Widget> _getTempoSlider(String facetCode, List<FacetValueDto> facetValues, Function setState) {
    return facetValues.map((fv) {
      return InputChip(avatar: Icon(Icons.check) , label: Text(fv.name), selectedColor: Colors.red);
    }).toList();
  }

  Future<void> _filtersDialogBuilder(BuildContext context, Future<PageDto> Function() fetchPage) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, refresh) {
            return FutureBuilder(
              future: fetchPage(), 
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator()); // Show loading state
                }
                var page = snapshot.data!;
                List<Widget> widgets = [];
                widgets.insert(0, Center(child: Text('Filter by:', style: AppTheme.titleMedium.copyWith(color: Colors.black))));
                widgets.insert(1, Container(
                  width: MediaQuery.of(context).size.width - 200,
                  //height: MediaQuery.of(context).size.height -  500,
                  padding: EdgeInsets.all(20),
                  child: ExpansionPanelList(
                    dividerColor: Colors.grey.shade500,
                    elevation: 0,
                    expandedHeaderPadding: EdgeInsets.all(0),
                    animationDuration: Duration(seconds: 1),
                    //expandedHeaderPadding: EdgeInsets.all(32),
                    children: page.facets!.map<ExpansionPanel>((f) {
                      return ExpansionPanel(
                        canTapOnHeader: true,
                        isExpanded: _selectedFacetTile == page.facets!.indexOf(f),
                        backgroundColor: Colors.transparent,
                        headerBuilder: (context, isOpen) {
                          return Text(f.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 2.5));
                        }, 
                        body: 
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [ 
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 10.0,
                                  runSpacing: 10.0,
                                  children: [
                                    if (f.code == 'allCategories') ..._getGenreChips(f.code, f.values, refresh),
                                    if (f.code == 'chords') ..._getChordsChips(f.code, f.values, refresh),
                                    if (f.code == 'tempo') ..._getTempoSlider(f.code, f.values, refresh)
                                  ]
                                )
                              ]
                            ),
                          )
                      );
                    }).toList(),

                    expansionCallback: (panelIndex, isExpanded) => {
                      if (isExpanded) {
                        refresh(() {
                          setState(() {
                            _selectedFacetTile = panelIndex;
                          });
                        }),

                      } else {
                        refresh(() {
                          setState(() {
                            _selectedFacetTile = -1;
                          });
                        }),                    

                      }
                    },
                  
                  ),
                ));
                return SimpleDialog(insetPadding: EdgeInsets.all(10), children: widgets);
              });
          });
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