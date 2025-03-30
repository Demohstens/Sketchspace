import 'package:flutter/widgets.dart';
import 'package:sketchspace/classes/element.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:ui' as ui show Image;

class ImageElement extends SketchElement {
  ui.Image image;
  Offset position;
  @override
  Rect get boundary {
    return Rect.fromLTWH(position.dx, position.dy, image.width!.toDouble(), image.height!.toDouble());
  }

  ImageElement({required this.image, required this.position, super.id, required super.layerId});
  
  @override
  draw(Canvas c) {
    c.drawImage(image as ui.Image, position, Paint());
  }

  @override
  bool hitTest(Offset touchPoint) {
    return boundary.contains(touchPoint);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  transform(Matrix4 transform) {
    // TODO: implement transform
    throw UnimplementedError();
  }

  @override
  translate(Offset offset) {
    // TODO: implement translate
    throw UnimplementedError();
  }
}