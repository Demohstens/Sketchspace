import 'package:sketchspace/classes/drawing_context.dart';
import 'package:sketchspace/classes/settings.dart';
import 'package:sketchspace/components/brush_menu.dart';
import 'package:sketchspace/components/drawing_canvas.dart';
import 'package:sketchspace/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CanvasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: DrawingCanvas(),
        ),
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
                    Navigator.pop(context);
                    context.read<DrawingContext>().reset();
                  });
                } else {
                  context.read<DrawingContext>().reset();
                  Navigator.pop(context);
                }

                context.read<DrawFileProvider>().updateFileList();
              },
              child: Icon(Icons.home)),
        ),
        // Toggle Dark mode button
        Positioned(
            top: MediaQuery.of(context).size.height * 0.05,
            right: 0,
            child: FloatingActionButton(
                heroTag: "darkmode",
                child: Icon(Icons.color_lens),
                onPressed: () => context.read<Settings>().toggleDarkMode())),
        // Brush Menu
        Positioned(
            bottom: MediaQuery.of(context).size.height * 0.01,
            left: MediaQuery.of(context).size.width / 2 - 50,
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
            top: MediaQuery.of(context).size.height * 0.45,
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
    );
  }
}
