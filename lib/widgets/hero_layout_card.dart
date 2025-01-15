import 'package:flutter/material.dart';
import '../utils/helpers/snackbar_helper.dart';
import '../widgets/app_text_form_field.dart';
import '../values/app_strings.dart';
import '../values/app_theme.dart';
import 'package:accompaneo/song/image_data.dart';


class HeroLayoutCard extends StatelessWidget {
  const HeroLayoutCard({
    super.key,
    required this.imageInfo,
  });

  final ImageData imageInfo;

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
              child: 
                  imageInfo.url.isNotEmpty ?
                    Image(
                      fit: BoxFit.cover,
                      image: NetworkImage('https://flutter.github.io/assets-for-api-docs/assets/material/${imageInfo.url}'))
                    :
                    FittedBox(fit: BoxFit.cover, child: Container(color:Theme.of(context).colorScheme.primary, child: Icon(Icons.music_note, color: Colors.white)))
            ),
          ),
          
          Visibility(
            visible: imageInfo.title.isNotEmpty && imageInfo.subtitle.isNotEmpty,
            child: 
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
              )
          )
        ]);
  }
}