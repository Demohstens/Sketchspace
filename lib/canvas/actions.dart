import 'package:flutter/material.dart';
import 'package:sketchspace/providers/drawing_context.dart';

class RedoIntent extends Intent {
  const RedoIntent();
}

class UndoIntent extends Intent {
  const UndoIntent();
}

class ResetIntent extends Intent {
  const ResetIntent();
}

// Action definitions

class RedoAction extends Action<RedoIntent> {
  final DrawingContext context;

  RedoAction(this.context);

  @override
  void invoke(covariant RedoIntent intent) {
    context.redo();
  }
}

class UndoAction extends Action<UndoIntent> {
  final DrawingContext context;

  UndoAction(this.context);

  @override
  void invoke(covariant UndoIntent intent) {
    context.undo();
  }
}

class ResetAction extends Action<ResetIntent> {
  final DrawingContext context;

  ResetAction(this.context);

  @override
  void invoke(covariant ResetIntent intent) {
    context.resetDrawing();
  }
}