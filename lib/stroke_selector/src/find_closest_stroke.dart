import 'package:demo_space/stroke_selector/src/stroke.dart';
import 'package:flutter/widgets.dart';

int? findClosestStrokeIndex(List<Stroke> strokes, Offset touchPoint) {
  if (strokes.isEmpty) {
    return null;
  }
  List<int> indeciesOfPossibleStrokes = [];

  for (int i = 0; i < strokes.length; i++) {
    Stroke stroke = strokes[i];
    if (_fitsConstraints(stroke, touchPoint)) {
      indeciesOfPossibleStrokes.add(i);
    }
  }
  // If there are multiple strokes that fit the constraints, return the one with the highest index
  return indeciesOfPossibleStrokes.isEmpty
      ? null
      : indeciesOfPossibleStrokes.last;
}

bool _fitsConstraints(Stroke stroke, Offset touchPoint) {
  double magicMaxDistance = 100.0;
  var boundary = stroke.boundary();
  // Check if the touchpoint is verifiabky outside the boundary
  if (touchPoint.dx <= boundary.left ||
      touchPoint.dx >= boundary.right ||
      touchPoint.dy <= boundary.top ||
      touchPoint.dy >= boundary.bottom) {
    return false;
  }
  // Assume boundary is complex and check if the touchpoint is close to the stroke
  for (Offset point in stroke.points) {
    if ((point - touchPoint).distance < magicMaxDistance) {
      // Temporary verification:
      return true;
    }
  }
  // assume that the touchpoint is inside the boundary
  if (boundary.left == boundary.right && boundary.top == boundary.bottom) {
    // Boundary is a single point
    if ((Offset(boundary.left, boundary.top) - touchPoint).distance <
        magicMaxDistance) {
      print("Single point stroke");
      return true;
    }
  }
  // throws an error as all bases should be covered. Ideally only for development
  print("${stroke.boundary()} $touchPoint");
  return false;
  // throw Exception("Something went wrong in _fitsConstraints");
}
