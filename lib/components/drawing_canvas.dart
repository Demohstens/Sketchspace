import 'package:flutter/material.dart';
import 'package:flutter_application/brushes/current_path_pen.dart';
import 'package:flutter_application/classes/drawing_context.dart';
import 'package:flutter_application/classes/settings.dart';
import 'package:flutter_application/brushes/lazy_painter.dart';
import 'package:flutter_application/stroke_selector/paint_selector.dart';
import 'package:flutter_application/stroke_selector/src/find_closest_stroke.dart';
import 'package:provider/provider.dart';

class DrawingCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingContext>(
      builder: (context, drawingContext, child) {
        return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: context.watch<Settings>().background,
            child: Stack(
              children: [
                /// Background Custom Paint - LazyPainter
                RepaintBoundary(
                  child: Container(
                    // Hacky way to force an update.
                    key: Key(context.watch<DrawingContext>().buffer.toString()),
                    child: CustomPaint(
                      willChange: false,
                      isComplex: true,
                      size: Size.infinite,
                      painter: LazyPainter(drawingContext.buffer,
                          drawingContext.repaintListener),
                    ),
                  ),
                ),

                /// Current Path Custom Paint - CurrentLinePainter
                GestureDetector(
                    onLongPressDown: (details) {
                      var c = paintSelector(
                          drawingContext.buffer, details.localPosition);
                      if (c != null) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: c,
                              );
                            });
                      }
                    },
                    onPanUpdate: (details) {
                      // Checks if the current point is the same as the last point
                      // to avoid adding the same point multiple times
                      if (details.localPosition !=
                          drawingContext.currentPoint) {
                        drawingContext.setCurrentPoint(details.localPosition);
                      }
                    },
                    onPanEnd: (details) {
                      drawingContext.createStroke(drawingContext.points);
                    },
                    child: Stack(children: [
                      RepaintBoundary(
                        child: CustomPaint(
                          isComplex: true,
                          size: Size.infinite,
                          painter: CurrentPathPen(drawingContext.points,
                              drawingContext.getPaint(), drawingContext.mode),
                        ),
                      ),
                    ])),
              ],
            ));
      },
    );
  }
}
