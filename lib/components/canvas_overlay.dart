import 'dart:math' as math; // For min/max
import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/classes/elements/stroke_element.dart';
import 'package:sketchspace/classes/transformation_controller.dart';
import 'package:sketchspace/components/color_selector.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/classes/element.dart';
import 'package:vector_math/vector_math_64.dart' as math;

class CanvasOverlay extends StatefulWidget {
  const CanvasOverlay({super.key});

  @override
  State<CanvasOverlay> createState() => _CanvasOverlayState();
}

class _CanvasOverlayState extends State<CanvasOverlay> {
  Rect oldRect = Rect.zero; // Rect before scaling started
  Offset pivot = Offset.zero; // Pivot point for scaling

  @override
  Widget build(BuildContext context) {
    final transformController = context.read<TransformController>();
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

              onResizeStart: (handle, details) {
                // flutter_box_transform >= 0.6.0 uses ResizeResult
                selectedElements.first.startScaling(handle);
              },
              onResizeUpdate: (result, event) {
                // 1. Get Initial State (from the element itself)
                Rect initialCanvasBounds =
                    selectedElements.first.initialBoundsOnScaleStart;
                HandlePosition? handle = result.handle;

                // Basic check for valid initial bounds
                if (initialCanvasBounds.width <= 1e-9 ||
                    initialCanvasBounds.height <= 1e-9) {
                  return; // Cannot scale from zero size
                }

                // 2. Determine Target Canvas Bounds
                // Transform the *new* screen rectangle corners back to canvas coordinates
                Rect newScreenRect = result.rect;
                Offset targetTopLeft = transformController.inversePoint(
                  newScreenRect.topLeft,
                );
                Offset targetBottomLeft = transformController.inversePoint(
                  newScreenRect.bottomLeft,
                );
                Offset targetTopRight = transformController.inversePoint(
                  newScreenRect.topRight,
                );
                Offset targetBottomRight = transformController.inversePoint(
                  newScreenRect.bottomRight,
                );

                // Reconstruct the target bounds in canvas space (assumes no rotation/skew)
                double minX = math.min(targetTopLeft.dx, targetBottomLeft.dx);
                double maxX = math.max(targetTopRight.dx, targetBottomRight.dx);
                double minY = math.min(targetTopLeft.dy, targetTopRight.dy);
                double maxY = math.max(
                  targetBottomLeft.dy,
                  targetBottomRight.dy,
                );
                // Ensure non-zero dimensions for calculation
                double targetWidth = math.max(1e-9, maxX - minX);
                double targetHeight = math.max(1e-9, maxY - minY);
                Rect targetCanvasBounds = Rect.fromLTWH(
                  minX,
                  minY,
                  targetWidth,
                  targetHeight,
                );

                // 3. Calculate Scale Factors
                double scaleFactorX =
                    targetCanvasBounds.width / initialCanvasBounds.width;
                double scaleFactorY =
                    targetCanvasBounds.height / initialCanvasBounds.height;

                // 4. Determine Pivot Point (in CANVAS coordinates) based on handle
                Offset pivot;
                switch (handle) {
                  case HandlePosition.topLeft:
                    pivot = initialCanvasBounds.bottomRight;
                    break;
                  case HandlePosition.topRight:
                    pivot = initialCanvasBounds.bottomLeft;
                    break;
                  case HandlePosition.bottomLeft:
                    pivot = initialCanvasBounds.topRight;
                    break;
                  case HandlePosition.bottomRight:
                    pivot = initialCanvasBounds.topLeft;
                    break;
                  // Add cases for middle handles if needed (adjust scale factors too)
                  case HandlePosition.top:
                    pivot = initialCanvasBounds.bottomCenter;
                    scaleFactorX = 1.0; // Only scale Y
                    break;
                  case HandlePosition.bottom:
                    pivot = initialCanvasBounds.topCenter;
                    scaleFactorX = 1.0; // Only scale Y
                    break;
                  case HandlePosition.left:
                    pivot = initialCanvasBounds.centerRight;
                    scaleFactorY = 1.0; // Only scale X
                    break;
                  case HandlePosition.right:
                    pivot = initialCanvasBounds.centerLeft;
                    scaleFactorY = 1.0; // Only scale X
                    break;
                  default: // Should not happen during resize
                    print("  Warning: Unexpected handle position: $handle");
                    pivot = initialCanvasBounds.center;
                    scaleFactorX = 1.0;
                    scaleFactorY = 1.0;
                    break;
                }

                // 5. Apply the scaling to the element
                selectedElements.first.scale(
                  math.Vector2(scaleFactorX, scaleFactorY),
                  pivot,
                );

                context.read<DrawingContext>().repaint();
              },

              // 6. Repaint the main canvas
              onResizeEnd: (handle, details) {
                selectedElements.first.endScaling();
                // Repaint needed to potentially hide handles or finalize appearance
                context.read<DrawingContext>().repaint();
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
            // Controls
            Positioned(
              left: screenTopCenter.dx - 2 * buttonSize,
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

  void getPivot(
    DragStartDetails details,
    SketchElement element,
    HandlePosition draggedHandleType,
  ) {
    oldRect = element.boundary; // Store the initial rect before resizing

    switch (draggedHandleType) {
      case HandlePosition.topLeft:
        pivot = oldRect.bottomRight;
        break;
      case HandlePosition.topRight:
        pivot = oldRect.bottomLeft;
        break;
      case HandlePosition.bottomLeft:
        pivot = oldRect.topRight;
        break;
      case HandlePosition.bottomRight:
        pivot = oldRect.topLeft;
        break;
      default:
        pivot = oldRect.center; // Fallback to center if no handle is dragged
    }
  }
}

math.Vector2 calculateSizeChange(
  HandlePosition draggedHandleType,
  Offset delta,
  Rect initialBounds,
) {
  math.Vector2 totalHandleDelta = math.Vector2(delta.dx, delta.dy); // Or global

  math.Vector2 totalSizeChange;

  // --- Determine Pivot and Adjust Delta ---
  switch (draggedHandleType) {
    case HandlePosition.topLeft:
      // Dragging left (negative dx) increases width
      // Dragging up (negative dy) increases height
      totalSizeChange = math.Vector2(-totalHandleDelta.x, -totalHandleDelta.y);
      break;
    case HandlePosition.topRight:
      // Dragging right (positive dx) increases width
      // Dragging up (negative dy) increases height
      totalSizeChange = math.Vector2(totalHandleDelta.x, -totalHandleDelta.y);
      break;
    case HandlePosition.bottomLeft:
      // Dragging left (negative dx) increases width
      // Dragging down (positive dy) increases height
      totalSizeChange = math.Vector2(-totalHandleDelta.x, totalHandleDelta.y);
      break;
    case HandlePosition.bottomRight:

      // Dragging right (positive dx) increases width
      // Dragging down (positive dy) increases height
      totalSizeChange = math.Vector2(totalHandleDelta.x, totalHandleDelta.y);
      break;
    default:
      totalSizeChange =
          math.Vector2.zero(); // No size change if no handle is dragged
      break;
  }
  return totalSizeChange;
}
