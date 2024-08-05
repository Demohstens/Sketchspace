import 'package:flutter/material.dart';

class Pen extends CustomPainter {
  List<Stroke>? _strokes;
  Stroke? _stroke;
  Color _color = Colors.blue;

  Pen({
    required DrawingState state,
  }) {
    if (state.isDrawing()) {
      _color = state._inputPoints!.color;
      _stroke = state._inputPoints;
      _strokes = state._inputBuffer;
    } else if (state.liftedPen()) {
      _color = state._inputBuffer!.last.color;
      _strokes = state._inputBuffer;
      _stroke = null;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_strokes != null) {
      for (Stroke stroke in _strokes!) {
        Paint paint = Paint()
          ..color = stroke.color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 5.0;
        for (int i = 0; i < stroke.points.length - 1; i++) {
          canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
        }
      }
      if (_stroke != null) {
        Paint paint = Paint()
          ..color = _color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 5.0;
        for (int i = 0; i < _stroke!.points.length - 1; i++) {
          canvas.drawLine(_stroke!.points[i], _stroke!.points[i + 1], paint);
        }
      }
    }
    // Paint paint = Paint()
    //   ..color = _color
    //   ..strokeCap = StrokeCap.round
    //   ..strokeWidth = 5.0;
    // List<Offset?> pointsToDraw = [];
    // if (_strokes != null) {
    //   for (Stroke stroke in _strokes!) {
    //     pointsToDraw.addAll(stroke.points);
    //     pointsToDraw.add(null);
    //   }
    //   if (_stroke != null) {
    //     pointsToDraw.addAll(_stroke!);
    //   }
    // } else if (_stroke != null) {
    //   pointsToDraw.addAll(_stroke!);
    // } else {
    //   print("No points to draw");
    // }
    // for (int i = 0; i < pointsToDraw.length - 1; i++) {
    //   if (pointsToDraw[i] != null && pointsToDraw[i + 1] != null) {
    //     canvas.drawLine(pointsToDraw[i]!, pointsToDraw[i + 1]!, Paint()..color = );
    //   }
    // }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

class DrawingState {
  List<Stroke>? _inputBuffer;
  Stroke? _inputPoints;

  DrawingState(List<Stroke>? inputBuffer, Stroke? inputPoints) {
    _inputBuffer = inputBuffer;
    _inputPoints = inputPoints;
  }

  bool isDrawing() {
    return _inputPoints != null;
  }

  bool liftedPen() {
    return _inputBuffer != null;
  }
}

class Stroke {
  Color color;
  List<Offset> points;
  Stroke(this.color, this.points);
}
