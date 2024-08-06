import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application/classes/DrawingContext.dart';
import 'package:flutter_application/classes/stroke.dart';

class Pen extends CustomPainter {
  final Color color;

  Pen(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;
    canvas.drawPoints(PointMode.points, [Offset(100, 100)], paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
