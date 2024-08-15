import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sketchspace/canvas/canvas_context.dart';

class Stroke {
  final Paint _paint;
  final List<Offset> _points;
  final Mode _mode;
  late Path _path;

  Stroke(this._paint, this._points, this._mode) {
    _path = Path()..moveTo(_points.first.dx, _points.first.dy);
    for (int i = 1; i < _points.length; i++) {
      _path.lineTo(_points[i].dx, _points[i].dy);
    }
  }

  Path get path => _path;
  Paint get paint => _paint;
  double get width => _paint.strokeWidth;
  Color get color => _paint.color;
  Mode get mode => _mode;
  List<Offset> get points => _points;
  PaintingStyle get style => _paint.style;

  /// Ramer-Douglas-Peucker Algorithm. Returns an optimized Stroke
  Stroke optimize() {
    if (_points.length < 3) {
      return this;
    }
    List<Offset> optimizedPoints = optimizeRDP(
      _points,
      0.05,
    );
    return Stroke(_paint, optimizedPoints, _mode);
  }

  /// Returns whether or not the point is within the stroke
  /// Takes in the point and the maximum allowed distance in pixels
  bool contains(Offset point, {double? maximumAllowedDistance}) {
    if (maximumAllowedDistance != null) {
      Offset closestPoint = getClosestPoint(point);
      return ((closestPoint - point).distance < maximumAllowedDistance) ||
          _path.contains(point);
    } else {
      return _path.contains(point);
    }
  }

  /// Returns the closest point to the provided point
  Offset getClosestPoint(Offset point) {
    double minDistance = double.maxFinite;
    Offset closestPoint = Offset.zero;
    for (Offset p in _points) {
      double distance = (p - point).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = p;
      }
    }
    return closestPoint;
  }

  /// calculates the distance between the stroke and a point
  double getDistanceToPoint(Offset point) {
    Offset closestPoint = getClosestPoint(point);
    return (closestPoint - point).distance;
  }

  /// Returns a Stroke object from a json object
  factory Stroke.fromJson(Map<String, dynamic> json) {
    print("Stroke.fromJson: $json");
    return Stroke(
      Paint()
        ..color = Color(json['paint']['color'])
        ..strokeWidth = json['paint']['strokeWidth']
        ..style = json['paint']['style'] == 'fill'
            ? PaintingStyle.fill
            : PaintingStyle.stroke,
      (json['points'] as List).map((e) => Offset(e[0], e[1])).toList(),
      Mode.values.firstWhere(
          (element) => element.toString().split('.').last == json['mode']),
    );
  }

  /// Returns A string for json serialization
  /// Format: {paint: {color: , strokeWidth: }, points: [(x, y), (x, y), ...], "Mode": }
  String toJson() {
    var ret = jsonEncode({
      "paint": {
        "color": _paint.color.value,
        "strokeWidth": _paint.strokeWidth,
        "style": _paint.style.toString().split('.').last,
      },
      "points": _points.map((e) => [e.dx, e.dy]).toList(),
      "mode": _mode.toString().split('.').last,
    });
    print("Stroke.toJson: $ret");
    return ret;
  }

  Rect boundary() {
    if (points.isEmpty) {
      return Rect.zero;
    }

    double minX = double.maxFinite;
    double minY = double.maxFinite;
    double maxX = -double.maxFinite;
    double maxY = -double.maxFinite;

    for (Offset point in points) {
      if (point.dx < minX) {
        minX = point.dx;
      }
      if (point.dx > maxX) {
        maxX = point.dx;
      }
      if (point.dy < minY) {
        minY = point.dy;
      }
      if (point.dy > maxY) {
        maxY = point.dy;
      }
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
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
