import 'dart:math';

import 'package:flutter/material.dart';

double perpendicularDistance(Offset a, Offset b, Offset p) {
  double d = (b.dx - a.dx) * (a.dy - p.dy) -
      (a.dx - p.dx) *
          (b.dy - a.dy).abs() /
          sqrt(pow(b.dx - a.dx, 2) + pow(b.dy - a.dy, 2));

  return d;
}

class Stroke {
  late Paint _paint;
  late Offset _startPoint;
  late List<Offset> _middlePoints;
  late Offset _endPoint;

  Stroke({
    required Paint paint,
    required List<Offset> points,
    Offset? startPoint,
    Offset? endPoint,
  }) {
    _paint = paint;
    _startPoint = points.first;
    _middlePoints = points;
    _endPoint = points.last;
  }

  Paint get paint => _paint;
  double get width => _paint.strokeWidth;
  Color get color => _paint.color;
  Offset get startPoint => _startPoint;
  List<Offset> get middlePoints => _middlePoints;
  Offset get endPoint => _endPoint;

  /// Ramer-Douglas-Peucker Algorithm
  void optimize() {
    List<Offset> optimizedPoints = optimizeRDP(
      [startPoint, ...middlePoints, endPoint],
      5,
    );
    _startPoint = optimizedPoints.first;
    _middlePoints = optimizedPoints.sublist(1, optimizedPoints.length - 1);
    _endPoint = optimizedPoints.last;
  }
}

List<Offset> optimizeRDP(List<Offset> points, double epsilon) {
  if (points.length < 3) {
    return points;
  }

  double dmax = 0;
  int index = 0;
  int end = points.length;
  for (int i = 2; i < end - 1; i++) {
    double d = perpendicularDistance(points[i], points[0], points[end]);
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
