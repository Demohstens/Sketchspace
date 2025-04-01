import 'package:sketchspace/components/add_imported.dart';
import 'package:sketchspace/components/color_selector.dart';
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
        child: 
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AddImported(),
              MouseToolButton(),
              BrushToolButton(),
              SketchColorPicker(onColorChanged: (c) {context.read<DrawingContext>().changeColor(c);},),
              MenuAnchor(
                controller: _menuController,
                menuChildren: <Widget>[_widthSlider(context)],
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque, // Ensures the entire area is clickable
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
    ])));
  }

  Widget _colorButton(Color color) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 15,
      child: null,
    );
  }

  Widget _toolButton(IconData icon) {
    return Container(
      child: Icon(icon),
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
    default:
      return Colors.black;
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


class ColorSelector extends StatelessWidget {
  void Function (Color color) changeColor;
  ColorSelector(this.changeColor);
  
  Widget _colorButton(Color color) {
    return Container(height: 30, width: 30, color: color, child: null);
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: PopupMenuButton<ColorButton>(
        constraints: BoxConstraints(maxWidth: 40),
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(),
        ),
        position: PopupMenuPosition.over,
        initialValue: ColorToColotButton(context.read<DrawingContext>().color),
        onSelected: (ColorButton result) {
          changeColor(ColorEnumToColorType(result));
        },
        tooltip: "Change Color",
        itemBuilder: (BuildContext context) => <PopupMenuEntry<ColorButton>>[
          PopupMenuItem(
              value: ColorButton.red, child: _colorButton(Colors.red)),
          PopupMenuItem(
              value: ColorButton.green, child: _colorButton(Colors.green)),
          PopupMenuItem(
              value: ColorButton.blue, child: _colorButton(Colors.blue)),
        ],
        child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
              color: context.watch<DrawingContext>().color,
              border: Border.all(width: 1, color: context.watch<Settings>().secondaryColor)),
        ),
    ));
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