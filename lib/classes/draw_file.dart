import 'dart:convert';
import 'dart:io';

import 'package:flutter_application/classes/stroke.dart';
import 'package:path_provider/path_provider.dart';

class DrawFile {
  int? _id;
  String? _name;
  String _path;
  String?
      _content; // Strokes:[{paint: {color: , strokeWidth: }, points: [(x, y), (x, y), ...]}, ...]

  // GETTERS
  int? get id => _id;
  String? get name => _name;
  String get path => _path;
  String? get content => _content;

  DrawFile(name, this._path, String? content) {
    _name = name;
    _content =
        content; //A string representation of the file content. might need to serailize Stroke obj.
  }
  factory DrawFile.fromJson(Map<String, dynamic> json) {
    return DrawFile(json['name'], json['path'], json['content']);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'path': _path,
      'content': _content,
    };
  }

  List<Stroke> getStrokes() {
    return [];
  }
}

Future<Directory> appDirectory() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final appDirectory = Directory('${directory.path}/DemoDraw');
  if (!await appDirectory.exists()) {
    await appDirectory.create();
  }
  return appDirectory;
}

// Returns a list of files in the app directory.
Future<List<File>> getFiles() async {
  List<File> files = [];
  final Directory appDir = await appDirectory();

  appDir.listSync().forEach((element) {
    if (element is File && element.path.endsWith('.json')) {
      files.add(element);
    }
  });
  return files;
}

/// Saves a list of strokes to a file
void saveToFile(String name, List<Stroke> strokes) async {
  if (strokes.isEmpty) {
    return;
  }
  if (name.isEmpty) {
    name = "Untitled";
  }

  // Convert strokes to JSON list
  final List<String> jsonStrokes = [
    for (var stroke in strokes) stroke.toJson()
  ];
  final String jsonString = jsonEncode({"Strokes": jsonStrokes});

  final Directory appDir = await appDirectory();
  final File file = File('${appDir.path}/$name.json');

  // Write the JSON string to the file
  await file.writeAsString(jsonString);
  print('Saved file to ${file.path}');
}

/// Loads a file and returns a list of strokes
List<Stroke> loadFile(File file) {
  try {
    final String content = file.readAsStringSync();
    final Map<String, dynamic> json = jsonDecode(content);

    if (json.containsKey("Strokes") && json["Strokes"] is List) {
      final strokes = json["Strokes"];
      if (strokes.isNotEmpty) {
        print("Loaded file: ${file.path}");
        return [
          for (var stroke in strokes) Stroke.fromJson(jsonDecode(stroke))
        ];
      } else {
        print('File contains no strokes: ${file.path}');
      }
    } else {
      print('Invalid JSON structure in file: ${file.path}');
    }
  } catch (e) {
    print('Error loading file: ${file.path}, Error: $e');
  }
  return [];
}
