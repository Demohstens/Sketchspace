import 'package:flutter/material.dart';

import 'package:sketchspace/brushes/current_path_pen.dart';
import 'package:sketchspace/brushes/lazy_painter.dart';
import 'package:sketchspace/classes/drawing_context.dart';
import 'package:provider/provider.dart';

class CanvasViewport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<DrawingContext>(builder: (context, drawingContext, _) {
          return Container(

              // Gesture handling for the Canvas
              child: GestureDetector(
                  onDoubleTap: () {
                    context.read<DrawingContext>().toggleUI();
                  },
                  onLongPressStart: (details) {
                    context
                        .read<DrawingContext>()
                        .selectStroke(details.globalPosition);
                  },
                  onScaleStart: (details) {
                    if (details.pointerCount > 1) {
                      drawingContext.startScaling(details);
                    } else {
                      drawingContext.endScaling();
                    }
                  },
                  onScaleUpdate: (details) {
                    drawingContext.scaling
                        ? drawingContext.updateScale(details)
                        : drawingContext
                            .setCurrentPoint(details.localFocalPoint);
                  },
                  onScaleEnd: (details) {
                    drawingContext.endScaling();
                    drawingContext.createStroke();
                  },

                  // The Visual Representation of the Canvas
                  child: Stack(children: [
                    // LazyCanvas - cached Background
                    // Moved to canvas.dart
                    // Current Path - CurrentLinePainter
                    RepaintBoundary(
                      child: Stack(children: [
                        CustomPaint(
                          isComplex: true,
                          size: Size.infinite,
                          painter: CurrentPathPen(
                              context.watch<DrawingContext>().points,
                              drawingContext.getPaint(),
                              drawingContext.mode,
                              drawingContext.transformMatrix),
                        ),
                        drawingContext.selectedPaint ?? Container(),
                      ]),
                    )
                  ])));
        })
      ],
    );
  }
}
