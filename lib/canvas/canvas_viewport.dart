import 'package:flutter/material.dart';

import 'package:sketchspace/brushes/active_painter.dart';
import 'package:sketchspace/brushes/lazy_painter.dart';
import 'package:sketchspace/classes/transformation_controller.dart';
import 'package:sketchspace/components/canvas_input_handler.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/canvas/zoom-widget-drawing/lib/zoom_widget.dart' as zoom;
import 'package:sketchspace/providers/settings.dart';
import 'package:sketchspace/components/canvas_overlay.dart';

class CanvasViewport extends StatefulWidget {
  @override
  State<CanvasViewport> createState() => _CanvasViewportState();
}

class _CanvasViewportState extends State<CanvasViewport> {
  final zoom.TransformationController controller = zoom.TransformationController();

  @override
  void dispose() {
    controller.dispose(); // IMPORTANT: Dispose the controller!
    super.dispose();
  }

  final TransformController _transformController = TransformController();

  @override
  Widget build(BuildContext context) {    
    return RepaintBoundary(
      child: Stack(children: [
        CanvasView(
          child: Stack(
            children: [
              ...context.read<DrawingContext>().canvas.layers.values.toList().map((layer) {
                return Stack(
                  children: [
                  // Use ValueListenableBuilder to rebuild layers when repaintNotifier changes
                  ValueListenableBuilder<bool>(
                    valueListenable: context.read<DrawingContext>().repaintNotifier,
                    builder: (context, value, child) {
                      return Stack(
                        children: context.read<DrawingContext>().canvas.layers.values.toList().map((layer) {
                          if (layer.visible == false) {
                            return Container();
                          }
                          return Positioned.fill(
                            child: RepaintBoundary(
                              child: CustomPaint(
                                willChange: false,
                                isComplex: true,
                                size: Size.infinite,
                                painter: LazyPainter(layer.elements.values.toList(), context.read<DrawingContext>().repaintNotifier)
                              )
                            )
                          );
                        }).toList(),
                      );
                    },
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.transparent,
                    child: CustomPaint(
                      isComplex: true,
                      size: Size.infinite,
                      painter: ActivePainter(
                          context.watch<DrawingContext>().points,
                          context.read<DrawingContext>().getPaint())
                          ,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ],
            );
                
              })
            ],
          ),
        ),
        // zoom.Zoom(
        //     transformationController: controller,
        //     canvasColor: context.watch<Settings>().background,
        //     doubleTapZoom: false,
        //     centerOnScale: false,
        //     maxScale: 3,
        //     drawCooldown: context.read<Settings>().drawCooldown,
        //     maxZoomWidth: context.read<DrawingContext>().canvas.width,
        //     maxZoomHeight: context.read<DrawingContext>().canvas.height,
        //     onDrawStart: (point) {
        //       context.read<DrawingContext>().addPoint(point);
        //       context.read<DrawingContext>().unSelectStroke();
        //     },
        //     onTapDown: (touchPoint) {
        //       if (context.read<DrawingContext>().selectedElementId != null) {
        //         context.read<DrawingContext>().unSelectStroke();
        //       }
        //     },
        //     onDrawUpdate: (point) {
        //       context.read<DrawingContext>().updateDrawing(point);
        //       context.read<DrawingContext>().unSelectStroke();
        //     },
        //     onDoubleTap: () {
        //       context.read<DrawingContext>().toggleUI();
        //     },
        //     onDrawEnd: () {
        //       context.read<DrawingContext>().endDrawing();
        //     },
        //     onLongPressStart: (touchPoint) {
        //       context.read<DrawingContext>().selectElement(touchPoint);
        //     },
        //     onLongPressEnd: (details) {},
        //     child: Stack(
        //       children: [
        //         // Use ValueListenableBuilder to rebuild layers when repaintNotifier changes
        //         ValueListenableBuilder<bool>(
        //           valueListenable: context.read<DrawingContext>().repaintNotifier,
        //           builder: (context, value, child) {
        //             return Stack(
        //               children: context.read<DrawingContext>().canvas.layers.values.toList().map((layer) {
        //                 if (layer.visible == false) {
        //                   return Container();
        //                 }
        //                 return Positioned.fill(
        //                   child: RepaintBoundary(
        //                     child: CustomPaint(
        //                       willChange: false,
        //                       isComplex: true,
        //                       size: Size.infinite,
        //                       painter: LazyPainter(layer.elements.values.toList(), context.read<DrawingContext>().repaintNotifier)
        //                     )
        //                   )
        //                 );
        //               }).toList(),
        //             );
        //           },
        //         ),
        //         Container(
        //           width: MediaQuery.of(context).size.width,
        //           height: MediaQuery.of(context).size.height,
        //           color: Colors.transparent,
        //           child: CustomPaint(
        //             isComplex: true,
        //             size: Size.infinite,
        //             painter: ActivePainter(
        //                 context.watch<DrawingContext>().points,
        //                 context.read<DrawingContext>().getPaint())
        //                 ,
        //             child: Container(
        //               width: MediaQuery.of(context).size.width,
        //               height: MediaQuery.of(context).size.height,
        //               color: Colors.transparent,
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
          CanvasOverlay(
            controller: controller,
          )
      ]),
    );
  }
}

