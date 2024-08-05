import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/utils/pen.dart';

class CanvasPage extends StatefulWidget {
  @override
  _CanvasPageState createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  Color color = Colors.green;

  @override
  Widget build(BuildContext context) {
    BrushMenu brushMenu = BrushMenu(onColorChanged: (_color) {
      setState(() {
        color = _color;
      });
    });

    const String appTitle = "My App";
    return MaterialApp(
        title: appTitle,
        home: Scaffold(
            body: Stack(
          children: [
            Positioned(
                left: 0,
                top: 0,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: DrawingCanvas(color)),
            Positioned(
                left: MediaQuery.of(context).size.width / 2 - 200,
                top: 0,
                child: brushMenu),
            Positioned(
                right: 0,
                bottom: 0,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.home),
                )),
          ],
        )));
  }
}

class DrawingCanvas extends StatefulWidget {
  final Color color;

  DrawingCanvas(this.color);

  @override
  _DrawingCanvasState createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<Offset> _points = [];
  List<Stroke> _inputBuffer = [];

  FocusNode _focusNode = FocusNode();
  Offset? _inputPoint;

  void _undo() {
    if (_inputBuffer.isNotEmpty) {
      setState(() {
        _inputBuffer.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyZ) {
            _undo();
          }
        },
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _inputPoint = details.localPosition;
              if (_inputPoint != null) _points.add(_inputPoint!);
            });
          },
          onPanEnd: (details) {
            setState(() {
              if (_points.isNotEmpty) {
                _inputBuffer.add(Stroke(widget.color, _points));
              }
              _inputPoint = null;
              _points = [];
            });
          },
          child: CustomPaint(
            painter: Pen(
                state:
                    DrawingState(_inputBuffer, Stroke(widget.color, _points))),
            child: Container(),
          ),
        ));
  }
}

class BrushMenu extends StatefulWidget {
  final Function(Color) onColorChanged;

  BrushMenu({required this.onColorChanged});

  @override
  _BrushMenuState createState() => _BrushMenuState();
}

class _BrushMenuState extends State<BrushMenu> {
  Color _selectedColor = Colors.red;

  Color get selectedColor => _selectedColor;

  void _changeColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          color: selectedColor,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _colorButton(Colors.red),
            _colorButton(Colors.green),
            _colorButton(Colors.blue),
            _colorButton(Colors.yellow),
          ],
        )
      ],
    );
  }

  Widget _colorButton(Color color) {
    return GestureDetector(
      onTap: () => _changeColor(color),
      child: Container(
          margin: EdgeInsets.all(8.0),
          height: 30,
          width: 30,
          color: color,
          child: Icon(Icons.draw_rounded)),
    );
  }
}
