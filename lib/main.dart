import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'thumbnails_page.dart';

void main() {
  runApp(const ImageGallery());
}

class ImageGallery extends StatelessWidget {
  const ImageGallery({super.key});

  static const title = "Gallery";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const GalleryListPage(title: title),
    );
  }
}

class GalleryListPage extends StatefulWidget {
  const GalleryListPage({super.key, required this.title});

  final String title;

  @override
  State<GalleryListPage> createState() => _GalleryListPageState();
}

class _GalleryListPageState extends State<GalleryListPage> {
  late final List<String> base64s;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: _fetchGalleries(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            Map<String, bool> map = snapshot.data;
            return ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: map.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  elevation: 5.0,
                  child: ListTile(
                    trailing: map.values.elementAt(index)
                        ? const Icon(Icons.lock_outline)
                        : const Icon(Icons.lock_open),
                    title:
                        Text(map.keys.elementAt(index), textScaleFactor: 2.0),
                    tileColor: Colors.black12,
                    contentPadding: const EdgeInsets.all(10.0),
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThumbnailsPage(
                            galleryName: map.keys.elementAt(index),
                          ),
                        ),
                      ),
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<Map<String, bool>> _fetchGalleries() async {
    Map<String, bool> galleries = {};
    var url = Uri.http('footeware.ca:8000', '/galleries');
    var response = await http.get(url);
    final List json = jsonDecode(response.body);
    for (var element in json) {
      String? name = element['name'];
      bool locked = element['secret'];
      galleries[name!] = locked;
    }
    return galleries;
  }
}
