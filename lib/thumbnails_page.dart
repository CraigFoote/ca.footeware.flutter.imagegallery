import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'image_page.dart';

class ThumbnailsPage extends StatefulWidget {
  const ThumbnailsPage({super.key, required this.galleryName});

  final String galleryName;

  @override
  State<StatefulWidget> createState() => ThumbnailsPageState();
}

class ThumbnailsPageState extends State<ThumbnailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.galleryName),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return FutureBuilder(
            future: _fetchThumbnails(),
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else {
                Map<String, Image> map = snapshot.data;
                return GridView.builder(
                  itemCount: map.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      child: Hero(
                        tag: map.keys.elementAt(index),
                        child: map.values.elementAt(index),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ImagePage(
                            gallery: widget.galleryName,
                            filename: map.keys.elementAt(index),
                          ),
                        ),
                      ),
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth > 700 ? 4 : 2,
                    mainAxisExtent: 150,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Future<Map<String, Image>> _fetchThumbnails() async {
    Map<String, Image> thumbs = {};
    var url = Uri.http('footeware.ca:8000', '/galleries/${widget.galleryName}');
    var response = await http.get(url);
    final List json = jsonDecode(response.body);
    for (var element in json) {
      String filename = element['filename'];
      String? thumb = element['thumb'];
      Uint8List bytes = base64.decode(thumb!);
      Image image = Image.memory(bytes);
      thumbs[filename] = image;
    }
    return thumbs;
  }
}
