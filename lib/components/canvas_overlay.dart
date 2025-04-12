import 'dart:math' as math; // For min/max
import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/classes/elements/stroke_element.dart';
import 'package:sketchspace/classes/transformation_controller.dart';
import 'package:sketchspace/components/color_selector.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/classes/element.dart';
import 'package:sketchspace/providers/sketch_canvas.dart';
import 'package:vector_math/vector_math_64.dart' as math;

class CanvasOverlay extends StatefulWidget {
  const CanvasOverlay({super.key});

  @override
  State<CanvasOverlay> createState() => _CanvasOverlayState();
}

class _CanvasOverlayState extends State<CanvasOverlay> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Matrix4>(
      valueListenable: context.read<TransformController>(),
      builder: (context, matrix, child) {
        Set<String> selectedIds =
            context.watch<DrawingContext>().selectedElementIds;
        final selectedElements = context
            .read<DrawingContext>()
            .canvas
            .getElementsByIds(selectedIds);

        if (selectedElements.isEmpty) {
          return const SizedBox.shrink();
        }
        Rect combinedBounds = selectedElements
            .map((e) => e.boundary)
            .reduce((a, b) => a.expandToInclude(b));
        final screenBounds = context.read<TransformController>().transformRect(
          combinedBounds,
        );
        List<Offset> screenPoints = [
          screenBounds.topLeft,
          screenBounds.topRight,
          screenBounds.bottomRight,
          screenBounds.bottomLeft,
        ];

        final screenTopCenter = (screenPoints[0] + screenPoints[1]) / 2.0;
        const double buttonSize = 50.0;
        const double buttonPadding = 5.0;

        Offset dragStartPosition = Offset.zero;

        return Stack(
          children: [
            TransformableBox(
              resizable: true, //TODO reimplement scaling.
              rect: screenBounds,
              onResizeUpdate: (result, event) {
                final transformedPosition = context
                    .read<TransformController>()
                    .inversePoint(result.delta);
                
                for (SketchElement element in selectedElements) {
                  // Apply the scaling matrix to the element
                  element.scale(math.Vector2(transformedPosition.dx, transformedPosition.dy));
                }

                // Repaint the canvas
                context.read<DrawingContext>().repaint();
              },
              onDragStart: (event) {
                dragStartPosition = event.globalPosition;
              },
              onDragUpdate: (result, event) {
                //  Convert the global position to canvas coordinates
                final globalPosition = event.globalPosition;
                final transformedPos = context
                    .read<TransformController>()
                    .inversePoint(globalPosition);

                // Calculate the delta relative to the element's current position
                final delta =
                    transformedPos - selectedElements.first.boundary.center;

                // Translate the selected element by the delta
                for (var element in selectedElements) {
                  element.translate(delta);
                }

                // Repaint the canvas
                context.read<DrawingContext>().repaint();
              },
              contentBuilder: (context, rect, flip) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(20),
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              },
            ),
            // // Controls
            Positioned(
              left: screenTopCenter.dx - (buttonSize / 2),
              top: screenPoints[0].dy - buttonSize - buttonPadding,
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: buttonSize * 0.7,
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      context.read<DrawingContext>().canvas.removeElements(
                        selectedElements,
                      );
                      context.read<DrawingContext>().unselectAll();
                      context.read<DrawingContext>().repaint();
                    },
                  ),
                  if (true)
                    SketchColorPicker(
                      onColorChanged: (c) {
                        for (var el in selectedElements) {
                          (el as Stroke).color = c;
                        }
                        context.read<DrawingContext>().repaint();
                      },
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

enum Position { topLeft, topRight, bottomRight, bottomLeft }

class DragHandle extends StatefulWidget {
  final Position position;
  final Offset origin;
  final Offset opposite;
  final double size;
  final SketchElement element;
  final TransformController controller;

  const DragHandle({
    required this.position,
    required this.origin,
    required this.opposite,
    required this.element,
    required this.controller,
    this.size = 20,
    Key? key,
  }) : super(key: key);

  @override
  State<DragHandle> createState() => _DragHandleState();
}

class _DragHandleState extends State<DragHandle> {
  @override
  Widget build(BuildContext context) {
    final rotationAngle = (widget.position.index * 90 - 45) * (math.pi / 180);

    return Positioned(
      left: widget.origin.dx - (widget.size / 2),
      top: widget.origin.dy - (widget.size / 2),
      child: GestureDetector(
        onPanUpdate: (details) {
          final globalPosition = details.globalPosition;
          final localPosition = widget.controller.inversePoint(globalPosition);

          // Calculate the vector from opposite corner to current position
          final currentVector = localPosition - widget.opposite;
          final originalVector = widget.origin - widget.opposite;

          // Calculate scaling factors maintaining aspect ratio
          double scaleX = currentVector.dx / originalVector.dx;
          double scaleY = currentVector.dy / originalVector.dy;

          // Ensure minimum scale
          scaleX = scaleX.sign * math.max(0.1, scaleX.abs());
          scaleY = scaleY.sign * math.max(0.1, scaleY.abs());

          // Apply the scaling matrix to the element
          widget.element.scale(math.Vector2(scaleX, scaleY));

          // Repaint the canvas
          context.read<DrawingContext>().repaint();
        },
        child: Container(
          width: widget.size + 10,
          height: widget.size + 10,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey, width: 1.5),
            borderRadius: BorderRadius.circular((widget.size + 10) / 2),
          ),
          child: Transform.rotate(
            angle: rotationAngle,
            child: Icon(
              Icons.drag_indicator,
              size: widget.size + 5,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
