import 'package:accompaneo/models/artist.dart';
import 'package:accompaneo/models/banner.dart';
import 'package:accompaneo/models/browseable.dart';
import 'package:accompaneo/models/playlist.dart';
import 'package:accompaneo/models/simple_playlist.dart';
import 'package:accompaneo/models/song/song.dart';
import 'package:accompaneo/utils/helpers/navigation_helper.dart';
import 'package:accompaneo/values/app_routes.dart';
import 'package:flutter/material.dart';
import '../values/app_theme.dart';
import '../pages/playlist_page.dart';
import 'package:accompaneo/widgets/hero_layout_card.dart';

class Section extends StatelessWidget {

  final String title;

  final String? playlistUrl;

  final List<Browseable>? sectionData;

  const Section({super.key, required this.title, required this.playlistUrl, required this.sectionData});

  @override
  Widget build(BuildContext context) {

    final double height = MediaQuery.sizeOf(context).height;
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
                            title,
                            style: AppTheme.sectionTitle,
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade600)),
                        Visibility(visible: playlistUrl != null,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(icon: Icon(Icons.arrow_circle_right_outlined), onPressed: () {
                                NavigationHelper.pushNamed(AppRoutes.playlist, arguments: {'playlistUrl' : playlistUrl!, 'playlistCode' : ''});
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
                //overlayColor: MaterialColor(Colors.red, Colors.black),
                scrollDirection: Axis.horizontal,
                itemSnapping: false,
                reverse: false,
                flexWeights: const <int>[1, 1, 1],
                onTap: (index) {
                  if (sectionData![index] is Song) {
                    NavigationHelper.pushNamed(AppRoutes.player, arguments : {'song' : sectionData![index] as Song});
                    return;
                  }

                  if (sectionData![index] is Artist) {
                    NavigationHelper.pushNamed(AppRoutes.playlist, arguments : {'playlistUrl' : '/artist/${(sectionData![index] as Artist).code}', 'playlistCode' : ''});
                    return;
                  }

                  if (sectionData![index] is SimplePlaylist) {
                    NavigationHelper.pushNamed(AppRoutes.playlist, arguments : {'playlistUrl' : '/category/${sectionData![index].code}', 'playlistCode' : ''});
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