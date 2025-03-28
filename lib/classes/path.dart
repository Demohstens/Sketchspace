import 'package:flutter/widgets.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:vector_math/vector_math_64.dart';

/// Represents a path in the sketch
/// DO NOT USE [points] for storage, use [_originalPoints] instead
/// [points] is for display only, not storage
/// [_originalPoints] is for storage only, not display
class SketchPath {
  List<Offset> points = []; // This is for display only, not storage
  Path _path = Path();
  List<Offset> _originalPoints = []; // Store original points

  Path get path => _path;

  SketchPath(this.points) {
    _originalPoints = List.from(points); // Save original points
    
    if (points.isNotEmpty) {
      // Process points with perfect_freehand only for display, not storage
      final processedPoints = getStroke(
        points.map((e) => PointVector(e.dx, e.dy)).toList(), 
        options: StrokeOptions(
          size: 1, 
          end: StrokeEndOptions.end(), 
          thinning: 0, 
          isComplete: true
        )
      );
      
      // Create path from processed points
      if (processedPoints.isNotEmpty) {
        _path.moveTo(processedPoints.first.dx, processedPoints.first.dy);
        for (int i = 1; i < processedPoints.length; i++) {
          _path.lineTo(processedPoints[i].dx, processedPoints[i].dy);
        }
      }
    }
  }

  void shift(Offset offset) {
    // Create new Offset objects with the shifted coordinates
    for (int i = 0; i < _originalPoints.length; i++) {
      _originalPoints[i] = Offset(
        _originalPoints[i].dx + offset.dx,
        _originalPoints[i].dy + offset.dy
      );
    }
    // Clear and rebuild the path
    recalculatePath();
  }
  void recalculatePath() {
    _path = Path();

    final processedPoints = getStroke(
        _originalPoints.map((e) => PointVector(e.dx, e.dy)).toList(), 
        options: StrokeOptions(
          size: 1, 
          end: StrokeEndOptions.end(), 
          thinning: 0, 
          isComplete: true
        )
      );
      points = processedPoints;
      
      // Create path from processed points
      if (processedPoints.isNotEmpty) {
        _path.moveTo(processedPoints.first.dx, processedPoints.first.dy);
        for (int i = 1; i < processedPoints.length; i++) {
          _path.lineTo(processedPoints[i].dx, processedPoints[i].dy);
        }
      }
  }
  void transform(Matrix4 transform) {
    for (int i = 0; i < points.length; i++) {
      final Vector4 transformed = transform.transform(Vector4(points[i].dx, points[i].dy, 0, 1));
      points[i] = Offset(transformed.x, transformed.y);
    }

    // Also transform original points to maintain consistency
    for (int i = 0; i < _originalPoints.length; i++) {
      final Vector4 transformed = transform.transform(Vector4(_originalPoints[i].dx, _originalPoints[i].dy, 0, 1));
      _originalPoints[i] = Offset(transformed.x, transformed.y);
    }

    // Recalculate the path with transformed points
    _path = Path();
    if (points.isNotEmpty) {
      final processedPoints = getStroke(
        points.map((e) => PointVector(e.dx, e.dy)).toList(),
        options: StrokeOptions(
          size: 1,
          end: StrokeEndOptions.end(),
          thinning: 0,
          isComplete: true
        )
      );

      if (processedPoints.isNotEmpty) {
        _path.moveTo(processedPoints.first.dx, processedPoints.first.dy);
        for (int i = 1; i < processedPoints.length; i++) {
          _path.lineTo(processedPoints[i].dx, processedPoints[i].dy);
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    // Store original points, not processed ones
    return {
      'points': _originalPoints.map((point) => {"x": point.dx, "y": point.dy}).toList()
    };
  }

  factory SketchPath.fromJson(Map<String, dynamic> json) {
    List<Offset> points = [];
    for (var point in json['points']) {
      double x = point["x"].toDouble();
      double y = point["y"].toDouble();
      points.add(Offset(x, y));
    } 
    return SketchPath(points);
  }
}

