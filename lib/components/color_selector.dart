import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';

class SketchColorPicker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SketchColorPickerState();

}

class _SketchColorPickerState extends State<SketchColorPicker> {
  final MenuController _menuController = MenuController();
  @override
  Widget build(BuildContext context) {
    return  Material(
      child: 
    Container(
      padding: EdgeInsets.all(8),
      child: MenuAnchor(
        controller: _menuController,
        menuChildren: [ 
          ColorPicker(
            pickerColor: context.read<DrawingContext>().color,
            onColorChanged: (color) {
              context.read<DrawingContext>().changeColor(color);
            },
          )
        ],
        child: Container(
          // height: 30,
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: context.read<Settings>().background,
            ),
          child: Row(
            spacing: 4,
            children: [
            if (context.read<DrawingContext>().colorHistory.isEmpty) 
            CircleAvatar(
              backgroundColor: context.read<DrawingContext>().color,
              radius: 12,
              child: InkWell(
              onLongPress: () {
                _menuController.open();
              },)),
            ...context.read<DrawingContext>().colorHistory.map((e) =>
            CircleAvatar(
            radius: 15,
            backgroundColor: e,
            child: InkWell(
              onTap: () => context.read<DrawingContext>().changeColor(e),
              onLongPress: () => _menuController.open(),
              onSecondaryTap: () => _menuController.open(),
            ),
          ))
      ])          
    ))));
  }
}