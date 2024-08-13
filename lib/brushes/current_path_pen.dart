import 'dart:ui';

import 'package:sketchspace/canvas/canvas_context.dart';
import 'package:flutter/material.dart';

class CurrentPathPen extends CustomPainter {
  List<Offset> currentPath;
  Paint strokePaint;
  Mode mode;
  Matrix4 transformMatrix;
  CurrentPathPen(
      this.currentPath, this.strokePaint, this.mode, this.transformMatrix);

  @override
  void paint(Canvas canvas, Size size) {
    void drawLine() {
      if (currentPath.length < 2) return;

      canvas.drawLine(currentPath.first, currentPath.last, strokePaint);
    }

    void drawPath() {
      if (currentPath.isNotEmpty) {
        Paint paint = strokePaint;
        Path currentPathToDraw = Path();
        currentPathToDraw.moveTo(currentPath.first.dx, currentPath.first.dy);
        for (int i = 1; i < currentPath.length; i++) {
          currentPathToDraw.lineTo(currentPath[i].dx, currentPath[i].dy);
        }
        canvas.drawPath(currentPathToDraw, paint);
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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
