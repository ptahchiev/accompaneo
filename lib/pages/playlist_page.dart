import 'dart:async';
import 'dart:convert' as convert;
import 'package:accompaneo/models/facet_value.dart';
import 'package:accompaneo/models/page.dart';
import 'package:accompaneo/models/playlists.dart';
import 'package:accompaneo/models/simple_playlist.dart';
import 'package:accompaneo/models/slider_facet.dart';
import 'package:accompaneo/models/song/song.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:accompaneo/utils/helpers/navigation_helper.dart';
import 'package:accompaneo/utils/helpers/snackbar_helper.dart';
import 'package:accompaneo/values/app_colors.dart';
import 'package:accompaneo/values/app_routes.dart';
import 'package:accompaneo/values/app_strings.dart';
import 'package:accompaneo/widgets/browsable_image.dart';
import 'package:accompaneo/widgets/chord_chip.dart';
import 'package:accompaneo/widgets/genre_chip.dart';
import 'package:accompaneo/widgets/placeholders.dart';
import 'package:accompaneo/widgets/practice_type_chip.dart';
import 'package:accompaneo/widgets/range_chip.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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
  State<PlaylistPage> createState() => _PlaylistPageState(queryTerm: queryTerm);
}

class PageProvider extends InheritedWidget {
  const PageProvider({
    Key? key,
    required this.page,
    required this.search,
    required this.loadMore,
    required Widget child,
  }) : super(key: key, child: child);

  final PageDto page;
  final VoidCallback search;
  final VoidCallback loadMore;

  static PageProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PageProvider>();
  }

  @override
  bool updateShouldNotify(PageProvider oldWidget) {
    return oldWidget.page != page;
  }
}

class _PlaylistPageState extends State<PlaylistPage> {

  StreamController<Song?> songController = StreamController<Song?>.broadcast();

  final PagingController<int, Song> _pagingController = PagingController(firstPageKey: 0);

  _PlaylistPageState({required this.queryTerm});

  String? queryTerm = "";
  int page = 0;
  int _selectedFacetTile = -1; 
  bool isLoading = true;

  late RangeValues tempoRangeValues;

  final TextEditingController searchController = TextEditingController();
  final PanelController pc = PanelController();
  late PageDto futurePage;

  List<Song> filteredItems = [];

