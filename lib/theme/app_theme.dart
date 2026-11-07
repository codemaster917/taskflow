import 'package:flutter/material.dart';
import '../models/task.dart';

class AppTheme {
  // The main color of our app (indigo / blue-purple).
  // Flutter makes a full set of matching colors from this one color.
  static const Color seedColor = Color(0xFF4F46E5);

  // ---------- LIGHT THEME ----------
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true, // use the modern Material 3 design
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F6FA), // light grey background
  );

  // ---------- DARK THEME ----------
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212), // almost black
  );

  // ---------- PRIORITY COLORS ----------
  // Each priority gets its own color: green, orange or red.
  static Color priorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
    }
  }

  // Each priority also has a nice text name.
  static String priorityLabel(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }
}