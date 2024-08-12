import 'package:flutter/material.dart';

abstract class Tool {
  // Paint brush settings
  late PaintingStyle _style;
  PaintingStyle get style => _style;

  Tool({required PaintingStyle style}) {
    _style = style;
  }
}
