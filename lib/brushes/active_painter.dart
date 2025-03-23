import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:sketchspace/canvas/canvas_context.dart';
import 'package:flutter/material.dart';

class ActivePainter extends CustomPainter {
  List<Offset> currentPath;
  Paint strokePaint;
  Mode mode;
  ActivePainter(this.currentPath, this.strokePaint, this.mode);

  @override
  void paint(Canvas canvas, Size size) {
    void drawLine() {
      if (currentPath.length < 2) return;

      canvas.drawLine(currentPath.first, currentPath.last, strokePaint);
    }
    void drawPath() {
      var st = getStroke(currentPath.map((e) => PointVector(e.dx, e.dy)).toList(), options: StrokeOptions(size: strokePaint.strokeWidth, end: StrokeEndOptions.end(cap: false), thinning: 0.05));

      Path pathToDraw = Path();
      for (int i = 0; i < st.length; i++) {
        if (i == 0) {
          pathToDraw.moveTo(st[i].dx, st[i].dy);
        } else if (i > 0) {
          pathToDraw.lineTo(st[i].dx, st[i].dy);
        }
      }
      canvas.drawPath(pathToDraw, strokePaint);
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
      case Mode.lifted || Mode.strokeErasing:
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
