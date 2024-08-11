import 'dart:io';

import 'package:sketchspace/classes/draw_file.dart';
import 'package:sketchspace/classes/drawing_context.dart';
import 'package:sketchspace/pages/canvas.dart';
import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// Menu for selecting pages (Canvas, etc.)
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page - Sketchspace'),
      ),
      body: FileGrid(),
    );
  }
}

// A display of all available Pages/windows. Hardcoded for now.
class FileGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey),
            ),
            child: TextButton(
                onPressed: () {
                  context.read<DrawingContext>().reset();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CanvasPage()),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      "+",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                    Text(
                      " New File",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
          ),
          IconButton(
              onPressed: () {
                context.read<DrawFileProvider>().updateFileList();
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      Expanded(
        flex: 4,
        child: Consumer<DrawFileProvider>(builder: (_, provider, __) {
          context.watch<DrawFileProvider>().files;
          print("Building FileGrid");
          if (provider.files.isEmpty) {
            return Center(child: CircularProgressIndicator());
          } else {
            return GridView.count(
                crossAxisCount: 6,
                children:
                    provider.files.map((e) => DrawFileButton(e)).toList());
          }
        }),
      )
    ]);
  }
}

class DrawFileProvider extends ChangeNotifier {
  List<File> files = [];
  DrawFileProvider() {
    getFiles().then((value) {
      files = value;
      notifyListeners();
    });
  }
  void updateFileList() {
    getFiles().then((value) {
      files = value;
      print("Files updated");
      notifyListeners();
    });
  }
}

class DrawFileButton extends StatelessWidget {
  final File file;
  DrawFileButton(this.file);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(children: [
        TextButton(
          onPressed: () {
            context.read<DrawingContext>().loadFileContext(file);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CanvasPage()),
            );
          },
          child: Text(file.uri.toString()),
        ),
        Positioned(
            right: 0,
            bottom: 0,
            child: IconButton(
              onPressed: () {
                file.delete();
                context.read<DrawFileProvider>().updateFileList();
              },
              icon: Icon(Icons.delete),
            )),
      ]),
    );
  }
}
