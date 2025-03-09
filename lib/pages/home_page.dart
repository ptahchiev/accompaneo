import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:accompaneo/models/homepage_sections.dart';
import 'package:accompaneo/models/playlists.dart';
import 'package:accompaneo/models/simple_playlist.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:accompaneo/values/app_colors.dart';
import 'package:accompaneo/widgets/placeholders.dart';
import 'package:flutter/material.dart';
import 'package:accompaneo/widgets/section_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late Future<HomepageSections> futureHomepageSections;

  @override
  void initState() {
    super.initState();
    getHomepageSections();
  }

  void getHomepageSections() {
    setState(() {
      futureHomepageSections = ApiService.getHomepageSections();
    });
  }

  Future<void> _pullRefresh() async {
    getHomepageSections();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      color: AppColors.primaryColor,
      onRefresh: _pullRefresh,
        child: Scaffold(
        resizeToAvoidBottomInset:false,
        body: FutureBuilder<HomepageSections>(
          future: futureHomepageSections,
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return Consumer<PlaylistsModel>(
                builder: (context, playlists, child) {
                  return ListView(
                    controller: ScrollController(),
                    children: [
                      Section(playlist: SimplePlaylist(code: '', name: AppLocalizations.of(context)!.genres), sectionData: snapshot.data?.genres),
                      Section(playlist: SimplePlaylist(code: '', name: AppLocalizations.of(context)!.artists), sectionData: snapshot.data?.artists),
                      Section(playlist: SimplePlaylist(code: '', name: AppLocalizations.of(context)!.mostPopular, url: '/mostPopular'), sectionData: snapshot.data?.mostPopular),
                      Section(playlist: SimplePlaylist(code: '', name: AppLocalizations.of(context)!.latest, url: '/latestAdded'), sectionData: snapshot.data?.latestAdded),
                      Consumer<PlaylistsModel>(
                          builder: (context, playlists, child) {
                            return Section(playlist: SimplePlaylist(code: '', name: AppLocalizations.of(context)!.jumpBackIn, url: '/latestPlayed', favourites: false, latestPlayed: true), sectionData: playlists.getLatestPlayedPlaylistSongs());
                          }
                      ),
                      Consumer<PlaylistsModel>(
                          builder: (context, playlists, child) {
                            return Section(playlist: SimplePlaylist(code: '', name: AppLocalizations.of(context)!.yourFavourites, url: '/favourites', favourites: true, latestPlayed: false), sectionData: playlists.getFavouritesPlaylist() != null ? playlists.getFavouritesPlaylist()!.firstPageSongs.content : []);
                          }
                      )
                  ]
                );
                }
              );
            } else if (snapshot.hasError) {
              return Text('ERROR ${snapshot.error}');
            }
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              loop: 0,
              enabled: true,
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  children: [ 
                    HomepageSectionsSectionPlaceholder(),
                    HomepageSectionsSectionPlaceholder(),
                    HomepageSectionsSectionPlaceholder(),
                    HomepageSectionsSectionPlaceholder(),
                    HomepageSectionsSectionPlaceholder(),
                  ]
                )
              )
            );
          })
        )
      )
    );
  }
}