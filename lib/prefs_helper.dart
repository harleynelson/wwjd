// lib/prefs_helper.dart
import 'package:shared_preferences/shared_preferences.dart';

class PrefsHelper {
  static SharedPreferences? _prefs;
  static const String _hiddenFlagsKey = 'hidden_default_flag_ids';

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
}