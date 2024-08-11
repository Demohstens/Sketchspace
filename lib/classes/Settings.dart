import 'package:flutter/material.dart';

class Settings with ChangeNotifier {
  // Theme and Color Settings
  Color background = ColorScheme.dark().surfaceDim;
  Color primaryColor = ColorScheme.dark().primary;
  Color secondaryColor = ColorScheme.dark().secondary;
  Color tertiaryColor = ColorScheme.dark().tertiary;
  ThemeMode themeMode = ThemeMode.system;

  bool get darkModeEnabled => themeMode == ThemeMode.dark;

  void toggleDarkMode() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    Color mainColor = Color(0xffbb86fc);
    Brightness brightness =
        themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light;
    ColorScheme scheme =
        ColorScheme.fromSeed(seedColor: mainColor, brightness: brightness);
    switch (themeMode) {
      case ThemeMode.light:
        scheme = ColorScheme.fromSeed(
            seedColor: mainColor, brightness: Brightness.light);
      case ThemeMode.dark:
        scheme = ColorScheme.fromSeed(
            seedColor: mainColor, brightness: Brightness.dark);
      case ThemeMode.system:
        break;
    }
    background = scheme.surfaceDim;
    primaryColor = scheme.primary;
    secondaryColor = scheme.secondary;
    tertiaryColor = scheme.tertiary;

    notifyListeners();
  }

  bool autoSaveExistingFiles = true;
  bool autoSaveCreatedFiles = false;
}
