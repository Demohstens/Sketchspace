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

class SketchCanvas  {
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
    required this.width,
    required this.height,
    List<Layer>? layers, 
    String? id,
    String? fileName,
    String? filePath,
  }) :
      id = id?? const Uuid().v4(),
      fileName = fileName?? "",
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
    return SketchCanvas(
      width: 1080,
      height: 1920,
    );
  }

  factory SketchCanvas.fromFile(File f) {
    return getCanvasFromFile(f);
  }
  // File management
  void save() {
    print("NOT IMPLEMENTED YET");
    isDirty = false;
  }

  void reinitialize({SketchCanvas? canvas, double? width, double? height, List<Layer>? layers, String? id, String? fileName, String? filePath}) {
    if (canvas != null) {
      this.width = canvas.width;
      this.height = canvas.height;
      _layers = canvas.layers;
      _activeLayer = canvas.activeLayer;
      this.id = canvas.id;
      this.fileName = canvas.fileName;
      this.filePath = canvas.filePath;
      isDirty = canvas.isDirty;
    } else {
      // Create new canvas with given properties or defaul
      this.width = width??  1080;
      this.height = height?? 1920; 
      // Intialize layers
      _layers = {};
      if (layers!= null) {
        _activeLayer = layers[0];
        for (var e in layers) {
          _layers[e.id] = e;
        } 
      }
      else {
        Layer newLayer = Layer.empty(0);
        _layers[newLayer.id] = newLayer;
        _activeLayer = newLayer; 
      }

      this.id = id?? const Uuid().v4();
      this.fileName = fileName?? "";
      this.filePath = filePath?? "";
      isDirty = false;
    }
    print("REINITIALIZED");
  }

  void removeElements(Set<SketchElement> elements) {
    for (var el in elements) {
      deleteElement(el);
    }
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

  void removeLayerById(String layerId) {
    print("Removing layer with id $layerId");
    layers.remove(id);
  }

  void setActiveLayer(Layer layer) {
    activeLayer = layer;
  }
  
  void updateElement(SketchElement el) {
    layers[el.layerId]?.updateElement(el);
  }

  Set<SketchElement> getElementsByIds(Set<String> ids) {
    Set<SketchElement> elements = {};
    for (String id in ids) {
      SketchElement? el = getElementById(id);
      if (el!=null) {
        elements.add(el);
      }
    }    
    return elements;
  }



  SketchElement? getElementById(String? id) {
    // if (id == null) {
    //   return null;
    // }
    for (Layer l in layers.values) {
      SketchElement? el = l.elements[id];
        if (el!=null) {
          return el;
        }
    }
    return null; 
  }

  void deleteElement(SketchElement el) {
    layers[el.layerId]?.elements.remove(el.id);
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

  void reinitializeFromFile(File file) {
    SketchCanvas newCanvas = getCanvasFromFile(file);
    reinitialize(
      width: newCanvas.width,
      height: newCanvas.height,
      layers: newCanvas.layers.values.toList(),
      id: newCanvas.id,
      fileName: newCanvas.fileName,
      filePath: newCanvas.filePath,
    );
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