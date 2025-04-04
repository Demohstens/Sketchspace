
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/tools/tools.dart';

class EraserToolButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: IconButton(
        icon: FaIcon(FontAwesomeIcons.eraser),
        onPressed: () {
          context.read<DrawingContext>().setTool(Tool.strokeEraser);
        },
      ),
    );
  }
}