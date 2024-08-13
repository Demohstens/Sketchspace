import 'package:flutter/material.dart';

import 'package:sketchspace/brushes/active_painter.dart';
import 'package:sketchspace/canvas/canvas_context.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/canvas/data/scale.dart';

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
                        .updateDrawing((details.localFocalPoint));
                  }
                },
                onScaleEnd: (details) {
                  scaleContext.endScaling();
                  context.read<DrawingContext>().endDrawing();
                },

                // The Visual Representation of the Canvas
                child: Stack(children: [
                  // Current Path - CurrentLinePainter
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.transparent,
                    child: CustomPaint(
                      isComplex: true,
                      size: Size.infinite,
                      painter: ActivePainter(
                          context.watch<DrawingContext>().points,
                          context.read<DrawingContext>().getPaint(),
                          context.read<DrawingContext>().mode),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  // TODO readd selected stroke
                  null ?? Container(),
                ]),
              ));
        })
      ],
    );
  }
}
