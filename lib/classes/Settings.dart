import 'package:flutter/material.dart';

class Settings with ChangeNotifier {
  Color background = Colors.white;
  bool autoSaveExistingFiles = true;
  bool autoSaveCreatedFiles = false;

  bool get darkModeEnabled => background == Colors.black;

  void toggleDarkMode() {
    background = background == Colors.white ? Colors.black : Colors.white;
    notifyListeners();
  }
}
