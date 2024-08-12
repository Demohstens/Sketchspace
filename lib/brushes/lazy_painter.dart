import 'dart:ui';

import 'package:sketchspace/stroke_selector/src/stroke.dart';
import 'package:sketchspace/utils/repaint_listener.dart';
import 'package:flutter/material.dart';

class LazyPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Matrix4 translationMatrix;

  final RepaintListener repaintListener;
  LazyPainter(this.strokes, this.repaintListener, this.translationMatrix)
      : super(repaint: repaintListener); // : super(repaint: repaintListener);

  @override
  void paint(Canvas canvas, Size size) {
    print("Painting lazy painter");
    // Thank you Philip! (https://github.com/lalondeph/flutter_performance_painter/)
    double scale = translationMatrix.getMaxScaleOnAxis();
    Offset pan = Offset(translationMatrix.getTranslation().xy.x,
        translationMatrix.getTranslation().xy.y);
    canvas.translate(pan.dx, pan.dy);
    canvas.transform(translationMatrix.storage);
    for (Stroke stroke in strokes) {
      if (stroke.points.length == 1) {
        canvas.drawPoints(PointMode.points, stroke.points, stroke.paint);
      }
      Paint paint = stroke.paint;

      Path pathToDraw = Path();
      for (int i = 0; i < stroke.points.length; i++) {
        if (i == 0) {
          pathToDraw.moveTo(stroke.points[i].dx, stroke.points[i].dy);
        } else if (i > 0) {
          pathToDraw.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
      }
      canvas.drawPath(pathToDraw, paint);
    }
  }

  /// repaint is controlled by a listener.
  /// Only called when a path is added to PathData.allPaths[] in onPanEnd
  @override
  bool shouldRepaint(LazyPainter oldDelegate) {
    return oldDelegate.repaintListener.toString() != repaintListener.toString();
  }
}
