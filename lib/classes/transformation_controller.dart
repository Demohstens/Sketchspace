import 'dart:math' as math;
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:flutter/widgets.dart'; // For Offset, Matrix4
import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector3;

class TransformController extends ValueNotifier<Matrix4>  {

  TransformController() : super(Matrix4.identity());
  // --- Internal State ---
  double _zoomLevel = 2.0; // Good to keep track of scale explicitly
  double _rotation = 0.0;  // and rotation if needed
  Offset _panOffset = Offset.zero;

  // Start with identity transformation, DO NOT EDIT AFTERWARDS

  // --- Accessors (Read-Only) ---
  double get zoomLevel => _zoomLevel; // Direct level
  double get rotation => _rotation;    // Radian format
  Offset get panOffset => _panOffset;  // Stored internal pan
  // Matrix4 get transformation => _transformation; // Store the source of truth

  // Helper method
  void resetTransformations() {
    _zoomLevel = 1.0;
    _rotation = 0.0;
    _panOffset = Offset.zero;
    value = Matrix4.identity();
    notifyListeners();
  }

  Matrix4 _newMatrix(Matrix4 transform) {
      value = transform.multiplied(value); // Compose transformations
      return value; // return the composed matrix
  }

  // Transformation to a value relative to the last transform
  void zoomRelative(double zoom) {
      // create a copy, and then change it and the return the value
    final Matrix4 newMatrix = Matrix4.identity()..scale(zoom); // Relative scale to the current transformation
    zoomUpdate(newMatrix);
  }

  void panRelative(Offset pan) {
     final Matrix4 newMatrix = Matrix4.identity()..translate(Vector3(pan.dx, pan.dy, 0.0));
     panUpdate(newMatrix);
  }

  void rotateRelative(double rotation) {
     final Matrix4 newMatrix = Matrix4.identity()..rotateZ(rotation);
     rotationUpdate(newMatrix);
  }

  // Direct matrix transformations that use the current matrix transform values in terms of translation, and scaling.
  void zoomUpdate(Matrix4 transform) { // Zoom update for Matrix4 parameter
    Matrix4 scaleMatrix = Matrix4.identity()..scale(transform.storage[0]);
    _newMatrix(scaleMatrix); // Apply the scale transformation
    _zoomLevel *= transform.storage[0]; // Update zoom level with the scale factor

    notifyListeners(); // Notifies
  }

  void panUpdate(Matrix4 transform) {
    _newMatrix(value..translate(transform.getTranslation().x,transform.getTranslation().y,transform.getTranslation().z));
    Offset pan = Offset(transform.getTranslation().x, transform.getTranslation().y); // Update the offset with the new pan
    _panOffset += pan;

    notifyListeners();
  }

    // Sets all value properties, and performs a transformation onto the next value
  void rotationUpdate(Matrix4 transform) {
      _newMatrix(value..rotateZ(transform.getRotation().row2.z)); // The rotation amount
      // Not 100% about the source, so using internal value to keep rotation consistent

      _rotation += transform.getRotation().row2.z;
      notifyListeners(); // Notify
  }
}
