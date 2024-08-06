import 'package:flutter/material.dart';

class CurrentPathPen extends CustomPainter {
  List<Offset> currentPath;
  Paint strokePaint;
  CurrentPathPen(this.currentPath, this.strokePaint);

  @override
  void paint(Canvas canvas, Size size) {
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawLine() {
    print('drawLine');
  }
}
