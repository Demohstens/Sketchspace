import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sketchspace/canvas/drawing_context.dart';
import 'package:sketchspace/components/new_file_dialog.dart';
import 'package:sketchspace/utils/draw_file.dart';
import 'package:sketchspace/classes/settings.dart';
import 'package:sketchspace/components/file_save_dialogs.dart';
import 'package:sketchspace/pages/canvas.dart';
import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/pages/settings_page.dart';

// Menu for selecting pages (Canvas, etc.)
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page - Sketchspace'),
        actions: [
          SizedBox(
        child: NewFileButton(),
      ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SettingsPage()))
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            FileGrid(),
          ],
        ),
      ),
    );
  }
}

class FileGrid extends StatefulWidget {
  @override
  _FileGridState createState() => _FileGridState();
}

// A display of all available Pages/windows. Hardcoded for now.
class _FileGridState extends State<FileGrid> {
  List<File> files = [];
  
  void setFiles(List<File> files) {
    setState(() {
      files = files;
    });
  }

  @override
  Widget build(BuildContext context) {
    getFiles().then((value) {
      setState(() {
        files = value;
      });
    });
    if (files.isEmpty) {
      return Expanded(child: Center(child: NewFileButton(tag: "newfileGrid")));
    } else {
      return Expanded(
          child: GridView(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 2,
              ),
              children: files.map((e) => DrawFileButton(e, setFiles)).toList()));
    }
  }
}

class DrawFileButton extends StatefulWidget {
  final File file;
  final Function setFiles;
  @override
  DrawFileButton(this.file, this.setFiles);
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
        onLongPress: () {
          hovering = true;
        },
        // child: Visibility(visible: hovering, child: Icon(Icons.image)),
        child: Stack(
          children: [
            if (thumbnail == null)
              const Center(child: Icon(Icons.image))
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
                  Center(child: Text(basename(widget.file.path).replaceFirst(".json", ""))),
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
                        getFiles().then((value) {
                          setState(() {
                            widget.setFiles(value);
                          });
                        });
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
                        Share.share(
                            "...But in the meantime check out this project's reposity for updates! ",
                            subject:
                                "This feature is not yet Implemented: https://github.com/Demohstens/Sketchspace");
                        getFiles().then((value) {
                          setState(() {
                            widget.setFiles(value);
                          });
                        });
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
                        // Rename file
                        showFileRenameDialog(context, file).then((value) {
                          if (mounted) {
                            // TODO
                          }
                        });
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
