import 'package:flutter/material.dart';
class PlaylistElementPlaceholder extends StatelessWidget {
  const PlaylistElementPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {

    return ListTile(
        visualDensity: VisualDensity(vertical: 0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            height: 80.0,
            width: 60.0,
            color: Colors.white,
          ),
        ),
        title: FractionallySizedBox(
          widthFactor: 0.5,
          alignment: Alignment.centerLeft,
          child: Container(
            width: 200,
            height: 15.0,
            color: Colors.white,
          ),
        ),
        subtitle: FractionallySizedBox(
          widthFactor: 0.3,
          alignment: Alignment.centerLeft,
          child: Container(
            width: 10.0,
            height: 15.0,
            color: Colors.white
          ),
        ),
        trailing: Wrap(
          children: [
            Icon(Icons.favorite_outline_outlined),
            Icon(Icons.more_horiz)
          ],
        ),
    );
  }
}

class PLaylistHeaderPlaceholder extends StatelessWidget {
  const PLaylistHeaderPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            width: 200,
            height: 25.0,
            color: Colors.white,
            //margin: const EdgeInsets.only(bottom: 8.0),
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