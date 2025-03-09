import 'dart:async';
import 'dart:convert' as convert;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import 'package:accompaneo/widgets/browsable_image.dart';
import 'package:accompaneo/widgets/chord_chip.dart';
import 'package:accompaneo/widgets/genre_chip.dart';
import 'package:accompaneo/widgets/placeholders.dart';
import 'package:accompaneo/widgets/practice_type_chip.dart';
import 'package:accompaneo/widgets/range_chip.dart';
import 'package:accompaneo/widgets/select_playlist_widget.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PlaylistPage extends StatefulWidget {
  final String? queryTerm;

  final SimplePlaylist playlist;

  const PlaylistPage({super.key, this.queryTerm, required this.playlist});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState(queryTerm: queryTerm);
}

class _PlaylistPageState extends State<PlaylistPage> {
  StreamController<Song?> songController = StreamController<Song?>.broadcast();

  final PagingController<int, Song> _pagingController =
      PagingController(firstPageKey: 0);

  _PlaylistPageState({required this.queryTerm});

  String? queryTerm = "";

  int page = 0;
  bool isLoading = true;
  bool _filtersDisplayed = false;

  late RangeValues tempoRangeValues = RangeValues(0, 100);

  final PanelController pc = PanelController();
  PageDto futurePage = PageDto(
      totalPages: -1,
      totalElements: 0,
      size: 0,
      number: 0,
      content: [],
      first: false,
      last: false);

  List<Song> filteredItems = [];

