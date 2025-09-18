import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  
  Locale? _locale;
  
  Locale? get locale => _locale;

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('es', ''), // Spanish
  ];

  /// Get locale display names
  static const Map<String, String> localeNames = {
    'en': 'English',
    'es': 'Español',
  };

  /// Initialize locale from stored preference or device locale
  Future<void> initializeLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLocaleCode = prefs.getString(_localeKey);
    
    if (storedLocaleCode != null) {
      // Use stored locale preference
      _locale = Locale(storedLocaleCode);
    } else {
      // Use device locale if supported, otherwise default to English
      final deviceLocale = PlatformDispatcher.instance.locale;
      
      if (supportedLocales.any((locale) => locale.languageCode == deviceLocale.languageCode)) {
        _locale = Locale(deviceLocale.languageCode);
        // Save the auto-detected locale
        await _saveLocale(deviceLocale.languageCode);
      } else {
        // Default to English if device locale is not supported
        _locale = const Locale('en');
        await _saveLocale('en');
      }
    }
    
    notifyListeners();
  }

  /// Change locale and persist the choice
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    
    _locale = locale;
    await _saveLocale(locale.languageCode);
    notifyListeners();
  }

  /// Set locale to system default (auto-detect)
  Future<void> setSystemLocale() async {
    final deviceLocale = PlatformDispatcher.instance.locale;
    
    if (supportedLocales.any((locale) => locale.languageCode == deviceLocale.languageCode)) {
      _locale = Locale(deviceLocale.languageCode);
    } else {
      _locale = const Locale('en'); // Fallback to English
    }
    
    // Clear stored preference to use system locale
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localeKey);
    
    notifyListeners();
  }

  /// Save locale preference
  Future<void> _saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
  }

  /// Check if a specific locale is currently selected
  bool isLocaleSelected(Locale locale) {
    return _locale?.languageCode == locale.languageCode;
  }

  /// Get the display name for current locale
  String get currentLocaleName {
    return localeNames[_locale?.languageCode] ?? 'English';
  }

  /// Check if using system default (no stored preference)
  Future<bool> get isUsingSystemDefault async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey(_localeKey);
  }

  /// Get device locale language code
  String get deviceLanguageCode {
    return PlatformDispatcher.instance.locale.languageCode;
  }

  /// Check if device locale is supported
  bool get isDeviceLocaleSupported {
    return supportedLocales.any(
      (locale) => locale.languageCode == deviceLanguageCode,
    );
  }
}