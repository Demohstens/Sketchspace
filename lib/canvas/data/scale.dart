import 'package:flutter/material.dart';

class ScaleProvier extends ChangeNotifier {
  double _scale = 1.0;
  Offset _scaleOffset = Offset.zero;
  Offset _panOffset = Offset.zero;
  // Matrix4 transformMatrix = Matrix4.identity();

  // * GETTERS *
  double get scale => _scale;
  Offset get getScaleOffset => _scaleOffset;
  Offset get getPanOffset => _panOffset;

  // Restraints
  Size _lazyCanvasSize = const Size(9000, 9000);
  double _minScale = 1;
  double _maxScale = 3;
  double _maxPanX = 3000;
  double _maxPanY = 3000;
  double _initialScale = 1;
  Offset _initialFocalPoint = Offset.zero;
  Offset _initialPanOffset = Offset.zero;

  set scale(double scale) {
    _scale = scale;
    notifyListeners();
  }

  set scaleOffset(Offset offset) {
    _scaleOffset = offset;
    notifyListeners();
  }

  void reset() {
    _scale = 1.0;
    _scaleOffset = Offset.zero;
    _panOffset = Offset.zero;
    // transformMatrix = Matrix4.identity();
    notifyListeners();
  }
}
