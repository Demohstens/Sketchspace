import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application/components/save_file_reminder.dart';
import 'package:flutter_application/stroke_selector/src/classes/stroke.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DrawFile {
  int? _id;
  String? _path;
  String? _name;

  List<Stroke>?
      _content; // Strokes:[{paint: {color: , strokeWidth: }, points: [(x, y), (x, y), ...]}, ...]

  // GETTERS
  int? get id => _id;
  String? get name => _name;
  String? get path => _path;
  List<Stroke>? get content => _content;

  set content(List<Stroke>? strokes) {
    _content = strokes;
  }

  DrawFile(String name, String path, content) {
    _name = name;
    _path = path;
    _content = content;
  }
  DrawFile.empty(name, {path}) {
    _name = name;
    if (path == null) {
      _path = '${appDirectory()}/$name.json';
    } else {
      _path = path;
    }
  }
  DrawFile.fromFile(File file) {
    loadFile(file);
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'name': _name,
  //     'path': _path,
  //     'content': _content,
  //   };
  // }

  List<Stroke> getStrokes() {
    return _content ?? [];
  }

  /// Saves a list of strokes to a file
  Future<bool> save(BuildContext context) async {
    bool success = false;
    if (_content == null) {
      print("No content to save.");
      return success;
    }
    if (_name == null) {
      await showFileNameDialog(context).then((value) {
        if (value != null && value != "") {
          _name = value;
          success = true;
        } else {
          _name = "Untitled";
        }
      });
    }
    // Convert strokes to JSON list
    final List<String> jsonStrokes = [
      for (var stroke in _content!) stroke.toJson()
    ];
    final String jsonString = jsonEncode({"Strokes": jsonStrokes});

    final Directory appDir = await appDirectory();
    final File file = File('${appDir.path}/$_name');

    // Write the JSON string to the file
    await file.writeAsString(jsonString);
    print('Saved file to ${file.path}');
    return success;
  }

  void addStroke(Stroke stroke) {
    _content ??= [];
    _content!.add(stroke);
  }

  void addStrokes(List<Stroke> strokes) {
    _content ??= [];
    _content!.addAll(strokes);
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

/// Loads a file and returns a list of strokes
DrawFile loadFile(File file) {
  try {
    final String content = file.readAsStringSync();
    final Map<String, dynamic> json = jsonDecode(content);
    List<Stroke> strokesList = [];

    if (json.containsKey("Strokes") && json["Strokes"] is List) {
      final strokes = json["Strokes"];
      if (strokes.isNotEmpty) {
        print("Loaded file: ${file.path}");
        strokesList = [
          for (var stroke in strokes) Stroke.fromJson(jsonDecode(stroke))
        ];
        return DrawFile(basename(file.path), file.path, strokesList);
      } else {
        print('File contains no strokes: ${file.path}');
        return DrawFile(basename(file.path), file.path, null);
      }
    } else {
      print('Invalid JSON structure in file: ${file.path}');
    }
  } catch (e) {
    print('Error loading file: ${file.path}, Error: $e');
  }
  return DrawFile.empty(basename(file.path));
}
