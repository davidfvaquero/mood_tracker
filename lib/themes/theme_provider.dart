import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeNotifier() {
    _loadInitialTheme();
  }

  Future<void> _loadInitialTheme() async {
    await loadThemePrefs();
  }

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode theme) {
    _themeMode = theme;
    saveThemePrefs(); // Guardar inmediatamente
    notifyListeners();
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    saveThemePrefs(); // Guardar inmediatamente
    notifyListeners();
  }

  Future<void> loadThemePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode =
        prefs.getBool('darkMode') ?? true ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> saveThemePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _themeMode == ThemeMode.dark);
  }
}
