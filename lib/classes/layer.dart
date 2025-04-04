import 'package:sketchspace/classes/element.dart';
import 'package:sketchspace/classes/elements/image_el.dart';
import 'package:sketchspace/classes/elements/stroke_element.dart';
import 'package:sketchspace/classes/elements/text_element.dart';
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
  Map<String, SketchElement> elements = {};
  bool visible = true;
  bool locked = false;
  late String name;


  Layer(this.index, {String? id, Map<String, SketchElement>? elements, this.name = "Layer", this.visible = true, this.locked = false}) 
    : id = id ?? const Uuid().v4(), elements = elements ?? {};


  void addElement(SketchElement element) {
    print("Adding Element $element");
    elements[element.id] = element;
  }

  factory Layer.empty(int index) {
    return Layer(index);
  }

  void updateElement(SketchElement el) {
    elements[el.id] = el;
  }

  void removeElement(SketchElement el) {
    elements.remove(el.id);
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
      'elements': elements.values.map((e) => e.toJson()).toList(),
      'visible': visible,
      'locked': locked,
      'name': name
    };
  }

  factory Layer.fromJson(Map<String, dynamic> json) {
    Map<String, SketchElement> elementsTemp = {};
    for (var el in (json['elements'] as List)) {
      try {
        switch (el["type"]) {
          case "stroke":
            elementsTemp[el["id"]] = Stroke.fromJson(el);
            break;
          case "image":
            ImageElement iElement = ImageElement.fromJson(el);
            elementsTemp[iElement.id] = iElement;
            iElement.load();
            break; 
          case "text":
            elementsTemp[el["id"]] = TextElement.fromJson(el);
            break;
        }
      } catch (e) {
        print(e); 
      }
    }
    
    return Layer(
      json["zIndex"] ?? 0,
      id: json['id'],
      elements: elementsTemp,
      visible: json['visible'],
      locked: json['locked'],
      name: json['name']
    );
  }
}