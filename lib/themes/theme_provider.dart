import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode theme) {
    _themeMode = theme;
    notifyListeners();
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}