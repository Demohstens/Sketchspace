import 'dart:math';

import 'package:flutter/material.dart';

class Stroke {
  final Paint _paint;
  final List<Offset> _points;

  Stroke(this._paint, this._points);
  Paint get paint => _paint;
  double get width => _paint.strokeWidth;
  Color get color => _paint.color;
  List<Offset> get points => _points;

  /// Ramer-Douglas-Peucker Algorithm. Returns an optimized Stroke
  Stroke optimize() {
    if (_points.length < 3) {
      return this;
    }
    List<Offset> optimizedPoints = optimizeRDP(
      _points,
      0.05,
    );
    return Stroke(_paint, optimizedPoints);
  }
}

double perpendicularDistance(Offset point, Offset lineStart, Offset lineEnd) {
  double dx = lineEnd.dx - lineStart.dx;
  double dy = lineEnd.dy - lineStart.dy;

  double mag = sqrt(dx * dx + dy * dy);
  if (mag == 0.0) return 0.0;

  double u = ((point.dx - lineStart.dx) * dx + (point.dy - lineStart.dy) * dy) /
      (mag * mag);

  double x = lineStart.dx + u * dx;
  double y = lineStart.dy + u * dy;

  dx = x - point.dx;
  dy = y - point.dy;

  return sqrt(dx * dx + dy * dy);
}

List<Offset> optimizeRDP(List<Offset> points, double epsilon) {
  if (points.length < 3) {
    return points;
  }

  double dmax = 0;
  int index = 0;
  int end = points.length;
  for (int i = 1; i < end - 1; i++) {
    double d = perpendicularDistance(points[i], points[0], points[end - 1]);
    if (d > dmax) {
      index = i;
      dmax = d;
    }
  }

  List<Offset> result = [];

  if (dmax > epsilon) {
    List<Offset> recResults1 =
        optimizeRDP(points.sublist(0, index + 1), epsilon);
    List<Offset> recResults2 = optimizeRDP(points.sublist(index, end), epsilon);
    result = recResults1.sublist(0, recResults1.length - 1) + recResults2;
  } else {
    result = [points.first, points.last];
  }

  return result;
}
