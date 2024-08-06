import 'package:flutter/material.dart';
import 'package:flutter_application/classes/stroke.dart';

enum State { drawing, lifted }

class DrawingContext with ChangeNotifier {
  Color _color = Colors.red;
  State _state = State.lifted;
  List<Stroke> _buffer = [];
  Offset _currentPoint = Offset(0, 0);
  List<Offset> _points = [];

  Color get color => _color;
  State get state => _state;
  List<Stroke> get buffer => _buffer;
  Offset get currentPoint => _currentPoint;
  List<Offset> get points => _points;

  void setCurrentPoint(Offset point) {
    _points.add(point);
    _currentPoint = point;
    notifyListeners();
  }

  void addStroke(Stroke? stroke) {
    if (stroke != null) {
      _buffer.add(stroke);
      notifyListeners();
    } else {
      _buffer.add(Stroke(_color, _points));
      _points = [];
      notifyListeners();
    }
  }

  void changeState(State state) {
    _state = state;
    notifyListeners();
  }

  void changeColor(Color color) {
    _color = color;
    notifyListeners();
  }
}
