import 'dart:convert';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery/info_page.dart';

import 'thumbnails_page.dart';

void main() {
  runApp(const ImageGallery());
}

class ImageGallery extends StatefulWidget {
  const ImageGallery({super.key});
  @override
  State<StatefulWidget> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  static const title = "Image Gallery";
  late ThemeMode themeMode = ThemeMode.dark;

  toggleThemeMode() {
    setState(() {
      themeMode =
          (themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: title,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: lightColorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme,
          useMaterial3: true,
        ),
        themeMode: themeMode,
        home: _GalleryListPage(title: title, themeModeCallBack: toggleThemeMode),
      );
    });
  }
}

class _GalleryListPage extends StatefulWidget {
  const _GalleryListPage(
      {required this.title, required this.themeModeCallBack});

  final String title;
  final Function() themeModeCallBack;

  @override
  State<_GalleryListPage> createState() => _GalleryListPageState();
}

class _GalleryListPageState extends State<_GalleryListPage> {
  late final List<String> base64s;
  final textController = TextEditingController();
  bool authenticated = false;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                widget.themeModeCallBack();
              });
            },
            icon: const Icon(Icons.invert_colors),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InfoPage(title: 'Info'),
                ),
              );
            },
            icon: const Icon(Icons.info_outline),
            tooltip: 'Info',
          ),
        ],
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
                    title:
                        Text(map.keys.elementAt(index), textScaleFactor: 1.5),
                    trailing: map.values.elementAt(index) && !authenticated
                        ? const Icon(
                            Icons.lock_outline,
                            color: Colors.red,
                          )
                        : const Icon(
                            Icons.lock_open,
                          ),
                    contentPadding: const EdgeInsets.all(10.0),
                    onTap: () => map.values.elementAt(index) && !authenticated
                        ? showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: TextField(
                                  autofocus: true,
                                  controller: textController,
                                  maxLength: 5,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: "Password",
                                  ),
                                  onSubmitted: (value) {
                                    if (value == 'bogie') {
                                      Navigator.pop(context);
                                      setState(() => authenticated = true);
                                    }
                                  },
                                ),
                              );
                            },
                          )
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ThumbnailsPage(
                                galleryName: map.keys.elementAt(index),
                              ),
                            ),
                          ),
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
      bool secret = element['secret'];
      galleries[name!] = secret;
    }
    return galleries;
  }
}
