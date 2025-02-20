import 'package:accompaneo/models/browseable.dart';
import 'package:accompaneo/models/song/song.dart';
import 'package:accompaneo/values/app_theme.dart';
import 'package:flutter/material.dart';

class HeroLayoutCard extends StatelessWidget {
  const HeroLayoutCard({
    super.key,
    required this.imageInfo,
  });

  final Browseable imageInfo;

  bool isSubtitlePresent() {
    return (imageInfo is Song) && (imageInfo as Song).artist.name.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double height = MediaQuery.sizeOf(context).height;
    
    return Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: <Widget>[
                ClipRect(
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: 
                      imageInfo.picture != null && imageInfo.picture!.isNotEmpty ?
                        Image.network(
                          imageInfo.picture!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return FittedBox(fit: BoxFit.fill, child: Container(color:Theme.of(context).colorScheme.primary, child: Icon(Icons.music_note, color: Colors.white)));
                          },                                  
                        )
                        :
                        FittedBox(fit: BoxFit.fill, child: Container(color:Theme.of(context).colorScheme.primary, child: Icon(Icons.music_note, color: Colors.white)))
                  ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent.withOpacity(0), Colors.black]))),
                Visibility(
                  visible: imageInfo.name.isNotEmpty || isSubtitlePresent(),
                  child: 
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Visibility(
                            visible: imageInfo.name.isNotEmpty,
                            child: Text(
                              imageInfo.name,
                              overflow: TextOverflow.clip,
                              softWrap: false,
                              style: AppTheme.heroCardTitle,
                            ),
                          ),
                          Visibility(
                            visible: isSubtitlePresent(),
                            child: Text(
                              (imageInfo is Song) ? (imageInfo as Song).artist.name : '',
                              overflow: TextOverflow.clip,
                              softWrap: false,
                              style: AppTheme.bodySmall.copyWith(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    )
                )
        ]);
  }
}