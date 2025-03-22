import 'package:flutter/services.dart';
import 'package:sketchspace/actions/menu_actions.dart';
import 'package:sketchspace/canvas/actions.dart';
import 'package:sketchspace/canvas/canvas_viewport.dart';
import 'package:sketchspace/canvas/canvas_context.dart';
import 'package:sketchspace/canvas/canvasUI.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CanvasPage extends StatelessWidget {
  final _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    final drawingContext = context.read<DrawingContext>();

    // context.read<Worldspace>().loadFile([]);
    return Shortcuts(
      shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ): UndoIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyY): RedoIntent(),
          LogicalKeySet(LogicalKeyboardKey.escape): OpenMenuIntent(context),
          },
        child: Actions(
          actions: {
            RedoIntent: RedoAction(context.read<DrawingContext>()),
            UndoIntent: UndoAction(context.read<DrawingContext>()),
            OpenMenuIntent: OpenMenuAction(),
            ResetIntent: ResetAction(context.read<DrawingContext>()),
          },
            child: GestureDetector(child:  Focus(
            autofocus: true,
            focusNode: _focusNode,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CanvasViewport(),
                ),
                Visibility(
                  visible: context.watch<DrawingContext>().ui_enabled,
                  child: CanvasUI(),
                ),
              ],
            )))));
  }
}
