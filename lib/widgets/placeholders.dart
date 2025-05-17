import 'package:flutter/material.dart';
class PlaylistElementPlaceholder extends StatelessWidget {
  const PlaylistElementPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: 60.0,
          width: 60.0,
          color: Colors.white,
        ),
      ),
      visualDensity: VisualDensity(vertical: 1),
      isThreeLine: true,
      titleAlignment: ListTileTitleAlignment.center,
      title: Container(
        width: 200,
        height: 15.0,
        color: Colors.white,
      ),
      subtitle:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("song artist name", style: Theme.of(context).textTheme.bodySmall!.copyWith(background: Paint()..color = Colors.white)),
        Wrap(
          spacing: 10,
          children: ['Am', 'Cm', 'Dm', 'Em']
              .map<Widget>((ch) => Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(ch,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.black))))
              .toList(),
        )
      ]),
      trailing: Wrap(
        children: [
          IconButton(
              icon: Icon(Icons.favorite_outline_outlined),
              onPressed: () {
              }),
          IconButton(
              icon: Icon(Icons.more_horiz),
              onPressed: () => {})
        ],
      ));

    // return ListTile(
    //     visualDensity: VisualDensity(vertical: 1),
    //     isThreeLine: true,
    //     titleAlignment: ListTileTitleAlignment.center,
    //     //dense: true,
    //     leading: ClipRRect(
    //       borderRadius: BorderRadius.circular(10.0),
    //       child: Container(
    //         height: 60.0,
    //         width: 60.0,
    //         color: Colors.white,
    //       ),
    //     ),
    //     title: Column(
    //       spacing: 50,
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         FractionallySizedBox(
    //           widthFactor: 0.5,
    //           alignment: Alignment.centerLeft,
    //           child: Container(
    //             width: 200,
    //             height: 20.0,
    //             color: Colors.white,
    //           ),
    //         ),
    //       ],
    //     ),
    //     subtitle: Column(
    //       spacing: 10,
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         FractionallySizedBox(
    //           widthFactor: 0.3,
    //           alignment: Alignment.centerLeft,
    //           child: Container(
    //             width: 10.0,
    //             height: 14.0,
    //             color: Colors.white
    //           ),
    //         ),
    //         Wrap(
    //           spacing: 10,
    //           children: [
    //             Container(color: Colors.white, width: 20, height: 10),
    //             Container(color: Colors.white, width: 20, height: 10),
    //             Container(color: Colors.white, width: 20, height: 10),
    //           ]
    //         )
    //       ],
    //     ),
    //     trailing: Wrap(
    //       children: [
    //         Icon(Icons.favorite_outline_outlined),
    //         Icon(Icons.more_horiz)
    //       ],
    //     ),
    // );
  }
}

class PlaylistHeaderPlaceholder extends StatelessWidget {
  const PlaylistHeaderPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Container(
              width: 200,
              height: 25.0,
              color: Colors.white,
              //margin: const EdgeInsets.only(bottom: 8.0),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade500)),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child:
                      Container(
            padding: EdgeInsets.all(10),
            width: 50,
            height: 10.0,
            color: Colors.white,
            //margin: const EdgeInsets.only(bottom: 8.0),
          ),   ),
          )
        ],
      ),
    );
  }
}

class AppliedFacetsPlaceholder extends StatelessWidget {
  const AppliedFacetsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
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
              children: []
            )
          ]
        ),
      ),
    );
  }
}

class HomepageSectionsSectionPlaceholder extends StatelessWidget {
  const HomepageSectionsSectionPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    //final double width = MediaQuery.sizeOf(context).width;
    final double height = MediaQuery.sizeOf(context).height;
    return Column(children: [
        Container(
              color: Colors.transparent,
              padding: EdgeInsets.all(5),
              child: 
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        width: 200,
                        height: 25.0,
                        color: Colors.white,
                        //margin: const EdgeInsets.only(bottom: 8.0),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade600)),
                  ],
                ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height / 5),
          child: CarouselView.weighted(
            elevation: 2.0,
            backgroundColor: Colors.transparent,
            //overlayColor: MaterialColor(Colors.red, Colors.black),
            scrollDirection: Axis.horizontal,
            itemSnapping: false,
            reverse: false,
            flexWeights: const <int>[1, 1, 1],
            children: [
                Container(color: Colors.white),
                Container(color: Colors.white),
                Container(color: Colors.white)
            ]
          ),
        ),
      ])
    ;
  }
}