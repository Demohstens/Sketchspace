import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application/classes/drawing_context.dart';

class CurrentPathPen extends CustomPainter {
  List<Offset> currentPath;
  Paint strokePaint;
  Mode mode;
  CurrentPathPen(this.currentPath, this.strokePaint, this.mode);

  @override
  void paint(Canvas canvas, Size size) {
    void drawLine() {
      if (currentPath.length < 2) return;
      canvas.drawLine(currentPath.first, currentPath.last, strokePaint);
    }

    void drawPath() {
      if (currentPath.isNotEmpty) {
        if (currentPath.length == 1) {
          canvas.drawPoints(PointMode.points, currentPath, strokePaint);
          return;
        }
        Paint paint = strokePaint;
        Path currentPathToDraw = Path();
        currentPathToDraw.moveTo(currentPath.first.dx, currentPath.first.dy);
        for (int i = 1; i < currentPath.length; i++) {
          currentPathToDraw.lineTo(currentPath[i].dx, currentPath[i].dy);
        }
        canvas.drawPath(currentPathToDraw, paint);
      }
    }

    switch (mode) {
      case Mode.drawing:
        drawPath();
      case Mode.erasing:
        drawPath();
      case Mode.line:
        drawLine();
      case Mode.fill:
        drawPath();
      case Mode.lifted:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
