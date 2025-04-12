import 'dart:ui';

import 'package:sketchspace/classes/element.dart';

class TextElement extends SketchElement {
  final String text;
  final double fontSize;
  final Offset position;

  Rect _rect = Rect.zero;

  TextElement({
    required this.text,
    required this.fontSize,
    required this.position,
    required super.layerId,
    super.id,
  });

  @override
  Rect get boundary => _rect;

  @override
  void draw(Canvas canvas) {
    final parbuilder = ParagraphBuilder(
      ParagraphStyle(fontSize: fontSize, textAlign: TextAlign.left),
    );
    parbuilder.addText(text);
    final par = parbuilder.build();
    par.layout(ParagraphConstraints(width: 100));

    _rect = Rect.fromLTWH(position.dx, position.dy, par.maxIntrinsicWidth, par.height);
    canvas.drawParagraph(par, position);
  }

  @override
  bool hitTest(Offset point) {
    return _rect.contains(point);
  }

  @override
  void scale(scale) {
    // TODO: implement moveBy
  }

  @override
  void transform(transform) {
    // TODO: implement transform
  }

  @override
  void translate(delta) {
    // TODO: implement translate
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'layerId': layerId,
      'type': 'text',
      'text': text,
      'fontSize': fontSize,
      'position': {'x': position.dx, 'y': position.dy},
    };
  }

  factory TextElement.fromJson(Map<String, dynamic> json) {
    return TextElement(
      text: json['text'],
      fontSize: json['fontSize'],
      position: Offset(json['position']['x'], json['position']['y']),
      layerId: json['layerId'],
      id: json['id'],
    );
  }
}
