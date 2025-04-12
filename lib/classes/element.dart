import 'package:flutter/widgets.dart';
import 'package:sketchspace/classes/elements/image_el.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/classes/path.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;

import 'package:vector_math/vector_math_64.dart'; 

abstract class SketchElement {
  late String id;
  final String layerId;

  Rect get boundary;

  SketchElement({
    required this.layerId,
    String? id, 
  }) : id = id ?? Uuid().v4();

  bool hitTest(Offset point);
  Map<String, dynamic> toJson();
  draw(Canvas c);
  transform(Matrix4 transform);
  scale(Vector2 scale);
  translate(Offset offset);

  factory SketchElement.fromJson(Map<String, dynamic> json) {
    throw Exception("Use subclass constructor");
  }
}
