import 'package:flutter/widgets.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

/// Represents a path in the sketch
/// DO NOT USE [points] for storage, use [_originalPoints] instead
/// [points] is for display only, not storage
/// [_originalPoints] is for storage only, not display
class SketchPath {
  List<Offset> points = []; // This is for display only, not storage
  Path path = Path();
  List<Offset> _originalPoints = []; // Store original points

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
        path.moveTo(processedPoints.first.dx, processedPoints.first.dy);
        for (int i = 1; i < processedPoints.length; i++) {
          path.lineTo(processedPoints[i].dx, processedPoints[i].dy);
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