  Future<void> _filtersDialogBuilder(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context1) {
          return PageProvider(
            pagingController: _pagingController,
            isLoading: isLoading,
            queryTerm: queryTerm,
            page: futurePage,
            tempoRangeValues: tempoRangeValues,
            search: _handleSearch,
            toggleFilters: _toggleFilters,
            tempRangeValuesChanged: _tempRangeValuesChanged,
            loadMore: _fetchPage,
            child: PageFilters(),
          );
        });
  }

  void _handleSearch(String input) {
    if (input.isEmpty || input.length > 3) {
      isLoading = true;
      if (widget.playlist.url != null && widget.playlist.url!.isNotEmpty) {
        ApiService.getPlaylistByUrl(widget.playlist.url!).then((val) {
          setState(() {
            futurePage = val;
            tempoRangeValues = val.getTempoRangeValues();
            isLoading = false;
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
          isLoading = false;
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
      if (widget.playlist.url != null && widget.playlist.url!.isNotEmpty) {
        ApiService.getPlaylistByUrl(widget.playlist.url!).then((newPage) {
          final isLastPage = newPage.last;
          if (isLastPage) {
            _pagingController.appendLastPage(newPage.content);
          } else {
            final nextPageKey = pageKey + 1;
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
      } else {
        ApiService.search(page: (pageKey).toInt(), queryTerm: queryTerm ?? '')
            .then((newPage) {
          final isLastPage = newPage.last;
          if (isLastPage) {
            _pagingController.appendLastPage(newPage.content);
          } else {
            final nextPageKey = pageKey + 1;
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
      }
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
    return Stack(
      children: [
        PageProvider(
          pagingController: _pagingController,
          isLoading: isLoading,
          queryTerm: queryTerm,
          tempoRangeValues: tempoRangeValues,
          page: futurePage,
          search: _handleSearch,
          loadMore: _fetchPage,
          toggleFilters: _toggleFilters,
          tempRangeValuesChanged: _tempRangeValuesChanged,
          child: PageResults(
            playlist: widget.playlist,
            buildDialog: _filtersDialogBuilder,
            toggleFilters: _toggleFilters,
          ),
        ),
        if (_filtersDisplayed)
          PageProvider(
            pagingController: _pagingController,
            isLoading: isLoading,
            queryTerm: queryTerm,
            page: futurePage,
            tempoRangeValues: tempoRangeValues,
            toggleFilters: _toggleFilters,
            tempRangeValuesChanged: _tempRangeValuesChanged,
            search: _handleSearch,
            loadMore: _fetchPage,
            child: PageFilters(),
          )
      ],
    );
  }

  void _toggleFilters() {
    setState(() {
      _filtersDisplayed = !_filtersDisplayed;
    });
  }

  void _tempRangeValuesChanged(RangeValues newValues) {
    setState(() {
      tempoRangeValues = newValues;
    });
  }
}

class PageProvider extends InheritedWidget {
  PageProvider({
    Key? key,
    required this.pagingController,
    required this.isLoading,
    required this.queryTerm,
    required this.page,
    required this.tempoRangeValues,
    required this.search,
    required this.loadMore,
    required this.toggleFilters,
    required this.tempRangeValuesChanged,
    required Widget child,
  }) : super(key: key, child: child);

  final PagingController<int, Song> pagingController;
  final bool isLoading;
  final String? queryTerm;
  final RangeValues tempoRangeValues;
  final PageDto page;
  final void Function(String) search;
  final void Function(int) loadMore;
  final void Function(RangeValues) tempRangeValuesChanged;
  final VoidCallback toggleFilters;

  static PageProvider? of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<PageProvider>();
    assert(result != null, 'No PageProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(PageProvider oldWidget) {
    return oldWidget.page != page;
  }
}

class PageResults extends StatefulWidget {
  final SimplePlaylist playlist;
  final Function buildDialog;
  final VoidCallback toggleFilters;

  const PageResults({
    super.key,
    required this.playlist,
    required this.buildDialog,
    required this.toggleFilters,
  });

  @override
  State<PageResults> createState() => _PageResultsState();
}

class _PageResultsState extends State<PageResults> {
  StreamController<Song?> songController = StreamController<Song?>.broadcast();

  _PageResultsState();

  final PanelController pc = PanelController();

  List<Song> filteredItems = [];

  final TextEditingController searchController = TextEditingController();

  final Map<Function, Timer> _timeouts = {};

  void debounce(Duration timeout, Function target,
      [List arguments = const []]) {
    if (_timeouts.containsKey(target)) {
      _timeouts[target]!.cancel();
    }

    Timer timer = Timer(timeout, () {
      Function.apply(target, arguments);
    });

    _timeouts[target] = timer;
  }

  Future<void> _playlistDialogBuilder(
      BuildContext context, String playlistCode) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(children: [
          ListTile(
              title: Text('Delete playlist'),
              leading: Icon(Icons.add, color: Colors.black, size: 28),
              onTap: () {
                final result = ApiService.deletePlaylist(playlistCode);
                result.then((response) {
                  if (response.statusCode == 200) {
                    Navigator.pop(context, true);
                    NavigationHelper.pushNamed(AppRoutes.playlists);
                    Provider.of<PlaylistsModel>(context, listen: false)
                        .removePlaylist(playlistCode);

                    //widget.onPlaylistDelete();
                    SnackbarHelper.showSnackBar(
                      AppLocalizations.of(context)!.playlistDeleted,
                    );
                  } else {
                    SnackbarHelper.showSnackBar(
                        'Failed to create a playlist: ${response.statusCode}',
                        isError: true);
                  }
                });
              })
        ]);
      },
    );
  }

  /// Returns a `RefreshIndicator` wrapping our results `ListView`
  Widget _refreshIndicator(PageProvider pageProvider) => RefreshIndicator(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      color: AppColors.primaryColor,
      onRefresh: () => _pullRefresh(pageProvider),
      child: _listView(pageProvider));

  Widget _listView(PageProvider pageProvider) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: playlistHeader(pageProvider)),
        SliverToBoxAdapter(child: appliedFacetsWidget(pageProvider)),
        PagedSliverList<int, Song>(
          pagingController: pageProvider.pagingController,
          builderDelegate: PagedChildBuilderDelegate<Song>(
            itemBuilder: (context, item, index) => playlistSong(item),
            // firstPageErrorIndicatorBuilder: (_) => FirstPageErrorIndicator(
            //   error: _pagingController.error,
            //   onTryAgain: () => _pagingController.refresh(),
            // ),
            // newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
            //   error: _pagingController.error,
            //   onTryAgain: () => _pagingController.retryLastFailedRequest(),
            // ),
            firstPageProgressIndicatorBuilder: (_) => getLoadingWidget(),
            // newPageProgressIndicatorBuilder: (_) => NewPageProgressIndicator(),
            noItemsFoundIndicatorBuilder: (_) =>
                _noDataView(AppLocalizations.of(context)!.noResultsFound),
            //noMoreItemsIndicatorBuilder: (_) => NoMoreItemsIndicator(),
          ),
        )
      ],
    );
  }

  Future<void> _pullRefresh(PageProvider pageProvider) async {
    pageProvider.pagingController.refresh();
  }

  Widget _noDataView(String message) => Center(
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  Widget playlistHeader(PageProvider pageProvider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              String playlistName = widget.playlist.name;
              final textPainter = TextPainter(
                text: TextSpan(
                  text: playlistName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                maxLines: 1,
                textDirection: TextDirection.ltr,
              )..layout(maxWidth: constraints.maxWidth);
      
              double textWidth = textPainter.width;
              double remainingWidth = constraints.maxWidth - textWidth - 20;
      
              Widget textWidget = Container(
                child: Text(
                  playlistName,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 1,
                ),
              );
              Widget dividerWidget = Container(
                color: Colors.grey.shade500,
                height: 1,
                constraints: BoxConstraints(
                  minWidth: 10,
                ),
              );
              if (remainingWidth > 20) {
                dividerWidget = Expanded(child: dividerWidget);
              } else {
                textWidget = Expanded(child: textWidget);
              }
              return Row(
                children: [
                  textWidget,
                  dividerWidget,
                ],
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(AppLocalizations.of(context)!.nSongs(pageProvider.page.totalElements),
                overflow: TextOverflow.clip),
          ),
        ],
      ),
    );
  }

  Widget appliedFacetsWidget(PageProvider pageProvider) {
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
                    ...pageProvider.page.appliedFacets!.map((af) {
                      switch (af.facetCode) {
                        case 'allCategories':
                          {
                            return GenreChip(
                                selected: true,
                                facetValueCode: af.facetValueCode,
                                facetValueName: af.facetValueName,
                                showCheckmark: true,
                                onDeleted: () {
                                  pageProvider.search(af.removeQueryUrl);
                                });
                          }
                        case 'chords':
                          {
                            return ChordChip(
                                selected: true,
                                facetValueCode: af.facetValueCode,
                                facetValueName: af.facetValueName,
                                showCheckmark: false,
                                onDeleted: () {
                                  pageProvider.search(af.removeQueryUrl);
                                });
                          }
                        case 'practiceTypes':
                          {
                            return PracticeTypesChip(
                                selected: true,
                                facetValueCode: af.facetValueCode,
                                facetValueName: af.facetValueName,
                                showCheckmark: false,
                                onDeleted: () {
                                  pageProvider.search(af.removeQueryUrl);
                                });
                          }
                        case 'musicKey':
                          {
                            return ChordChip(
                                selected: true,
                                facetValueCode: af.facetValueCode,
                                facetValueName: af.facetValueName,
                                showCheckmark: false,
                                onDeleted: () {
                                  pageProvider.search(af.removeQueryUrl);
                                });
                          }
                        case 'timeSignature':
                          {
                            return GenreChip(
                                selected: true,
                                facetValueCode: af.facetValueCode,
                                facetValueName: af.facetValueName,
                                showCheckmark: true,
                                onDeleted: () {
                                  pageProvider.search(af.removeQueryUrl);
                                });
                          }
                        case 'tempo':
                          {
                            return RangeChip(
                                selected: true,
                                facetValueCode: af.facetValueCode,
                                facetValueName: af.facetValueName,
                                showCheckmark: false,
                                onDeleted: () {
                                  pageProvider.search(af.removeQueryUrl);
                                });
                          }
                      }
                      return Container();
                    }),
                  ])
            ]),
      ),
    );
  }

  Widget playlistSong(Song song) {
    return ListTile(
        leading: BrowsableImage(imageUrl: song.picture),
        visualDensity: VisualDensity(vertical: 1),
        isThreeLine: true,
        titleAlignment: ListTileTitleAlignment.center,
        onTap: () {
          ApiService.markSongAsPlayed(song.code).then((v) {
            if (v.statusCode == 200) {
              Provider.of<PlaylistsModel>(context, listen: false)
                  .addSongToLatestPlayed(song);
              NavigationHelper.pushNamed(AppRoutes.player,
                  arguments: {'song': song});
            }
          });
        },
        title: Text(song.name, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(song.artist.name, style: Theme.of(context).textTheme.bodySmall),
          Wrap(
            spacing: 10,
            children: song.chords!
                .map<Widget>((ch) => Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(ch, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black))))
                .toList(),
          )
        ]),
        trailing: Wrap(
          children: [
            IconButton(
                icon: song.favoured
                    ? Icon(Icons.favorite, color: Colors.red)
                    : Icon(Icons.favorite_outline_outlined),
                onPressed: () {
                  if (song.favoured) {
                    ApiService.removeSongFromFavouritesPlaylist(song.code)
                        .then((v) {
                      Provider.of<PlaylistsModel>(context, listen: false)
                          .removeSongFromFavourites(song);
                      SnackbarHelper.showSnackBar(AppLocalizations.of(context)!.songRemovedFromFavourites);
                      song.favoured = false;
                      setState(() {
                        //futurePlaylist = Future.value(snapshot.data);
                      });
                    });
                  } else {
                    ApiService.addSongToFavouritesPlaylist(song.code).then((v) {
                      Provider.of<PlaylistsModel>(context, listen: false)
                          .addSongToFavourites(song);
                      SnackbarHelper.showSnackBar(AppLocalizations.of(context)!.songAddedToFavourites);
                      song.favoured = true;
                      setState(() {
                        //futurePlaylist = Future.value(snapshot.data);
                      });
                    });
                  }
                }),
            IconButton(
                icon: Icon(Icons.more_horiz),
                onPressed: () => _songDialogBuilder(context, song))
          ],
        ));
  }

  Widget getLoadingWidget() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        loop: 0,
        enabled: true,
        child: SizedBox(
            height: 300 * .7, // 70% height
            width: 400 * .9,
            child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(children: [
                  AppliedFacetsPlaceholder(),
                  ListView.builder(
                      itemCount: 50,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return PlaylistElementPlaceholder();
                      }),
                ]))));
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
                  title: Text(AppLocalizations.of(context)!.removeFromPlaylist),
                  leading: Icon(Icons.remove, color: Colors.black, size: 28),
                  onTap: () {
                    Navigator.pop(context, true);
                    final result = ApiService.removeSongFromPlaylist(
                        song.code, widget.playlist.code);
                    result.then((response) {
                      if (response.statusCode == 200) {
                        Provider.of<PlaylistsModel>(context, listen: false)
                            .removeSongFromPlaylist(widget.playlist.code, song);
                        SnackbarHelper.showSnackBar(
                            AppLocalizations.of(context)!.songRemovedFromPlaylist);
                      } else {
                        var jsonResponse = convert.jsonDecode(response.body)
                            as Map<String, dynamic>;
                        if (jsonResponse['message'] != null) {
                          SnackbarHelper.showSnackBar(jsonResponse['message'],
                              isError: true);
                        } else {
                          SnackbarHelper.showSnackBar(
                              'Failed to fetch post: ${response.statusCode}',
                              isError: true);
                        }
                      }
                    });
                  }),
            ),
            ListTile(
                title: Text(AppLocalizations.of(context)!.addToPlaylist),
                leading: Icon(Icons.add, color: Colors.black, size: 28),
                onTap: () {
                  Navigator.pop(context, true);
                  pc.open();
                  songController.sink.add(song);
                }),
            Divider(),
            ListTile(
                title: Text(AppLocalizations.of(context)!.viewAllSongsByArtists),
                leading: Icon(Icons.search, color: Colors.black, size: 28),
                onTap: () {
                  Navigator.pop(context, true);
                  NavigationHelper.pushNamed(AppRoutes.playlist, arguments: {
                    'playlist': SimplePlaylist(
                        code: '',
                        name: 'Songs by ${song.artist.name}',
                        searchable: true),
                    'queryTerm': ':artistCode:${song.artist.code}'
                  });
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    PageProvider pageProvider = PageProvider.of(context)!;

    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, isScrolled) {
          return [
            SliverAppBar(
              snap: true,
              floating: true,
              centerTitle: true,
              backgroundColor: Colors.transparent,
              title: widget.playlist.searchable
                  ? TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchForSongsArtists,
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.all(15),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  pageProvider.search("");
                                })
                            : null,
                        border: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 12)),
                      ),
                      onChanged: (val) => debounce(
                          const Duration(milliseconds: 300),
                          pageProvider.search,
                          [val]),
                    )
                  : Container(),
              actions: [
                Visibility(
                    visible: widget.playlist.code.isNotEmpty,
                    child: IconButton(
                        onPressed: () {
                          _playlistDialogBuilder(context, widget.playlist.code);
                        },
                        icon: Icon(Icons.more_vert))),
                Visibility(
                    visible: widget.playlist.searchable,
                    child: pageProvider.isLoading
                        ? Padding(
                            padding: EdgeInsets.only(right: 25),
                            child: Icon(Icons.tune_rounded))
                        : Padding(
                            padding: EdgeInsets.only(right: 25),
                            child: IconButton(
                                onPressed: () {
                                  widget.toggleFilters();
                                  // widget.buildDialog(context);
                                },
                                icon: Icon(Icons.tune_rounded))))
              ],
            )
          ];
        },
        body: SlidingUpPanel(
            backdropEnabled: true,
            body: _refreshIndicator(pageProvider),
            controller: pc,
            borderRadius: radius,
            maxHeight: MediaQuery.of(context).size.height - 300,
            minHeight: 0,
            panel: StreamBuilder(
              stream: songController.stream,
              builder: (context, snapshot) {
                if (snapshot.data == null) return const SizedBox.shrink();
                return SelectPlaylistWidget(
                    song: snapshot.data!, panelController: pc);
              },
            )),
      ),
    );
  }
}

