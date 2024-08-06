import 'package:flutter/material.dart';
import 'package:flutter_application/classes/DrawingContext.dart';
import 'package:flutter_application/classes/stroke.dart';

class Pen extends CustomPainter {
  final List<Stroke> strokes;
  List<Offset> points;
  Color currentColor;
  Pen(this.strokes, this.points, this.currentColor);

  @override
  void paint(Canvas canvas, Size size) {
    for (Stroke stroke in strokes) {
      Paint paint = Paint()
        ..color = stroke.color
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
      }
    }
    if (points.length > 1) {
      Paint paint = Paint()
        ..color = currentColor
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
