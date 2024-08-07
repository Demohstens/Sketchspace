import 'package:flutter/material.dart';
import 'package:flutter_application/classes/drawing_context.dart';
import 'package:provider/provider.dart';

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

class BrushMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      PopupMenuButton<ColorButton>(
        initialValue: ColorButton.red,
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
        tooltip: "Change Tool",
        itemBuilder: (BuildContext context) => <PopupMenuEntry<Mode>>[
          PopupMenuItem(value: Mode.line, child: _toolButton(Icons.line_axis)),
          PopupMenuItem(value: Mode.fill, child: _toolButton(Icons.circle)),
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
              Mode.fill => Icon(Icons.circle_sharp),
              _ => null,
            }),
      ),
    ]));
  }

  Widget _colorButton(Color color) {
    return Container(
        margin: EdgeInsets.all(8.0),
        height: 30,
        width: 30,
        color: color,
        child: null);
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
}

// class LineToolButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         context.read<DrawingContext>().changeMode(Mode.line);
//       },
//       child: Container(
//         margin: EdgeInsets.all(8.0),
//         height: 30,
//         width: 30,
//         color: Colors.white,
//         child: Icon(Icons.line_style),
//       ),
//     );
//   }
// }

// class FillToolButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         context.read<DrawingContext>().changeMode(Mode.fill);
//       },
//       child: Container(
//         margin: EdgeInsets.all(8.0),
//         height: 30,
//         width: 30,
//         color: Colors.white,
//         child: Icon(Icons.circle_sharp),
//       ),
//     );
//   }
// }

// class DrawToolButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         context.read<DrawingContext>().changeMode(Mode.drawing);
//       },
//       child: Container(
//         margin: EdgeInsets.all(8.0),
//         height: 30,
//         width: 30,
//         color: Colors.white,
//         child: Icon(Icons.draw_outlined),
//       ),
//     );
//   }
// }
