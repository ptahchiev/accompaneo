import 'package:flutter/material.dart';
import '../values/app_theme.dart';
import '../pages/playlist_page.dart';

enum ImageInfo {
  image0('The Flow', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_1.png'),
  image1('Through the Pane', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_2.png'),
  image2('Iridescence', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_3.png'),
  image3('Sea Change', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_4.png'),
  image4('Blue Symphony', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_5.png'),
  image5('When It Rains', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_6.png');


  const ImageInfo(this.title, this.subtitle, this.url);
  final String title;
  final String subtitle;
  final String url;
}

class HeroLayoutCard extends StatelessWidget {
  const HeroLayoutCard({
    super.key,
    required this.imageInfo,
  });

  final ImageInfo imageInfo;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: <Widget>[
          ClipRect(
            child: OverflowBox(
              maxWidth: width * 7 / 8,
              minWidth: width * 7 / 8,
              child: Image(
                fit: BoxFit.cover,
                image: NetworkImage(
                    'https://flutter.github.io/assets-for-api-docs/assets/material/${imageInfo.url}'),
              ),
            ),
          ),
          

          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  imageInfo.title,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  imageInfo.subtitle,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white),
                )
              ],
            ),
          ),
        ]);
  }
}


class Section extends StatelessWidget {

  final String title;

  final bool viewAll;

  const Section({super.key, required this.title, required this.viewAll});

  @override
  Widget build(BuildContext context) {

    final double height = MediaQuery.sizeOf(context).height;
    final CarouselController controller = CarouselController(initialItem: 0);

    return Column(children: [
          // SearchBar(hintText: "Search...",),
          //Column(children: [
          Container(
                color: Theme.of(context).cardColor,
                padding: EdgeInsets.all(5),
                child: 
                  Row(
                    children: [
                      //Expanded(child: Divider(color: Colors.grey.shade200)),
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
              scrollDirection: Axis.horizontal,
              itemSnapping: true,
              flexWeights: const <int>[1, 1, 1],
              children: ImageInfo.values.map((ImageInfo image) {
                return HeroLayoutCard(imageInfo: image);
              }).toList(),
            ),
          ),
        ]);
  }
}