import 'package:sketchspace/brushes/current_path_pen.dart';
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
                // Background Custom Paint - LazyPainter
                // RepaintBoundary(
                //   child: Container(
                //       // Hacky way to force an update.
                //       key: Key("Canvas"),
                //       child: AnimatedScale(
                //         scale: context.watch<DrawingContext>().scale,
                //         duration: Duration(milliseconds: 0),
                //         child: CustomPaint(
                //             willChange: false,
                //             isComplex: true,
                //             size: Size.infinite,
                //             painter: DrawImage(drawingContext.backgroundImage,
                //                 drawingContext.repaintListener)),
                //       )),
                // ),

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
                    onScaleStart: (details) {
                      if (details.pointerCount > 1) {
                        drawingContext.startScaling();
                      } else {
                        drawingContext.endScaling();
                        drawingContext.setCurrentPoint(details.localFocalPoint);
                      }
                    },
                    // Scale logic
                    onScaleUpdate: (details) {
                      if (drawingContext.scaling) {
                        drawingContext.updateScale(details.scale);
                      } else {
                        // Checks if the current point is the same as the last point
                        // to avoid adding the same point multiple times
                        if (details.localFocalPoint !=
                            drawingContext.currentPoint) {
                          drawingContext.setCurrentPoint(details.focalPoint);
                        }
                      }
                    },
                    onScaleEnd: (details) {
                      if (drawingContext.scaling) {
                        drawingContext.endScaling();
                      } else {
                        drawingContext.createStroke(drawingContext.points);
                      }
                    },
                    child: Stack(children: [
                      RepaintBoundary(
                        child: AnimatedScale(
                          scale: context.watch<DrawingContext>().scale,
                          duration: Duration(milliseconds: 0),
                          child: CustomPaint(
                            isComplex: true,
                            size: Size.infinite,
                            painter: CurrentPathPen(drawingContext.points,
                                drawingContext.getPaint(), drawingContext.mode),
                          ),
                        ),
                      ),
                      AnimatedScale(
                          scale: context.watch<DrawingContext>().scale,
                          duration: Duration(milliseconds: 0),
                          child:
                              context.watch<DrawingContext>().selectedPaint ??
                                  Container()),
                    ])),
              ],
            ));
      },
    );
  }
}
