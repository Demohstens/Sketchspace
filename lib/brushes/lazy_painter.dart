import 'dart:ui';

import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/classes/element.dart';
import 'package:sketchspace/classes/stroke.dart';
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
    canvas.drawColor(Colors.transparent, BlendMode.color);
    // Thank you Philip! (https://github.com/lalondeph/flutter_performance_painter/)
    for (Stroke stroke in strokes) {
      stroke.draw(canvas);
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
