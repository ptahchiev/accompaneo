import 'package:flutter/material.dart';
class PlaylistElementPlaceholder extends StatelessWidget {
  const PlaylistElementPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {

    return ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white,
          ),
        ),
        title: Container(
          width: 200,
          height: 10.0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 8.0),
        ),
        subtitle: Container(
          width: 10.0,
          height: 10.0,
          color: Colors.white,
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