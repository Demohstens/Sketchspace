import 'dart:math';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/classes/transformation_controller.dart';
import 'package:sketchspace/components/context_menu/context_menu.dart';
import 'package:sketchspace/components/context_menu/stroke_context.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';
import 'package:sketchspace/tools/tools.dart';

class CanvasInputHandler extends StatefulWidget {
  final Widget? child;
  final double canvasWidth;
  final double canvasHeight;

  late bool isLandscape = canvasWidth > canvasHeight;

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
  final contextMenuController = PositionedContextController();
  final FocusNode _focusNode = FocusNode();

  Offset scaleStart = Offset.zero;
  Offset panStart = Offset.zero;
  double lastScaleFactor = 1.0;
  Offset scaleEnd = Offset.zero;
  double scaleFactor = 1.0;
  double rotation = 0.0;
  bool isAltPressed = false;
  bool isShiftPressed = false;
  bool canDraw = true;
  bool isPanning = false;
  late double scaleStartDistance;
  late Offset scaleStartMidpoint;
  late Matrix4 scaleStartMatrix;

  Offset longPressLocation = Offset.zero;
  Offset scaleStartFocalPoint = Offset.zero;

  DateTime timeOfLastDown = DateTime.fromMicrosecondsSinceEpoch(0);

  bool isDrawing = false;
  bool isScaling = false;
  bool potentialLongPress = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  void startDrawing() {
    context.read<DrawingContext>().unselectAll();
    isDrawing = true;
  }

  void endDrawing() {
    context.read<DrawingContext>().endDrawing();
    isDrawing = false;
  }

  void cancelDrawing() {
    context.read<DrawingContext>().cancelDrawing();
    isDrawing = false;
  }

  void endErasing() {
    context.read<DrawingContext>().endErasing();
    isDrawing = false;
  }

  void startPanning(Offset position) {
    panStart = position;
    isPanning = true;
    canDraw = false;
  }

  void endPanning() {
    isPanning = false;
    canDraw = true;
  }

  void onDoubleTap(BuildContext c) {
    c.read<TransformController>().resetTransformations();
  }

  void onLongPress(DrawingContext c, Offset transformedPosition) {
    canDraw = false;
    potentialLongPress = false;
    c.cancelDrawing();
    c.selectElement(transformedPosition);
  }

