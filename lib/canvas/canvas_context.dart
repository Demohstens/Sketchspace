import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:sketchspace/classes/draw_file.dart';
import 'package:sketchspace/components/save_file_reminder.dart';
import 'package:sketchspace/canvas/data/stroke_selector/paint_selector.dart';
import 'package:sketchspace/canvas/data/stroke_selector/src/stroke.dart';
import 'package:sketchspace/utils/repaint_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Mode { drawing, lifted, erasing, line, fill }

/// Everything the active painter needs to draw on the canvas
/// Also includes everything the
class DrawingContext with ChangeNotifier {
  // * ATTRIBUTES * //
  Offset _currentPoint = Offset.zero;
  List<Offset> _points = [];
  RepaintListener repaintListener = RepaintListener();
  Mode _mode = Mode.drawing;
  DrawFile _workingFile = DrawFile.empty("Untitled");

  // * Paint Attributes * //
  Color _color = Colors.orange;
  double _width = 10.0;
  Widget? selectedPaint;

  bool ui_enabled = true;

  List<Stroke> redoBuffer = [];
  List<Stroke> undoBuffer = [];

  // GETTERS
  Color get color => _color;
  Mode get mode => _mode;
  // Offset get currentPoint => _currentPoint;
  List<Offset> get points => _points;
  double get strokeWidth => _width;
  DrawFile? get workingFile => _workingFile;
  Matrix4 get inverseTransformMatrix => _inverseMatrix;

  Matrix4 _inverseMatrix = Matrix4.identity();
  // Drawing logic
  void setCurrentPoint(Offset point) {
    _points.add(point);
    _currentPoint = point;
    notifyListeners();
  }

  void toggleUI() {
    ui_enabled = !ui_enabled;
    notifyListeners();
  }

  // Undo / redo logic
  // void undo() {
  //   if (undoBuffer.isNotEmpty) {
  //     print("Undoing stroke");
  //     _buffer.add(undoBuffer.removeLast());
  //     redoBuffer.add(_buffer.last);
  //     _workingFile.content = _buffer;
  //     notifyListeners();
  //     repaintListener.notifyListeners();
  //   } else if (_buffer.isNotEmpty) {
  //     redoBuffer.add(_buffer.removeLast());
  //     _workingFile.content = _buffer;
  //     notifyListeners();
  //     repaintListener.notifyListeners();
  //   }
  // }

  // void redo() {
  //   if (redoBuffer.isNotEmpty) {
  //     _buffer.add(redoBuffer.removeLast());
  //     _workingFile.content = _buffer;
  //     notifyListeners();
  //     repaintListener.notifyListeners();
  //   }
  // }

  // File logic
  // Future<bool> saveFile(BuildContext context, {String? name}) async {
  //   // return await _workingFile.save(context);
  //   String _name;
  //   if (name != null) {
  //     _name = name;
  //   } else if (_workingFile.name != null) {
  //     _name = _workingFile.name!;
  //   } else {
  //     _name = "Untitled";
  //   }
  //   bool success = false;
  //   if (_buffer.isEmpty) {
  //     print("No content to save.");
  //     return success;
  //   }
  //   if (_name == "") {
  //     String? fileName = await showFileNameDialog(context);
  //     if (fileName != null) {
  //       _name = fileName;
  //     } else {
  //       return success;
  //     }
  //   }
  //   // Convert strokes to JSON list
  //   final List<String> jsonStrokes = [
  //     for (var stroke in _buffer) stroke.toJson()
  //   ];
  //   final String jsonString = jsonEncode({"Strokes": jsonStrokes});

  //   final Directory appDir = await getAppDirectory();
  //   String filePath;
  //   if (_name.endsWith(".json")) {
  //     filePath = '${appDir.path}/$_name';
  //   } else {
  //     filePath = '${appDir.path}/$_name.json';
  //   }
  //   File file = File(filePath);

  //   // Write the JSON string to the file
  //   await file.writeAsString(jsonString);
  //   print('Saved file to ${file.path}');
  //   return success;
  // }

  // void loadFileContext(File file) {
  //   reset(); // TODO check if this is necessary
  //   _workingFile = loadFile(file);
  //   _buffer = _workingFile.getStrokes();

  //   if (_workingFile.content == null) {
  //     print("Error loading file: ${file.path}. Invalid file.");
  //   } else {
  //     print("Loaded file: ${file.path}");
  //     ui_enabled = true;
  //     notifyListeners();
  //     repaintListener.notifyListeners();
  //   }
  // }

  void changeWidth(double width) {
    _width = width;
    notifyListeners();
  }

  Paint getPaint() {
    Paint pt = Paint()
      ..color = _color
      ..strokeWidth = _width
      ..style = _getStyle();
    return pt;
  }

  PaintingStyle _getStyle() {
    switch (_mode) {
      case Mode.drawing:
        return PaintingStyle.stroke;
      case Mode.erasing:
        return PaintingStyle.stroke;
      case Mode.line:
        return PaintingStyle.stroke;
      case Mode.fill:
        return PaintingStyle.fill;
      case Mode.lifted:
        return PaintingStyle.stroke;
    }
  }

  void changeMode(Mode mode) {
    print("Changing mode: $mode");
    _mode = mode;
    notifyListeners();
  }

  void changeColor(Color color) {
    print("Changing color: $color");

    _color = color;
    notifyListeners();
  }

  void exit() {
    return;
  }
}
