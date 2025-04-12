import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';

class SketchColorPicker extends StatefulWidget {
  final Function(Color) onColorChanged;
  final Color? initColor;
  const SketchColorPicker({
    required this.onColorChanged,
    this.initColor,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _SketchColorPickerState();
}

class _SketchColorPickerState extends State<SketchColorPicker> {
  final MenuController _menuController = MenuController();
  Color? selectedColor;
  @override
  void initState() {
    selectedColor = widget.initColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.read<Settings>().background,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(4),
        child: MenuAnchor(
          controller: _menuController,
          menuChildren: [
            ColorPicker(
              paletteType: PaletteType.hsv,
              pickerColor:
                  selectedColor ?? context.watch<DrawingContext>().color,
              onColorChanged: (color) {
                widget.onColorChanged(color);
                setState(() {
                  selectedColor = color;
                });
              },
            ),
          ],
          child: Container(
            // height: 30,
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: context.watch<Settings>().background,
            ),
            child: Row(
              spacing: 4,
              children: [
                if (context.watch<DrawingContext>().colorHistory.isEmpty)
                  CircleAvatar(
                    backgroundColor: context.watch<DrawingContext>().color,
                    radius: 12,
                    child: InkWell(
                      onLongPress: () {
                        _menuController.open();
                      },
                    ),
                  ),
                ...context.watch<DrawingContext>().colorHistory.map(
                  (e) => CircleAvatar(
                    radius: 15,
                    backgroundColor: e,
                    child: InkWell(
                      splashColor: e,
                      onTap: () {
                        widget.onColorChanged(e);
                        setState(() {
                          selectedColor = e;
                        });
                      },
                      onLongPress: () => _menuController.open(),
                      onSecondaryTap: () => _menuController.open(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
