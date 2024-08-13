import 'package:flutter/material.dart';

import 'package:sketchspace/brushes/active_painter.dart';
import 'package:sketchspace/brushes/error_painter.dart';
import 'package:sketchspace/canvas/canvas_context.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/canvas/stroke_selector/paint_selector.dart';
import 'package:sketchspace/canvas/data/worldspace.dart';
import 'package:sketchspace/canvas/zoom-widget-drawing/lib/zoom_widget.dart';
import 'package:sketchspace/classes/settings.dart';

class CanvasViewport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget? selectedStroke;
    ErrorPainter('No Painter Found');
    Color background = context.watch<Settings>().background;
    return Stack(children: [
      Container(
          color: background,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
              minHeight: MediaQuery.of(context).size.height),
          child: Zoom(
            canvasColor: context.watch<Settings>().background,
            doubleTapZoom: false,
            maxScale: 3,
            drawCooldown: context.read<Settings>().drawCooldown,
            maxZoomWidth: 2000,
            maxZoomHeight: 2000,
            onDrawUpdate: (point) {
              context.read<DrawingContext>().updateDrawing(point);
            },
            onDoubleTap: () {
              context.read<DrawingContext>().toggleUI();
            },
            onDrawEnd: () {
              context.read<DrawingContext>().endDrawing();
            },
            onLongPressStart: (details) {
              Offset touchPoint = details.localPosition;
              selectedStroke = strokeSelector(
                  context.read<Worldspace>().strokes, touchPoint);
              context.read<DrawingContext>().unSelectStroke();
            },
            onLongPressEnd: (details) {
              context.read<DrawingContext>().selectedPaint = null;
            },
            child: Stack(children: [
              Positioned.fill(
                  child: RepaintBoundary(
                      child: CustomPaint(
                          willChange: false,
                          isComplex: true,
                          size: Size.infinite,
                          painter:
                              context.read<Worldspace>().getLazyPainter()))),
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
              context.watch<DrawingContext>().selectedStroke ?? Container(),
            ]),
          ))
    ]);
  }
}
