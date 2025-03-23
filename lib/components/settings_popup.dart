import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/canvas/Actions.dart';
import 'package:sketchspace/canvas/canvas_context.dart';

class SettingsPopup extends StatelessWidget {
  const SettingsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Settings', style: TextStyle(color: Colors.white, decoration: TextDecoration.none), ),
            TextButton(
              onPressed: () {
                context.read<DrawingContext>().resetDrawing();
                Navigator.pop(context);
                // Actions.invoke(context, ResetIntent());
              },
              child: const Text("Reset canvas"),
            ),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.blue),
                ),
                child: const Text("Resume"),
            ),
            ]);
  }
}