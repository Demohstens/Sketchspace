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
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                  top: MediaQuery.of(context).size.height * 0.05),
              child: Expanded(
                  child: Column(children: [
                // Toggle Dark Mode
                Center(
                    child: SwitchListTile(
                        title: const Text("Dark Mode"),
                        subtitle: const Text("Toggle dark mode."),
                        value: context.watch<Settings>().darkModeEnabled,
                        onChanged: (bool newValue) {
                          context.read<Settings>().toggleDarkMode();
                        })),
                // Toggle Auto Save
                Center(
                    child: SwitchListTile(
                        title: const Text("Auto save on exit"),
                        subtitle: const Text(
                            "Automatically save your work when you exit the canvas."),
                        value: context.watch<Settings>().autoSaveExistingFiles,
                        onChanged: (bool newValue) {
                          context.read<Settings>().toggleAutoSaveOnExit();
                        })),
                Center(
                    child: ListTile(
                  minVerticalPadding: 50,
                  leading: const Icon(Icons.timer),
                  title: const Text("Draw Cooldown (1h = 100ms, 1s = 1ms)"),
                  subtitle: Text(
                      "Current cooldown: ${context.watch<Settings>().drawCooldown} ms"),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Draw Cooldown"),
                            content: TextField(
                              controller: TextEditingController.fromValue(
                                  TextEditingValue(
                                      text: context
                                          .watch<Settings>()
                                          .drawCooldown
                                          .toString())),
                              onSubmitted: (String value) {
                                if (value == "") {
                                  value = "0";
                                }
                                context
                                    .read<Settings>()
                                    .changeDrawCooldown(int.parse(value) ?? 0);
                              },
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        });
                  },
                )),
              ]))));
    });
  }
}
