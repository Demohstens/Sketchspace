import 'package:flutter/material.dart';
import 'package:sketchspace/brushes/lazy_painter.dart';
import 'package:sketchspace/canvas/stroke_selector/src/stroke.dart';
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

  List<Stroke>? _crucialStrokes;
  CanvasSpace canvasSpace;
  final ValueNotifier<bool> _repaintNotifier = ValueNotifier<bool>(false);

  // * GETTERS * //
  List<Stroke> get strokes => _crucialStrokes ?? [];
  ValueNotifier<bool> get repaintNotifier => _repaintNotifier;

  set strokes(List<Stroke> strokes) {
    _crucialStrokes = strokes;
    notifyListeners();
  }
  // * METHODS * //

  @override
  void notifyListeners() {
    _repaintNotifier.value = !_repaintNotifier.value; // Toggle the value

    super.notifyListeners();
  }

  // List<Stroke> getStrokesInCanvasSpace(CanvasSpace canvasSpace) {
  //   return canvasSpace.convertStrokes(_strokes);
  // }

  void addStroke(Stroke stroke) {
    _crucialStrokes = _crucialStrokes == null ? [stroke] : _crucialStrokes!
      ..add(stroke);
    notifyListeners();
  }

  void addStrokeFromPoints(List<Offset> points, Paint paint, mode) {
    List<Offset> worldSpacePoints = canvasSpace.convertPoints(points);
    addStroke(Stroke(paint, worldSpacePoints, mode));
  }

  Stroke removeLastStroke() {
    print("Removing last stroke");
    Stroke stroke = strokes.removeLast();
    notifyListeners();
    return stroke;
  }

  /// Attempts to remove the stroke at the given index, defaults to removing
  /// the last stroke if the index is out of bounds.
  Stroke removeStrokeAt(int index) {
    List<Stroke> _strokes = strokes;
    if (index < 0 || index >= _strokes.length) {
      return removeLastStroke();
    }
    Stroke stroke = _strokes.removeAt(index);
    notifyListeners();
    if (_strokes.length == _crucialStrokes!.length) {
      _crucialStrokes = _strokes;
    } else {
      print("WTF");
    }
    return stroke;
  }

  void clear() {
    strokes.clear();

    notifyListeners();
    // TODO
  }

  /// Provides the closest stroke to the touchpoint within 25p.
  // Stroke? selectStroke(Offset touchPoint) {
  //   Offset p = canvasSpace.convertPoint(touchPoint);
  //   int? index = findClosestStrokeIndex(_strokes, p);
  //   return index != null ? _strokes[index] : null;
  // }

  LazyPainter getLazyPainter() {
    return LazyPainter(strokes, _repaintNotifier);
  }

  /// Loads a file into the worldspace.
  void loadStrokes(List<Stroke> strokes) {
    _crucialStrokes = strokes;
    notifyListeners();
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
      return Stroke(Paint.from(stroke.paint), transformedPoints, stroke.mode);
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
