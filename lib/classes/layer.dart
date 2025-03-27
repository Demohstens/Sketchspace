import 'package:sketchspace/classes/stroke.dart';
import 'package:uuid/uuid.dart';

class Layer {
  String id;
  List<Stroke> strokes;
  bool visible = true;
  bool locked = false;
  late String name;

  Layer({String? id, required this.strokes, this.name = "Layer", this.visible = true, this.locked = false}) 
    : id = id ?? const Uuid().v4();
  void addStroke(Stroke stroke) {
    strokes.add(stroke);
  }

  factory Layer.empty() {
    return Layer(strokes: []);
  }

  void removeStroke(Stroke stroke) {
    strokes.remove(stroke);
  }

  void toggleVisibilty() {
    visible = !visible;
  }

  void toggleLock() {
    locked = !locked;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'strokes': strokes.map((e) => e.toJson()).toList(),
      'visible': visible,
      'locked': locked,
      'name': name
    };
  }

  factory Layer.fromJson(Map<String, dynamic> json) {
    return Layer(
      id: json['id'],
      strokes: json['strokes'].map<Stroke>((e) => Stroke.fromJson(e)).toList(),
      visible: json['visible'],
      locked: json['locked'],
      name: json['name']
    );
  }
}