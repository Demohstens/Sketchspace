import 'package:flutter/material.dart';

import 'package:sketchspace/brushes/active_painter.dart';
import 'package:sketchspace/brushes/lazy_painter.dart';
import 'package:sketchspace/canvas/canvas_context.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/canvas/data/scale.dart';
import 'package:sketchspace/canvas/data/worldspace.dart';
import 'package:sketchspace/canvas/zoom-widget/lib/zoom_widget.dart';
import 'package:sketchspace/classes/settings.dart';

class CanvasViewport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<ScaleProvier>(builder: (context, scaleContext, _) {
          return Container(
              color: context.watch<Settings>().background,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                  minHeight: MediaQuery.of(context).size.height),
              child: Zoom(
                canvasColor: context.watch<Settings>().background,
                doubleTapZoom: false,
                maxScale: 3,
                maxZoomWidth: 2000,
                maxZoomHeight: 2000,
                onScaleUpdateDetails: (details) {
                  if (details.pointerCount == 1) {
                    context
                        .read<DrawingContext>()
                        .updateDrawing((details.localFocalPoint));
                  }
                },
                child:
                    //  GestureDetector(
                    //   onDoubleTap: () {
                    //     context.read<DrawingContext>().toggleUI();
                    //   },
                    //   // onLongPressStart: (details) {
                    //   //   context
                    //   //       .read<DrawingContext>()
                    //   //       .selectStroke(details.globalPosition);
                    //   // },
                    //   // onScaleStart: (details) {
                    //   //   if (details.pointerCount > 1) {
                    //   //     scaleContext.startScaling(details);
                    //   //   } else {
                    //   //     scaleContext.endScaling();
                    //   //   }
                    //   // },
                    //   onPanUpdate: (details) {
                    //     context
                    //         .read<DrawingContext>()
                    //         .updateDrawing((details.localPosition));
                    //   },
                    //   // onScaleEnd: (details) {
                    //   //   scaleContext.endScaling();
                    //   //   context.read<DrawingContext>().endDrawing();
                    //   // },

                    //   // The Visual Representation of the Canvas
                    //   child:
                    Stack(children: [
                  Positioned.fill(
                      child: RepaintBoundary(
                    child: CustomPaint(
                        willChange: false,
                        isComplex: true,
                        size: Size.infinite,
                        painter: LazyPainter(context.read<Worldspace>().strokes,
                            context.read<DrawingContext>().repaintListener)),
                  )),
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
