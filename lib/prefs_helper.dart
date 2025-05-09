// lib/prefs_helper.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'models/reader_settings_enums.dart';


class PrefsHelper {
  static SharedPreferences? _prefs;
  static const String _hiddenFlagsKey = 'hidden_default_flag_ids';

  static const String _lastDevotionalDateKey = 'last_devotional_date'; // Stores YYYY-MM-DD
  static const String _lastDevotionalIndexKey = 'last_devotional_index';

  // --- Reader Settings Keys ---
  static const String _readerFontSizeDeltaKey = 'reader_font_size_delta';
  static const String _readerFontFamilyKey = 'reader_font_family';
  static const String _readerThemeModeKey = 'reader_theme_mode';

  // Call this method in main.dart before runApp
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    print("SharedPreferences initialized.");
  }

  // Get the set of hidden default flag IDs (negative integers)
  static Set<int> getHiddenFlagIds() {
    if (_prefs == null) {
      print("Warning: SharedPreferences not initialized!");
      return {};
    }
    final List<String> idStrings = _prefs!.getStringList(_hiddenFlagsKey) ?? [];
    // Convert string IDs back to negative integers
    return idStrings.map((idStr) => int.tryParse(idStr) ?? 0).where((id) => id < 0).toSet();
  }

  // Hide a default flag ID (add its negative ID string to the list)
  static Future<void> hideFlagId(int flagId) async {
    if (_prefs == null || flagId >= 0) return; // Only hide pre-built (negative) IDs
    final Set<int> hiddenIds = getHiddenFlagIds();
    hiddenIds.add(flagId); // Add the new ID
    final List<String> idStrings = hiddenIds.map((id) => id.toString()).toList();
    await _prefs!.setStringList(_hiddenFlagsKey, idStrings);
     print("Hid flag ID: $flagId. Current hidden: $idStrings");
  }

  // Unhide a default flag ID (remove its negative ID string from the list)
  // Useful for a future "Restore Defaults" feature
  static Future<void> unhideFlagId(int flagId) async {
     if (_prefs == null || flagId >= 0) return;
     final Set<int> hiddenIds = getHiddenFlagIds();
     hiddenIds.remove(flagId); // Remove the ID
     final List<String> idStrings = hiddenIds.map((id) => id.toString()).toList();
     await _prefs!.setStringList(_hiddenFlagsKey, idStrings);
      print("Unhid flag ID: $flagId. Current hidden: $idStrings");
  }

  // Optional: Clear all hidden flags (for restoring all defaults)
  static Future<void> clearHiddenFlags() async {
     if (_prefs == null) return;
     await _prefs!.remove(_hiddenFlagsKey);
      print("Cleared all hidden flags.");
  }

  // --- Methods for Daily Devotional Tracking ---
  static String? getLastDevotionalDate() {
    if (_prefs == null) return null;
    return _prefs!.getString(_lastDevotionalDateKey);
  }

  static Future<void> setLastDevotionalDate(String date) async {
    if (_prefs == null) return;
    await _prefs!.setString(_lastDevotionalDateKey, date);
  }

  static int getLastDevotionalIndex() {
    if (_prefs == null) return -1; // Return -1 if not found, so next is 0
    return _prefs!.getInt(_lastDevotionalIndexKey) ?? -1;
  }

  static Future<void> setLastDevotionalIndex(int index) async {
    if (_prefs == null) return;
    await _prefs!.setInt(_lastDevotionalIndexKey, index);
  }

  // --- Reader Settings Methods ---

  // Font Size Delta (how much to add/subtract from base size)
  static double getReaderFontSizeDelta() {
    if (_prefs == null) return 0.0;
    return _prefs!.getDouble(_readerFontSizeDeltaKey) ?? 0.0; // Default to 0.0 (no change)
  }

  static Future<void> setReaderFontSizeDelta(double delta) async {
    if (_prefs == null) return;
    await _prefs!.setDouble(_readerFontSizeDeltaKey, delta);
  }

  // Font Family
  static ReaderFontFamily getReaderFontFamily() {
    if (_prefs == null) return ReaderFontFamily.systemDefault;
    String? fontFamilyName = _prefs!.getString(_readerFontFamilyKey);
    return ReaderFontFamily.values.firstWhere(
      (e) => e.name == fontFamilyName,
      orElse: () => ReaderFontFamily.systemDefault, // Default if not found or null
    );
  }

  static Future<void> setReaderFontFamily(ReaderFontFamily fontFamily) async {
    if (_prefs == null) return;
    await _prefs!.setString(_readerFontFamilyKey, fontFamily.name);
  }

  // Reader Theme Mode
  static ReaderThemeMode getReaderThemeMode() {
    if (_prefs == null) return ReaderThemeMode.light;
    String? themeModeName = _prefs!.getString(_readerThemeModeKey);
    return ReaderThemeMode.values.firstWhere(
      (e) => e.name == themeModeName,
      orElse: () => ReaderThemeMode.light, // Default to light if not found or null
    );
  }

  static Future<void> setReaderThemeMode(ReaderThemeMode themeMode) async {
    if (_prefs == null) return;
    await _prefs!.setString(_readerThemeModeKey, themeMode.name);
  }

}