import 'dart:ui';

import 'package:sketchspace/classes/drawing_context.dart';
import 'package:flutter/material.dart';

class CurrentPathPen extends CustomPainter {
  List<Offset> currentPath;
  Paint strokePaint;
  Mode mode;
  Matrix4 transformMatrix;
  CurrentPathPen(
      this.currentPath, this.strokePaint, this.mode, this.transformMatrix);

  @override
  void paint(Canvas canvas, Size size) {
    void drawLine() {
      if (currentPath.length < 2) return;

      canvas.drawLine(currentPath.first, currentPath.last, strokePaint);
    }

    Matrix4 inverseMatrix =
        Matrix4.tryInvert(transformMatrix) ?? Matrix4.identity();

    // void drawPath(Canvas canvas) {
    //   if (currentPath.isNotEmpty) {
    //     Paint paint = strokePaint;

    //     if (currentPath.length == 1) {
    //       // Draw a single point
    //       canvas.drawPoints(PointMode.points, currentPath, paint);
    //       return;
    //     }

    //     Path pathToDraw = Path();
    //     Vector3 transformedPoint = Vector3.zero();

    //     // Transform the first point
    //     // Vector3 localPoint =
    //     //     Vector3(currentPath.first.dx, currentPath.first.dy, 0.0);
    //     // inverseMatrix.transform3(transformedPoint);
    //     // pathToDraw.moveTo(transformedPoint.x, transformedPoint.y);

    //     // Transform and draw the rest of the points
    //     // for (int i = 1; i < currentPath.length; i++) {
    //     //   localPoint.setValues(currentPath[i].dx, currentPath[i].dy, 0.0);
    //     //   inverseMatrix.transform3(transformedPoint);
    //     //   pathToDraw.lineTo(transformedPoint.x, transformedPoint.y);
    //     // }

    //     // Draw the transformed path
    //     canvas.drawPath(pathToDraw, paint);
    //   }

    void drawPath() {
      if (currentPath.isNotEmpty) {
        if (currentPath.length == 1) {
          canvas.drawPoints(PointMode.points, currentPath, strokePaint);
          return;
        }
        Paint paint = strokePaint;
        Path currentPathToDraw = Path();
        currentPathToDraw.moveTo(currentPath.first.dx, currentPath.first.dy);
        for (int i = 1; i < currentPath.length; i++) {
          currentPathToDraw.lineTo(currentPath[i].dx, currentPath[i].dy);
        }
        canvas.drawPath(currentPathToDraw, paint);
      }

      switch (mode) {
        case Mode.drawing:
          drawPath();
        case Mode.erasing:
          drawPath();
        case Mode.line:
          drawLine();
        case Mode.fill:
          drawPath();
        case Mode.lifted:
          break;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
