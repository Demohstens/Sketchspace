import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application/classes/draw_file.dart';
import 'package:flutter_application/classes/drawing_context.dart';
import 'package:flutter_application/pages/canvas.dart';
import 'package:provider/provider.dart';

// Menu for selecting pages (Canvas, etc.)
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: FileGrid(),
    );
  }
}

// A display of all available Pages/windows. Hardcoded for now.
class FileGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DrawFileProvider>(builder: (_, provider, __) {
      if (provider.files.isEmpty) {
        return Center(child: CircularProgressIndicator());
      } else {
        return GridView.count(
            crossAxisCount: 3,
            children: provider.files.map((e) => DrawFileButton(e)).toList());
      }
    });
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
}

class DrawFileButton extends StatelessWidget {
  final File file;
  DrawFileButton(this.file);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          context.read<DrawingContext>().loadFileContext(file);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CanvasPage()),
          );
        },
        child: Text(file.uri.toString()),
      ),
    );
  }
}
