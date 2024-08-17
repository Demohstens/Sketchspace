import 'package:flutter/material.dart';
import 'package:sketchspace/canvas/stroke_selector/src/stroke.dart';

class SelectedStrokePainter extends CustomPainter {
  final Stroke stroke;
  final Color selectionColor;

  SelectedStrokePainter(this.stroke, this.selectionColor);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = stroke.paint;
    List<Offset> points = stroke.points;
    if (points.isEmpty) {
      return;
    }
    Paint shadowPaint = Paint()
      ..color = selectionColor
      ..strokeWidth = paint.strokeWidth * 2.5
      ..style = PaintingStyle.stroke;
    Path shadowPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      shadowPath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(shadowPath, shadowPaint);
    Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
