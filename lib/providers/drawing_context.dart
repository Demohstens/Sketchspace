import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';
import 'package:sketchspace/classes/element.dart';
import 'package:sketchspace/classes/elements/image_el.dart';
import 'package:sketchspace/classes/path.dart';
import 'package:sketchspace/classes/sketch_canvas.dart';
import 'package:sketchspace/tools/tools.dart';
import 'package:sketchspace/utils/draw_file.dart';
import 'package:sketchspace/classes/layer.dart';
import 'package:sketchspace/components/file_save_dialogs.dart';
import 'package:flutter/material.dart';

enum Mode { drawing, lifted, erasing, strokeErasing, line, fill }

/// Everything the active painter needs to draw on the canvas
/// Also includes everything the
class DrawingContext with ChangeNotifier {
  // * ATTRIBUTES * //
  List<Offset> _points = [];
  // Populated with default colors
  List<Color> colorHistory = [Colors.red, Colors.green, Colors.blue, Colors.black];
  Tool _tool = Tool.mouse;
  String? _selectedElementId;
  SketchCanvas canvas;
  ValueNotifier<bool> repaintNotifier = ValueNotifier(false);

  DrawingContext() : canvas = SketchCanvas();

  // * Paint Attributes * //
  Color _color = Colors.orange;
  double _width = 10.0;

  bool ui_enabled = true;

  // * GETTERS & SETTERS * //
  set selecedStrokeId(String? id) {
    _selectedElementId = id;
    notifyListeners();
  }

  // GETTERS
  Color get color => _color;
  String? get selectedElementId => _selectedElementId;
  Tool get tool => _tool;
  List<Offset> get points => _points;
  double get strokeWidth => _width;
  // * LAYERS * //
  Layer get activeLayer => canvas.activeLayer;
  
  @override
  void notifyListeners() {
    repaintNotifier.value = !repaintNotifier.value;
    super.notifyListeners();
  }

  // Drawing logic
  void setTool(Tool tool) {
    _tool = tool;
    notifyListeners();
  }

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

  void addImported(XFile file) {
    try {
      File(file.path).readAsBytes()
        .then((bytes) => ui.instantiateImageCodec(bytes))
        .then((codec) => codec.getNextFrame())
        .then((frame) => frame.image)
        .then((image) {
          SketchElement element = ImageElement(
            path: file.path,
            image: image,
            layerId: activeLayer.id,
            position: Offset(50, 200));
          print(element);  
          activeLayer.addElement(element);
          notifyListeners();    
        });
          
    }
    catch(e)  {
      print("File is not an image${e}");
    }
    notifyListeners();
  }

  void newLayer() {
    // Id is equal to the length of the list as the first layer is 0
    canvas.addLayer();
    notifyListeners();
  }

  void changeActiveLayer(Layer layer) {
    print("Changed active layer to ${layer.id}");
    canvas.activeLayer = canvas.layers[layer.id] ?? layer;
    notifyListeners();
  }

  void deleteLayer(Layer layer) {
    canvas.layers.remove(layer);
    notifyListeners();
  }

  void pushCanvas(SketchCanvas canvas) {
    this.canvas = canvas;
    notifyListeners();
  }

  void endDrawing() {
    if (_points.isNotEmpty) {
      // Create a copy of the points before clearing
      List<Offset> pointsCopy = List.from(_points);
      _points.clear();
      var paint = getPaint();
      // Only add the stroke if there are enough points
      if (pointsCopy.length >= 2) {
        canvas.activeLayer.addElement(Stroke(paint: paint, path: SketchPath(pointsCopy), layerId: activeLayer.id));
      }
      if (!colorHistory.contains(paint.color)) {
      // Ensure a max size of 4 in the color history
        if (colorHistory.length >= 4) {
          colorHistory.removeAt(0);
        }
        colorHistory.add(paint.color);
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

  /// Attempts to save the current canvas to the given path
  /// Returns true if the file was saved successfully 
  Future<bool> saveFile(BuildContext context) async {
    String _name = canvas.fileName ?? "";
    bool saveSuccess = false;
    
    print("SAVING FILE: $_name");
    if (_name == "" || _name == "Untitled") {
      String? fileName = await showFileNameDialog(context);
      if (fileName != null && fileName != "") {
        canvas.fileName = fileName;
      } else {
        return saveSuccess;
      }
    }
    
    try {
      // First validate the canvas data
      bool isValid = canvas.validate();
      if (!isValid) {
        throw Exception("Canvas contains invalid data (NaN values)");
      }

      // Convert strokes to JSON list
      Map<String, dynamic> jsonData = canvas.toJson();
      final String jsonString = jsonEncode(jsonData);

      final Directory appDir = await getAppDirectory();
      String filePath = '${appDir.path}/${canvas.fileName}.json';
      
      File file = File(filePath);
      await file.writeAsString(jsonString);
      saveSuccess = true;
      print("File saved successfully to: $filePath");
    } catch (e) {
      print("Error saving file: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error Saving File"),
          content: Text("An error occurred while saving the file: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
    
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
        return PaintingStyle.stroke;
  }

  BlendMode _getBlendMode() {
    return BlendMode.srcOver;
    
  }

  void changeColor(Color color) {
    _color = color;
    notifyListeners();
  }

  void exit() {
    return;
  }

  void deleteElement(SketchElement el) {
    canvas.deleteElement(el);
  }

  // * SELECTION * //
  void selectElement(Offset touchPoint) {
    // TODO optimize the shit out of this
    for (Layer l in canvas.layers.values.toList().reversed) {
      for (SketchElement el in l.elements.values) {
        if (el.hitTest(touchPoint)) {
          _selectedElementId = el.id;
          notifyListeners();
          return;
        } 
      }
    }
    _selectedElementId = null;
    notifyListeners();
  }

  void unSelectStroke() {
    _selectedElementId = null;
    notifyListeners();
  }

}

