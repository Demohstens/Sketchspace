import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';
import 'package:sketchspace/classes/draw_file.dart';
import 'package:sketchspace/classes/drawing_context.dart';
import 'package:sketchspace/classes/settings.dart';
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
        title: const Text('Home Page - Sketchspace'),
      ),
      body: Container(
        child: Column(
          children: [
            TopBar(),
            FileGrid(),
          ],
        ),
      ),
    );
  }
}

// A display of all available Pages/windows. Hardcoded for now.
class FileGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<File> files = context.watch<DrawFileProvider>().files;
    if (files.isEmpty) {
      return Center(child: NewFileButton(tag: "newfileGrid"));
    } else {
      return Expanded(
          child: GridView(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 2,
              ),
              children: files.map((e) => DrawFileButton(e)).toList()));
    }
  }
}

class TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return // Top row of buttons: New File, Refresh
        Row(children: [
      SizedBox(
        child: NewFileButton(),
      ),
      Expanded(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
        ),
      ),
      SizedBox(
          child: Container(
              margin: EdgeInsets.all(10),
              child: FloatingActionButton(
                  onPressed: () {
                    context.read<DrawFileProvider>().updateFileList();
                  },
                  child: const Icon(Icons.refresh))))
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
      notifyListeners();
    });
  }
}

class DrawFileButton extends StatefulWidget {
  final File file;
  @override
  DrawFileButton(this.file);
  _DrawFileButtonState createState() => _DrawFileButtonState(file);
}

class _DrawFileButtonState extends State<DrawFileButton> {
  final File file;
  _DrawFileButtonState(this.file);

  bool hovering = false;
  Image? thumbnail;

  void _onHover(bool hover) {
    setState(() {
      hovering = hover;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: context.read<Settings>().secondaryColor,
      child: InkWell(
        onTap: () {
          context.read<DrawingContext>().loadFileContext(widget.file);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CanvasPage()),
          );
        },
        onHover: (hover) {
          _onHover(hover);
        },
        // child: Visibility(visible: hovering, child: Icon(Icons.image)),
        child: Stack(
          children: [
            if (thumbnail == null)
              const Center(child: Positioned(top: 30, child: Icon(Icons.image)))
            else
              Positioned.fill(
                child: Icon(Icons.image),
                //  Image.memory(
                // context.read<DrawingContext>().getThumbnail(widget.file)
                // fit: BoxFit.cover,`
              ),
            Positioned(
              left: 4,
              right: 4,
              bottom: 4,
              child:
                  Center(child: Text(basename(widget.file.path.split(".")[0]))),
            ),
            // Hover context menu
            Visibility(
                visible: hovering,
                child: Stack(children: [
                  // Delete button
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton(
                      onPressed: () {
                        widget.file.delete();
                        context.read<DrawFileProvider>().updateFileList();
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ),
                  // share
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: IconButton(
                      onPressed: () {
                        // Share(file);
                        context.read<DrawFileProvider>().updateFileList();
                      },
                      icon: const Icon(Icons.share),
                    ),
                  ),
                  // Rename
                  Positioned(
                    left: 0,
                    top: 0,
                    child: IconButton(
                      onPressed: () {
                        // Share(file);
                        context.read<DrawFileProvider>().updateFileList();
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  ),
                ]))
          ],
        ),
      ),
    );
  }
}

class NewFileButton extends StatelessWidget {
  final String tag;
  NewFileButton({this.tag = "newfile"});
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(10),
        child: FloatingActionButton.extended(
          heroTag: tag,
          tooltip: "Create a new file",
          onPressed: () {
            context.read<DrawingContext>().reset();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CanvasPage()),
            );
          },
          label: const Text("New File"),
          icon: FaIcon(FontAwesomeIcons.plus),
        ));
  }
}
