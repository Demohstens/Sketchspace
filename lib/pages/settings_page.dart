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
            child: Center(
              child: Column(
                children: [
                  // Toggle Dark Mode
                  Row(children: [
                    const Text('Dark Mode'),
                    Switch(
                        value: context.watch<Settings>().darkModeEnabled,
                        onChanged: (bool newValue) {
                          context.read<Settings>().toggleDarkMode();
                        })
                  ])
                ],
              ),
            ),
          ));
    });
  }
}
