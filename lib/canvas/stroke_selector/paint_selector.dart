library paint_selector;

import 'package:sketchspace/canvas/data/worldspace.dart';
import 'package:sketchspace/canvas/stroke_selector/src/find_closest_stroke.dart';
import 'package:sketchspace/canvas/stroke_selector/src/stroke.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget? strokeSelector(List<Stroke> strokes, Offset touchPoint) {
  print('Selecting Stroke');
  int? indexOfClosestStroke = findClosestStrokeIndex(strokes, touchPoint);
  // If there is no stroke, which is close enough to fit the pramaters, return null
  if (indexOfClosestStroke == null) {
    return null;
  }

  Stroke closestStroke = strokes[indexOfClosestStroke];
  Rect boundary = closestStroke.boundary();
  print('Boundary: $boundary');

  if (boundary.width == 0 || boundary.height == 0) {
    print('Invalid boundary dimensions');
    return null;
  }

  return Stack(children: [
    Positioned(
        left: boundary.left,
        top: boundary.top,
        child: Container(
          color: const Color.fromARGB(232, 255, 17, 17),
          width: boundary.width,
          height: boundary.height,
          child: CustomPaint(
            painter: _Painter(closestStroke),
          ),
        )),
    // CircularContextMenu(),
    StrokeManipulationMenu(indexOfClosestStroke, touchPoint)
  ]);
}

class _Painter extends CustomPainter {
  final Stroke stroke;

  _Painter(this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = stroke.paint;
    List<Offset> points = stroke.points;
    if (points.isEmpty) {
      return;
    }
    Paint shadowPaint = Paint()
      ..color = Color.fromARGB(255, 0, 0, 0).withOpacity(0.5)
      ..strokeWidth = paint.strokeWidth + 5
      ..style = PaintingStyle.stroke;
    Path shadowPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      shadowPath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(shadowPath, shadowPaint);
    Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class StrokeManipulationMenu extends StatelessWidget {
  final int index;
  final Offset touchPoint;
  StrokeManipulationMenu(this.index, this.touchPoint);
  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: touchPoint.dy - 100,
        left: touchPoint.dx,
        child: FloatingActionButton.small(
            onPressed: () {
              context.read<Worldspace>().removeStrokeAt(index);
            },
            child: Icon(Icons.delete)));
  }
}
