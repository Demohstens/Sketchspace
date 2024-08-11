import 'package:flutter/material.dart';

class Settings with ChangeNotifier {
  static const Color mainColor = Color(0xffbb86fc);

  // Theme and Color Settings
  ThemeMode themeMode = ThemeMode.system;
  Brightness brightness =
      ThemeMode.system == ThemeMode.dark ? Brightness.dark : Brightness.light;
  ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: mainColor,
      brightness: ThemeMode.system == ThemeMode.dark
          ? Brightness.dark
          : Brightness.light);
  late Color _background;
  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _tertiaryColor;

  Settings() {
    themeMode = ThemeMode.system;
    _background = colorScheme.surface;
    _primaryColor = colorScheme.primary;
    _secondaryColor = colorScheme.secondary;
    _tertiaryColor = colorScheme.tertiary;
  }

  bool get darkModeEnabled => themeMode == ThemeMode.dark;
  ColorScheme get colorScheme => scheme;
  Color get background => _background;
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get tertiaryColor => _tertiaryColor;

  void toggleDarkMode() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    brightness =
        themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light;
    scheme = ColorScheme.fromSeed(seedColor: mainColor, brightness: brightness);

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
    _background = scheme.surface;
    _primaryColor = scheme.primary;
    _secondaryColor = scheme.secondary;
    _tertiaryColor = scheme.tertiary;

    notifyListeners();
  }

  bool autoSaveExistingFiles = true;
  bool autoSaveCreatedFiles = false;
}
