import 'package:demo_space/classes/drawing_context.dart';
import 'package:demo_space/classes/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// possible to use menu anchor instead?
// https://api.flutter.dev/flutter/material/PopupMenuButton-class.html

enum MenuEntry { width }

class BrushMenu extends StatelessWidget {
  final MenuController _menuController = MenuController();
  @override
  Widget build(BuildContext context) {
    Color secondary = context.watch<Settings>().secondaryColor;
    return Material(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      PopupMenuButton<ColorButton>(
        constraints: BoxConstraints(maxWidth: 50),
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(),
        ),
        position: PopupMenuPosition.over,
        initialValue: ColorToColotButton(context.read<DrawingContext>().color),
        onSelected: (ColorButton result) {
          context
              .read<DrawingContext>()
              .changeColor(ColorEnumToColorType(result));
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
          height: 40,
          width: 40,
          decoration: BoxDecoration(
              color: context.watch<DrawingContext>().color,
              border: Border.all(width: 1, color: secondary)),
        ),
      ),
      PopupMenuButton<Mode>(
        constraints: BoxConstraints(maxWidth: 50),
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(),
        ),
        position: PopupMenuPosition.over,
        onSelected: (Mode result) {
          context.read<DrawingContext>().changeMode(result);
        },
        initialValue: context.read<DrawingContext>().mode,
        tooltip: "Change Tool",
        itemBuilder: (BuildContext context) => <PopupMenuEntry<Mode>>[
          PopupMenuItem(value: Mode.line, child: _toolButton(Icons.line_style)),
          PopupMenuItem(
              value: Mode.fill, child: _toolButton(Icons.crop_3_2_rounded)),
          PopupMenuItem(value: Mode.drawing, child: _toolButton(Icons.draw)),
        ],
        child: Container(
            height: 40,
            width: 40,
            decoration:
                BoxDecoration(border: Border.all(width: 1, color: secondary)),
            child: switch (context.read<DrawingContext>().mode) {
              Mode.drawing => Icon(Icons.draw_rounded, color: secondary),
              Mode.line => Icon(
                  Icons.line_style,
                  color: secondary,
                ),
              Mode.fill => Icon(Icons.crop_3_2_rounded, color: secondary),
              _ => null,
            }),
      ),
      MenuAnchor(
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
                      border: Border.all(width: 1, color: secondary)),
                  child: Icon(Icons.circle,
                      size: context.read<DrawingContext>().strokeWidth,
                      color: secondary)))),
    ]));
  }

  Widget _colorButton(Color color) {
    return Container(height: 30, width: 30, color: color, child: null);
  }

  Widget _toolButton(IconData icon) {
    return Container(
      child: Icon(icon),
    );
  }

  Widget _widthButton(double width) {
    return Container(
      child: Icon(
        Icons.circle_sharp,
        size: width,
      ),
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
