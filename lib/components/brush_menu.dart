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
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _colorButton(Colors.red, context),
            _colorButton(Colors.green, context),
            _colorButton(Colors.blue, context),
            _colorButton(Colors.yellow, context),
            LineToolButton(),
            SizedBox(
                height: 30,
                width: 30,
                child: Center(
                    child: Text(
                  context.watch<DrawingContext>().buffer.length.toString(),
                  style: TextStyle(
                    fontSize: 10,
                  ),
                )))
          ],
        )
      ],
    );
  }

  Widget _colorButton(Color color, BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        ctx.read<DrawingContext>().changeColor(color);
        ctx.read<DrawingContext>().changeMode(Mode.drawing);
      },
      child: Container(
          margin: EdgeInsets.all(8.0),
          height: 30,
          width: 30,
          color: color,
          child: Icon(Icons.draw_rounded)),
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
