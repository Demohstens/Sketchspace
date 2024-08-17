// library paint_selector;

// import 'package:sketchspace/canvas/data/worldspace.dart';
// import 'package:sketchspace/canvas/stroke_selector/src/find_closest_stroke.dart';
// import 'package:sketchspace/canvas/stroke_selector/src/stroke.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// Widget? strokeSelector(List<Stroke> strokes, Offset touchPoint) {
//   print('Selecting Stroke');
//   int? indexOfClosestStroke = findClosestStrokeIndex(strokes, touchPoint);
//   // If there is no stroke, which is close enough to fit the pramaters, return null
//   if (indexOfClosestStroke == null) {
//     print('No stroke found');
//     return null;
//   }

//   Stroke closestStroke = strokes[indexOfClosestStroke];
//   Rect boundary = closestStroke.boundary();
//   if (boundary.width == 0 || boundary.height == 0) {
//     print('Invalid boundary dimensions');
//     return null;
//   }

//   return Stack(children: [
//     Positioned(
//         left: boundary.left,
//         top: boundary.top,
//         child: Container(
//           color: const Color.fromARGB(232, 255, 17, 17),
//           width: boundary.width,
//           height: boundary.height,
//           child: CustomPaint(
//             painter: _Painter(closestStroke),
//           ),
//         )),
//     // CircularContextMenu(),
//     StrokeManipulationMenu(indexOfClosestStroke, touchPoint)
//   ]);
// }



// class StrokeManipulationMenu extends StatelessWidget {
//   final int index;
//   final Offset touchPoint;
//   StrokeManipulationMenu(this.index, this.touchPoint);
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//         top: touchPoint.dy - 100,
//         left: touchPoint.dx,
//         child: FloatingActionButton.small(
//             onPressed: () {
//               context.read<Worldspace>().removeStrokeAt(index);
//             },
//             child: Icon(Icons.delete)));
//   }
// }
