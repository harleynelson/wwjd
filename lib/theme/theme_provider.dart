// lib/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:wwjd_app/helpers/prefs_helper.dart'; // Your PrefsHelper

enum AppThemeMode { system, light, dark }

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system

  ThemeProvider() {
    _loadThemePreference();
  }

  ThemeMode get themeMode => _themeMode;
  AppThemeMode get appThemeMode { // Helper to map ThemeMode to our enum for saving
    if (_themeMode == ThemeMode.light) return AppThemeMode.light;
    if (_themeMode == ThemeMode.dark) return AppThemeMode.dark;
    return AppThemeMode.system;
  }


  Future<void> _loadThemePreference() async {
    String? savedTheme = await PrefsHelper.getAppThemeMode(); // New method in PrefsHelper
    if (savedTheme == AppThemeMode.light.name) {
      _themeMode = ThemeMode.light;
    } else if (savedTheme == AppThemeMode.dark.name) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      AppThemeMode modeToSave;
      if (mode == ThemeMode.light) {
        modeToSave = AppThemeMode.light;
      } else if (mode == ThemeMode.dark) {
        modeToSave = AppThemeMode.dark;
      } else {
        modeToSave = AppThemeMode.system;
      }
      await PrefsHelper.setAppThemeMode(modeToSave.name); // New method in PrefsHelper
      notifyListeners();
    }
  }

  // Helper to toggle between light and dark, ignoring system for direct toggle
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light || (_themeMode == ThemeMode.system && WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.light)) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
}