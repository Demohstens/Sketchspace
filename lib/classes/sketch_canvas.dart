import 'dart:convert';
import 'dart:io';

import 'package:sketchspace/classes/layer.dart';
import 'package:uuid/uuid.dart';


/// A canvas class that represents a drawing surface with multiple layers.
/// 
/// The SketchCanvas manages:
/// - Canvas dimensions (width and height)
/// - Multiple drawing layers
/// - Active layer selection
/// - File operations (save/load)
/// - Canvas state tracking (dirty state)
/// 
/// Each canvas has a unique ID and can be associated with a file on disk.
/// The canvas maintains a list of [Layer] objects and tracks which layer
/// is currently active for drawing operations.

class SketchCanvas {
  // Canvas properties
  String id; // UUID - used for actual management of the canvas and data storage
  String? fileName; // Name of the file - used for displaying in the UI
  String? filePath; 
  double width; 
  double height;
  List<Layer> _layers;
  
  // Current state
  bool isDirty; // Whether the canvas has been modified since last save
  late Layer _activeLayer; 
  
  // Getters
  Layer get activeLayer => _activeLayer;
  List<Layer> get layers => _layers;

  // Setters 
  set activeLayer(Layer layer) {
    _activeLayer = layer;
    isDirty = true;
  }
  // Constructor
  SketchCanvas({
    this.isDirty = false,
    double? width,
    double? height,
    List<Layer>? layers, 
    String? id,
    String? fileName,
    String? filePath,
  }) :
      id = id?? const Uuid().v4(),
      fileName = fileName?? "",
      _layers = layers ?? [Layer.empty()],
      width = width ??  1080,
      height = height?? 1920 
      {
        _activeLayer = _layers.first ;
      }
  
  factory SketchCanvas.empty(){
    return SketchCanvas();
  }

  factory SketchCanvas.fromFile(File f) {
    return getCanvasFromFile(f);
  }
  // File management
  void save() {
    print("NOT IMPLEMENTED YET");
    isDirty = false;
  }

  void load(String fileId) {
    // Load canvas data from file
  }

  // Layer management 
  Layer addLayer() {
    Layer newLayer = Layer.empty();
    layers.add(newLayer);
    activeLayer = newLayer;
    return newLayer;
  }

  void removeLayer(Layer layer) {
    for (int i = 0; i < layers.length; i++) {
      if (layers[i] == layer) {
        layers.removeAt(i);
        break;
      } 
    }
  }

  void setActiveLayer(Layer layer) {
    activeLayer = layer;
  }

  Map<String, dynamic> toJson() {
    return {
      "name": fileName,
      "width": width,
      "height": height,
      "id": id,
      "Layers": layers.map((layer) => layer.toJson()).toList(),
    };
  }
}

SketchCanvas getCanvasFromFile(File file) {
  try {
    // print('Loading file: ${file.path}');
    // print('File content: ${file.readAsStringSync()}');
    final String content = file.readAsStringSync();
    final Map<String, dynamic> json = jsonDecode(content);
    List<Layer> layersList = [];
    
    if (json.containsKey("Layers") && json["Layers"] is List) {
      final layers = json["Layers"];
      if (layers.isNotEmpty) {
        layersList = [
          for (var layer in layers) Layer.fromJson(layer) 
        ];
      }
    } 
    return SketchCanvas(
      fileName: json["name"],
      filePath: file.path,
      width: json["width"] ?? 1080,
      height: json["height"] ?? 1920,
      layers: layersList,
      id: json["id"] ?? const Uuid().v4(),
    );
  } catch (e) {
    print('Error loading file: ${file.path}, Error: $e');
      return SketchCanvas.empty();
  }
}