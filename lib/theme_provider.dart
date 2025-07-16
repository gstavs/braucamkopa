// lib/theme_provider.dart
import 'package:flutter/material.dart';
// No need for shared_preferences import

class ThemeProvider with ChangeNotifier {
  // No _themeModeKey needed if not persisting
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  // Constructor can be empty if _loadThemeMode is removed
  ThemeProvider() {
    // _loadThemeMode(); // Remove this call
  }

  // _loadThemeMode is removed as there's nothing to load without persistence
  // Future<void> _loadThemeMode() async { ... }

  Future<void> setThemeMode(ThemeMode mode) async { // Can be non-async now
    if (_themeMode == mode) return; // No change needed

    _themeMode = mode;
    notifyListeners();

    // No saving logic needed
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setInt(_themeModeKey, mode.index);
  }

  // isDarkMode logic can remain, as it depends on the current _themeMode
  // and potentially platform brightness, not persistence.
  bool isDarkMode(BuildContext? context) {
    if (_themeMode == ThemeMode.system) {
      if (context != null) {
        return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      }
      // Fallback using platformDispatcher
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void toggleTheme(bool isOn) {
    setThemeMode(isOn ? ThemeMode.dark : ThemeMode.light);
  }
}
