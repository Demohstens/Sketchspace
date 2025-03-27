import 'dart:convert';
import 'dart:io';

import 'package:sketchspace/brushes/selected_stroke_painter.dart';
import 'package:sketchspace/classes/sketch_canvas.dart';
import 'package:sketchspace/utils/draw_file.dart';
import 'package:sketchspace/classes/layer.dart';
import 'package:sketchspace/classes/stroke.dart';
import 'package:sketchspace/components/brush_menu.dart';
import 'package:sketchspace/components/file_save_dialogs.dart';
import 'package:flutter/material.dart';

enum Mode { drawing, lifted, erasing, strokeErasing, line, fill }

/// Everything the active painter needs to draw on the canvas
/// Also includes everything the
class DrawingContext with ChangeNotifier {
  // * ATTRIBUTES * //
  List<Offset> _points = [];
  Mode _mode = Mode.drawing;
  Widget? _selectedStrokeWidget; // TODO replace with proper context menu ASAP
  Stroke? _selectedStroke;
  SketchCanvas canvas;
  ValueNotifier<bool> repaintNotifier = ValueNotifier(false);

  DrawingContext() : canvas = SketchCanvas();

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
  // * LAYERS * //
  List<Layer> get layers => canvas.layers;
  Layer get activeLayer => canvas.activeLayer;
  
  @override
  void notifyListeners() {
    repaintNotifier.value = !repaintNotifier.value;
    super.notifyListeners();
  }

  // Drawing logic
  void toggleUI() {
    ui_enabled = !ui_enabled;
    notifyListeners();
  }

  void updateDrawing(Offset p) {
    _points.add(p);
    notifyListeners();
  }

  void repaint() {
    notifyListeners();
  }

  void addPoint(Offset p) {
    _points.add(p);
    notifyListeners();
  }

  void newLayer() {
    // Id is equal to the length of the list as the first layer is 0
    canvas.addLayer();
    notifyListeners();
  }

  void changeActiveLayer(Layer layer) {
    print("Changed active layer to ${layer.id}");
    canvas.activeLayer = layer;
    notifyListeners();
  }

  void deleteLayer(Layer layer) {
    layers.remove(layer);
    notifyListeners();
  }

  void endDrawing() {
    if (_points.isNotEmpty) {
      // Create a copy of the points before clearing
      List<Offset> pointsCopy = List.from(_points);
      _points.clear();
      
      // Only add the stroke if there are enough points
      if (pointsCopy.length >= 2) {
        canvas.activeLayer.addStroke(Stroke(getPaint(), pointsCopy, mode));
      }
      
      notifyListeners();
    }
  }

  void resetDrawing() {
    unSelectStroke();
    _points.clear();
    notifyListeners();
  }

  void resetAll() {
    unSelectStroke();
    _points.clear();
    notifyListeners();
  }

  // * UNDO/REDO * //
  List<Stroke> redoBuffer = [];
  List<Stroke> undoBuffer = [];
  // Undo / redo logic
  void undo() {
      Stroke undoneStroke = undoBuffer.removeLast();
      redoBuffer.add(undoneStroke);
      notifyListeners();
    
      notifyListeners();
    }

  void redo() {
    // TODO

  }

  // File logic
  void newFile() {
    canvas = SketchCanvas();
    notifyListeners();
  }

  Future<bool> saveFile(BuildContext context, {String? name}) async {
    // return await _workingFile.save(context);
    String _name;
    _name = name ?? canvas.fileName ?? "";

    bool saveSuccess = false;

    if (_name == "" || _name == "Untitled") {
      String? fileName = await showFileNameDialog(context);
      if (fileName != null) {
        _name = fileName;
      } else {
        return saveSuccess;
      }
    }
    // Convert strokes to JSON list
    print("STARTING SAVE: ${layers.length} layers");
    print("ACTIVE LAYER: ${layers[0].strokes.length} strokes");
    final List<Map<String, dynamic>> jsonLayers = [
      for (var layer in layers) layer.toJson()
    ];
    print(jsonLayers);
    final String jsonString = jsonEncode({"Layers": jsonLayers});

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
    canvas = SketchCanvas.fromFile(file);
    ui_enabled = true;
    notifyListeners();
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

  void deleteStroke(Stroke s) {
    for (Layer layer in layers) {
      if (layer.strokes.contains(s)) {
        if (layer.strokes.remove(s)) {
            repaint();
        } 
        return;
      }
    }
  }

  // * SELECTION * //
  void selectStroke(Offset touchPoint) {
    print("SELECTING STROKE");
    double maxAllowedDistance =
        10; // The maximum distance allowed to select a stroke in pixels
    // TODO optimize the shit out of this
    for (Layer l in canvas.layers.reversed) {
      for (Stroke stroke in l.strokes) {
        if (stroke.contains(touchPoint,
            maximumAllowedDistance: maxAllowedDistance)) {
          print("SELECTED STROKE");
          _selectedStrokeWidget = getSelectedStrokeWidget(stroke, touchPoint);
          _selectedStroke = stroke;
          notifyListeners();
          return;
        } 
      }
    }
    _selectedStroke = null;
    notifyListeners();
    print("No stroke selected");
  }

  // void setSelectedStroke(Stroke s) {
  //   s.transform(Offset(50, 10));
  //   _selectedStrokeWidget = getSelectedStrokeWidget(s);
  //   notifyListeners();
  // }

  void unSelectStroke() {
    _selectedStrokeWidget = Container();
    notifyListeners();
  }

  Widget? getSelectedStrokeWidget(Stroke s, Offset touchPoint) {
    var child = Stack(
      children: [
      Positioned.fill(child: 
          CustomPaint(
            painter: SelectedStrokePainter(
                s,
            Colors.grey
                .withAlpha(150)), // TODO properly handle the selection color
      ),),
      Positioned(
        left: touchPoint.dx,
        top: touchPoint.dy,
        child: Container( 
           decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(120),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ]
            ),
            child: Row(
              children: [
                IconButton(onPressed: () {
                  deleteStroke(s);
                  unSelectStroke();
                }, icon: const Icon(Icons.delete)),
                ColorSelector((Color color){
                  s.color = color;
                }),
                // WidthSelector()
              ],
            ),)),
      ],
    );
      return child;

  }
}
