import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/canvas/Actions.dart';
import 'package:sketchspace/canvas/canvas_context.dart';

class SettingsPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Settings', style: TextStyle(color: Colors.white, decoration: TextDecoration.none), ),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Resume"),
          ),
          TextButton(
            onPressed: () {
              Actions.invoke(context, ResetIntent());
            },
            child: Text("Reset canvas"),
          ),
          ]);
  }
}