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

  /// Returns a Stroke object from a json object
  factory Stroke.fromJson(Map<String, dynamic> json) {
    return Stroke(
      Paint()
        ..color = Color(json['paint']['color'])
        ..strokeWidth = json['paint']['strokeWidth'],
      (json['points'] as List).map((e) => Offset(e[0], e[1])).toList(),
    );
  }

  /// Returns A string for json serialization
  /// Format: {paint: {color: , strokeWidth: }, points: [(x, y), (x, y), ...]}
  String toJsonString() {
    return """
{
  "paint": {
    "color": ${_paint.color.value},
    "strokeWidth": ${_paint.strokeWidth}
  },
  "points": ${_points.map((e) => "[${e.dx}, ${e.dy}]").toList()}
}
  """;
  }

//   {
//   "Strokes": [
//     {
//       "paint": {
//         "color": 4278190080,
//         "strokeWidth": 0.0
//       },
//       "points": [
//         [0.0, 0.0],
//         [1.0, 1.0]
//       ]
//     }
//   ]
// }
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
