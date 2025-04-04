import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/classes/transformation_controller.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';
import 'package:sketchspace/tools/tools.dart';

class CanvasInputHandler extends StatefulWidget {
  final Widget child;
  // final TransformController controller;
  CanvasInputHandler({required this.child,super.key});
  @override
  State<CanvasInputHandler> createState() => _CanvasInputHandlerState();
}

class _CanvasInputHandlerState extends State<CanvasInputHandler> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  Offset scaleStart = Offset.zero;
  double lastScaleFactor = 1.0;
  Offset scaleEnd = Offset.zero;
  double scaleFactor = 1.0;
  double rotation = 0.0;
  bool isAltPressed = false;
  bool canDraw = true;

  /// Location of a registered LongpressDown
  Offset longPressLocation = Offset.zero;

  bool isDrawing = false;

  @override
  void initState() {
    super.initState();
    // Add focus node to capture keyboard events
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  void startDrawing() {
    // context.read<DrawingContext>().startDrawing();
    context.read<DrawingContext>().unselectAll();
    isDrawing = true;
  }

  void endDrawing() {
    context.read<DrawingContext>().endDrawing();
    isDrawing = false; 
  }

  void endErasing() {
    context.read<DrawingContext>().endErasing();
    isDrawing = false;
  }

  void startScaling() {
    canDraw = false;
  }

  void endScaling() {
    Future.delayed(Duration(milliseconds: context.read<Settings>().drawCooldown), () {
      canDraw = true;
    });
  }

  void _handleScroll(PointerScrollEvent event, BuildContext context) {
      // Prevent default scroll behavior when Alt is pressed
      // event.preventDefault();

      // Calculate zoom factor based on scroll delta
      final double zoomDelta = event.scrollDelta.dy > 0 ? 0.95 : 1.05;

      // Get the mouse position in local coordinates
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final Offset localPosition = renderBox.globalToLocal(event.position);

      // Apply zoom transformation around mouse position
      context.read<TransformController>().value = Matrix4.identity()
        ..translate(localPosition.dx, localPosition.dy)
        ..scale(zoomDelta)
        ..translate(-localPosition.dx, -localPosition.dy)
        ..multiply(context.read<TransformController>().value);
    
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
          onPointerSignal: (PointerSignalEvent event) {
            if (event is PointerScrollEvent) {
              _handleScroll(event, context);
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: context.watch<Settings>().background,
              child: SizedBox(
                        width: 3000,
                        height: 3000,
                        child: Stack(
                          children: [
                            ValueListenableBuilder<Matrix4>(
                              valueListenable: context.read<TransformController>(),
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
                                onTapUp: (details) {
                                  if (context.read<DrawingContext>().tool == Tool.mouse) {
                                    final Offset transformedPoint =
                                        context.read<TransformController>().inversePoint(
                                            details.localPosition);
                                    context.read<DrawingContext>().selectElement(transformedPoint);
                                  }
                                  if (context.read<DrawingContext>().tool ==
                                      Tool.text) {
                                    final pos = context.read<TransformController>()
                                      .inversePoint(details.localPosition);
                                    context.read<DrawingContext>().insertText(pos);
                                  }
                                },
                                
                                onDoubleTap: () {
                                  context.read<TransformController>().resetTransformations();
                                },
                                onLongPressDown: (details) {
                                  longPressLocation = context.read<TransformController>()
                                      .inversePoint(details.localPosition);
                                },
                                onLongPress: () {
                                  context
                                      .read<DrawingContext>()
                                      .selectElement(longPressLocation);
                                },
                                onScaleStart: (details) {
                                  Tool selectedTool =  context.read<DrawingContext>().tool;
                                  if (details.pointerCount == 1 && canDraw && selectedTool == Tool.strokeEraser || selectedTool == Tool.brush) {
                                    // Start drawing
                                    startDrawing();
                                  } else {
                                    startScaling();
                                  }
                                  scaleStart = details.focalPoint;
                                  lastScaleFactor = 1.0;
                                  
                                },
                                onScaleEnd: (details) {
                                  if (isDrawing) {
                                    Tool selectedTool =  context.read<DrawingContext>().tool;

                                    if (selectedTool == Tool.brush) {
                                      endDrawing();
                                    } else if (selectedTool == Tool.strokeEraser) {
                                      endErasing();
                                    }
                                  } else {
                                    endScaling();
                                  }
                                },
                                onScaleUpdate: (details) {
                                  if (context.read<DrawingContext>().tool ==
                                      Tool.brush) {
                                    if (details.pointerCount == 1 && isDrawing) {
                                      final Offset transformedPoint =
                                          context.read<TransformController>().inversePoint(
                                              details.localFocalPoint);
                                      context
                                          .read<DrawingContext>()
                                          .addPoint(transformedPoint);
                                    }
                                  }
                                  if (details.pointerCount >= 2 || context.read<DrawingContext>().tool == Tool.mouse) {
                                    final Offset localFocalPoint =
                                        details.localFocalPoint;
                                    final double delta =
                                        details.scale / lastScaleFactor;

                                    final Offset panDelta =
                                        details.focalPoint - scaleStart;
                                    scaleStart = details.focalPoint;

                                    context.read<TransformController>().value = Matrix4.identity()
                                      ..translate(
                                          localFocalPoint.dx, localFocalPoint.dy)
                                      ..scale(delta)
                                      ..translate(
                                          -localFocalPoint.dx, -localFocalPoint.dy)
                                      ..translate(panDelta.dx, panDelta.dy)
                                      ..multiply(context.read<TransformController>().value);

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
                      ),
                    ),
                  );
  }
}
