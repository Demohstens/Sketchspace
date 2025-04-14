import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:sketchspace/classes/elements/stroke_element.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:flutter/material.dart';
import 'package:sketchspace/classes/element.dart';
import 'package:sketchspace/classes/path.dart';

class ActivePainter extends CustomPainter {
  List<Offset> currentPath;
  Paint strokePaint;
  ActivePainter(this.currentPath, this.strokePaint);

  @override
  void paint(Canvas canvas, Size size) {
    var stroke = Stroke(
      path: SketchPath(currentPath),
      paint: strokePaint,
      layerId: "",
    );
    var path = stroke.path;
    canvas.drawPath(path.path, strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
