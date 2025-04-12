import 'package:sketchspace/components/add_imported.dart';
import 'package:sketchspace/components/color_selector.dart';
import 'package:sketchspace/components/width_menu.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/tools/brush.dart';
import 'package:sketchspace/tools/mouse.dart';

// possible to use menu anchor instead?
// https://api.flutter.dev/flutter/material/PopupMenuButton-class.html

enum MenuEntry { width }

class BrushMenu extends StatelessWidget {
  final MenuController _menuController = MenuController();
  @override
  Widget build(BuildContext context) {
    Color secondary = context.watch<Settings>().secondaryColor;
    return Material(
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: context.watch<Settings>().background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: secondary),
        ),
        child: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AddImported(),
            MouseToolButton(),
            BrushToolButton(),
            SketchColorPicker(
              onColorChanged: (c) {
                context.read<DrawingContext>().changeColor(c);
              },
            ),
            MenuAnchor(
              controller: _menuController,
              menuChildren: <Widget>[WidthSelector()],
              child: GestureDetector(
                behavior:
                    HitTestBehavior
                        .opaque, // Ensures the entire area is clickable
                onTap: () {
                  switch (_menuController.isOpen) {
                    case true:
                      _menuController.close();
                      break;
                    case false:
                      _menuController.open();
                      break;
                  }
                },
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: Icon(
                    Icons.circle,
                    size: context.read<DrawingContext>().strokeWidth,
                    color: secondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
