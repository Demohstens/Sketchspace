import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketchspace/classes/settings.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, Settings settings, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings - Sketchspace'),
        ),
        body: Container(
            child: Column(children: [
          // Toggle Dark Mode
          Center(
              child: SwitchListTile(
                  title: const Text("Dark Mode"),
                  value: context.watch<Settings>().darkModeEnabled,
                  onChanged: (bool newValue) {
                    context.read<Settings>().toggleDarkMode();
                  })),
        ])),
      );
    });
  }
}
