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
  List<Offset> get originalPoints => _originalPoints; // Getter for original points

  SketchPath(this.points) {
    _originalPoints = List.from(points); // Save original points

    if (points.isNotEmpty) {
      List<Offset> processedPoints = [];
      // Process points with perfect_freehand only for display, not storage
      if (points.length <= 3) {
        processedPoints = points;
      } else {
        processedPoints = getStroke(
          points.map((e) => PointVector(e.dx, e.dy)).toList(),
          options: StrokeOptions(
            size: 1,
            end: StrokeEndOptions.end(),
            thinning: 0,
            isComplete: true,
          ),
        );
      }

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
        _originalPoints[i].dy + offset.dy,
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
        isComplete: true,
      ),
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

  // Scale in Pixel offset from the original points
  void scale(double scaleFactorX, double scaleFactorY, Offset pivot, List<Offset> _initialPointsOnScaleStart) {
    // Prevent division by zero or extreme scaling if factors are invalid
    // Use a small threshold to allow shrinking close to zero
    if (scaleFactorX.isNaN || scaleFactorY.isNaN ||
        scaleFactorX.isInfinite || scaleFactorY.isInfinite ||
        scaleFactorX < 1e-9 || scaleFactorY < 1e-9) { // Allow very small scales      // Reset to initial points to avoid broken state
      _originalPoints = List.from(_initialPointsOnScaleStart);
      recalculatePath();
      return;
    }

    List<Offset> scaledPoints = [];
    // *** Iterate over the INITIAL points ***
    print(_initialPointsOnScaleStart.length);
    for (Offset p in _initialPointsOnScaleStart) {
      Offset pTranslated = p - pivot;
      Offset pScaled = Offset(
        pTranslated.dx * scaleFactorX,
        pTranslated.dy * scaleFactorY,
      );
      Offset pNew = pScaled + pivot;
      scaledPoints.add(pNew);
    }

    _originalPoints = scaledPoints; // Update the current points
    print("Scaled points: ${scaledPoints.length}");
    _path = Path(); // Clear the path before redrawing
    _path.moveTo(scaledPoints.first.dx, scaledPoints.first.dy);
    for (Offset p in scaledPoints) {
      _path.lineTo(p.dx, p.dy);
    }
  }

  void transform(Matrix4 transform) {
    // Transform original points first since they are the source of truth
    for (int i = 0; i < _originalPoints.length; i++) {
      // Create a Vector3 instead of Vector4 to avoid perspective issues
      final Vector3 point3 = Vector3(
        _originalPoints[i].dx,
        _originalPoints[i].dy,
        0,
      );

      // Apply the transformation directly to the Vector3
      // This correctly applies rotation, scaling, AND translation from the matrix
      transform.transform3(point3); // <--- Correct standard application

      // Update the original point with the transformed coordinates
      _originalPoints[i] = Offset(point3.x, point3.y);
    }
    // Recalculate the path with the transformed points
    recalculatePath();
  }

  Map<String, dynamic> toJson() {
    // Store original points, not processed ones
    return {
      'points':
          _originalPoints
              .map((point) => {"x": point.dx, "y": point.dy})
              .toList(),
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
