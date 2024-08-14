import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sketchspace/canvas/canvas_context.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/classes/draw_file.dart';
import 'package:sketchspace/pages/homepage.dart';
import 'package:path/path.dart' as path;

Future<String?> showFileNameDialog(BuildContext context) async {
  final Completer<String?> completer = Completer<String?>();
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return FileSaveDialog(
            saveCallback: (textInput) {
              completer.complete(textInput);
            },
            exitCallback: context.read<DrawingContext>().exit);
      });
  return await completer.future;
}

// Future<String?> showFileSaveOnExitDialog(BuildContext context) async
// uses a regexp to validate the input
bool validateFileName(String input) {
  return RegExp("^[^~)('!*<>:;,?\"*|/]+\$").hasMatch(input);
}

class FileSaveDialog extends StatefulWidget {
  /// Function to be called when the user saves a file with valid name.
  final Function saveCallback; // saveCallback(String fileName) {};
  final Function exitCallback;
  FileSaveDialog({required this.saveCallback, required this.exitCallback});
  @override
  _FileSaveDialogState createState() => _FileSaveDialogState();
}

class _FileSaveDialogState extends State<FileSaveDialog> {
  String? input;
  final fileSavingError = 'Invalid file name.';
  bool invalidFileName = false;

  void validateFileNameCallback(String value) {
    if (validateFileName(value)) {
      setState(() {
        input = value;

        invalidFileName = false;
      });
    } else {
      setState(() {
        invalidFileName = true;
      });
    }
  }

  void save() {
    if (input != null) {
      Navigator.pop(context, input!);
      widget.saveCallback(input!);
    } else {
      setState(() {
        invalidFileName = true;
      });
    }
  }

  void cancel() {
    Navigator.pop(context);
  }

  void exitWithoutSaving() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
    widget.exitCallback();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save File'),
      content: Container(
        constraints: const BoxConstraints(maxHeight: 100),
        child: Column(
          children: [
            TextField(
              canRequestFocus: true,
              autofocus: true,
              onSubmitted: (value) {
                validateFileNameCallback(value);
                if (!invalidFileName) {
                  save();
                }
              },
              onChanged: (value) {
                validateFileNameCallback(value);
              },
              decoration: const InputDecoration(hintText: 'Enter file name'),
            ),
            Text(invalidFileName ? fileSavingError : ''),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: cancel,
          child: const Text('Cancel'),
        ),
        TextButton(
            onPressed: exitWithoutSaving,
            child: const Text('Exit without saving')),
        TextButton(
          onPressed: save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

Future<File> showFileRenameDialog(BuildContext context, File file) async {
  final Completer<String?> completer = Completer<String?>();
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return FileRenameDialog(
            renameCallback: (textInput) {
              completer.complete(textInput);
            },
            oldFileName: path.basenameWithoutExtension(file.path));
      });
  String? newFileName = await completer.future;
  // Await the result of getAppDirectory() to get the actual directory path
  final appDirectory = await getAppDirectory();

  return file.renameSync(path.join(
      appDirectory.path, '${newFileName ?? "DebugRenameError"}.json'));
}

class FileRenameDialog extends StatefulWidget {
  /// Function to be called when the user saves a file with valid name.
  final Function renameCallback; // saveCallback(String fileName) {};
  final String oldFileName;
  FileRenameDialog({required this.renameCallback, required this.oldFileName});
  @override
  _FileRenameDialogState createState() => _FileRenameDialogState(
      renameCallback: renameCallback, oldFileName: oldFileName);
}

class _FileRenameDialogState extends State<FileRenameDialog> {
  _FileRenameDialogState(
      {required this.renameCallback, required this.oldFileName});
  String? input;
  final String oldFileName;
  final fileRenameError = 'Invalid file name.';
  bool invalidFileName = false;
  final Function renameCallback;

  void validateFileNameCallback(String value) {
    if (validateFileName(value)) {
      setState(() {
        input = value;

        invalidFileName = false;
      });
    } else {
      setState(() {
        invalidFileName = true;
      });
    }
  }

  void rename() {
    if (input != null) {
      Navigator.pop(context, input!);
      widget.renameCallback(input!);
    } else {
      setState(() {
        invalidFileName = true;
      });
    }
  }

  void cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename File'),
      content: Container(
        constraints: const BoxConstraints(maxHeight: 100),
        child: Column(
          children: [
            TextField(
              undoController: UndoHistoryController(),
              // controller: TextEditingController.fromValue(TextEditingValue(
              //     text: oldFileName,
              //     selection: TextSelection(
              //         baseOffset: 0, extentOffset: oldFileName.length))),
              scribbleEnabled: true,
              canRequestFocus: true,
              autofocus: true,
              onSubmitted: (value) {
                validateFileNameCallback(value);
                if (!invalidFileName) {
                  rename();
                }
              },
              onChanged: (value) {
                validateFileNameCallback(value);
              },
              decoration: const InputDecoration(hintText: 'Enter file name'),
            ),
            Text(invalidFileName ? fileRenameError : ''),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: cancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: rename,
          child: const Text('Rename'),
        ),
      ],
    );
  }
}
