import 'package:sketchspace/canvas/canvas_viewport.dart';
import 'package:sketchspace/canvas/canvas_context.dart';
import 'package:sketchspace/canvas/canvasUI.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CanvasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
      children: [
        Positioned.fill(
          child: CanvasViewport(),
        ),
        Visibility(
          visible: context.watch<DrawingContext>().ui_enabled,
          child: CanvasUI(),
        ),
      ],
    ));
  }
}
