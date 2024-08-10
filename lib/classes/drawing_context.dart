import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application/classes/draw_file.dart';
import 'package:flutter_application/components/save_file_reminder.dart';
import 'package:flutter_application/stroke_selector/paint_selector.dart';
import 'package:flutter_application/stroke_selector/src/classes/stroke.dart';
import 'package:flutter_application/utils/repaint_listener.dart';

enum Mode { drawing, lifted, erasing, line, fill }

class DrawingContext with ChangeNotifier {
  Color _color = Colors.red;
  List<Stroke> _buffer = [];
  Offset _currentPoint = Offset(0, 0);
  List<Offset> _points = [];
  RepaintListener repaintListener = RepaintListener();
  Mode _mode = Mode.drawing;
  double _width = 10.0;
  DrawFile _workingFile = DrawFile.empty("Untitled");
  Widget? selectedPaint;

  // GETTERS
  Color get color => _color;
  Mode get mode => _mode;
  List<Stroke> get buffer => _buffer;
  Offset get currentPoint => _currentPoint;
  List<Offset> get points => _points;
  double get strokeWidth => _width;
  DrawFile? get workingFile => _workingFile;

  void selectStroke(Offset point) {
    selectedPaint = paintSelector(_buffer, point);
    notifyListeners();
  }

  void unselectStroke() {
    selectedPaint = null;
    notifyListeners();
  }

  Future<bool> saveFile(BuildContext context, {String? name}) async {
    // return await _workingFile.save(context);
    String _name;
    if (name != null) {
      _name = name;
    } else if (_workingFile.name != null) {
      _name = _workingFile.name!;
    } else {
      _name = "Untitled";
    }
    bool success = false;
    if (_buffer.isEmpty) {
      print("No content to save.");
      return success;
    }
    if (_name == "") {
      await showFileNameDialog(context).then((value) {
        if (value != null && value != "") {
          _name = value;
          success = true;
        } else {
          _name = "Untitled";
        }
      });
    }
    // Convert strokes to JSON list
    final List<String> jsonStrokes = [
      for (var stroke in _buffer) stroke.toJson()
    ];
    final String jsonString = jsonEncode({"Strokes": jsonStrokes});

    final Directory appDir = await appDirectory();
    String filePath;
    if (_name.endsWith(".json")) {
      filePath = '${appDir.path}/$_name';
    } else {
      filePath = '${appDir.path}/$_name.json';
    }
    File file = File(filePath);

    // Write the JSON string to the file
    await file.writeAsString(jsonString);
    print('Saved file to ${file.path}');
    return success;
  }

  void setCurrentPoint(Offset point) {
    _points.add(point);
    _currentPoint = point;
    notifyListeners();
  }

  void loadFileContext(File file) {
    _workingFile = loadFile(file) ?? DrawFile.empty("Untitled");
    _buffer = _workingFile.getStrokes();

    if (_workingFile.content == null) {
      print("Error loading file: ${file.path}. Invalid file.");
    } else {
      print("Loaded file: ${file.path}");
      notifyListeners();
      repaintListener.notifyListeners();
    }
  }

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

  /// Creates a new Stroke object depending on the mode
  void createStroke(List<Offset>? points) {
    Stroke stroke;
    if (points != null) {
      _points = points;
      switch (_mode) {
        case Mode.drawing:
          stroke = Stroke(getPaint(), points);
          // stroke.optimize();
          _buffer.add(stroke);
        case Mode.erasing:
          break;
        case Mode.line:
          if (points.length < 2) {
            _buffer.add(Stroke(getPaint(), points));
          }
          stroke = (Stroke(getPaint(), [points.first, points.last]));
          _buffer.add(stroke);
        case Mode.fill:
          stroke = (Stroke(getPaint(), points));
          // stroke.optimize();
          _buffer.add(stroke);
        case Mode.lifted:
          break;
      }
      _workingFile.content = _buffer;

      _points = [];
      notifyListeners();
      repaintListener.notifyListeners();
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

  void reset() {
    _workingFile = DrawFile.empty("");
    _buffer = [];
    _points = [];
    repaintListener.notifyListeners();
    notifyListeners();
  }
}
