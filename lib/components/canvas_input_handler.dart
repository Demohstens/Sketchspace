import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/classes/transformation_controller.dart';
import 'package:sketchspace/components/canvas_overlay.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/tools/tools.dart';

class CanvasView extends StatefulWidget {
  final Widget child;
  const CanvasView({required this.child, super.key});
  @override
  State<CanvasView> createState() => _CanvasViewState();
}


class _CanvasViewState extends State<CanvasView> {
  final TransformController _transformController = TransformController();

  Offset scaleStart = Offset.zero;
  double lastScaleFactor = 1.0;
  Offset scaleEnd = Offset.zero;
  double scaleFactor = 1.0;
  double rotation = 0.0;

  bool isDrawing = false;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Canvas Test')),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.red,
        child: Stack(
        children: [
          ValueListenableBuilder<Matrix4>(
            valueListenable: _transformController,
            builder: (context, matrix, child) {
              return Transform(
                transform: matrix,
                child: widget.child,
              );
            },
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onDoubleTap: () {
                print('Tapped');
                _transformController.resetTransformations();
              },
              onScaleStart: (details) {
                print('Scale Start');
                if (details.pointerCount == 1) {
                  isDrawing = true;
                  print('Drawing');
                }
                scaleStart = details.focalPoint;
                lastScaleFactor = 1.0;
              },
              onScaleEnd: (details) {
                if (isDrawing) {
                  context.read<DrawingContext>().endDrawing();
                  isDrawing = false;
                }
              },
              onScaleUpdate: (details) {
                if (context.read<DrawingContext>().tool == Tool.brush) {
                  if (details.pointerCount == 1 && isDrawing) {
                    final Offset localFocalPoint = details.localFocalPoint;
                    context.read<DrawingContext>().addPoint(localFocalPoint);
                  }
                }
                if (details.pointerCount >= 2) {
                  // Calculate the focal point in local coordinates
                  final Offset localFocalPoint = details.localFocalPoint;
                  final double delta = details.scale / lastScaleFactor;
                  
                  // Calculate pan delta
                  final Offset panDelta = details.focalPoint - scaleStart;
                  scaleStart = details.focalPoint;
                  
                  // Apply both zoom and pan transformations
                  _transformController.value = Matrix4.identity()
                    ..translate(localFocalPoint.dx, localFocalPoint.dy)
                    ..scale(delta)
                    ..translate(-localFocalPoint.dx, -localFocalPoint.dy)
                    ..translate(panDelta.dx, panDelta.dy)
                    ..multiply(_transformController.value);
                  
                  // Store the current scale for next update
                  lastScaleFactor = details.scale;
                }
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
