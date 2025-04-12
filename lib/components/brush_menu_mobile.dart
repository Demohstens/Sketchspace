import 'package:pie_menu/pie_menu.dart';
import 'package:sketchspace/components/add_imported.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/tools/tools.dart';

// possible to use menu anchor instead?
// https://api.flutter.dev/flutter/material/PopupMenuButton-class.html

enum MenuEntry { width }

class BrushMenuMobile extends StatefulWidget {
  const BrushMenuMobile({super.key});

  @override
  State<BrushMenuMobile> createState() => BrushMenuMobileState();
}

class BrushMenuMobileState extends State<BrushMenuMobile> {
  final MenuController _colorMenuController = MenuController();
  final PieMenuController menuController = PieMenuController();
  @override
  Widget build(BuildContext context) {
    Color secondary = context.watch<Settings>().secondaryColor;
    return PieMenu(
      theme: PieTheme(
        overlayColor: Colors.transparent,
        radius: 80,
        iconSize: 20,
        childBounceEnabled: false,
        delayDuration: Duration.zero,
        spacing: 4,
      ),
      controller: menuController,
      actions: [
        PieAction(
          child: Icon(Icons.brush, color: secondary, size: 15),
          onSelect: () {
            context.read<DrawingContext>().setTool(Tool.brush);
          },
          tooltip: Text("Brush"),
        ),
        PieAction(
          child: Icon(Icons.mouse, color: secondary, size: 30),
          onSelect: () {
            context.read<DrawingContext>().setTool(Tool.mouse);
          },
          tooltip: Text("Mouse"),
        ),
        PieAction(
          child: Icon(Icons.text_fields, color: secondary, size: 15),
          onSelect: () {
            context.read<DrawingContext>().setTool(Tool.text);
          },
          tooltip: Text("Text"),
        ),
      ],
      child: IconButton(
        onPressed: () {
          _colorMenuController.isOpen
              ? _colorMenuController.close()
              : _colorMenuController.open();
          menuController.toggleMenu();
        },
        icon: Icon(Icons.menu, color: secondary, size: 40),
      ),
    );
  }
}
