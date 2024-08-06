import 'package:flutter/material.dart';
import 'package:flutter_application/brushes/utils/repaint_listener.dart';
import 'package:flutter_application/classes/stroke.dart';

class LazyPainter extends CustomPainter {
  final List<Stroke> strokes;

  final RepaintListener repaintListener;
  LazyPainter(
      this.strokes, this.repaintListener); // : super(repaint: repaintListener);

  @override
  void paint(Canvas canvas, Size size) {
    // Thank you Philip! (https://github.com/lalondeph/flutter_performance_painter/)
    for (Stroke stroke in strokes) {
      Paint paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        // ..blendMode = BlendMode.src
        // ..strokeCap = StrokeCap.round
        // ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

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
