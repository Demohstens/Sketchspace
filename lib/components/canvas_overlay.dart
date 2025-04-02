import 'dart:math' as math; // For min/max
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Matrix4>(
      valueListenable: context.read<TransformController>(),
      builder: (context, matrix, child) {
        final selectedElementId = context.watch<DrawingContext>().selectedElementId;
        final selectedElement = context.read<DrawingContext>().canvas.getElementById(selectedElementId);

        if (selectedElement == null) {
          return const SizedBox.shrink();
        }

        final screenBounds = context.read<TransformController>().transformRect(selectedElement.boundary);
        List<Offset> screenPoints = [
          screenBounds.topLeft,
          screenBounds.topRight,
          screenBounds.bottomRight,
          screenBounds.bottomLeft,
        ];

        final screenTopCenter = (screenPoints[0] + screenPoints[1]) / 2.0;
        const double buttonSize = 50.0;
        const double buttonPadding = 5.0;
        

        return Stack(
          children: [
            // Draggable Area
            Positioned.fromRect(
              rect: screenBounds,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  // Convert the global position to canvas coordinates
                  final globalPosition = details.globalPosition;
                  final localPosition = context.read<TransformController>().inversePoint(globalPosition);

                  // Calculate the delta relative to the element's current position
                  final delta = localPosition - selectedElement.boundary.center;

                  // Translate the selected element by the delta
                  selectedElement.translate(delta);

                  // Repaint the canvas
                  context.read<DrawingContext>().repaint();
                },
                onPanEnd: (details) {
                  context.read<DrawingContext>().canvas.updateElement(selectedElement);
                  context.read<DrawingContext>().repaint();
                },
                onLongPress: () => context.read<DrawingContext>().unSelectStroke(),
                child: CustomPaint(
                  size: screenBounds.size,
                  painter: HitTestPainter(
                    points: screenPoints.map((p) => p - screenBounds.topLeft).toList(),
                  ),
                ),
              ),
            ),

            // Corner Handles
            for (var i = 0; i < 4; i++)
              DragHandle(
                position: Position.values[i],
                origin: screenPoints[i],
                opposite: screenPoints[(i + 2) % 4],
                element: selectedElement,
                controller:  context.read<TransformController>(),
              ),

            // Controls
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
                      context.read<DrawingContext>().deleteElement(selectedElement);
                      context.read<DrawingContext>().repaint();
                    }
                  ),
                  if (selectedElement is Stroke) 
                    SketchColorPicker(
                      onColorChanged: (c) {
                        selectedElement.color = c;
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


enum Position {
  topLeft,
  topRight,
  bottomRight,
  bottomLeft,
}

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
class HitTestPainter extends CustomPainter {
  final List<Offset> points;

  HitTestPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(91, 74, 74, 74)
      ..style = PaintingStyle.fill;
      
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HitTestPainter oldDelegate) {
    return !List.generate(4, (i) => points[i] == oldDelegate.points[i]).contains(false);
  }
}