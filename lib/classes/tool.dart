// import 'package:flutter/material.dart';
// import 'package:flutter_application/classes/stroke.dart';

// class Tool extends CustomPainter {
//   final Stroke stroke;
//   final Color currentColor;

//   Tool(this.stroke, this.currentColor);

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = currentColor
//       ..strokeWidth = stroke.width
//       ..style = PaintingStyle.stroke;
//     Path currentPathToDraw = Path();
//     currentPathToDraw.moveTo(stroke.points.first.dx, stroke.points.first.dy);
//     for (int i = 1; i < stroke.points.length; i++) {
//       currentPathToDraw.lineTo(stroke.points[i].dx, stroke.points[i].dy);
//     }
//     canvas.drawPath(currentPathToDraw, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }
