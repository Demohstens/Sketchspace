
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';

class WidthSelector extends StatelessWidget {
  final MenuController _menuController = MenuController();
  @override
  Widget build(BuildContext context) {
    double width = context.watch<DrawingContext>().strokeWidth;
    return MenuAnchor(
      controller: _menuController,
      menuChildren: <Widget>[
        Slider(
          value: context.watch<DrawingContext>().strokeWidth,
          min: 1,
          max: 50,
          divisions: 49,
          label: 'Stroke Width: ${context.read<DrawingContext>().strokeWidth}',
          onChanged: (double value) {
            context.read<DrawingContext>().changeWidth(value);
          },
        ),
      ],
      child: IconButton(
        onPressed: () {
          _menuController.open();
        },
        icon :Icon(
            Icons.circle,
            size: width,
            color: context.watch<Settings>().secondaryColor,
          ),
        ),
      
    );
  }
}
