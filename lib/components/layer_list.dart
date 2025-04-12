import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/components/context_menu/layer_context.dart';
import 'package:sketchspace/components/context_menu/stroke_context.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';

class LayerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: context.read<Settings>().background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: Colors.black),
      ),
      child: Column(
        children: [
          IconButton(
            onPressed: () {
              context.read<DrawingContext>().newLayer();
            },
            icon: const Icon(Icons.add),
          ),
          SizedBox(
            height: 200,
            width: 100,
            child: ListView.builder(
              reverse: true,
              itemCount: context.watch<DrawingContext>().canvas.layers.length,
              itemBuilder: (context, index) {
                var contextMenuController = PositionedContextController();
                var layer =
                    context
                        .watch<DrawingContext>()
                        .canvas
                        .layers
                        .values
                        .toList()[index];
                var isActive =
                    context.watch<DrawingContext>().activeLayer.id == layer.id;
                var isVisible = layer.visible;
                var backgroundOpacity = isVisible ? 255 : 100;
                var background =
                    isActive
                        ? const Color.fromARGB(255, 212, 100, 92)
                        : layer.visible
                        ? context.read<Settings>().background
                        : const Color.fromARGB(255, 209, 209, 209);
                return GestureDetector(
                  onLongPress: () => contextMenuController.show(), // TODO
                  onSecondaryTapUp:
                      (details) => {
                        contextMenuController.setPosition(details.globalPosition),
                        contextMenuController.show(),
                      },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: background.withAlpha(backgroundOpacity),
                    ),
                    child: Row(
                      children: [
                        // Toggle layer visibility
                        IconButton(
                          tooltip: 'Toggle visibility',
                          onPressed: () {
                            layer.toggleVisibilty();
                            context.read<DrawingContext>().repaint();
                          },
                          icon: Icon(
                            isVisible ? Icons.visibility : Icons.visibility_off,
                            size: 15,
                            color: context.read<Settings>().secondaryColor,
                          ),
                        ),
                        // Change Layer
                        LayerContextMenu(
                          contextMenuController,
                          IconButton(
                            tooltip: layer.name,
                            onPressed: () {
                              context.read<DrawingContext>().changeActiveLayer(
                                layer,
                              );
                            },
                            icon: Icon(
                              Icons.layers,
                              color: context.read<Settings>().secondaryColor,
                            ),
                          ),
                          layer.id,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
