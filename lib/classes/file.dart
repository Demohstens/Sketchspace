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
void saveFile(String name, List<Stroke> strokes) async {
  final String content =
      [for (var stroke in strokes) stroke.toJson()].toString();
  final Directory appDir = await appDirectory();
  final File file = File('${appDir.path}/$name.json');
  file.writeAsString(content);
  print('Saved file to ${file.path}');
}
