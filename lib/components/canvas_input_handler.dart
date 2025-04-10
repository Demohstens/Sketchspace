import 'dart:math';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/classes/transformation_controller.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';
import 'package:sketchspace/tools/tools.dart';
import 'package:vector_math/vector_math_64.dart';

class CanvasInputHandler extends StatefulWidget {
  final Widget? child;
  final double canvasWidth;
  final double canvasHeight;

  late bool isLandscape = canvasWidth > canvasHeight;

  // final TransformController controller;
  CanvasInputHandler({
    this.child,
    super.key,
    required this.canvasWidth,
    required this.canvasHeight,
  });
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
  late double scaleStartDistance;
  late Offset scaleStartMidpoint;
  late Matrix4 scaleStartMatrix;

  /// Location of a registered LongpressDown
  Offset longPressLocation = Offset.zero;
  Offset scaleStartFocalPoint = Offset.zero;

  DateTime timeOfLastDown = DateTime.fromMicrosecondsSinceEpoch(0);

  bool isDrawing = false;
  bool isScaling = false;

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

  void cancelDrawing() {
    print("cancelled drawing");
    context.read<DrawingContext>().cancelDrawing();
    isDrawing = false;
  }

  void endErasing() {
    context.read<DrawingContext>().endErasing();
    isDrawing = false;
  }

  void onDoubleTap(BuildContext c) {
    c.read<TransformController>().resetTransformations();
  }

  void onLongPress(BuildContext c, Offset position) {
    var transformedPoint = c.read<TransformController>().inversePoint(position);
    c.read<DrawingContext>().selectElement(transformedPoint);
    // Handle long press here
  }

  void startScaling(Offset screenPos) {
    scaleStart = screenPos;

    Offset point1 = inputEvents[0].position;
    Offset point2 = inputEvents[1].position;

    scaleStartFocalPoint = Offset(
      (point1.dx + point2.dx) / 2,
      (point1.dy + point2.dy) / 2,
    );
    canDraw = false;
    isScaling = true;
  }

  void endScaling() {
    isScaling = false;
    Future.delayed(
      Duration(milliseconds: context.read<Settings>().drawCooldown),
      () {
        canDraw = true;
      },
    );
  }

  void _handleScroll(PointerScrollEvent event, BuildContext context) {
    final double zoomDelta = event.scrollDelta.dy > 0 ? 0.95 : 1.05;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(event.position);

    final Matrix4 currentTransform = context.read<TransformController>().value;
    final double currentScale = currentTransform.getMaxScaleOnAxis();

    // TODO clamp by canvas size

    context.read<TransformController>().value =
        Matrix4.identity()
          ..translate(localPosition.dx, localPosition.dy)
          ..scale(zoomDelta)
          ..translate(-localPosition.dx, -localPosition.dy)
          ..multiply(currentTransform);
  }

  List<SketchPointerEvent> inputEvents = [];

  @override
  Widget build(BuildContext context) {
    final tool = context.watch<DrawingContext>().tool;

    return SizedBox(
      width: context.width,
      height: context.height,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          inputEvents.add(
            SketchPointerEvent(
              pointer: event.pointer,
              buttons: event.buttons,
              position: event.localPosition,
              timeStamp: DateTime.now(),
            ),
          );
          // Check for double tap
          final timeDif = timeOfLastDown.difference(DateTime.now()).abs();
          if (timeDif < Duration(milliseconds: 200) && inputEvents.length == 1) {
            onDoubleTap(context);
          }
          if (inputEvents.length == 2) {
            isScaling = true;
            final point1 = inputEvents[0].position;
            final point2 = inputEvents[1].position;
            scaleStartDistance = (point1 - point2).distance;
            scaleStartMidpoint = Offset(
              (point1.dx + point2.dx) / 2,
              (point1.dy + point2.dy) / 2,
            );
            scaleStartMatrix = context.read<TransformController>().value;
          }
          print("Pointer Down: ${inputEvents.length}");
          if (event.buttons == kPrimaryButton &&
              canDraw &&
              tool == Tool.brush &&
              inputEvents.length == 1) {
            startDrawing();
            final transformedPoint = context
                .read<TransformController>()
                .inversePoint(event.localPosition);
            context.read<DrawingContext>().addPoint(transformedPoint);
          } else if (inputEvents.length == 2 && event.buttons == kTouchContact) {
            // Start scaling when two fingers are down
            cancelDrawing();
            startScaling(event.localPosition);

            lastScaleFactor = 1.0;
          }
          timeOfLastDown = DateTime.now();
        },
        onPointerUp: (event) {
          final removedEvent = inputEvents.firstWhere(
            (ev) => ev.pointer == event.pointer,
            orElse: () => SketchPointerEvent(
              pointer: -1,
              buttons: 0,
              position: Offset.zero,
              timeStamp: DateTime.now(),
            ),
          );

          if (removedEvent.pointer != -1) {
            final pressDuration =
                DateTime.now().difference(removedEvent.timeStamp);
            if (pressDuration >= Duration(milliseconds: 500)) {
              onLongPress(context, removedEvent.position);
            }
          }

          inputEvents.removeWhere((ev) {
            return ev.pointer == event.pointer;
          });

          if (isDrawing) {
            endDrawing();
          }
          if (inputEvents.length < 2 && isScaling) {
            endScaling();
          }
          canDraw = true;
        },
        onPointerMove: (event) {
          for (int i = 0; i < inputEvents.length; i++) {
            if (inputEvents[i].pointer == event.pointer) {
              inputEvents[i] = SketchPointerEvent(
                pointer: event.pointer,
                buttons: event.buttons,
                position: event.localPosition,
                timeStamp: inputEvents[i].timeStamp,
              );
              break;
            }
          }

          if (event.buttons == kPrimaryButton && inputEvents.length == 1) {
            if (isDrawing) {
              final transformedPoint = context
                  .read<TransformController>()
                  .inversePoint(event.localPosition);
              context.read<DrawingContext>().addPoint(transformedPoint);
            }
          }

          if (inputEvents.length == 2 && isScaling) {
            final point1 = inputEvents[0].position;
            final point2 = inputEvents[1].position;

            // Current state
            final currentDistance = (point1 - point2).distance;
            final currentMidpoint = Offset(
              (point1.dx + point2.dx) / 2,
              (point1.dy + point2.dy) / 2,
            );

            // Calculate scale
            final scale = currentDistance / scaleStartDistance;

            final controller = context.read<TransformController>();
            final matrix = Matrix4.identity()
              ..translate(currentMidpoint.dx, currentMidpoint.dy)
              ..scale(scale)
              ..translate(-scaleStartMidpoint.dx, -scaleStartMidpoint.dy)
              ..multiply(scaleStartMatrix);

            controller.value = matrix;
          }
        },
        onPointerSignal: (PointerSignalEvent event) {
          switch (event) {
            case PointerScrollEvent scrollEvent:
              _handleScroll(scrollEvent, context);
              break;
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            ValueListenableBuilder<Matrix4>(
              valueListenable: context.read<TransformController>(),
              builder: (context, matrix, child) {
                return Transform(transform: matrix, child: widget.child);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SketchPointerEvent {
  final int pointer;
  final int buttons;
  final Offset position;
  final DateTime timeStamp;

  SketchPointerEvent({
    required this.pointer,
    required this.buttons,
    required this.position,
    required this.timeStamp,
  });
}
