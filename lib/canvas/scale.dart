import 'package:flutter/material.dart';

class ScaleProvier extends ChangeNotifier {
  double _scale = 1.0;
  Offset _scaleOffset = Offset.zero;
  Offset _panOffset = Offset.zero;
  Matrix4 transformMatrix = Matrix4.identity();

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

  void setScale(double scale) {
    _scale = scale;
    notifyListeners();
  }

  void startScaling(ScaleStartDetails details) {
    _initialScale = _scale;
    _initialFocalPoint = details.focalPoint;
    _initialPanOffset = _panOffset;
    notifyListeners();
  }

  void endScaling() {
    _initialPanOffset = _panOffset;
    _initialScale = _scale;
    notifyListeners();
  }

  void updateScale(ScaleUpdateDetails details) {
    // Calculate the scale
    _scale = (_initialScale * details.scale).clamp(_minScale, _maxScale);

    // Calculate the new pan offset relative to the initial pan offset
    Offset deltaPan = details.focalPoint - _initialFocalPoint;
    double _panOffsetX =
        (_initialPanOffset.dx + deltaPan.dx).clamp(-_maxPanX, _maxPanX);
    double _panOffsetY =
        (_initialPanOffset.dy + deltaPan.dy).clamp(-_maxPanX, _maxPanY);
    _panOffset = Offset(_panOffsetX, _panOffsetY);

    // Update the transformation matrix
    transformMatrix = Matrix4.identity()
      ..scale(_scale)
      ..translate(_panOffset.dx, _panOffset.dy);
    notifyListeners();
  }

  void reset() {
    _scale = 1.0;
    _scaleOffset = Offset.zero;
    _panOffset = Offset.zero;
    transformMatrix = Matrix4.identity();
    notifyListeners();
  }
}
