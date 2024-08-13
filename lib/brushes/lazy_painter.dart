import 'dart:ui';

import 'package:sketchspace/canvas/canvas_context.dart';
import 'package:sketchspace/canvas/stroke_selector/src/stroke.dart';
import 'package:sketchspace/utils/repaint_listener.dart';
import 'package:flutter/material.dart';

class LazyPainter extends CustomPainter {
  final List<Stroke> strokes;
  // RepaintListener repaintListener;

  // LazyPainter(this.strokes, this.repaintListener)
  //     : super(repaint: repaintListener); // : super(repaint: repaintListener);

  LazyPainter(this.strokes, this.repaintNotifier)
      : super(repaint: repaintNotifier);

  final ValueNotifier<bool> repaintNotifier;
  @override
  void paint(Canvas canvas, Size size) {
    // Thank you Philip! (https://github.com/lalondeph/flutter_performance_painter/)
    print("Painting ${strokes.length} strokes");
    void drawLine(Stroke stroke) {
      canvas.drawLine(stroke.points.first, stroke.points.last, stroke.paint);
    }

    void drawPath(Stroke stroke) {
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

    // Switch through all modes to allow for different handling of the strokes
    for (Stroke stroke in strokes) {
      switch (stroke.mode) {
        case Mode.drawing:
          drawPath(stroke);
        case Mode.lifted:
          break;
        case Mode.erasing:
          break;
        case Mode.line:
          drawLine(stroke);
        case Mode.fill:
          drawPath(stroke);
      }
    }
  }

  /// repaint is controlled by a listener.
  /// Only called when a path is added to PathData.allPaths[] in onPanEnd
  // @override
  // bool shouldRepaint(LazyPainter oldDelegate) {
  //   return oldDelegate.repaintListener.toString() != repaintListener.toString();
  // }
  @override
  bool shouldRepaint(LazyPainter oldDelegate) {
    // This will trigger a repaint whenever the ValueNotifier's value changes
    return oldDelegate.repaintNotifier != repaintNotifier;
  }
}
