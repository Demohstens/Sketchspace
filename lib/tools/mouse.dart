import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/tools/tools.dart';

class MouseToolButton extends StatelessWidget {

  const MouseToolButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: FaIcon(FontAwesomeIcons.arrowPointer),
      onPressed: () {
        // Handle mouse tool button click
        context.read<DrawingContext>().setTool(Tool.mouse);
      },
    );
  }
}