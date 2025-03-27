import 'package:flutter/material.dart';
import 'package:sketchspace/canvas/Actions.dart';
import 'package:sketchspace/canvas/drawing_context.dart';
import 'package:sketchspace/classes/settings.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/components/brush_menu.dart';
import 'package:sketchspace/components/context_menu/layer_context.dart';
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
          child: Column(
            children: [
              IconButton(onPressed: () {
                context.read<DrawingContext>().newLayer();
                
              }, icon: const Icon(Icons.add)),
              SizedBox(
            height: 200,
            width: 100,
            child:  ListView.builder(
              reverse: true,
              itemCount: context.read<DrawingContext>().layers.length,
              itemBuilder: (context, index) {
                var controller = PositionedContextController();
                var layer = context.read<DrawingContext>().layers[index];
                var isActive = context.watch<DrawingContext>().activeLayer.id == layer.id;
                var isVisible = layer.visible;
                var backgroundOpacity = isVisible ? 255 : 100;
                var background = isActive ? Colors.red : layer.visible ? context.read<Settings>().background : Colors.grey;
                return GestureDetector(
                  onLongPress: () => controller.show(), // TODO
                  onSecondaryTapUp: (details) => {
                    controller.setPosition(details.globalPosition),
                    controller.show() 
                    },
                  child: 
                Container(
                    decoration: BoxDecoration(
                        color: background.withAlpha(backgroundOpacity),
                        border: Border.all(
                            width: 1,
                            color: context.watch<Settings>().secondaryColor)),
                    child:
                    Row(children: [
                      // Toggle layer visibility
                      IconButton(
                        tooltip: 'Toggle visibility',
                        onPressed: () {
                          layer.toggleVisibilty();
                          context.read<DrawingContext>().repaint();
                        }, 
                        icon: Icon(isVisible? Icons.visibility : Icons.visibility_off,
                          size: 15,
                          color: context.read<Settings>().secondaryColor)),
                      // Change Layer
                      LayerContextMenu(controller, IconButton(
                        tooltip: context.read<DrawingContext>().layers[index].name,
                        onPressed: () {
                          context.read<DrawingContext>().changeActiveLayer(context.read<DrawingContext>().layers[index]);
                        },
                        icon: Icon(Icons.layers,
                        color: context.read<Settings>().secondaryColor
                        )),)
                        ])));}))
            ],
          )
          ,),
                
        // Button to return Home and save if needed / allowed
        Positioned(
          right: 0,
          bottom: 0,
          child: FloatingActionButton(
              heroTag: "home",
              onPressed: () {
                // TODO: Add auto save on exit
                if (context.read<Settings>().autoSaveExistingFiles ){
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
