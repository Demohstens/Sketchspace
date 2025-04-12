import 'package:flutter/material.dart';
import 'package:sketchspace/canvas/actions.dart';
import 'package:sketchspace/components/layer_list.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/components/brush_menu.dart';
import 'package:sketchspace/components/context_menu/layer_context.dart';
import 'package:sketchspace/pages/settings_page.dart';

class CanvasUIDesktop extends StatefulWidget {
  @override
  _CanvasUIState createState() => _CanvasUIState();
}

class _CanvasUIState extends State<CanvasUIDesktop> {
  void toggleVisibilty() {
    setState(() {});
  }
  

  @override
  Widget build(BuildContext context) {
    final drawingContext = context.read<DrawingContext>(); 
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Actions(
          actions: <Type, Action<Intent>>{
            UndoIntent: UndoAction(drawingContext),
            RedoIntent: RedoAction(drawingContext),
          },
          child: Stack(
      children: [
         // Layer
        Positioned(
          top: MediaQuery.of(context).size.height * 0.5,
          right: 10,
          child: LayerList()),
                
        // Button to return Home and save if needed / allowed
        Positioned(
          right: 0,
          bottom: 0,
          child: FloatingActionButton(
              heroTag: "home",
              onPressed: () {
                if (context.read<Settings>().autoSave){
                  context
                      .read<DrawingContext>()
                      .saveFile(context)
                      .then((saveSuccess) {
                    if (mounted) {
                      // TODO load files
                      Navigator.pop(context);

                    }
                  });
                } else {
                  context.read<DrawingContext>().resetAll();
                  // TODO UPDATE files
                  Navigator.pop(context);
                }
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
