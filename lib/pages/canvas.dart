import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_application/classes/DrawingContext.dart';
import 'package:flutter_application/classes/Settings.dart';
import 'package:flutter_application/classes/stroke.dart';
import 'package:flutter_application/utils/pen.dart';
import 'package:provider/provider.dart';

class CanvasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: DrawingCanvas(),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: FloatingActionButton(
              heroTag: "home",
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.home)),
        ),
        // Toggle Dark mode button
        Positioned(
            top: 0,
            right: 0,
            child: FloatingActionButton(
                heroTag: "darkmode",
                child: Icon(Icons.color_lens),
                onPressed: () => context.read<Settings>().toggleDarkMode())),
        Positioned(
            top: 0,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: BrushMenu()),
      ],
    );
  }
}

class DrawingCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingContext>(
      builder: (context, drawingContext, child) {
        return Container(
            color: context.watch<Settings>().background,
            child: GestureDetector(
              onPanUpdate: (details) {
                drawingContext.setCurrentPoint(details.localPosition);
              },
              onPanEnd: (details) {
                drawingContext.addStroke(null);
              },
              child: CustomPaint(
                  painter: Pen(drawingContext.buffer, drawingContext.points,
                      drawingContext.color)),
            ));
      },
    );
  }
}

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
          child: Icon(Icons.draw_rounded)),
    );
  }
}
