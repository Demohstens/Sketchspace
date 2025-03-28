import 'dart:math' as math; // For min/max
import 'package:flutter/gestures.dart'; // For HitTestBehavior
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/canvas/drawing_context.dart';
import 'package:sketchspace/canvas/zoom-widget-drawing/lib/zoom_widget.dart' as zoom;
import 'package:sketchspace/components/brush_menu.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3, Matrix4;

// The main overlay widget
class CanvasOverlay extends StatelessWidget { // Renamed for consistency
  final zoom.TransformationController controller; // Controller from Zoom widget

  const CanvasOverlay({super.key, required this.controller});

  // Helper function to transform a single point from canvas to screen space
  Offset _transformPoint(Matrix4 matrix, Offset canvasPoint) {
    final Vector3 transformed = matrix.transform3(Vector3(
      canvasPoint.dx,
      canvasPoint.dy,
      0,
    ));
    return Offset(transformed.x, transformed.y);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Matrix4>(
      valueListenable: controller,
      builder: (context, matrix, child) {
        final selectedStrokeId = context.watch<DrawingContext>().selectedStrokeId;
        // Use read here if the overlay rebuilds primarily on matrix/selection ID change
        final selectedStroke = context.read<DrawingContext>().canvas.getStrokeById(selectedStrokeId);

        if (selectedStroke == null) {
          return const SizedBox.shrink();
        }

        final Rect canvasBounds = selectedStroke.boundary;

        // Transform corners to SCREEN coordinates
        final Offset screenP1 = _transformPoint(matrix, canvasBounds.topLeft);
        final Offset screenP2 = _transformPoint(matrix, canvasBounds.topRight);
        final Offset screenP3 = _transformPoint(matrix, canvasBounds.bottomRight);
        final Offset screenP4 = _transformPoint(matrix, canvasBounds.bottomLeft);

        // --- Calculate SCREEN Bounding Box for positioning the drag detector ---
        final double minX = math.min(screenP1.dx, math.min(screenP2.dx, math.min(screenP3.dx, screenP4.dx)));
        final double minY = math.min(screenP1.dy, math.min(screenP2.dy, math.min(screenP3.dy, screenP4.dy)));
        final double maxX = math.max(screenP1.dx, math.max(screenP2.dx, math.max(screenP3.dx, screenP4.dx)));
        final double maxY = math.max(screenP1.dy, math.max(screenP2.dy, math.max(screenP3.dy, screenP4.dy)));
        final double screenWidth = maxX - minX;
        final double screenHeight = maxY - minY;

        // --- Calculate coordinates relative to the screen bounding box for painters ---
        // This makes painters draw correctly within their positioned container
        final Offset relativeP1 = screenP1 - Offset(minX, minY);
        final Offset relativeP2 = screenP2 - Offset(minX, minY);
        final Offset relativeP3 = screenP3 - Offset(minX, minY);
        final Offset relativeP4 = screenP4 - Offset(minX, minY);

        // --- Calculate Top Center for Delete Button (using absolute screen coords) ---
        final Offset screenTopCenter = (screenP1 + screenP2) / 2.0;
        const double buttonSize = 50.0;
        const double buttonPadding = 5.0;

        return Stack( // Use Stack for layering all overlay elements
          children: [
            // --- Layer 1: Draggable Area (Positioned) ---
            Positioned(
              left: minX,
              top: minY,
              width: screenWidth,
              height: screenHeight,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent, // Allow taps outside path to pass through
                onPanStart: (details) {
                  // Optional: Record start details if needed
                },
                onPanUpdate: (details) {
                  final Offset screenDelta = details.delta;
                  final double currentScale = matrix.getMaxScaleOnAxis();
                  if (currentScale == 0) return;
                  final Offset canvasDelta = screenDelta / currentScale;
                  selectedStroke.translate(canvasDelta);
                  context.read<DrawingContext>().repaint(); // Trigger visual update
                },
                onPanEnd: (details) {
                  context.read<DrawingContext>().canvas.updateStroke(selectedStroke); // Persist
                  context.read<DrawingContext>().repaint();
                  // context.read<DrawingContext>().repaint(); // May not be needed if updateStroke notifies
                },
                // Optional but recommended: Use CustomPaint for accurate hit-testing area
                child: CustomPaint(
                  size: Size(screenWidth, screenHeight),
                  painter: HitTestPainter( // Draws a transparent fill for hit-testing
                    p1: relativeP1,
                    p2: relativeP2,
                    p3: relativeP3,
                    p4: relativeP4,
                  ),
                ),
              ),
            ),

            // --- Layer 2: Boundary Outline (Positioned - same as drag area) ---
            // Drawn separately so it's always visible, even if drag area is transparent
            Positioned(
              left: minX,
              top: minY,
              width: screenWidth,
              height: screenHeight,
              child: IgnorePointer( // Outline doesn't need to be interactive itself
                child: CustomPaint(
                  size: Size(screenWidth, screenHeight),
                  painter: BoundaryPainter( // Draws the visible red line
                    p1: relativeP1,
                    p2: relativeP2,
                    p3: relativeP3,
                    p4: relativeP4,
                  ),
                ),
              ),
            ),

            // --- Layer 3: Delete Button (Positioned absolutely on screen) ---
            Positioned(
              left: screenTopCenter.dx - (buttonSize / 2),
              top: screenP1.dy - buttonSize - buttonPadding, // Use absolute screen Y
              child: Row(children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: buttonSize * 0.7,
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                          context.read<DrawingContext>().deleteStroke(selectedStroke);
                          context.read<DrawingContext>().repaint();
                      }
                    ),
                    ColorSelector((c) {
                      selectedStroke.paint.color = c;
                      context.read<DrawingContext>().repaint();
                    })
                ],)
                ),
            // --- Add other handles (resize, rotate) as Positioned widgets here ---
          ],
        );
      },
    );
  }
}

// Painter for the visible boundary outline
class BoundaryPainter extends CustomPainter {
  final Offset p1, p2, p3, p4; // Relative coordinates

  BoundaryPainter({required this.p1, required this.p2, required this.p3, required this.p4});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..lineTo(p4.dx, p4.dy)..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BoundaryPainter oldDelegate) {
    return oldDelegate.p1 != p1 || oldDelegate.p2 != p2 || oldDelegate.p3 != p3 || oldDelegate.p4 != p4;
  }
}

// Painter for the hit-test area (transparent fill)
class HitTestPainter extends CustomPainter {
    final Offset p1, p2, p3, p4; // Relative coordinates

  HitTestPainter({required this.p1, required this.p2, required this.p3, required this.p4});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent // Invisible fill for hit-testing
      // Or use a very faint color for debugging: Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..lineTo(p4.dx, p4.dy)..close();
    canvas.drawPath(path, paint);
  }

   @override
  bool shouldRepaint(covariant HitTestPainter oldDelegate) {
     // Only repaint if the shape changes
    return oldDelegate.p1 != p1 || oldDelegate.p2 != p2 || oldDelegate.p3 != p3 || oldDelegate.p4 != p4;
  }
}
