import 'package:sketchspace/brushes/current_path_pen.dart';
import 'package:sketchspace/brushes/lazy_painter.dart';
import 'package:sketchspace/classes/drawing_context.dart';
import 'package:sketchspace/classes/settings.dart';
import 'package:flutter/material.dart';
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
                    onDoubleTap: () {
                      context.read<DrawingContext>().toggleUI();
                    },
                    onLongPressStart: (details) {
                      context
                          .read<DrawingContext>()
                          .selectStroke(details.globalPosition);
                    },
                    onLongPressEnd: (details) {},
                    onTap: () {
                      context.read<DrawingContext>().unselectStroke();
                    },
                    onPanUpdate: (details) {
                      context.read<DrawingContext>().unselectStroke();

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
                      context.watch<DrawingContext>().selectedPaint ??
                          Container(),
                    ])),
              ],
            ));
      },
    );
  }
}
