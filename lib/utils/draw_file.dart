import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sketchspace/classes/layer.dart';
import 'package:sketchspace/components/file_save_dialogs.dart';

class DrawFile {
  int? _id;
  String? _path;
  String? _name;

  List<Layer>?
      _content; // Strokes:[{paint: {color: , strokeWidth: }, points: [(x, y), (x, y), ...]}, ...]

  // GETTERS
  int? get id => _id;
  String? get name => _name;
  String? get path => _path;
  List<Layer>? get content => _content;

  set content(List<Layer>? layers) {
    _content = layers;
  }

  DrawFile(String name, String path, content) {
    _name = name;
    _path = path;
    _content = content;
  }
  DrawFile.empty(name, {path}) {
    _name = name;
    if (path == null) {
      _path = '${getAppDirectory()}/$name.json';
    } else {
      _path = path;
    }
  }
  DrawFile.fromFile(File file) {
    loadFile(file);
  }
  Image? getThumbnail() {
    // return Image.asset('assets/images/thumbnail.png');
  }



  List<Layer> getLayers() {
    return _content ?? [];
  }

  /// Saves a list of strokes to a file
  Future<bool> save(BuildContext context) async {
    bool success = false;
    if (_content == null) {
      return success;
    }
    if (_name == null) {
      _name = await showFileNameDialog(context);
      if (_name == null) {
        return success;
      }
    }
    // Convert strokes to JSON list
    final List<Map<String, dynamic>> jsonStrokes = [
      for (var stroke in _content!) stroke.toJson()
    ];
    final String jsonString = jsonEncode({"Layers": jsonStrokes});

    final Directory appDir = await getAppDirectory();
    final File file = File('${appDir.path}/$_name');

    // Write the JSON string to the file
    await file.writeAsString(jsonString);
    return success;
  }
}

Future<Directory> getAppDirectory() async {
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
  final Directory appDir = await getAppDirectory();

  appDir.listSync().forEach((element) {
    if (element is File && element.path.endsWith('.json')) {
      files.add(element);
    }
  });
  return files;
}

/// Loads a file and returns a list of strokes
DrawFile? loadFile(File file) {
  try {
    final String content = file.readAsStringSync();
    final Map<String, dynamic> json = jsonDecode(content);
    List<Layer> layersList = [];


    if (json.containsKey("Layers") && json["Layers"] is List) {
      final layers = json["Layers"];
      if (layers.isNotEmpty) {
        layersList = [
          for (var layer in layers) Layer.fromJson(layer) 
        ];
        return DrawFile(basename(file.path), file.path, layersList);
      } else {
        return DrawFile(basename(file.path), file.path, null);
      }
    } else {
      print("Error loading file: $json");
      return null; // Return null if the JSON is invalid or doesn't have the expected format
    }
  } catch (e) {
    print("Error loading file: $e");
    return null;
  }
}
