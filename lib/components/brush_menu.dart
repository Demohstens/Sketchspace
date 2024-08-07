import 'package:flutter/material.dart';
import 'package:flutter_application/classes/drawing_context.dart';
import 'package:provider/provider.dart';

// possible to use menu anchor instead?
// https://api.flutter.dev/flutter/material/PopupMenuButton-class.html

class BrushMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      PopupMenuButton<ColorButton>(
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
              border: Border.all(width: 1, color: Colors.black)),
        ),
      ),
      PopupMenuButton<Mode>(
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
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black)),
            child: switch (context.read<DrawingContext>().mode) {
              Mode.drawing => Icon(Icons.draw_rounded),
              Mode.line => Icon(Icons.line_style),
              Mode.fill => Icon(Icons.crop_3_2_rounded),
              _ => null,
            }),
      ),
      PopupMenuButton<double>(
        onSelected: (double result) {
          context.read<DrawingContext>().changeWidth(result);
        },
        initialValue: context.read<DrawingContext>().strokeWidth,
        tooltip: "Change stroke width",
        itemBuilder: (BuildContext context) => <PopupMenuEntry<double>>[
          PopupMenuItem(value: 5.0, child: _widthButton(5.0)),
          PopupMenuItem(value: 10.0, child: _widthButton(10.0)),
          PopupMenuItem(value: 15, child: _widthButton(15.0)),
          PopupMenuItem(value: 20, child: _widthButton(20.0)),
        ],
        child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black)),
            child: switch (context.read<DrawingContext>().strokeWidth) {
              (double a) => Icon(
                  (Icons.circle),
                  size: a,
                ),
            }),
      )
    ]));
  }

  Widget _colorButton(Color color) {
    return Container(height: 30, width: 30, color: color, child: null);
  }

  Widget _toolButton(IconData icon) {
    return Container(
      margin: EdgeInsets.all(8.0),
      height: 30,
      width: 30,
      color: Colors.white,
      child: Icon(icon),
    );
  }

  Widget _widthButton(double width) {
    return Container(
      margin: EdgeInsets.all(8.0),
      height: 30,
      width: 30,
      color: Colors.white,
      child: Icon(
        Icons.circle_sharp,
        size: width,
      ),
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
