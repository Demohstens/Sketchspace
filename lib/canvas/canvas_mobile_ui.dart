import 'package:flutter/material.dart';
import 'package:sketchspace/canvas/actions.dart';
import 'package:sketchspace/components/add_imported.dart';
import 'package:sketchspace/components/brush_menu_mobile.dart';
import 'package:sketchspace/components/collapsed_layer_button.dart';
import 'package:sketchspace/components/color_selector.dart';
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
          Positioned(
            bottom: 10,
            left: 10,
            child: Row(
              children: [
                AddImported(),
                SketchColorPicker(
                  onColorChanged: (c) {
                    context.read<DrawingContext>().changeColor(c);
                  },
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: Column(
              children: [
                IconButton(
                  onPressed: () {
                    importImage(drawingContext, context);
                  },
                  icon: Icon(Icons.add, color: Colors.white, size: iconSize),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.import_contacts,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
                CollapsedLayerButton(
                    iconSize: iconSize,
                  ),
              ],
            ),
          ),
          Positioned(bottom: 10, right: 10, child: WidthSelector()),
          Positioned(
            bottom: 10,
            left: screenWidth * 0.5 - 30,
            child: BrushMenuMobile(),
          ),
        ],
      ),
    );
  }
}