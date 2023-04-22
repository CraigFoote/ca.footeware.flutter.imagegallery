import 'package:flutter/material.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

class ImagePage extends StatelessWidget {
  const ImagePage({super.key, required this.gallery, required this.filename});

  final String gallery;
  final String filename;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SimpleGestureDetector(
        child: Center(
          child: Hero(
            tag: filename,
            child:  Image.network('http://footeware.ca:8000/galleries/$gallery/$filename'),
            ),
          ),
        onVerticalSwipe: (swipeDirection) => Navigator.pop(context),
      ),
    );
  }
}
