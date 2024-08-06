import 'package:flutter/material.dart';
import 'package:flutter_application/classes/DrawingContext.dart';
import 'package:flutter_application/classes/Settings.dart';
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
                child: Icon(Icons.color_lens),
                onPressed: () => context.read<Settings>().toggleDarkMode()))
      ],
    );
  }
}

class DrawingCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Drawingcontext>(
      builder: (context, drawingContext, child) {
        return Container(
            color: context.watch<Settings>().background,
            child: GestureDetector(
                child: CustomPaint(
              painter: Pen(
                  drawingContext.color), // Pass any necessary parameters to Pen
            )));
      },
    );
  }
}

// class _CanvasPageState extends State<CanvasPage> {
//   Color color = Colors.green;

//   @override
//   Widget build(BuildContext context) {
//     // Callback of the brushMenu to change the color of the pen
//     BrushMenu brushMenu = BrushMenu(onColorChanged: (_color) {
//       // Updates the CanvasPage's color
//       //(Implicitly updates the Pen's color as it is re-initialized with the new color)
//       setState(() {
//         color = _color;
//         context.read<Drawingcontext>().changeColor(_color);
//       });
//     });
//     // This is an example of tutorial yoinked code. Ignore.
//     const String appTitle = "My App";

//     // Material app already as parent in main.dart? Not sure if this is required but got errors without it. Keyboard didn't work.
//     return MaterialApp(
//         title: appTitle,
//         home: Scaffold(
//             // Stack is the actually displayed content. Positioned widgets are placed on top of each other.
//             body: Stack(
//           children: [
//             // This is the actual drawing canvas
//             Positioned(
//                 left: 0,
//                 top: 0,
//                 // sets the width and height of the canvas to the screen size
//                 width: MediaQuery.of(context).size.width,
//                 height: MediaQuery.of(context).size.height,
//                 // initializes the DrawingCanvas with the color. The color is in the state so re-initialising the DrawingCanvas will update the color of the Pen.
//                 child: DrawingCanvas(color)),
//             // This is the brush menu for selecting colors.
//             Positioned(
//                 left: MediaQuery.of(context).size.width / 2 - 200,
//                 top: 0,
//                 child: brushMenu),
//             // This is the Home button.
//             Positioned(
//                 right: 0,
//                 bottom: 0,
//                 child: FloatingActionButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: Icon(Icons.home),
//                 )),
//           ],
//         )));
//   }
// }

// /// Attr: color (Color - required) - The color of the pen.
// /// Used to allow for input to be rendered
// class DrawingCanvas extends StatefulWidget {
//   final Color color;

//   DrawingCanvas(this.color);

//   @override
//   _DrawingCanvasState createState() => _DrawingCanvasState();
// }

// class _DrawingCanvasState extends State<DrawingCanvas> {
//   // List of every point of input. Every point the mouse/finger touched.
//   // Reset after every "stroke".
//   List<Offset> _points = [];
//   // List of all the strokes. Every stroke consists of a list of points
//   // as well as the color selected.
//   List<Stroke> _inputBuffer = [];

//   FocusNode _focusNode = FocusNode();
//   // The current point of input.
//   Offset? _inputPoint;

//   // rudementary undo function. Removes the last stroke from the input buffer.
//   void _undo() {
//     if (_inputBuffer.isNotEmpty) {
//       setState(() {
//         _inputBuffer.removeLast();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // KeyboardListener listens for the "Z" key to undo. No combinations FOR NOW.
//     return KeyboardListener(
//         focusNode: _focusNode,
//         autofocus: true,
//         onKeyEvent: (KeyEvent event) {
//           if (event is KeyDownEvent &&
//               event.logicalKey == LogicalKeyboardKey.keyZ) {
//             _undo();
//           }
//         },
//         // Detects touch or mouse input and handles it.
//         child: GestureDetector(
//           // While input is detected, add the point to the list of points.
//           onPanUpdate: (details) {
//             // Setstate is used to update the Custompaint widget with the new inputs.
//             setState(() {
//               _inputPoint = details.localPosition;
//               if (_inputPoint != null) _points.add(_inputPoint!);
//             });
//           },
//           // Once the Finger is lifted or the mouse is released, add the stroke(list of points) to the input buffer.
//           onPanEnd: (details) {
//             setState(() {
//               if (_points.isNotEmpty) {
//                 // widget.color is the color of the pen currently selected.
//                 _inputBuffer.add(Stroke(widget.color, _points));
//               }
//               // Reset the points list.
//               _inputPoint = null;
//               _points = [];
//             });
//           },
//           child: CustomPaint(
//             // CustomPainter is used to draw the input on the screen.
//             painter: Pen(
//                 state:
//                     DrawingState(_inputBuffer, Stroke(widget.color, _points))),
//             child: Container(),
//           ),
//         ));
//   }
// }

// class BrushMenu extends StatefulWidget {
//   final Function(Color) onColorChanged;

//   BrushMenu({required this.onColorChanged});

//   @override
//   _BrushMenuState createState() => _BrushMenuState();
// }

// class _BrushMenuState extends State<BrushMenu> {
//   Color _selectedColor = Colors.red;

//   Color get selectedColor => _selectedColor;

//   void _changeColor(Color color) {
//     setState(() {
//       _selectedColor = color;
//     });
//     widget.onColorChanged(color);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           height: 50,
//           width: 50,
//           color: selectedColor,
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _colorButton(Colors.red),
//             _colorButton(Colors.green),
//             _colorButton(Colors.blue),
//             _colorButton(Colors.yellow),
//           ],
//         )
//       ],
//     );
//   }

//   Widget _colorButton(Color color) {
//     return GestureDetector(
//       onTap: () => _changeColor(color),
//       child: Container(
//           margin: EdgeInsets.all(8.0),
//           height: 30,
//           width: 30,
//           color: color,
//           child: Icon(Icons.draw_rounded)),
//     );
//   }
// }
