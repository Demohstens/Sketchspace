import 'package:sketchspace/classes/drawing_context.dart';
import 'package:sketchspace/components/canvasUI.dart';
import 'package:sketchspace/components/drawing_canvas.dart';
import 'package:flutter/material.dart';
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
        Visibility(
          visible: context.watch<DrawingContext>().ui_enabled,
          child: CanvasUI(),
        ),
      ],
    );
  }
}
