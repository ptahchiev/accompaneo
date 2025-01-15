import 'package:accompaneo/song/image_data.dart';
import 'package:flutter/material.dart';
import '../values/app_theme.dart';
import '../pages/playlist_page.dart';
import 'package:accompaneo/widgets/hero_layout_card.dart';

List<ImageData> images=[
  ImageData(title: 'The Flow', subtitle: 'Sponsored | Season 1 Now Streaming',
      url:'content_based_color_scheme_1.png'),

  ImageData(title:'Through the Pane', subtitle: 'Sponsored | Season 1 Now Streaming',
      url: 'content_based_color_scheme_2.png'),

  ImageData(title: 'Iridescence', subtitle: 'Sponsored | Season 1 Now Streaming',
      url: 'content_based_color_scheme_3.png'),

  ImageData(title:'Sea Change', subtitle: 'Sponsored | Season 1 Now Streaming',
       url: 'content_based_color_scheme_4.png'),

  ImageData(title:'Blue Symphony', subtitle: 'Sponsored | Season 1 Now Streaming',
      url: 'content_based_color_scheme_5.png'),

  ImageData(title: 'When It Rains', subtitle: 'Sponsored | Season 1 Now Streaming',
      url: 'content_based_color_scheme_6.png'),

  ImageData(title: 'AAAA', subtitle: 'Sponsored | Season 1 Now Streaming',
      url: ''),

  ImageData(title: '', subtitle: '', url: 'content_based_color_scheme_6.png')    
];

class Section extends StatelessWidget {

  final String title;

  final bool viewAll;

  const Section({super.key, required this.title, required this.viewAll});

  @override
  Widget build(BuildContext context) {

    final double height = MediaQuery.sizeOf(context).height;
    final CarouselController controller = CarouselController(initialItem: 0);

    return Column(children: [
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
                      Visibility(visible: viewAll,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(icon: Icon(Icons.arrow_circle_right_outlined), onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistPage(songs:[])));
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
              children: images.map((ImageData image) {
                return HeroLayoutCard(imageInfo: image);
              }).toList(),
            ),
          ),
        ]);
  }
}