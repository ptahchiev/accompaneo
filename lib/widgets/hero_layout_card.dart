import 'package:accompaneo/utils/helpers/navigation_helper.dart';
import 'package:accompaneo/values/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:accompaneo/models/banner.dart';


class HeroLayoutCard extends StatelessWidget {
  const HeroLayoutCard({
    super.key,
    required this.imageInfo,
  });

  final BannerData imageInfo;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double height = MediaQuery.sizeOf(context).height;
    
    // if ()


    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: ()=> {
        print('aa'),
        NavigationHelper.pushNamed(AppRoutes.forgotPassword)
      },
      child: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: <Widget>[
                  GestureDetector(
                    onTap: () => {
                      print('1')
                    },
                    child: GestureDetector(
                      onTap: () => {
                        print('sss')
                      },
                      child: ClipRect(
                            child: SizedBox(
                              width: width,
                              height: height,
                              child: 
                                  imageInfo.imageUrl != null && imageInfo.imageUrl!.isNotEmpty ?
                                    Image(
                                        fit: BoxFit.cover,
                                        image: NetworkImage('${imageInfo.imageUrl}'),
                                    )
                                    :
                                    FittedBox(fit: BoxFit.cover, child: Container(color:Theme.of(context).colorScheme.primary, child: Icon(Icons.music_note, color: Colors.white)))
                            ),
                        ),
                    ),
                  ),
                  GestureDetector(
                    onTap: ()=>{
                      print('aaa')
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent.withOpacity(0), Colors.black]))),
                  ),
                  GestureDetector(
                    onTap: ()=>{
                      print('')
                    },
                    child: Visibility(
                      visible: imageInfo.title.isNotEmpty || imageInfo.subtitle.isNotEmpty,
                      child: 
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Visibility(
                                visible: imageInfo.title.isNotEmpty,
                                child: Text(
                                  imageInfo.title,
                                  overflow: TextOverflow.clip,
                                  softWrap: false,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: Colors.white),
                                ),
                              ),
                              Visibility(
                                visible: imageInfo.subtitle.isNotEmpty,
                                child: Text(
                                  imageInfo.subtitle,
                                  overflow: TextOverflow.clip,
                                  softWrap: false,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        )
                    ),
                  )
          ]),
    );
  }
}