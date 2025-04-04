import 'package:flutter/material.dart';
import 'package:sketchspace/canvas/actions.dart';
import 'package:sketchspace/components/brush_menu_mobile.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/components/context_menu/layer_context.dart';

class CanvasUIMobile extends StatefulWidget {
  const CanvasUIMobile({super.key});

  @override
  _CanvasUIState createState() => _CanvasUIState();
}

class _CanvasUIState extends State<CanvasUIMobile> {
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
          child: Positioned(
            bottom: screenHeight * 0.03,
            left: screenWidth / 2 - 45,
            child: BrushMenuMobile()
          ));
  }
}


class LayerSlide extends StatefulWidget {
  const LayerSlide({super.key});

  @override
  _LayerSlideState createState() => _LayerSlideState();
}

class _LayerSlideState extends State<LayerSlide> {

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
              itemCount: context.read<DrawingContext>().canvas.layers.length,
              itemBuilder: (context, index) {
                var controller = PositionedContextController();
                var layer = context.read<DrawingContext>().canvas.layers.values.toList()[index];
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
                        tooltip: layer.name,
                        onPressed: () {
                          context.read<DrawingContext>().changeActiveLayer(layer);
                        },
                        icon: Icon(Icons.layers,
                        color: context.read<Settings>().secondaryColor
                        )),)
                        ])));}))
            ],
          )
          ,);
  }
}