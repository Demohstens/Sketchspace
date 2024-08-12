import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:sketchspace/classes/draw_file.dart';
import 'package:sketchspace/components/save_file_reminder.dart';
import 'package:sketchspace/stroke_selector/paint_selector.dart';
import 'package:sketchspace/stroke_selector/src/stroke.dart';
import 'package:sketchspace/utils/repaint_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Mode { drawing, lifted, erasing, line, fill }

class DrawingContext with ChangeNotifier {
  Color _color = Colors.red;
  List<Stroke> _buffer = [];
  Offset _currentPoint = Offset.zero;
  List<Offset> _points = [];
  RepaintListener repaintListener = RepaintListener();
  Mode _mode = Mode.drawing;
  double _width = 10.0;
  DrawFile _workingFile = DrawFile.empty("Untitled");
  Widget? selectedPaint;
  ui.Image? backgroundImage;

  // Zoom logic
  bool _scaling = false;
  double _scale = 1.0;
  Matrix4 transformMatrix = Matrix4.identity();
  double _initialScale = 1.0;
  Offset _initialFocalPoint = Offset.zero;
  Offset _panOffset = Offset.zero;
  Offset _initialPanOffset = Offset.zero;
  double scaleSensitivity = 2;
  double minScale = 1;
  double maxScale = 3;
  double get scale => transformMatrix.getMaxScaleOnAxis();
  bool get scaling => _scaling;
  Offset get pan => _panOffset;

  void startScaling(ScaleStartDetails details) {
    _scaling = true;
    _initialScale = _scale;
    _initialFocalPoint = details.focalPoint;
    _initialPanOffset = _panOffset;
    notifyListeners();
  }

  void endScaling() {
    _scaling = false;
    _initialPanOffset = _panOffset;
    _initialScale = _scale;
    notifyListeners();
    repaintListener.notifyListeners();
  }

  void updateScale(ScaleUpdateDetails details) {
    // Calculate the scale
    _scale = (_initialScale * details.scale).clamp(minScale, maxScale);

    // Calculate the new pan offset relative to the initial pan offset
    Offset deltaPan = details.focalPoint - _initialFocalPoint;
    _panOffset = _initialPanOffset + deltaPan;

    // Update the transformation matrix
    transformMatrix = Matrix4.identity()
      ..scale(_scale)
      ..translate(_panOffset.dx, _panOffset.dy);

    notifyListeners();
  }

  bool ui_enabled = true;

  List<Stroke> redoBuffer = [];
  List<Stroke> undoBuffer = [];

  // GETTERS
  Color get color => _color;
  Mode get mode => _mode;
  List<Stroke> get buffer => _buffer;
  Offset get currentPoint => _currentPoint;
  List<Offset> get points => _points;
  double get strokeWidth => _width;
  DrawFile? get workingFile => _workingFile;

  // Drawing logic
  void setCurrentPoint(Offset point) {
    _points.add(point);
    _currentPoint = point;
    notifyListeners();
  }

  /// Creates a new Stroke object depending on the mode
  void createStroke({List<Offset>? points}) {
    Stroke stroke;
    if (points != null) {
      _points = localToGlobal(points);
    } else {
      points = localToGlobal(_points);
    }
    if (points.isNotEmpty) {
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
    }
    // backgroundImage = getLazyLayer(_buffer, 1920, 1080);
    _workingFile.content = _buffer;
    redoBuffer = [];
    undoBuffer = [];
    _points = [];
    notifyListeners();
    repaintListener.notifyListeners();
  }

  // Convert localpoints to equivalent global points
  List<Offset> localToGlobal(List<Offset> points) {
    return points.map((point) {
      return Offset(point.dx * _scale, point.dy * _scale);
    }).toList();
  }

  // seleection logic
  void selectStroke(Offset point) {
    selectedPaint = paintSelector(_buffer, point);
    if (selectedPaint != null) {
      HapticFeedback.selectionClick();
      notifyListeners();
    }
  }

  void unselectStroke() {
    selectedPaint = null;
    notifyListeners();
  }

  void removeStroke(int index) {
    if (index < 0 || index >= _buffer.length) {
      return;
    }
    selectedPaint = null;

    undoBuffer.add(_buffer.removeAt(index));
    _workingFile.content = _buffer;
    HapticFeedback.lightImpact();
    notifyListeners();
    repaintListener.notifyListeners();
  }

  void toggleUI() {
    ui_enabled = !ui_enabled;
    notifyListeners();
  }

  // Undo / redo logic
  void undo() {
    if (undoBuffer.isNotEmpty) {
      print("Undoing stroke");
      _buffer.add(undoBuffer.removeLast());
      redoBuffer.add(_buffer.last);
      _workingFile.content = _buffer;
      notifyListeners();
      repaintListener.notifyListeners();
    } else if (_buffer.isNotEmpty) {
      redoBuffer.add(_buffer.removeLast());
      _workingFile.content = _buffer;
      notifyListeners();
      repaintListener.notifyListeners();
    }
  }

  void redo() {
    if (redoBuffer.isNotEmpty) {
      _buffer.add(redoBuffer.removeLast());
      _workingFile.content = _buffer;
      notifyListeners();
      repaintListener.notifyListeners();
    }
  }

  // File logic
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
      String? fileName = await showFileNameDialog(context);
      if (fileName != null) {
        _name = fileName;
      } else {
        return success;
      }
    }
    // Convert strokes to JSON list
    final List<String> jsonStrokes = [
      for (var stroke in _buffer) stroke.toJson()
    ];
    final String jsonString = jsonEncode({"Strokes": jsonStrokes});

    final Directory appDir = await getAppDirectory();
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

  void loadFileContext(File file) {
    reset(); // TODO check if this is necessary
    _workingFile = loadFile(file);
    _buffer = _workingFile.getStrokes();

    if (_workingFile.content == null) {
      print("Error loading file: ${file.path}. Invalid file.");
    } else {
      print("Loaded file: ${file.path}");
      ui_enabled = true;
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

  void reset() {
    transformMatrix = Matrix4.identity();
    _scale = 1.0;
    undoBuffer = [];
    redoBuffer = [];
    selectedPaint = null;
    _workingFile = DrawFile.empty("");
    _buffer = [];
    _points = [];
    repaintListener.notifyListeners();
    notifyListeners();
  }
}
