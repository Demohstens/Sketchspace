library paint_selector;

import 'package:flutter/material.dart';
import 'package:flutter_application/stroke_selector/src/classes/stroke.dart';
import 'package:flutter_application/stroke_selector/src/find_closest_stroke.dart';

Container? paintSelector(List<Stroke> strokes, Offset touchPoint) {
  int? indexOfClosestStroke = findClosestStrokeIndex(strokes, touchPoint);
  // If there is no stroke, which is close enough to fit the pramaters, return null
  if (indexOfClosestStroke == null) {
    return null;
  }

  Stroke closestStroke = strokes[indexOfClosestStroke];
  return Container(
    color: Colors.transparent,
    width: closestStroke.boundary().width,
    height: closestStroke.boundary().height,
    child: CustomPaint(
      painter: _Painter(closestStroke),
    ),
  );
}

class _Painter extends CustomPainter {
  final Stroke stroke;

  _Painter(this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = stroke.paint;
    List<Offset> points = stroke.points;
    if (points.isEmpty) {
      return;
    }
    Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = paint.strokeWidth + 5;
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
