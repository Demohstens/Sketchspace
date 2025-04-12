
import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:sketchspace/classes/element.dart';
import 'package:sketchspace/classes/path.dart';
import 'package:vector_math/vector_math_64.dart';

class Stroke extends SketchElement {
  SketchPath path;
  Paint paint;

  Stroke({
    required this.path,
    required this.paint,
    required super.layerId,
  });

  @override
  Rect get boundary {
    final Rect pathBounds = path.path.getBounds();
    final double expansion = strokeWidth / 2.0;
    return pathBounds.inflate(expansion);
  }

  Color get color => paint.color;
  set color(Color color) {
    paint.color = color;
  }
  double get strokeWidth => paint.strokeWidth;

  @override
  bool hitTest(Offset point) {
    // 1. Bounding Box Check (Quick Rejection)
    if (!boundary.contains(point)) {
      return false;
    }

    // 2. Point-to-Line Segment Distance Check
    final double baseThreshold = 10.0; // Base threshold for better touch/click detection
    final double tolerance = max(strokeWidth * 1.5, baseThreshold); // Use larger of stroke-based or minimum threshold
    double toleranceSq = tolerance * tolerance;

    // Need access to the original points that define the segments
    final List<Offset> points = path.points;

    if (points.length < 2) {
      // If only one point, check distance to that point
      return points.isNotEmpty && (points.first - point).distanceSquared < toleranceSq;
    }

    // Iterate through line segments (p1 to p2)
    for (int i = 0; i < points.length - 1; i++) {
      final Offset p1 = points[i];
      final Offset p2 = points[i+1];

      // Calculate the squared distance from the point to the line segment
      final double distSq = _pointSegmentDistanceSq(point, p1, p2);

      if (distSq < toleranceSq) {
        return true; // Hit detected!
      }
    }

    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "stroke",
      "id": id,
      "layerId": layerId,
      "path": path.toJson(),
      "paint": {
        "color": paint.color.toARGB32(),
        "strokeWidth": paint.strokeWidth,
        "style": paint.style.toString().split('.').last,
      },
    };
  }
  @override
  void translate(Offset offset) {
    path.shift(offset);
  }

  @override
  void draw(Canvas c) {
    if (path.points.isEmpty) return; // No points to draw
    if (path.points.length < 5) {
      c.drawOval(Rect.fromCenter(center: path.points[0], width: paint.strokeWidth, height: paint.strokeWidth), paint..style = PaintingStyle.fill);
      return;
    }
    c.drawPath(path.path, paint);
  }

  @override
  void transform(Matrix4 transform) {
    path.transform(transform);
  }

  @override
  void scale(Vector2 scale) {
    path.scale(scale);
  }

  @override
  factory Stroke.fromJson(Map<String, dynamic> json) {
    return Stroke(
      path: SketchPath.fromJson(json["path"]),
      paint: Paint()
        ..color = Color(json["paint"]["color"])
        ..strokeWidth = json["paint"]["strokeWidth"]
        ..style = PaintingStyle.values.firstWhere(
          (style) => style.toString().split('.').last == json["paint"]["style"]
        ),
      layerId: json["layerId"],
    )..id = json["id"];
  }
}

// Helper function to calculate the squared distance from a point C to a line segment AB
double _pointSegmentDistanceSq(Offset C, Offset A, Offset B) {
  final double l2 = (A - B).distanceSquared; // Squared length of segment AB
  if (l2 == 0.0) return (C - A).distanceSquared; // A and B are the same point

  // Consider the line extending the segment, parameterized as A + t (B - A).
  // Project point C onto the line. The parameter t is given by:
  // t = [(C - A) . (B - A)] / |B - A|^2
  final double t = ((C.dx - A.dx) * (B.dx - A.dx) + (C.dy - A.dy) * (B.dy - A.dy)) / l2;

  // Clamp t to the range [0, 1] to ensure the projection lies on the segment AB
  final double tClamped = t.clamp(0.0, 1.0);

  // Calculate the coordinates of the projection point P on the segment
  final Offset P = Offset(A.dx + tClamped * (B.dx - A.dx),
                         A.dy + tClamped * (B.dy - A.dy));

  // Return the squared distance between C and P
  return (C - P).distanceSquared;
}