import 'package:flutter/material.dart';
import 'package:flutter_application/classes/drawing_context.dart';
import 'package:provider/provider.dart';

class BrushMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          color: context.watch<DrawingContext>().color,
          child: switch (context.read<DrawingContext>().mode) {
            Mode.drawing => Icon(Icons.draw_rounded),
            Mode.line => Icon(Icons.line_style),
            Mode.fill => Icon(Icons.circle_sharp),
            _ => null,
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _colorButton(Colors.red, context),
            _colorButton(Colors.green, context),
            _colorButton(Colors.blue, context),
            LineToolButton(),
            FillToolButton(),
            DrawToolButton(),
          ],
        )
      ],
    );
  }

  Widget _colorButton(Color color, BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        ctx.read<DrawingContext>().changeColor(color);
      },
      child: Container(
          margin: EdgeInsets.all(8.0),
          height: 30,
          width: 30,
          color: color,
          child: null),
    );
  }
}

class LineToolButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<DrawingContext>().changeMode(Mode.line);
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        height: 30,
        width: 30,
        color: Colors.white,
        child: Icon(Icons.line_style),
      ),
    );
  }
}

class FillToolButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<DrawingContext>().changeMode(Mode.fill);
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        height: 30,
        width: 30,
        color: Colors.white,
        child: Icon(Icons.circle_sharp),
      ),
    );
  }
}

class DrawToolButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<DrawingContext>().changeMode(Mode.drawing);
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        height: 30,
        width: 30,
        color: Colors.white,
        child: Icon(Icons.draw_outlined),
      ),
    );
  }
}
