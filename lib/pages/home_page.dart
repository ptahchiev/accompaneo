import 'package:flutter/material.dart';
import 'package:accompaneo/widgets/section_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //       body: CustomScrollView(
    //         slivers: [
    //           SliverAppBar(),
    //           SliverList(delegate: SliverChildListDelegate(
    //             [
    //               Container(
    //                 width: double.infinity,
    //                 child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
    //                   const Section(title: 'Genres', viewAll: false),
    //                   const Section(title: 'Artists', viewAll: false),
    //                   const Section(title: 'Latest', viewAll: true),
    //                   const Section(title: 'Jump back in', viewAll: true),
    //                   const Section(title: 'Most Popular', viewAll: true),
    //                   const Section(title: 'Your favourites', viewAll: true)
    //                 ]),
    //               )
    //             ]
    //           ))
    //         ],
    //       ),
    // );


    return Scaffold(
      resizeToAvoidBottomInset:false,
      body: ListView(children: [
            const Section(title: 'Genres', viewAll: false),
            const Section(title: 'Artists', viewAll: false),
            const Section(title: 'Latest', viewAll: true),
            const Section(title: 'Jump back in', viewAll: true),
            const Section(title: 'Most Popular', viewAll: true),
            const Section(title: 'Your favourites', viewAll: true)
          ]),
          //bottomNavigationBar: buildAppNavigationBar(context, 0)
      );
  }
}