import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePage extends StatelessWidget {
  const ImagePage({super.key, required this.gallery, required this.filename});

  final String gallery;
  final String filename;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: filename,
            child: PhotoView(
              imageProvider: NetworkImage(
                'http://footeware.ca:8000/galleries/$gallery/$filename',
              ),
              minScale: 0.1,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
