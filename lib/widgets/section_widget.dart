import 'package:accompaneo/models/song/image_data.dart';
import 'package:flutter/material.dart';
import '../values/app_theme.dart';
import '../pages/playlist_page.dart';
import 'package:accompaneo/widgets/hero_layout_card.dart';

class Section extends StatelessWidget {

  final String title;

  final String? playlistUrl;

  final List<ImageData>? sectionData;

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
                                Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistPage(playlistUrl:playlistUrl!, playlistCode: '')));
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
                children: sectionData!.map((ImageData image) {
                  return HeroLayoutCard(imageInfo: image);
                }).toList(),
              ),
            ),
          ]),
    );
  }
}