import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/tools/tools.dart';

class BrushToolButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: IconButton(
        icon: Icon(Icons.brush),
        onPressed: () {
          context.read<DrawingContext>().setTool(Tool.brush);
        },
      ),
    );
  }
}