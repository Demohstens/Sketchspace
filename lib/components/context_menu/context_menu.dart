import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/classes/transformation_controller.dart';
import 'package:sketchspace/components/add_imported.dart';
import 'package:sketchspace/components/context_menu/stroke_context.dart';
import 'package:sketchspace/providers/drawing_context.dart';

class SketchContextMenu extends StatelessWidget {
  final PositionedContextController controller;
  final Widget child;
  const SketchContextMenu(this.controller, this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: controller,
      overlayChildBuilder: (BuildContext context) {
        return Positioned(
          left: controller.position.dx,
          top: controller.position.dy - 20,
          child: Container(
            color: Colors.black.withAlpha(200),
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    DrawingContext drawingContext = context.read<DrawingContext>();
                    Offset transformedPosition = context.read<TransformController>().inversePoint(controller.position);
                    Clipboard.getData('text/plain').then((value) {
                      if (value != null) {
                        drawingContext.insertText(transformedPosition, value.text!);
                      }
                    });
                    controller.hide();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 4,
                    children: [
                      Icon(Icons.paste, color: Colors.white, size: 20),
                      const Text("Paste"),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    importImage(context.read<DrawingContext>(), context);
                    controller.hide();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 4,
                    children: [
                      Icon(Icons.image, color: Colors.white, size: 20),
                      const Text("Import image"),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("This is not Implemented yet :("), duration: Duration(milliseconds: 500),));
                    controller.hide();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 4,
                    children: [
                      Icon(Icons.image, color: Colors.white, size: 20),
                      const Text("Clear", style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: child,
    );
  }
}