class PageFilters extends StatefulWidget {
  const PageFilters({
    super.key,
  });

  @override
  State<PageFilters> createState() => _PageFiltersState();
}

class _PageFiltersState extends State<PageFilters> {
  int selectedFacetTile = -1;

  List<Widget> _getGenreChips(String facetCode, List<FacetValueDto> facetValues,
      Function isApplied, Function setDialogState, PageProvider pageProvider) {
    return facetValues.where((fv) => fv.code != '001').map((fv) {
      return GenreChip(
          selected: isApplied(fv),
          facetValueCode: fv.code,
          facetValueName: fv.name,
          facetValueCount: fv.count,
          onSelected: (bool selected) {
            setDialogState(() {
              pageProvider.search(fv.currentQueryUrl);
            });
          });
    }).toList();
  }

  List<Widget> _getChordsChips(
      String facetCode,
      List<FacetValueDto> facetValues,
      Function isApplied,
      Function setDialogState,
      PageProvider pageProvider) {
    return facetValues.map((fv) {
      return ChordChip(
          selected: isApplied(fv),
          facetValueCode: fv.code,
          facetValueName: fv.name,
          facetValueCount: fv.count,
          onSelected: (bool selected) {
            pageProvider.search(fv.currentQueryUrl);
          });
    }).toList();
  }