  final Map<Function, Timer> _timeouts = {};

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
    if (input.isEmpty || input.length > 3) {
      if (widget.playlist.url != null && widget.playlist.url!.isNotEmpty) {
        ApiService.getPlaylistByUrl(widget.playlist.url!).then((val) {
          setState(() {
            futurePage = val;
            tempoRangeValues = val.getTempoRangeValues();
          });
        });
      } else {
        ApiService.search(queryTerm: input).then((val) {
          setState(() {
            queryTerm = input;
            futurePage = val;
            tempoRangeValues = val.getTempoRangeValues();
          });
          _pagingController.refresh();        
        });
    }
    }
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    _pagingController.addStatusListener((status) {
      if (status == PagingStatus.completed) {
        // setState(() {
        //   _completed = true;
        // });
      }
      if (status == PagingStatus.subsequentPageError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Something went wrong while fetching a new page.',
            ),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _pagingController.retryLastFailedRequest(),
            ),
          ),
        );
      }
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      ApiService.search(page: (pageKey).toInt(), queryTerm: queryTerm ?? '').then((newPage) {
        final isLastPage = newPage.last;
        if (isLastPage) {
          _pagingController.appendLastPage(newPage.content);
        } else {
          final nextPageKey = pageKey+1;
          _pagingController.appendPage(newPage.content, nextPageKey);
        }
        if (pageKey == 0) {
          setState(() {
            futurePage = newPage;
            isLoading = false;
            tempoRangeValues = newPage.getTempoRangeValues();
          });
        }

      });
    } catch (error) {
      _pagingController.error = error;
    }
  }


  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    return Scaffold(
      resizeToAvoidBottomInset:false,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, isScrolled) {
          return [
            SliverAppBar(
              snap: true,
              floating:true,
              centerTitle: true,
              backgroundColor: Colors.transparent,
              title: widget.playlist.searchable ?
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for songs, artists...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.all(15),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty ? IconButton(    
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        _handleSearch(widget.queryTerm ?? "");
                      }
                    ) : null,
                    border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width:12)),
                  ),
                  onChanged: (val) => debounce(const Duration(milliseconds: 300), _handleSearch, [val]),
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
                  child: isLoading ?
                      Padding(padding: EdgeInsets.only(right: 25), child: Icon(Icons.tune_rounded))
                    : 
                      Padding(padding: EdgeInsets.only(right: 25), child: IconButton(onPressed: () { _filtersDialogBuilder(context);}, icon: Icon(Icons.tune_rounded)))
                )
              ],
            )
          ];
        }, 
        body: SlidingUpPanel(
          backdropEnabled: true, 
          body: _refreshIndicator(), 
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
      ),
    );
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

  List<Widget> _getGenreChips(String facetCode, List<FacetValueDto> facetValues, Function isApplied, Function setDialogState) {
    return facetValues.where((fv) => fv.code != '001').map((fv) {
      return GenreChip(selected: isApplied(fv), facetValueCode: fv.code, facetValueName: fv.name, facetValueCount: fv.count, onSelected: (bool selected) {
        setDialogState(() {
          _handleSearch(fv.currentQueryUrl);
        });
      });
    }).toList();
  }

  List<Widget> _getChordsChips(String facetCode, List<FacetValueDto> facetValues, Function isApplied, Function setDialogState) {
    return facetValues.map((fv) {
      return ChordChip(selected: isApplied(fv), facetValueCode: fv.code, facetValueName: fv.name, facetValueCount: fv.count, onSelected: (bool selected) {
        _handleSearch(fv.currentQueryUrl);
      });
    }).toList();
  }

  List<Widget> _getPracticeTypeChips(String facetCode, List<FacetValueDto> facetValues, Function isApplied, Function setDialogState) {
    return facetValues.map((fv) {
      return PracticeTypesChip(selected: isApplied(fv), facetValueCode: fv.code, facetValueName: fv.name, facetValueCount: fv.count, showCheckmark: false, onSelected: (bool selected) {
        _handleSearch(fv.currentQueryUrl);
      });
    }).toList();
  }

  List<Widget> _getTempoSlider(SliderFacetDto sliderFacet, Function setDialogState) {
    return [
      Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('${tempoRangeValues.start.ceilToDouble()} - ${tempoRangeValues.end.ceilToDouble()}', style: AppTheme.titleMedium)),
              )
          ]
        ),
      ),
      tempoRangeValues.start != -1 && tempoRangeValues.end != -1 ?
        RangeSlider(
          values: tempoRangeValues,
          min: sliderFacet.initialMinValue.ceilToDouble(),
          max: sliderFacet.initialMaxValue.ceilToDouble(),
          labels: RangeLabels(
            tempoRangeValues.start.ceilToDouble().toString(),
            tempoRangeValues.end.ceilToDouble().toString(),
          ),
          onChanged: (RangeValues values) {
            setDialogState(() {
              //setState(() {
                tempoRangeValues = values;
              //});
            });
          },
          onChangeEnd: (RangeValues values) {
            String query = '${queryTerm ?? ''}:tempo:[${values.start.ceilToDouble()}-${values.end.ceilToDouble()}][${sliderFacet.initialMinValue.ceilToDouble()}-${sliderFacet.initialMaxValue.ceilToDouble()}]';
            _handleSearch(query);
          },
        ) : Container()
    ];
  }

  Future<void> _filtersDialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            
            // if (isLoading) {
            //   return Center(child: CircularProgressIndicator()); // Show loading state
            // }
            PageDto page = futurePage;
            List<Widget> widgets = [];
            widgets.insert(0, Center(child: Text('Filter by:', style: AppTheme.titleMedium.copyWith(color: Colors.black))));
            widgets.insert(1, Container(
              width: MediaQuery.of(dialogContext).size.width - 200,
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
                    headerBuilder: (dialogContext, isOpen) {
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
                                if (f.code == 'allCategories') ..._getGenreChips(f.code, f.values, (FacetValueDto fv) {return page.isFacetValueApplied(fv);}, setDialogState),
                                if (f.code == 'chords') ..._getChordsChips(f.code, f.values, (FacetValueDto fv) {return page.isFacetValueApplied(fv);}, setDialogState),
                                if (f.code == 'practiceTypes') ..._getPracticeTypeChips(f.code, f.values, (FacetValueDto fv) {return page.isFacetValueApplied(fv);}, setDialogState),
                                if (f.code == 'tempo') ..._getTempoSlider(f as SliderFacetDto, setDialogState)
                              ]
                            )
                          ]
                        ),
                      )
                  );
                }).toList(),

                expansionCallback: (panelIndex, isExpanded) => {
                  if (isExpanded) {
                    setDialogState(() {
                      setState(() {
                        _selectedFacetTile = panelIndex;
                      });
                    }),

                  } else {
                    setDialogState(() {
                      setState(() {
                        _selectedFacetTile = -1;
                      });
                    }),                    

                  }
                },
              
              ),
            ));
            return SimpleDialog(insetPadding: EdgeInsets.all(10), children: widgets);
          }
        );
      }
    );
  }

  Future<void> _pullRefresh() async {
    _pagingController.refresh();
  }

  Widget playlistHeader() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              widget.playlist.name,
              style: AppTheme.sectionTitle,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade500)),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('${futurePage.totalElements} songs', overflow: TextOverflow.clip)),
        )
      ],
    );
  }

  Widget appliedFacetsWidget() {
    return Padding(
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
                ...futurePage.appliedFacets!.map((af) {
                  switch(af.facetCode) {
                    case 'allCategories': {
                      return GenreChip(selected: true, facetValueCode: af.facetValueCode, facetValueName: af.facetValueName, showCheckmark: true, onDeleted: () {
                        _handleSearch(af.removeQueryUrl);
                      });
                    }
                    case 'chords': {
                      return ChordChip(selected: true, facetValueCode: af.facetValueCode, facetValueName: af.facetValueName, showCheckmark: false, onDeleted: () {
                        _handleSearch(af.removeQueryUrl);
                      });
                    }
                    case 'practiceTypes': {
                      return PracticeTypesChip(selected: true, facetValueCode: af.facetValueCode, facetValueName: af.facetValueName, showCheckmark: false, onDeleted: () {
                        _handleSearch(af.removeQueryUrl);
                      });
                    }
                    case 'tempo': {
                      return RangeChip(selected: true, facetValueCode: af.facetValueCode, facetValueName: af.facetValueName, showCheckmark: false, onDeleted: () {
                        _handleSearch(af.removeQueryUrl);
                      });
                    }
                  }
                  return Container();
                }),
              ]
            )
          ]
        ),
      ),
    );
  }

  /// Returns a `RefreshIndicator` wrapping our results `ListView`
  Widget _refreshIndicator() => RefreshIndicator(
    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    triggerMode: RefreshIndicatorTriggerMode.anywhere,
    color: AppColors.primaryColor,
    onRefresh: _pullRefresh,
    child: _listView()
    
    // ListView (
    //   //controller: _scrollController,
    //   children: [
    //     playlistHeader(),
    //     appliedFacetsWidget(),
    //     _listView()
    //   ],
    // )    
  );

  Widget getLoadingWidget() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      loop: 0,
      enabled: true,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child:
          Column(
            children: [
              PlaylistHeaderPlaceholder(),
              AppliedFacetsPlaceholder(),
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
  }

  Widget _listView() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: isLoading ? PlaylistHeaderPlaceholder() : playlistHeader()),
        SliverToBoxAdapter(child: isLoading ? AppliedFacetsPlaceholder() : appliedFacetsWidget()),
        PagedSliverList<int, Song>(
          //shrinkWrap: true,
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Song>(
            itemBuilder: (context, item, index) => playlistSong(item)
          ),
        )
      ],
    );
  }
  
  /// Returns a `Widget` informing of "No Data Fetched"
  Widget _noDataView(String message) => Center(
    child: Text(
      message,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    ),
  );


  Widget playlistSong(Song song) {
    return ListTile(
      leading: BrowsableImage(imageUrl: song.picture),
      visualDensity: VisualDensity(vertical: 1),
      isThreeLine: true,
      titleAlignment: ListTileTitleAlignment.center,
      onTap: () {
        ApiService.markSongAsPlayed(song.code).then((v) {
          if (v.statusCode == 200) {
            Provider.of<PlaylistsModel>(context, listen: false).addSongToLatestPlayed(song);
            NavigationHelper.pushNamed(AppRoutes.player, arguments: {'song' : song});
          }
        });
      },
      title: Text(song.name, style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(song.artist.name),
          Wrap(
            spacing: 10,
            children: song.chords!.map<Widget>((ch) => Container(padding: EdgeInsets.all(3), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(5)), child: Text(ch))).toList(),
          )
        ]
      ),
      trailing: Wrap(
        children: [
          IconButton(
            icon: song.favoured ? Icon(Icons.favorite, color: Colors.red) : Icon(Icons.favorite_outline_outlined),
            onPressed: () {
              if(song.favoured) {
                ApiService.removeSongFromFavouritesPlaylist(song.code).then((v) {
                  Provider.of<PlaylistsModel>(context, listen: false).removeSongFromFavourites(song);
                  SnackbarHelper.showSnackBar('Song removed favourites');
                  song.favoured = false;
                  setState(() {
                    //futurePlaylist = Future.value(snapshot.data);
                  });
                });
              } else {
                ApiService.addSongToFavouritesPlaylist(song.code).then((v) {
                  Provider.of<PlaylistsModel>(context, listen: false).addSongToFavourites(song);
                  SnackbarHelper.showSnackBar('Song added to favourites');
                  song.favoured = true;
                  setState(() {
                    //futurePlaylist = Future.value(snapshot.data);
                  });
                });
              }
            }),
          IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () => _songDialogBuilder(context, song)
          )
        ],
      )
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