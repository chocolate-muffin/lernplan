import 'package:flutter/material.dart';

// Light Theme
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    // You can customize other colorScheme properties here
  ),
  useMaterial3: true,
);

// Dark Theme
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Use non-nullable type
    brightness: Brightness.dark,
    // You can customize other colorScheme properties here
  ),
  useMaterial3: true,
);

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode? newThemeMode) {
    if (newThemeMode != null) {
      _themeMode = newThemeMode;
      notifyListeners(); // Notify listeners when theme changes
    }
  }
}
