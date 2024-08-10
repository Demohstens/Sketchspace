import 'package:flutter/material.dart';
import 'package:flutter_application/classes/drawing_context.dart';
import 'package:flutter_application/classes/settings.dart';
import 'package:flutter_application/components/brush_menu.dart';
import 'package:flutter_application/components/drawing_canvas.dart';
import 'package:flutter_application/pages/homepage.dart';
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
            top: 0,
            right: 0,
            child: FloatingActionButton(
                heroTag: "darkmode",
                child: Icon(Icons.color_lens),
                onPressed: () => context.read<Settings>().toggleDarkMode())),
        Positioned(
            top: 0,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: BrushMenu()),
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
        Positioned(
            top: MediaQuery.of(context).size.height / 2,
            child: FloatingActionButton(
              heroTag: "save",
              onPressed: () {
                context.read<DrawingContext>().saveFile(context);
              },
            ))
      ],
    );
  }
}
