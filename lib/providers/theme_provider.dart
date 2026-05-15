import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  ThemeProvider(this._prefs);

  bool get isDarkMode => _prefs.getBool('dark_mode') ?? false;
  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    await _prefs.setBool('dark_mode', !isDarkMode);
    notifyListeners();
  }
}
