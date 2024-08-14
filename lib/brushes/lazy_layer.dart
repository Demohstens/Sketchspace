// import 'dart:ui';

// import 'package:flutter/material.dart' as material;
// import 'package:path/path.dart';
// import 'package:sketchspace/stroke_selector/src/stroke.dart';
// import 'package:sketchspace/utils/repaint_listener.dart';

// Image getLazyLayer(List<Stroke> strokes, width, height) {
//   late PictureRecorder _recorder = PictureRecorder();
//   late Canvas canvas = Canvas(_recorder);

//   print("Painting lazy painter 2");
//   // Thank you Philip! (https://github.com/lalondeph/flutter_performance_painter/)
//   for (Stroke stroke in strokes) {
//     if (stroke.points.length == 1) {
//       canvas.drawPoints(PointMode.points, stroke.points, stroke.paint);
//     }
//     Paint paint = stroke.paint;

//     Path pathToDraw = Path();
//     for (int i = 0; i < stroke.points.length; i++) {
//       if (i == 0) {
//         pathToDraw.moveTo(stroke.points[i].dx, stroke.points[i].dy);
//       } else if (i > 0) {
//         pathToDraw.lineTo(stroke.points[i].dx, stroke.points[i].dy);
//       }
//     }
//     canvas.drawPath(pathToDraw, paint);
//   }

//   return _recorder.endRecording().toImageSync(width, height);
// }

// class DrawImage extends material.CustomPainter {
//   late Image? image;
//   final RepaintListener repaintListener;
//   DrawImage(this.image, this.repaintListener);

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (image != null) {
//       print("Drawing Image");
//       canvas.drawImage(image!, Offset.zero, Paint());
//     }
//   }

//   @override
//   bool shouldRepaint(DrawImage oldDelegate) {
//     return oldDelegate.repaintListener.toString() != repaintListener.toString();
//   }
// }
