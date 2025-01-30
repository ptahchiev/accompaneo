
import 'package:flutter/material.dart';

class BrowsableImage extends StatelessWidget {
  final Color? backgroundColor;
  final IconData icon; 
  final String imageUrl;

  // Constructor
  const BrowsableImage({
    super.key,
    this.backgroundColor,
    this.icon = Icons.music_note,
    this.imageUrl = ''
  });

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        height: 80.0,
        width: 60.0,
        color: backgroundColor ?? Theme.of(context).colorScheme.primary,
        child: imageUrl.isEmpty ? Icon(icon, color: Colors.white, size: 30.0) : Image(height: 80, fit: BoxFit.cover, image: NetworkImage(imageUrl))
      ),
    );
  }
}