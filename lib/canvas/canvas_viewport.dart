import 'package:flutter/material.dart';

import 'package:sketchspace/brushes/current_path_pen.dart';
import 'package:sketchspace/brushes/lazy_painter.dart';
import 'package:sketchspace/canvas/data/worldspace.dart';
import 'package:sketchspace/canvas/canvas_context.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/canvas/scale.dart';

class CanvasViewport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<ScaleProvier>(builder: (context, scaleContext, _) {
          return Container(
              constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                  minHeight: MediaQuery.of(context).size.height),
              // Gesture handling for the Canvas
              child: GestureDetector(
                  onDoubleTap: () {
                    context.read<DrawingContext>().toggleUI();
                  },
                  // onLongPressStart: (details) {
                  //   context
                  //       .read<DrawingContext>()
                  //       .selectStroke(details.globalPosition);
                  // },
                  onScaleStart: (details) {
                    if (details.pointerCount > 1) {
                      scaleContext.startScaling(details);
                    } else {
                      scaleContext.endScaling();
                    }
                  },
                  onScaleUpdate: (details) {
                    if (details.pointerCount > 1) {
                      scaleContext.updateScale(details);
                    } else {
                      context
                          .read<DrawingContext>()
                          .setCurrentPoint((details.localFocalPoint));
                    }
                  },
                  onScaleEnd: (details) {
                    scaleContext.endScaling();
                    context.read<Worldspace>().addStrokeFromPoints(
                        context.read<DrawingContext>().points,
                        context.read<DrawingContext>().getPaint());
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
                              context.read<DrawingContext>().getPaint(),
                              context.read<DrawingContext>().mode,
                              Matrix4.identity()),
                          child: Container(),
                        ),
                        // TODO readd selected stroke
                        null ?? Container(),
                      ]),
                    )
                  ])));
        })
      ],
    );
  }
}
