import 'package:flutter/material.dart';

Future<String?> showFileNameDialog(BuildContext context) async {
  String? input = '';
  return showDialog<String?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Save File'),
        content: TextField(
          onChanged: (value) {
            if (value != "") {
              input = value;
            } else {
              input = null;
            }
          },
          decoration: const InputDecoration(hintText: 'Enter file name'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, input),
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}

// Future<String?> showFileSaveOnExitDialog(BuildContext context) async 