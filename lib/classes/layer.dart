import 'package:sketchspace/classes/element.dart';
import 'package:sketchspace/classes/stroke.dart';
import 'package:uuid/uuid.dart';

/// A layer represents a collection of strokes in a drawing canvas.
/// 
/// Each layer can contain multiple strokes and has properties to control its visibility
/// and editing capabilities.
/// 
/// Properties:
/// * [id] - Unique identifier for the layer
/// * [strokes] - List of stroke objects contained in the layer
/// * [visible] - Controls whether the layer is visible in the canvas
/// * [locked] - Controls whether the layer can be edited
/// * [name] - Display name of the layer
/// 
/// The layer supports JSON serialization through [toJson] and [Layer.fromJson] methods
/// for persistence and data transfer.

class Layer {
  String id;
  int index;
  // List<Stroke> strokes;
  Map<String, Stroke> strokes = {};
  bool visible = true;
  bool locked = false;
  late String name;

  Layer(this.index, {String? id, Map<String, Stroke>? strokes, this.name = "Layer", this.visible = true, this.locked = false}) 
    : id = id ?? const Uuid().v4(), strokes = strokes ?? {};
  
  void addStroke(Stroke stroke) {
    strokes[stroke.id] =  stroke;
  }

  factory Layer.empty(int index) {
    return Layer(index);
  }

  void updateStroke(Stroke s) {
    strokes[s.id] = s;
  }

  void removeStroke(Stroke stroke) {
    strokes.remove(stroke.id);
  }

  void toggleVisibilty() {
    visible = !visible;
  }

  void toggleLock() {
    locked = !locked;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'index': index,
      'id': id,
      'strokes': strokes.values.map((e) => e.toJson()).toList(),
      'visible': visible,
      'locked': locked,
      'name': name
    };
  }

  factory Layer.fromJson(Map<String, dynamic> json) {
    Map<String, Stroke> strokesTemp = {};
    for (var el in (json['strokes'] as List)) {
      final stroke = Stroke.fromJson(el);
      strokesTemp[stroke.id] = stroke;
    }
    
    return Layer(
      json["zIndex"] ?? 0,
      id: json['id'],
      strokes: strokesTemp,
      visible: json['visible'],
      locked: json['locked'],
      name: json['name']
    );
  }
}