// lib/helpers/prefs_helper.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reader_settings_enums.dart';


class PrefsHelper {
  static SharedPreferences? _prefs;
  static const String _hiddenFlagsKey = 'hidden_default_flag_ids';

  static const String _lastDevotionalDateKey = 'last_devotional_date'; 
  static const String _lastDevotionalIndexKey = 'last_devotional_index';

  static const String _readerFontSizeDeltaKey = 'reader_font_size_delta';
  static const String _readerFontFamilyKey = 'reader_font_family';
  static const String _readerThemeModeKey = 'reader_theme_mode';

  static const String _appThemeModeKey = 'app_theme_mode';

  // --- NEW: Keys for TTS Voice Preferences ---
  static const String _ttsSelectedVoiceNameKey = 'tts_selected_voice_name';
  static const String _ttsSelectedVoiceLangCodeKey = 'tts_selected_voice_lang_code';
  // --- END NEW ---


  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    print("SharedPreferences initialized.");
  }

  // --- Get/Set Hidden Flags (existing methods) ---
  static Set<int> getHiddenFlagIds() {
    if (_prefs == null) {
      print("Warning: SharedPreferences not initialized!");
      return {};
    }
    final List<String> idStrings = _prefs!.getStringList(_hiddenFlagsKey) ?? [];
    return idStrings.map((idStr) => int.tryParse(idStr) ?? 0).where((id) => id < 0).toSet();
  }

  static Future<void> hideFlagId(int flagId) async {
    if (_prefs == null || flagId >= 0) return; 
    final Set<int> hiddenIds = getHiddenFlagIds();
    hiddenIds.add(flagId); 
    final List<String> idStrings = hiddenIds.map((id) => id.toString()).toList();
    await _prefs!.setStringList(_hiddenFlagsKey, idStrings);
     print("Hid flag ID: $flagId. Current hidden: $idStrings");
  }

  static Future<void> unhideFlagId(int flagId) async {
     if (_prefs == null || flagId >= 0) return;
     final Set<int> hiddenIds = getHiddenFlagIds();
     hiddenIds.remove(flagId); 
     final List<String> idStrings = hiddenIds.map((id) => id.toString()).toList();
     await _prefs!.setStringList(_hiddenFlagsKey, idStrings);
      print("Unhid flag ID: $flagId. Current hidden: $idStrings");
  }

  static Future<void> clearHiddenFlags() async {
     if (_prefs == null) return;
     await _prefs!.remove(_hiddenFlagsKey);
      print("Cleared all hidden flags.");
  }

  // --- Daily Devotional Tracking (existing methods) ---
  static String? getLastDevotionalDate() {
    if (_prefs == null) return null;
    return _prefs!.getString(_lastDevotionalDateKey);
  }

  static Future<void> setLastDevotionalDate(String date) async {
    if (_prefs == null) return;
    await _prefs!.setString(_lastDevotionalDateKey, date);
  }

  static int getLastDevotionalIndex() {
    if (_prefs == null) return -1; 
    return _prefs!.getInt(_lastDevotionalIndexKey) ?? -1;
  }

  static Future<void> setLastDevotionalIndex(int index) async {
    if (_prefs == null) return;
    await _prefs!.setInt(_lastDevotionalIndexKey, index);
  }

  // --- Reader Settings Methods (existing methods) ---
  static double getReaderFontSizeDelta() {
    if (_prefs == null) return 0.0;
    return _prefs!.getDouble(_readerFontSizeDeltaKey) ?? 0.0; 
  }

  static Future<void> setReaderFontSizeDelta(double delta) async {
    if (_prefs == null) return;
    await _prefs!.setDouble(_readerFontSizeDeltaKey, delta);
  }

  static ReaderFontFamily getReaderFontFamily() {
    if (_prefs == null) return ReaderFontFamily.systemDefault;
    String? fontFamilyName = _prefs!.getString(_readerFontFamilyKey);
    return ReaderFontFamily.values.firstWhere(
      (e) => e.name == fontFamilyName,
      orElse: () => ReaderFontFamily.systemDefault, 
    );
  }

  static Future<void> setReaderFontFamily(ReaderFontFamily fontFamily) async {
    if (_prefs == null) return;
    await _prefs!.setString(_readerFontFamilyKey, fontFamily.name);
  }

  static ReaderThemeMode getReaderThemeMode() {
    if (_prefs == null) return ReaderThemeMode.light;
    String? themeModeName = _prefs!.getString(_readerThemeModeKey);
    return ReaderThemeMode.values.firstWhere(
      (e) => e.name == themeModeName,
      orElse: () => ReaderThemeMode.light, 
    );
  }

  static Future<void> setReaderThemeMode(ReaderThemeMode themeMode) async {
    if (_prefs == null) return;
    await _prefs!.setString(_readerThemeModeKey, themeMode.name);
  }

  // --- App Theme Mode Methods (existing methods) ---
  static Future<String?> getAppThemeMode() async {
    if (_prefs == null) await init(); 
    return _prefs!.getString(_appThemeModeKey);
  }

  static Future<void> setAppThemeMode(String themeModeName) async {
    if (_prefs == null) await init();
    await _prefs!.setString(_appThemeModeKey, themeModeName);
  }

  // --- NEW: TTS Voice Preference Methods ---
  static String? getSelectedVoiceName() {
    if (_prefs == null) return null;
    return _prefs!.getString(_ttsSelectedVoiceNameKey);
  }

  static Future<void> setSelectedVoiceName(String name) async {
    if (_prefs == null) return;
    await _prefs!.setString(_ttsSelectedVoiceNameKey, name);
  }

  static String? getSelectedVoiceLanguageCode() {
    if (_prefs == null) return null;
    return _prefs!.getString(_ttsSelectedVoiceLangCodeKey);
  }

  static Future<void> setSelectedVoiceLanguageCode(String langCode) async {
    if (_prefs == null) return;
    await _prefs!.setString(_ttsSelectedVoiceLangCodeKey, langCode);
  }
  // --- END NEW ---
}
