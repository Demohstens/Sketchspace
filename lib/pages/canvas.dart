import 'package:sketchspace/brushes/lazy_painter.dart';
import 'package:sketchspace/canvas/canvas_viewport.dart';
import 'package:sketchspace/classes/drawing_context.dart';
import 'package:sketchspace/classes/settings.dart';
import 'package:sketchspace/components/canvasUI.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/stroke_selector/src/stroke.dart';

class CanvasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Stroke> buffer =
        context.select<DrawingContext, List<Stroke>>((value) => value.buffer);
    final Matrix4 transformMatrix = context
        .select<DrawingContext, Matrix4>((value) => value.transformMatrix);
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
                  painter: LazyPainter(
                      buffer,
                      context.read<DrawingContext>().repaintListener,
                      transformMatrix),
                ),
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
