import 'package:flutter/material.dart';
import 'package:sketchspace/canvas/actions.dart';
import 'package:sketchspace/components/add_imported.dart';
import 'package:sketchspace/components/brush_menu_mobile.dart';
import 'package:sketchspace/components/collapsed_layer_button.dart';
import 'package:sketchspace/components/color_selector.dart';
import 'package:sketchspace/components/width_menu.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:provider/provider.dart';

class CanvasUIMobile extends StatefulWidget {
  const CanvasUIMobile({super.key});

  @override
  _CanvasUIState createState() => _CanvasUIState();
}

class _CanvasUIState extends State<CanvasUIMobile> {
  void toggleVisibilty() {
    setState(() {});
  }

  final double iconSize = 20;
  final Color iconColor = Colors.black.withAlpha(200);
  @override
  Widget build(BuildContext context) {
    final drawingContext = context.read<DrawingContext>();


    return Actions(
      actions: <Type, Action<Intent>>{
        UndoIntent: UndoAction(drawingContext),
        RedoIntent: RedoAction(drawingContext),
      },
      child: Stack(
        children: [
          Positioned(
            right: 10,
            top: 20,
            child: Column(
              children: [
                IconButton(
                  onPressed: () {
                    importImage(drawingContext, context);
                  },
                  icon: Icon(Icons.add, color: iconColor, size: iconSize),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Not implemented")),
                    );
                  },
                  icon: Icon(
                    Icons.import_export,
                    color: iconColor,
                    size: iconSize,
                  ),
                ),
                CollapsedLayerButton(iconSize: iconSize, iconColor: iconColor),
              ],
            ),
          ),

          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: SizedBox(
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SketchColorPicker(
                      onColorChanged: (c) {
                        drawingContext.changeColor(c);
                      },
                    ),
                  ),
                  Align(alignment: Alignment.center, child: BrushMenuMobile()),
                  Align(
                    alignment: Alignment.centerRight,
                    child: WidthSelector(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
