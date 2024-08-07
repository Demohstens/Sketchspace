import 'package:flutter/material.dart';

enum StartedFrom { left, right, top, bottom, none }

class Gestures extends ChangeNotifier {
  Offset _potentialGestureStart = Offset.zero;
  StartedFrom _startedFrom = StartedFrom.none;
  List<Offset> _path = [];
  Offset _potentialGestureEnd = Offset.zero;

  Offset get potentialGestureStart => _potentialGestureStart;
  StartedFrom get startedFrom => _startedFrom;
  List<Offset> get path => _path;
  Offset get potentialGestureEnd => _potentialGestureEnd;

  void openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  bool startGesture(Offset start, StartedFrom from) {
    _potentialGestureStart = start;
    _startedFrom = from;
    return true;
  }

  void endGesture(Offset end) {
    _potentialGestureEnd = end;
    _path = [_potentialGestureStart, _potentialGestureEnd];
    notifyListeners();
  }

  void Gesture() {
    _path = [];
    notifyListeners();
  }
}
