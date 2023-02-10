import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

class SlideshowPage extends StatelessWidget {
  const SlideshowPage(
      {super.key, required this.gallery, required this.filenames});

  final String gallery;
  final Iterable<String> filenames;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Builder(
        builder: (context) {
          return ImageSlideshow(
            indicatorRadius: 2.5,
            indicatorColor: Colors.blue,
            autoPlayInterval: 10000,
            isLoop: true,
            children: [for (String filename in filenames) getImage(filename)],
          );
        },
      ),
    );
  }

  getImage(String filename) {
    return Image.network(
        'http://footeware.ca:8000/galleries/$gallery/$filename',
        fit: BoxFit.contain, loadingBuilder: (BuildContext context,
            Widget child, ImageChunkEvent? loadingProgress) {
      if (loadingProgress == null) {
        return child;
      }
      return const Center(child: CircularProgressIndicator(color: Colors.grey));
    });
  }
}
