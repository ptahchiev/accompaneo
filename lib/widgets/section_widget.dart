import 'package:accompaneo/models/artist.dart';
import 'package:accompaneo/models/browseable.dart';
import 'package:accompaneo/models/category.dart';
import 'package:accompaneo/models/playlists.dart';
import 'package:accompaneo/models/simple_playlist.dart';
import 'package:accompaneo/models/song/song.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:accompaneo/utils/helpers/navigation_helper.dart';
import 'package:accompaneo/values/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../values/app_theme.dart';
import 'package:accompaneo/widgets/hero_layout_card.dart';

class Section extends StatelessWidget {

  final SimplePlaylist playlist;


  final List<Browseable>? sectionData;

  const Section({super.key, required this.playlist, required this.sectionData});

  @override
  Widget build(BuildContext context) {

    final double height = MediaQuery.sizeOf(context).height - 100;
    final CarouselController controller = CarouselController(initialItem: 0);

    return Visibility(
      visible: sectionData != null && sectionData!.isNotEmpty,
      child: Column(children: [
        Container(
          color: Colors.transparent,
          padding: EdgeInsets.all(5),
          child: 
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    playlist.name,
                    style: AppTheme.sectionTitle,
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade600)),
                Visibility(visible: playlist.url != null,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(icon: Icon(Icons.arrow_circle_right_outlined), onPressed: () {
                        NavigationHelper.pushNamed(AppRoutes.playlist, arguments: {'playlist' : playlist});
                      }),
                    )
                )
              ],
            ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height / 5),
          child: CarouselView.weighted(
            controller: controller,
            elevation: 2.0,
            backgroundColor: Colors.transparent,
            scrollDirection: Axis.horizontal,
            itemSnapping: false,
            reverse: false,
            flexWeights: const <int>[1, 1, 1],
            onTap: (index) {
              if (sectionData![index] is Song) {
                ApiService.markSongAsPlayed(sectionData![index].code).then((v) {
                  Song song = sectionData![index] as Song;
                  Provider.of<PlaylistsModel>(context, listen: false).addSongToLatestPlayed(song);
                  NavigationHelper.pushNamed(AppRoutes.player, arguments: {'song' : song});
                });
                return;
              }

              if (sectionData![index] is Category) {
                NavigationHelper.pushNamed(AppRoutes.playlist, arguments : {'queryTerm' : ':allCategories:${(sectionData![index] as Category).code}', 'playlist' : SimplePlaylist(code: '', name: (sectionData![index] as Category).name, favourites: false, latestPlayed: false, searchable: true)});
                return;
              }              

              if (sectionData![index] is Artist) {
                NavigationHelper.pushNamed(AppRoutes.playlist, arguments : {'queryTerm' : ':artistCode:${(sectionData![index] as Artist).code}', 'playlist' : SimplePlaylist(code: '', name: 'Songs by ${(sectionData![index] as Artist).name}', favourites: false, latestPlayed: false, searchable: true)});
                return;
              }

              if (sectionData![index] is SimplePlaylist) {
                NavigationHelper.pushNamed(AppRoutes.playlist, arguments : {'playlist' : sectionData![index]});
                return;
              }
            },
            children: sectionData!.map((Browseable image) {
              return HeroLayoutCard(imageInfo: image);
            }).toList(),
          ),
        ),
      ]),
    );
  }
}