import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/components/context_menu/layer_context.dart';
import 'package:sketchspace/components/context_menu/stroke_context.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';

class LayerList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
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
          );
  }
}