  List<Widget> _getPracticeTypeChips(
      String facetCode,
      List<FacetValueDto> facetValues,
      Function isApplied,
      Function setDialogState,
      PageProvider pageProvider) {
    return facetValues.map((fv) {
      return PracticeTypesChip(
          selected: isApplied(fv),
          facetValueCode: fv.code,
          facetValueName: fv.name,
          facetValueCount: fv.count,
          showCheckmark: false,
          onSelected: (bool selected) {
            pageProvider.search(fv.currentQueryUrl);
          });
    }).toList();
  }

  List<Widget> _getTempoSlider(SliderFacetDto sliderFacet,
      Function setDialogState, PageProvider pageProvider) {
    RangeValues tempoRangeValues = pageProvider.tempoRangeValues;

    return [
      Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                    '${tempoRangeValues.start.ceilToDouble()} - ${tempoRangeValues.end.ceilToDouble()}',
                    style: Theme.of(context).textTheme.titleMedium)),
          )
        ]),
      ),
      tempoRangeValues.start != -1 && tempoRangeValues.end != -1
          ? RangeSlider(
              values: tempoRangeValues,
              min: sliderFacet.initialMinValue.ceilToDouble(),
              max: sliderFacet.initialMaxValue.ceilToDouble(),
              labels: RangeLabels(
                tempoRangeValues.start.ceilToDouble().toString(),
                tempoRangeValues.end.ceilToDouble().toString(),
              ),
              onChanged: (RangeValues values) {
                setDialogState(() {
                  setState(() {
                    pageProvider.tempRangeValuesChanged(values);
                  });
                });
              },
              onChangeEnd: (RangeValues values) {
                pageProvider.tempRangeValuesChanged(values);
                String currentQueryTerm = pageProvider.queryTerm ?? '';
                String cleanedCurrentQueryTerm = currentQueryTerm.replaceAll(
                    RegExp(r':tempo:\[[^\]]*\]\[[^\]]*\]'), '');

                String query =
                    '${cleanedCurrentQueryTerm ?? ''}:tempo:[${values.start.ceilToDouble()}-${values.end.ceilToDouble()}][${sliderFacet.initialMinValue.ceilToDouble()}-${sliderFacet.initialMaxValue.ceilToDouble()}]';

                pageProvider.search(query);
              },
            )
          : Container()
    ];
  }

  @override
  Widget build(BuildContext context) {
    PageProvider pageProvider = PageProvider.of(context)!;

    return StatefulBuilder(builder: (dialogContext, setDialogState) {
      PageDto page = pageProvider.page;
      List<Widget> widgets = [];
      widgets.insert(
          0,
          Center(
              child: Text(AppLocalizations.of(context)!.filterBy,
                  style: Theme.of(context).textTheme.titleMedium)));
      widgets.insert(
          1,
          Container(
            width: MediaQuery.of(dialogContext).size.width - 200,

            // height: MediaQuery.of(context).size.height - 500,
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
                    isExpanded: selectedFacetTile == page.facets!.indexOf(f),
                    backgroundColor: Colors.transparent,
                    headerBuilder: (dialogContext, isOpen) {
                      return Text(f.name,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 2.5));
                    },
                    body: Padding(
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
                                  if (f.code == 'allCategories')
                                    ..._getGenreChips(f.code, f.values,
                                        (FacetValueDto fv) {
                                      return page.isFacetValueApplied(fv);
                                    }, setDialogState, pageProvider),
                                  if (f.code == 'chords')
                                    ..._getChordsChips(f.code, f.values,
                                        (FacetValueDto fv) {
                                      return page.isFacetValueApplied(fv);
                                    }, setDialogState, pageProvider),
                                  if (f.code == 'practiceTypes')
                                    ..._getPracticeTypeChips(f.code, f.values,
                                        (FacetValueDto fv) {
                                      return page.isFacetValueApplied(fv);
                                    }, setDialogState, pageProvider),
                                  if (f.code == 'musicKey')
                                    ..._getChordsChips(f.code, f.values,
                                        (FacetValueDto fv) {
                                      return page.isFacetValueApplied(fv);
                                    }, setDialogState, pageProvider),
                                  if (f.code == 'timeSignature')
                                    ..._getGenreChips(f.code, f.values,
                                        (FacetValueDto fv) {
                                      return page.isFacetValueApplied(fv);
                                    }, setDialogState, pageProvider),
                                  if (f.code == 'tempo')
                                    ..._getTempoSlider(
                                      f as SliderFacetDto,
                                      setDialogState,
                                      pageProvider,
                                    )
                                ])
                          ]),
                    ));
              }).toList(),

              expansionCallback: (panelIndex, isExpanded) {
                if (isExpanded) {
                  setState(() {
                    selectedFacetTile = panelIndex;
                  });
                } else {
                  setState(() {
                    selectedFacetTile = -1;
                  });
                }
              },
            ),
          ));
      return GestureDetector(
        onTap: () {
          pageProvider.toggleFilters();
        },
        child: Container(
          color: Colors.black.withAlpha(100),
          child: Container(
            constraints: BoxConstraints(
                // maxHeight: 60 / 100 * MediaQuery.of(context).size.height,
                ),
            child: SafeArea(
              child: SimpleDialog(
                insetPadding: EdgeInsets.all(10),
                children: widgets,
              ),
            ),
          ),
        ),
      );
    });
  }
}
