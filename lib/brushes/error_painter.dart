import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

class ErrorPainter extends CustomPainter {
  final String error;
// Create a ParagraphStyle
  final paragraphStyle = ParagraphStyle(
    textAlign: TextAlign.center,
    fontSize: 14.0,
    maxLines: 1,
  );
  ErrorPainter(this.error);

  @override
  void paint(Canvas canvas, Size size) {
    // Create a ParagraphBuilder with the ParagraphStyle
    final paragraphBuilder = ParagraphBuilder(paragraphStyle)
      ..addText('Error: Something went wrong');

    // Build the Paragraph
    final paragraph = paragraphBuilder.build();

    // Layout the Paragraph with a specific width
    paragraph.layout(ParagraphConstraints(width: size.width));

    // Draw the Paragraph on the canvas
    canvas.drawParagraph(paragraph, Offset(size.width / 2, size.height / 2));
  }

  bool shouldRepaint(ErrorPainter oldDelegate) {
    return oldDelegate.error != error;
  }
}
