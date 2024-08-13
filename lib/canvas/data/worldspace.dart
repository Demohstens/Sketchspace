import 'package:flutter/material.dart';
import 'package:sketchspace/canvas/data/stroke_selector/src/find_closest_stroke.dart';
import 'package:sketchspace/canvas/data/stroke_selector/src/stroke.dart';
import 'package:vector_math/vector_math_64.dart';

/// The "World" in which all Strokes are stored in relation to the 0,0 coordinates.
/// This class is used to store all the strokes in a single file, and to provide a
/// way to manipulate the strokes in relation to each other.
/// DO NOT use this class for rendering, or for any other purpose than storing and
/// manipulating strokes.

class Worldspace extends ChangeNotifier {
  // * CONSTRUCTOR * //

  Worldspace(this.canvasSpace);

  // * ATTRIBUTES * //

  List<Stroke> _strokes = [];
  CanvasSpace canvasSpace;

  // * GETTERS * //
  List<Stroke> get strokes => _strokes;

  // * METHODS * //

  List<Stroke> getStrokesInCanvasSpace(CanvasSpace canvasSpace) {
    return canvasSpace.convertStrokes(_strokes);
  }

  void addStroke(Stroke stroke) {
    _strokes.add(stroke);
  }

  void addStrokeFromPoints(List<Offset> points, Paint paint) {
    List<Offset> worldSpacePoints = canvasSpace.convertPoints(points);
    _strokes.add(Stroke(paint, worldSpacePoints));
  }

  void removeStrokeAt(int index) {
    _strokes.removeAt(index);
  }

  void clear() {
    _strokes.clear();
  }

  /// Provides the closest stroke to the touchpoint within 25p.
  Stroke? selectStroke(Offset touchPoint) {
    Offset p = canvasSpace.convertPoint(touchPoint);
    int? index = findClosestStrokeIndex(_strokes, p);
    return index != null ? _strokes[index] : null;
  }
}

// CanvasSpace or LocalSpace represents the space in which the strokes are rendered.
// This space is used to calculate the strokes' position in local space.
class CanvasSpace extends ChangeNotifier {
  // * CONSTRUCTOR * //

  CanvasSpace(translationMatrix) {
    _translationMatrix = translationMatrix;
  }
  // * ATTRIBUTES * //

  late Matrix4 _translationMatrix;

  // * GETTERS * //

  double get scale => _translationMatrix.getMaxScaleOnAxis();
  Offset get pan => Offset(_translationMatrix.getTranslation().x,
      _translationMatrix.getTranslation().y);

  // * SETTERS * //

  void transForm(Matrix4 matrix) {
    _translationMatrix = matrix;
  }
  // * METHODS * //

  /// Converts a list of strokes from worldspace to the local space.
  List<Stroke> convertStrokes(List<Stroke> strokes) {
    return strokes.map((stroke) {
      final transformedPoints = stroke.points.map((point) {
        return Offset(
            _translationMatrix.transform(Vector4(point.dx, point.dy, 0, 1)).x,
            _translationMatrix.transform(Vector4(point.dx, point.dy, 0, 1)).y);
      }).toList();
      return Stroke(Paint.from(stroke.paint), transformedPoints);
    }).toList();
  }

  List<Offset> convertPoints(List<Offset> points) {
    return points.map((point) {
      return Offset(
          _translationMatrix.transform(Vector4(point.dx, point.dy, 0, 1)).x,
          _translationMatrix.transform(Vector4(point.dx, point.dy, 0, 1)).y);
    }).toList();
  }

  Offset convertPoint(Offset point) {
    return Offset(
            _translationMatrix.transform(Vector4(point.dx, point.dy, 0, 1)).x,
            _translationMatrix.transform(Vector4(point.dx, point.dy, 0, 1)).y)
        as Offset;
  }
}
