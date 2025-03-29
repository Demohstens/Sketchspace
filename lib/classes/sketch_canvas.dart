import 'dart:convert';
import 'dart:io';

import 'package:sketchspace/classes/element.dart';
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
  Map<String, Layer> _layers;
  
  // Current state
  bool isDirty; // Whether the canvas has been modified since last save
  late Layer _activeLayer; 
  
  // Getters
  Layer get activeLayer => _activeLayer;
  Map<String, Layer> get layers => _layers;

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
      width = width ??  1080,
      height = height?? 1920,
      _layers = {}
      {
        if (layers != null) {
          _activeLayer = layers[0];
          layers.forEach((e) {
            _layers[e.id] = e;
          });
        } else {
          Layer newLayer = Layer.empty(0);
          _layers[newLayer.id] = newLayer;
          _activeLayer = newLayer;
        }
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

  bool validate() {
    // Validate canvas has required properties
    if (width <= 0 || height <= 0) {
      return false;
    }
    
    // Validate canvas has at least one layer
    if (_layers.isEmpty) {
      return false;
    }
    
    // Validate active layer exists and is in layers map
    if (!_layers.containsKey(_activeLayer.id)) {
      return false;
    }
    
    // Validate all layers have valid data
    // for (var layer in _layers.values) {
    //   if (!layer.validate()) {
    //     return false;
    //   }
    // }
    
    return true;
  }

  void load(String fileId) {
    // Load canvas data from file
  }

  // Layer management 
  Layer addLayer() {
    Layer newLayer = Layer.empty(layers.length);
    layers[newLayer.id] = newLayer;
    activeLayer = newLayer;
    return newLayer;
  }

  void removeLayer(Layer layer) {
    layers.remove(layer.id);
  }

  void setActiveLayer(Layer layer) {
    activeLayer = layer;
  }

  void updateStroke(Stroke s) {
    layers[s.layerId]?.updateStroke(s);
  }

  Stroke? getStrokeById(String? id) {
    // if (id == null) {
    //   return null;
    // }
    for (Layer l in layers.values) {
      Stroke? s = l.strokes[id];
        if (s!=null) {
          return s;
        }
    }
    return null; 
  }

  void deleteStroke(Stroke s) {
    layers[s.layerId]?.strokes.remove(s.id);
  }
  // Serialization

  Map<String, dynamic> toJson() {
    return {
      "name": fileName,
      "width": width,
      "height": height,
      "id": id,
      "Layers": layers.values.map((layer) => layer.toJson()).toList(),
    };
  }
}

SketchCanvas getCanvasFromFile(File file) {
  try {
    final String content = file.readAsStringSync();
    final Map<String, dynamic> json = jsonDecode(content);
    Map<String, Layer> layersMap = {};
    
    if (json.containsKey("Layers") && json["Layers"] is List) {
      final layers = json["Layers"];
      if (layers.isNotEmpty) {
        for (var layer in layers) {
          Layer newLayer = Layer.fromJson(layer);
          layersMap[newLayer.id] = newLayer;
        }
      }
    } 

    // Convert map to list for constructor
    List<Layer> layersList = layersMap.values.toList();
    
    return SketchCanvas(
      fileName: json["name"],
      filePath: file.path,
      width: json["width"] ?? 1080,
      height: json["height"] ?? 1920,
      layers: layersList.isNotEmpty ? layersList : null,
      id: json["id"] ?? const Uuid().v4(),
    );
  } catch (e) {
    print('Error loading file: ${file.path}, Error: $e');
    return SketchCanvas.empty();
  }
}