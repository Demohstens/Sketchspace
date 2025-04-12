import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class PositionedContextController extends OverlayPortalController {
  Offset position = const Offset(0, 0);

  void setPosition(Offset position) {
    this.position = position;
  }
}
