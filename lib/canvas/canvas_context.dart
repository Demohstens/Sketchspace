import 'dart:convert';
import 'dart:io';

import 'package:sketchspace/brushes/selected_stroke_painter.dart';
import 'package:sketchspace/canvas/data/worldspace.dart';
import 'package:sketchspace/classes/draw_file.dart';
import 'package:sketchspace/canvas/stroke_selector/src/stroke.dart';
import 'package:sketchspace/components/file_save_dialogs.dart';
import 'package:flutter/material.dart';

enum Mode { drawing, lifted, erasing, strokeErasing, line, fill }

/// Everything the active painter needs to draw on the canvas
/// Also includes everything the
class DrawingContext with ChangeNotifier {
  DrawingContext(this.worldspace);
  // * ATTRIBUTES * //
  Worldspace worldspace;
  List<Offset> _points = [];
  Mode _mode = Mode.drawing;
  DrawFile _workingFile = DrawFile.empty("Untitled");
  Widget? _selectedStrokeWidget; // TODO replace with proper context menu ASAP
  Stroke? _selectedStroke;

  // * Paint Attributes * //
  Color _color = Colors.orange;
  double _width = 10.0;

  bool ui_enabled = true;

  // GETTERS
  Color get color => _color;
  Widget get selectedStrokeWidget =>
      _selectedStrokeWidget ??
      Container(); // Empty Container is a placeholder for null
  Stroke? get selectedStroke => _selectedStroke;
  Mode get mode => _mode;
  List<Offset> get points => _points;
  double get strokeWidth => _width;
  DrawFile? get workingFile => _workingFile;

  // Drawing logic
  void toggleUI() {
    ui_enabled = !ui_enabled;
    notifyListeners();
  }

  void updateDrawing(Offset p) {
    _points.add(p);
    notifyListeners();
  }

  void addPoint(Offset p) {
    _points.add(p);
    notifyListeners();
  }

  void endDrawing() {
    if (_points.isNotEmpty) {
      worldspace.addStrokeFromPoints(_points, getPaint(), _mode);
      _points.clear();
      notifyListeners();
    }
  }

  void resetDrawing() {
    _points.clear();
    notifyListeners();
  }

  void resetAll() {
    _points.clear();
    worldspace.clear();
    notifyListeners();
  }

  // * UNDO/REDO * //
  List<Stroke> redoBuffer = [];
  List<Stroke> undoBuffer = [];
  // Undo / redo logic
  void undo() {
    if (undoBuffer.isNotEmpty) {
      Stroke undoneStroke = undoBuffer.removeLast();
      worldspace.addStroke(undoneStroke);
      redoBuffer.add(undoneStroke);
      _workingFile.content =
          worldspace.strokes; // Replace with a method to handle this properly.
      notifyListeners();
    } else if (worldspace.strokes.isNotEmpty) {
      redoBuffer.add(worldspace.removeStrokeAt(-1));
      _workingFile.content = worldspace.strokes; // Again: Don't do this.
      notifyListeners();
    }
  }

  void redo() {
    if (redoBuffer.isNotEmpty) {
      worldspace.addStroke(redoBuffer.removeLast());
      _workingFile.content = worldspace.strokes; // Again: Don't do this.
      notifyListeners();
    }
  }

  // File logic
  void newFile() {
    resetAll();
  }

  Future<bool> saveFile(BuildContext context, {String? name}) async {
    // return await _workingFile.save(context);
    String _name;
    _name = name ?? _workingFile.name ?? "";

    bool saveSuccess = false;
    if (worldspace.strokes.isEmpty) {
      return saveSuccess;
    }
    if (_name == "" || _name == "Untitled") {
      String? fileName = await showFileNameDialog(context);
      if (fileName != null) {
        _name = fileName;
      } else {
        return saveSuccess;
      }
    }
    // Convert strokes to JSON list
    final List<String> jsonStrokes = [
      for (var stroke in worldspace.strokes) stroke.toJson()
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
    return saveSuccess;
  }

  void loadFileContext(File file) {
    resetAll(); // TODO check if this is necessary
    _workingFile = loadFile(file) ?? DrawFile.empty("Untitled");
    worldspace.loadStrokes(_workingFile.getStrokes());

    if (_workingFile.content == null) {
    } else {
      ui_enabled = true;
      notifyListeners();
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
      ..style = _getStyle()
      ..blendMode = _getBlendMode();
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
      case Mode.strokeErasing:
        return PaintingStyle.stroke;
    }
  }

  BlendMode _getBlendMode() {
    switch (_mode) {
      case Mode.erasing:
        return BlendMode.clear;
      default:
        return BlendMode.srcOver;
    }
  }

  void changeMode(Mode mode) {
    _mode = mode;
    notifyListeners();
  }

  void changeColor(Color color) {
    _color = color;
    notifyListeners();
  }

  void exit() {
    return;
  }

  // * SELECTION * //
  void selectStroke(Offset touchPoint) {
    double maxAllowedDistance =
        50; // The maximum distance allowed to select a stroke in pixels
    for (Stroke stroke in worldspace.strokes.reversed) {
      if (stroke.contains(touchPoint,
              maximumAllowedDistance: maxAllowedDistance) &&
          stroke.getDistanceToPoint(touchPoint) < maxAllowedDistance) {
        setSelectedStroke(stroke);
        return;
      }
    }
  }

  void setSelectedStroke(Stroke s) {
    _selectedStroke = s;
    _selectedStrokeWidget = getSelectedStrokeWidget();
    notifyListeners();
  }

  void unSelectStroke() {
    _selectedStroke = null;
    notifyListeners();
  }

  Widget? getSelectedStrokeWidget() {
    if (_selectedStroke == null) {
      return null;
    } else {
      Rect bounds = _selectedStroke!.boundary();
      return Container(
        width: bounds.width,
        height: bounds.height,
        child: CustomPaint(
          painter: SelectedStrokePainter(
              _selectedStroke!,
              Colors.grey
                  .withAlpha(150)), // TODO properly handle the selection color
        ),
      );
    }
  }
}
