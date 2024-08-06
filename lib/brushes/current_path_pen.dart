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
    }

    switch (mode) {
      case Mode.drawing:
        drawPath();
        break;
      case Mode.erasing:
        drawPath();
        break;
      case Mode.line:
        drawLine();
        break;
      case Mode.fill:
        drawPath();
        break;
      case Mode.lifted:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
