// import 'dart:convert';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter_application/classes/drawing_context.dart';

// class Stroke {
//   final Paint _paint;
//   final List<Offset> _points;
//   final Mode _mode;

//   Stroke(this._paint, this._points, this._mode);
//   Paint get paint => _paint;
//   double get width => _paint.strokeWidth;
//   Color get color => _paint.color;
//   List<Offset> get points => _points;
//   Mode get mode => _mode;

//   /// Ramer-Douglas-Peucker Algorithm. Returns an optimized Stroke
//   Stroke optimize() {
//     if (_points.length < 3) {
//       return this;
//     }
//     List<Offset> optimizedPoints = optimizeRDP(
//       _points,
//       0.05,
//     );
//     return Stroke(_paint, optimizedPoints, _mode);
//   }

//   /// Returns a Stroke object from a json object
//   factory Stroke.fromJson(Map<String, dynamic> json) {
//     return Stroke(
//       Paint()
//         ..color = Color(json['paint']['color'])
//         ..strokeWidth = json['paint']['strokeWidth']
//         ..style = json['mode'])),
//       (json['points'] as List).map((e) => Offset(e[0], e[1])).toList(),
//       stringToMode(json['mode']),
//     );
//   }

//   /// Returns A string for json serialization
//   /// Format: {paint: {color: , strokeWidth: }, points: [(x, y), (x, y), ...]}
//   String toJson() {
//     return jsonEncode({
//       "mode": _mode.toString().split('.').last,
//       "paint": {
//         "color": _paint.color.value,
//         "strokeWidth": _paint.strokeWidth,
//       },
//       "points": _points.map((e) => [e.dx, e.dy]).toList(),
//     });
//   }
// }

// double perpendicularDistance(Offset point, Offset lineStart, Offset lineEnd) {
//   double dx = lineEnd.dx - lineStart.dx;
//   double dy = lineEnd.dy - lineStart.dy;

//   double mag = sqrt(dx * dx + dy * dy);
//   if (mag == 0.0) return 0.0;

//   double u = ((point.dx - lineStart.dx) * dx + (point.dy - lineStart.dy) * dy) /
//       (mag * mag);

//   double x = lineStart.dx + u * dx;
//   double y = lineStart.dy + u * dy;

//   dx = x - point.dx;
//   dy = y - point.dy;

//   return sqrt(dx * dx + dy * dy);
// }

// List<Offset> optimizeRDP(List<Offset> points, double epsilon) {
//   if (points.length < 3) {
//     return points;
//   }

//   double dmax = 0;
//   int index = 0;
//   int end = points.length;
//   for (int i = 1; i < end - 1; i++) {
//     double d = perpendicularDistance(points[i], points[0], points[end - 1]);
//     if (d > dmax) {
//       index = i;
//       dmax = d;
//     }
//   }

//   List<Offset> result = [];

//   if (dmax > epsilon) {
//     List<Offset> recResults1 =
//         optimizeRDP(points.sublist(0, index + 1), epsilon);
//     List<Offset> recResults2 = optimizeRDP(points.sublist(index, end), epsilon);
//     result = recResults1.sublist(0, recResults1.length - 1) + recResults2;
//   } else {
//     result = [points.first, points.last];
//   }

//   return result;
// }

// PaintingStyle modeToPaintingStyle(Mode mode) {
//   switch (mode) {
//     case Mode.drawing:
//       return PaintingStyle.stroke;
//     case Mode.erasing:
//       return PaintingStyle.stroke;
//     case Mode.line:
//       return PaintingStyle.stroke;
//     case Mode.fill:
//       return PaintingStyle.fill;
//     case Mode.lifted:
//       return PaintingStyle.stroke;
//   }
// }

// Mode stringToMode(String str) {
//   switch (str) {
//     case 'drawing':
//       return Mode.drawing;
//     case 'erasing':
//       return Mode.erasing;
//     case 'line':
//       return Mode.line;
//     case 'fill':
//       return Mode.fill;
//     case 'lifted':
//       return Mode.lifted;
//     case _:
//       return Mode.lifted;
//   }
// }
