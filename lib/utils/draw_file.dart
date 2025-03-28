import 'dart:io';
import 'package:path_provider/path_provider.dart';


Future<Directory> getAppDirectory() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final appDirectory = Directory('${directory.path}${Platform.pathSeparator}sketches');
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


