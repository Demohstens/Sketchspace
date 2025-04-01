import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class Settings with ChangeNotifier {
  static const Color mainColor = Color(0xffbb86fc);

  //* ALL SETTINGS *// 
  bool useMobile = true;
  bool autoSave = true;
  bool darkModeEnabled = true;

  set darkMode(bool value) {
    darkModeEnabled = value;
    brightness = darkModeEnabled? Brightness.dark : Brightness.light;
    scheme = ColorScheme.fromSeed(seedColor: mainColor, brightness: brightness);
  }

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

  // Application Settings
  late Directory saveDirectory;

  // Default Settings
  Settings() {
    _populate();
  }

  /// Populate the settings with async data
  void _populate() async {
    brightness =
        darkModeEnabled? Brightness.dark : Brightness.light;
    scheme = ColorScheme.fromSeed(seedColor: mainColor, brightness: brightness);
    _background = colorScheme.surface;
    _primaryColor = colorScheme.primary;
    _secondaryColor = colorScheme.secondary;
    _tertiaryColor = colorScheme.tertiary;
    saveDirectory = await getApplicationDocumentsDirectory();
    notifyListeners();
  }

  ColorScheme get colorScheme => scheme;
  Color get background => _background;
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get tertiaryColor => _tertiaryColor;

  void toggleDarkMode() {
    darkModeEnabled = !darkModeEnabled;
    brightness =
        darkModeEnabled ? Brightness.dark : Brightness.light;
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

  void toggleMobile() {
    useMobile = !useMobile;
    notifyListeners();
  }

  void toggleAutoSave() {
    autoSave = !autoSave;
    notifyListeners();
  }
  int drawCooldown = 75;
  void changeDrawCooldown(int value) {
    drawCooldown = value;
    notifyListeners();
  }

  void update() {
    // Update the settings
    notifyListeners();
  }
}



