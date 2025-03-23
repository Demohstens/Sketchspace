import 'package:sketchspace/classes/stroke.dart';

class Layer {
  int id;
  List<Stroke> strokes;
  bool visible = true;
  bool locked = false;
  late String name;

  Layer({required this.id, required this.strokes, this.name = "Layer", this.visible = true, this.locked = false}) {
    name = '$name $id';
  } 
  
  void addStroke(Stroke stroke) {
    strokes.add(stroke);
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
    print(this.strokes);

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