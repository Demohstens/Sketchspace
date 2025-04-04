import 'package:sketchspace/components/add_imported.dart';
import 'package:sketchspace/components/color_selector.dart';
import 'package:sketchspace/providers/drawing_context.dart';
import 'package:sketchspace/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/tools/brush.dart';
import 'package:sketchspace/tools/mouse.dart';
import 'package:sketchspace/tools/text.dart';

// possible to use menu anchor instead?
// https://api.flutter.dev/flutter/material/PopupMenuButton-class.html

enum MenuEntry { width }

class BrushMenuMobile extends StatefulWidget {

  const BrushMenuMobile({
    super.key,
  });

  @override
  State<BrushMenuMobile> createState() => BrushMenuMobileState();
}

class BrushMenuMobileState extends State<BrushMenuMobile> {
  final MenuController _widthMenuController = MenuController();
  final MenuController _colorMenuController = MenuController();
  final MenuController menuController = MenuController();
  @override
  Widget build(BuildContext context) {
    Color secondary = context.watch<Settings>().secondaryColor;
    return Material(
      color: Colors.transparent,
      child: MenuAnchor(
        controller: menuController,
        menuChildren: [
          TextToolButton(),
          AddImported(),
          MouseToolButton(),
          BrushToolButton(),
          MenuAnchor(
            controller: _colorMenuController,
            menuChildren: [
              SketchColorPicker(onColorChanged: (c) {context.read<DrawingContext>().changeColor(c);},),
            ],
            child: IconButton(onPressed: () {
              _colorMenuController.isOpen ? _colorMenuController.close() : _colorMenuController.open();
            }, icon: Icon(Icons.color_lens, color: context.read<DrawingContext>().color,)),
          ),
          MenuAnchor(
                controller: _widthMenuController,
                menuChildren: <Widget>[_widthSlider(context)],
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque, // Ensures the entire area is clickable
                  onTap: () {
                    switch (_widthMenuController.isOpen) {
                      case true:
                        _widthMenuController.close();
                        break;
                      case false:
                        _widthMenuController.open();
                        break;
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    child: Icon(
                      Icons.circle,
                      size: context.read<DrawingContext>().strokeWidth,
                      color: secondary,
                    ),
                  ),
                ),
        )
      ],
        child:CircleAvatar( 
          backgroundColor: Colors.transparent, 
          child: IconButton(
            iconSize: 40,
          tooltip: "Brush Menu",
          color: context.read<Settings>().secondaryColor,
          onPressed: () {
          switch (menuController.isOpen) {
            case true: 
              {
                setState(() {
                  menuController.close();

                });
              }
              break;
            case false:
              {
                setState(() {
                  menuController.open();

                });
              }
              break;
            
          }
        }, icon: menuController.isOpen ? Icon(Icons.close) : Icon(Icons.menu)),
    )));
  }

  Widget _colorButton(Color color) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 15,
      child: null,
    );
  }

  Widget _widthSlider(BuildContext context) {
    return Slider(
      value: context.read<DrawingContext>().strokeWidth,
      min: 1,
      max: 20,
      divisions: 19,
      label: 'Stroke Width: ${context.read<DrawingContext>().strokeWidth}',
      onChanged: (double value) {
        context.read<DrawingContext>().changeWidth(value);
      },
    );
  }
}

enum ColorButton { red, green, blue }

Color ColorEnumToColorType(ColorButton color) {
  switch (color) {
    case ColorButton.red:
      return Colors.red;
    case ColorButton.green:
      return Colors.green;
    case ColorButton.blue:
      return Colors.blue;
  }
}

ColorButton ColorToColotButton(Color color) {
  if (color == Colors.red) {
    return ColorButton.red;
  } else if (color == Colors.green) {
    return ColorButton.green;
  } else if (color == Colors.blue) {
    return ColorButton.blue;
  } else {
    return ColorButton.red;
  }
}

class WidthSelector extends StatelessWidget {
  final MenuController _menuController = MenuController();

  Widget _widthSlider(BuildContext context) {
    return Slider(
      value: context.read<DrawingContext>().strokeWidth,
      min: 1,
      max: 20,
      divisions: 19,
      label: 'Stroke Width: ${context.read<DrawingContext>().strokeWidth}',
      onChanged: (double value) {
        context.read<DrawingContext>().changeWidth(value);
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
          controller: _menuController,
          menuChildren: <Widget>[_widthSlider(context)],
          child: GestureDetector(
              onTap: () {
                _menuController.open();
              },
              child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: context.watch<Settings>().secondaryColor)),
                  child: Icon(Icons.circle,
                      size: context.read<DrawingContext>().strokeWidth,
                      color: context.watch<Settings>().secondaryColor))));
  }
}