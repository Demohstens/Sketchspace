import 'package:flutter/material.dart';

class Stroke {
  late Color _color;
  late List<Offset> _points;
  late double _width;
  Stroke(
      {required color, required List<Offset> points, required double width}) {
    this._color = color;
    this._points = points;
    this._width = width;
  }

  double get width => _width;
  Color get color => _color;
  List<Offset> get points => _points;
}
