import 'package:flutter/material.dart';
import 'package:flutter_application/brushes/utils/repaint_listener.dart';
import 'package:flutter_application/classes/stroke.dart';

enum Mode { drawing, lifted, erasing, line, fill }

class DrawingContext with ChangeNotifier {
  Color _color = Colors.red;
  List<Stroke> _buffer = [];
  Offset _currentPoint = Offset(0, 0);
  List<Offset> _points = [];
  RepaintListener repaintListener = RepaintListener();
  Mode _mode = Mode.drawing;
  double _width = 10.0;

  Color get color => _color;
  Mode get mode => _mode;
  List<Stroke> get buffer => _buffer;
  Offset get currentPoint => _currentPoint;
  List<Offset> get points => _points;
  double get strokeWidth => _width;
  void setCurrentPoint(Offset point) {
    _points.add(point);
    _currentPoint = point;
    notifyListeners();
  }

  Paint getPaint() {
    Paint pt = Paint()
      ..color = _color
      ..strokeWidth = _width
      ..style = _getStyle()
      ..strokeCap = StrokeCap.round;
    return pt;
  }

  PaintingStyle _getStyle() {
    switch (_mode) {
      case Mode.drawing:
        return PaintingStyle.stroke;
      case Mode.erasing:
        return PaintingStyle.stroke;
      case Mode.line:
        return PaintingStyle.stroke;
      case Mode.fill:
        return PaintingStyle.fill;
      case Mode.lifted:
        return PaintingStyle.stroke;
    }
  }

  /// Creates a new Stroke object depending ont he mode
  void createStroke(List<Offset>? points) {
    Stroke stroke;
    if (points != null) {
      _points = points;
      switch (_mode) {
        case Mode.drawing:
          stroke = Stroke(points: points, paint: getPaint());
          // stroke.optimize();
          _buffer.add(stroke);
        case Mode.erasing:
          break;
        case Mode.line:
          stroke =
              (Stroke(points: [points.first, points.last], paint: getPaint()));
          _buffer.add(stroke);
        case Mode.fill:
          stroke = (Stroke(points: points, paint: getPaint()));
          // stroke.optimize();
          _buffer.add(stroke);
        case Mode.lifted:
          break;
      }

      _points = [];
      notifyListeners();
      repaintListener.notifyListeners();
    }
  }

  void changeMode(Mode mode) {
    _mode = mode;
    notifyListeners();
  }

  void changeColor(Color color) {
    _color = color;
    notifyListeners();
  }

  void reset() {
    _buffer = [];
    _points = [];
    repaintListener.notifyListeners();
    notifyListeners();
  }
}