  void startPotentialLongPress(BuildContext c, Offset position) {
    var transformedPoint = c.read<TransformController>().inversePoint(position);
    var dc = context.read<DrawingContext>();
    potentialLongPress = true;
    Future.delayed(Duration(milliseconds: 500), () {
      if (potentialLongPress) {
        onLongPress(dc, transformedPoint);
      }
    });
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
        inputEvents.clear();
      },
    );
  }

  void _handleScroll(PointerScrollEvent event, BuildContext context) {
    final double zoomDelta = event.scrollDelta.dy > 0 ? 0.95 : 1.05;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(event.position);

    final Matrix4 currentTransform = context.read<TransformController>().value;

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

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
              event.logicalKey == LogicalKeyboardKey.shiftRight) {
            isShiftPressed = true;
          }
        }
        if (event is KeyUpEvent) {
          if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
              event.logicalKey == LogicalKeyboardKey.shiftRight) {
            isShiftPressed = false;
          }
        }
        return KeyEventResult.handled;
      },
      child: SizedBox(
        width: context.width,
        height: context.height,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) {
            // Creates and adds the event to the list of events being tracke
            inputEvents.add(
              SketchPointerEvent(
                pointer: event.pointer,
                buttons: event.buttons,
                position: event.localPosition,
                timeStamp: DateTime.now(),
              ),
            );

            // Starts the Long press timer
            startPotentialLongPress(context, event.localPosition);

            // checks for double taps.
            final timeDif = timeOfLastDown.difference(DateTime.now()).abs();
            if (timeDif < Duration(milliseconds: 200) &&
                inputEvents.length == 1) {
              onDoubleTap(context);
            }

            final transformedPoint = context
                .read<TransformController>()
                .inversePoint(event.localPosition);

            switch (event.buttons) {
              case kPrimaryButton:
                {
                  switch (inputEvents.length) {
                    case 1:
                      {
                        if (isShiftPressed || tool == Tool.mouse) {
                          startPanning(event.localPosition);
                          context.read<DrawingContext>().selectElement(
                            transformedPoint,
                          );
                        } else if (canDraw && tool == Tool.brush) {
                          startDrawing();
                          context.read<DrawingContext>().addPoint(
                            transformedPoint,
                          );
                        } else if (tool == Tool.text) {
                          context.read<DrawingContext>().insertText(
                            transformedPoint,
                            "MEGA"
                          );
                        }
                      }
                    // Two fingers down starts the scaling function:
                    case 2:
                      {
                        if (inputEvents.length == 2 &&
                            event.buttons == kTouchContact) {
                          isScaling = true;
                          final point1 = inputEvents[0].position;
                          final point2 = inputEvents[1].position;
                          scaleStartDistance = (point1 - point2).distance;
                          scaleStartMidpoint = Offset(
                            (point1.dx + point2.dx) / 2,
                            (point1.dy + point2.dy) / 2,
                          );
                          scaleStartMatrix =
                              context.read<TransformController>().value;

                          cancelDrawing();
                          startScaling(event.localPosition);
                          lastScaleFactor = 1.0;
                        }
                      }
                  }
                  break;
                }
              case kSecondaryButton:
                {
                  contextMenuController.setPosition(event.localPosition);
                  contextMenuController.show();
                }
              case kTertiaryButton:
                {
                  startPanning(event.localPosition);
                  break;
                }
            }

            timeOfLastDown = DateTime.now();
          },
          onPointerUp: (event) {
            potentialLongPress = false;

            inputEvents.removeWhere((ev) => ev.pointer == event.pointer);

            if (isDrawing) {
              endDrawing();
            }
            if (isPanning) {
              endPanning();
            }
            if (inputEvents.length < 2 && isScaling) {
              endScaling();
            }
            canDraw = true;
          },
          onPointerMove: (event) {
            if ((inputEvents.first.position - event.localPosition).distance >
                10) {
              potentialLongPress = false;
            }
            context.read<DrawingContext>().unselectAll();

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

            if (event.buttons == kPrimaryButton && inputEvents.length == 1 ||
                event.buttons == kTertiaryButton) {
              if (isPanning) {
                final delta = event.localPosition - panStart;
                final controller = context.read<TransformController>();
                final matrix =
                    Matrix4.identity()
                      ..translate(delta.dx, delta.dy)
                      ..multiply(controller.value);
                controller.value = matrix;
                panStart = event.localPosition;
              } else if (isDrawing) {
                if (!canDraw) {
                  isDrawing = false;
                  context.read<DrawingContext>().cancelDrawing();
                } else {
                  potentialLongPress = false;
                  final transformedPoint = context
                      .read<TransformController>()
                      .inversePoint(event.localPosition);
                  context.read<DrawingContext>().addPoint(transformedPoint);
                }
              }
            }

            if (inputEvents.length == 2 && isScaling) {
              final point1 = inputEvents[0].position;
              final point2 = inputEvents[1].position;

              final currentDistance = (point1 - point2).distance;
              final currentMidpoint = Offset(
                (point1.dx + point2.dx) / 2,
                (point1.dy + point2.dy) / 2,
              );

              final scale = currentDistance / scaleStartDistance;

              final controller = context.read<TransformController>();
              final matrix =
                  Matrix4.identity()
                    ..translate(currentMidpoint.dx, currentMidpoint.dy)
                    ..scale(scale)
                    ..translate(-scaleStartMidpoint.dx, -scaleStartMidpoint.dy)
                    ..multiply(scaleStartMatrix);

              controller.value = matrix;
            }
          },
          onPointerSignal: (PointerSignalEvent event) {
            if (event is PointerScrollEvent) {
              _handleScroll(event, context);
            }
          },
          child: SketchContextMenu(
            contextMenuController,
            Stack(
              fit: StackFit.expand,
              children: [
                ValueListenableBuilder<Matrix4>(
                  valueListenable: context.read<TransformController>(),
                  builder: (context, matrix, child) {
                    return Transform(transform: matrix, child: widget.child);
                  },
                ),
              ],
          )),
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
