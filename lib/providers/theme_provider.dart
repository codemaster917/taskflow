import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false; // false = light mode, true = dark mode

  bool get isDark => _isDark;

  // MaterialApp needs a ThemeMode, so we convert true/false to it.
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  // Constructor: load the saved theme when the app starts.
  ThemeProvider() {
    _loadTheme();
  }

  // Read the saved choice from the browser.
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? false; // if nothing saved, use light
    notifyListeners();
  }

  // Switch between light and dark, then save the choice.
  Future<void> toggleTheme() async {
    _isDark = !_isDark; // ! means "the opposite"
    notifyListeners(); // update the screens right away
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
  }
}