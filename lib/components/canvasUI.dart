import 'package:flutter/material.dart';
import 'package:sketchspace/classes/drawing_context.dart';
import 'package:sketchspace/classes/settings.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/components/brush_menu.dart';
import 'package:sketchspace/pages/homepage.dart';
import 'package:sketchspace/pages/settings_page.dart';

class CanvasUI extends StatefulWidget {
  @override
  _CanvasUIState createState() => _CanvasUIState();
}

class _CanvasUIState extends State<CanvasUI> {
  void toggleVisibilty() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Visibility(
        child: Stack(
      children: [
        Positioned(
            top: 0,
            left: 0,
            child: Text(
                "${context.read<DrawingContext>().scale.toString()}, panx: ${context.read<DrawingContext>().transformMatrix.getTranslation().x}, pany: ${context.read<DrawingContext>().transformMatrix.getTranslation().y}")),
        // Button to return Home and save if needed / allowed
        Positioned(
          right: 0,
          bottom: 0,
          child: FloatingActionButton(
              heroTag: "home",
              onPressed: () {
                if (context.read<Settings>().autoSaveExistingFiles &&
                    context.read<DrawingContext>().buffer != []) {
                  context
                      .read<DrawingContext>()
                      .saveFile(context)
                      .then((saveSuccess) {
                    if (mounted) {
                      Navigator.pop(context);
                      context.read<DrawFileProvider>().updateFileList();

                      context.read<DrawingContext>().reset();
                    }
                  });
                } else {
                  context.read<DrawingContext>().reset();
                  context.read<DrawFileProvider>().updateFileList();
                  Navigator.pop(context);
                }

                context.read<DrawFileProvider>().updateFileList();
              },
              child: Icon(Icons.home)),
        ),
        // Open Settings Page
        Positioned(
            top: screenHeight * 0.05,
            right: 0,
            child: FloatingActionButton(
                heroTag: "settingscanvas",
                child: const Icon(Icons.settings),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage())))),
        // Brush Menu
        Positioned(
            bottom: screenHeight * 0.01,
            left: screenWidth / 2 - 50,
            child: BrushMenu()),
        // Reset Button
        Positioned(
          bottom: 0,
          left: 0,
          child: FloatingActionButton(
            heroTag: "reset",
            onPressed: () {
              context.read<DrawingContext>().reset();
            },
            child: Icon(Icons.lock_reset_sharp),
          ),
        ),
        // Redo/undo
        Positioned(
            top: screenHeight * 0.45,
            child: Container(
                decoration: BoxDecoration(
                    color: context.read<Settings>().background,
                    border: Border.all(
                        width: 1,
                        color: context.watch<Settings>().secondaryColor)),
                child: Column(children: [
                  // Redo Button
                  IconButton(
                      onPressed: () {
                        context.read<DrawingContext>().redo();
                      },
                      icon: Icon(Icons.redo,
                          color: context.read<Settings>().secondaryColor)),
                  // Undo Button
                  IconButton(
                      onPressed: () {
                        context.read<DrawingContext>().undo();
                      },
                      icon: Icon(
                        Icons.undo,
                        color: context.read<Settings>().secondaryColor,
                      )),
                ]))),
      ],
    ));
  }
}
