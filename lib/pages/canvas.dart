import 'package:sketchspace/brushes/lazy_painter.dart';
import 'package:sketchspace/canvas/canvas_viewport.dart';
import 'package:sketchspace/classes/drawing_context.dart';
import 'package:sketchspace/classes/settings.dart';
import 'package:sketchspace/components/canvasUI.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CanvasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedScale(
            scale: context.watch<DrawingContext>().scale,
            duration: Duration(milliseconds: 0),
            child: RepaintBoundary(
                child: Container(
              color: context.watch<Settings>().background,
              child: CustomPaint(
                willChange: false,
                isComplex: true,
                size: Size.infinite,
                painter: LazyPainter(context.watch<DrawingContext>().buffer,
                    context.read<DrawingContext>().repaintListener),
              ),
            ))),
        Positioned.fill(
          child: CanvasViewport(),
        ),
        Visibility(
          visible: context.watch<DrawingContext>().ui_enabled,
          child: CanvasUI(),
        ),
      ],
    );
  }
}
