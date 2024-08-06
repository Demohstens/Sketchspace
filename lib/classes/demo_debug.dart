import 'package:flutter/material.dart';

class DemoDebug with ChangeNotifier {
  int _numberOfPoints = 0;

  int get numberOfPoints => _numberOfPoints;

  void incrementNumberOfPoints() {
    _numberOfPoints++;
    notifyListeners();
  }
}
