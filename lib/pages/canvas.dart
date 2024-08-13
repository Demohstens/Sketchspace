import 'package:sketchspace/brushes/lazy_painter.dart';
import 'package:sketchspace/canvas/canvas_viewport.dart';
import 'package:sketchspace/canvas/data/worldspace.dart';
import 'package:sketchspace/canvas/canvas_context.dart';
import 'package:sketchspace/classes/settings.dart';
import 'package:sketchspace/components/canvasUI.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/canvas/data/stroke_selector/src/stroke.dart';

class CanvasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Stroke> buffer =
        context.select<Worldspace, List<Stroke>>((value) => value.strokes);
    return Container(
        color: context.watch<Settings>().background,
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                    willChange: false,
                    isComplex: true,
                    size: Size.infinite,
                    painter: LazyPainter(buffer,
                        context.read<DrawingContext>().repaintListener)),
              ),
            ),
            Positioned.fill(
              child: CanvasViewport(),
            ),
            Visibility(
              visible: context.watch<DrawingContext>().ui_enabled,
              child: CanvasUI(),
            ),
          ],
        ));
  }
}
