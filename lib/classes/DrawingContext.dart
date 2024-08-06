import 'package:flutter/material.dart';
import 'package:flutter_application/classes/stroke.dart';

enum State { drawing, lifted }

class DrawingContext with ChangeNotifier {
  Color _color = Colors.red;
  State _state = State.lifted;
  List<Stroke> _buffer = [];
  Offset _currentPoint = Offset(0, 0);

  Color get color => _color;
  State get state => _state;
  List<Stroke> get buffer => _buffer;
  Offset get currentPoint => _currentPoint;

  void setCurrentPoint(Offset point) {
    _currentPoint = point;
    notifyListeners();
  }

  void addStroke(Stroke stroke) {
    _buffer.add(stroke);
    notifyListeners();
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
