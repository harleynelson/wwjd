// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wwjd_app/helpers/database_helper.dart';
import 'package:wwjd_app/helpers/prefs_helper.dart';
import 'package:wwjd_app/models/reader_settings_enums.dart';
import '../helpers/daily_devotions.dart'; // For forceNextDevotional if it's still here
import '../theme/theme_provider.dart';
import '../services/text_to_speech_service.dart'; 
import '../config/tts_voices.dart'; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper(); // For dev options
  bool _devOptionsEnabled = false;
  int _devTapCount = 0;

  // Reader Appearance Settings
  double _fontSizeDelta = 0.0;
  ReaderFontFamily _selectedFontFamily = ReaderFontFamily.systemDefault;
  ReaderThemeMode _selectedReaderTheme = ReaderThemeMode.light;
  
  bool _isLoadingSettings = true; // General loading flag for the screen

  // TTS Service and Voice List
  final TextToSpeechService _ttsService = TextToSpeechService();
  List<AppTtsVoice> _availableAppTtsVoices = [];

  static const double _baseReaderFontSize = 18.0; // Base size for reader font

  @override
  void initState() {
    super.initState();
    _loadScreenSettings();
  }

  Future<void> _loadScreenSettings() async {
    if (mounted) {
      setState(() {
        _isLoadingSettings = true;
      });
    }

    // Ensure PrefsHelper is initialized (idempotent call)
    await PrefsHelper.init();

    // Explicitly initialize TTS Service and wait for it to load its own prefs
    await _ttsService.ensureInitialized(); 

    // Load reader appearance settings synchronously from PrefsHelper
    _fontSizeDelta = PrefsHelper.getReaderFontSizeDelta();
    _selectedFontFamily = PrefsHelper.getReaderFontFamily();
    _selectedReaderTheme = PrefsHelper.getReaderThemeMode();

    // Get the curated list of voices (this is synchronous)
    _availableAppTtsVoices = _ttsService.getCuratedAppVoices();
    
    // The selected voice for the dropdown will be taken from _ttsService.selectedAppVoiceNotifier
    // via a ValueListenableBuilder in the build method.
    // _ttsService.ensureInitialized() should have already loaded the preferred voice.

    if (mounted) {
      setState(() {
        _isLoadingSettings = false;
      });
    }
  }

  TextStyle _getTextStyleForFontFamilyPreview(ReaderFontFamily family, BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    switch (family) {
      case ReaderFontFamily.serif:
        return GoogleFonts.notoSerif(textStyle: defaultStyle);
      case ReaderFontFamily.sansSerif:
        return GoogleFonts.roboto(textStyle: defaultStyle);
      case ReaderFontFamily.systemDefault:
      default:
        return defaultStyle;
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Assuming forceNextDevotional is defined in daily_devotions.dart or similar
  Future<void> _handleForceNextDevotional() async {
    await forceNextDevotional(); 
    _showSnackBar("Next devotional will be shown on Home screen refresh.");
  }

  Future<void> _handleResetAllPlanProgress() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reset All Plan Progress?"),
        content: const Text(
            "This will reset ALL progress (streaks, completed days, current day) for ALL reading plans. This action cannot be undone."),
        actions: [
          TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(ctx).pop(false)),
          TextButton(
            child: Text("Reset All Progress",
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _dbHelper.resetAllStreaksAndProgress();
        _showSnackBar("All reading plan progress and streaks have been reset.");
      } catch (e) {
        _showSnackBar("Error resetting plan progress: ${e.toString()}", isError: true);
      }
    }
  }

  void _onAppVersionTap() {
    _devTapCount++;
    if (_devTapCount >= 7 && !_devOptionsEnabled) {
      if (mounted) {
        setState(() { _devOptionsEnabled = true; });
        _showSnackBar("Developer Options Enabled!");
      }
    } else if (_devOptionsEnabled && _devTapCount >= 10) { 
        if (mounted) {
            setState(() { _devOptionsEnabled = false; });
            _showSnackBar("Developer Options Disabled.");
            _devTapCount = 0; 
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: _isLoadingSettings
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("App Version"),
            subtitle: const Text("1.0.0 (WWJD Daily)"), 
            onTap: _onAppVersionTap,
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              "App Theme",
              style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            leading: Icon(
                themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode_outlined :
                themeProvider.themeMode == ThemeMode.light ? Icons.light_mode_outlined :
                Icons.brightness_auto_outlined
            ),
            title: const Text("Appearance"),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<ThemeMode>(
                value: themeProvider.themeMode,
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text("System Default")),
                  DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
                ],
                onChanged: (ThemeMode? newValue) {
                  if (newValue != null) {
                    themeProvider.setThemeMode(newValue);
                  }
                },
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              "Reader Appearance",
              style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.format_size_rounded),
            title: const Text("Font Size"),
            subtitle: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  tooltip: "Decrease font size",
                  onPressed: _fontSizeDelta > -4.0 ? () async {
                    setState(() { _fontSizeDelta -= 1.0; });
                    await PrefsHelper.setReaderFontSizeDelta(_fontSizeDelta);
                  } : null,
                ),
                Expanded(
                  child: Text(
                    "Aa (${(_baseReaderFontSize + _fontSizeDelta).toStringAsFixed(0)})",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  tooltip: "Increase font size",
                  onPressed: _fontSizeDelta < 6.0 ? () async {
                    setState(() { _fontSizeDelta += 1.0; });
                    await PrefsHelper.setReaderFontSizeDelta(_fontSizeDelta);
                  } : null,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.font_download_outlined),
            title: const Text("Font Family"),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<ReaderFontFamily>(
                value: _selectedFontFamily,
                items: ReaderFontFamily.values.map((ReaderFontFamily family) {
                  return DropdownMenuItem<ReaderFontFamily>(
                    value: family,
                    child: Text(
                      family.displayName,
                      style: _getTextStyleForFontFamilyPreview(family, context),
                    ),
                  );
                }).toList(),
                onChanged: (ReaderFontFamily? newValue) async {
                  if (newValue != null) {
                    setState(() { _selectedFontFamily = newValue; });
                    await PrefsHelper.setReaderFontFamily(newValue);
                  }
                },
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text("Reader Theme"),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<ReaderThemeMode>(
                value: _selectedReaderTheme,
                items: ReaderThemeMode.values.map((ReaderThemeMode themeMode) {
                  return DropdownMenuItem<ReaderThemeMode>(
                    value: themeMode,
                    child: Text(themeMode.displayName),
                  );
                }).toList(),
                onChanged: (ReaderThemeMode? newValue) async {
                  if (newValue != null) {
                    setState(() { _selectedReaderTheme = newValue; });
                    await PrefsHelper.setReaderThemeMode(newValue);
                  }
                },
              ),
            ),
          ),
          const Divider(), 
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              "Narration Voice (Google Cloud TTS)",
              style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ValueListenableBuilder<AppTtsVoice?>(
            valueListenable: _ttsService.selectedAppVoiceNotifier,
            builder: (context, currentSelectedVoice, child) {
              if (_availableAppTtsVoices.isEmpty && _isLoadingSettings) {
                return const ListTile(
                  leading: Icon(Icons.record_voice_over_outlined),
                  title: Text("Narration Voice"),
                  subtitle: Text("Loading voice options..."),
                );
              }
              if (_availableAppTtsVoices.isEmpty) {
                return const ListTile(
                  leading: Icon(Icons.record_voice_over_outlined),
                  title: Text("Narration Voice"),
                  subtitle: Text("No voices available or API key issue."),
                );
              }

              AppTtsVoice? dropdownValue = currentSelectedVoice;
              // Ensure the value in the notifier is actually present in the dropdown items
              if (currentSelectedVoice != null && 
                  !_availableAppTtsVoices.any((v) => v.name == currentSelectedVoice.name)) {
                print("SettingsScreen WARNING: Selected voice '${currentSelectedVoice.name}' from service "
                      "is not in the current _availableAppTtsVoices list. Defaulting dropdown.");
                dropdownValue = _availableAppTtsVoices.isNotEmpty ? _availableAppTtsVoices.first : null;
              } else if (currentSelectedVoice == null && _availableAppTtsVoices.isNotEmpty) {
                // If service notifier is null but we have voices, maybe default the dropdown display
                // but the service should ideally have a default.
                // This case is mostly covered by the service's own default logic.
                // For safety, if currentSelectedVoice is null, dropdownValue will be null, showing hintText.
              }


              return ListTile(
                leading: const Icon(Icons.record_voice_over_outlined),
                title: const Text("Narration Voice"),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<AppTtsVoice>(
                    value: dropdownValue, 
                    hint: const Text("Select Voice"),
                    isExpanded: false, // Keep false to prevent overly wide dropdown
                    items: _availableAppTtsVoices.map((AppTtsVoice voice) {
                      return DropdownMenuItem<AppTtsVoice>(
                        value: voice, 
                        child: Text(
                          voice.displayName,
                          style: textTheme.bodyMedium, // Ensure consistent text style
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (AppTtsVoice? newValue) async {
                      if (newValue != null) {
                        await _ttsService.setAppVoice(newValue, savePreference: true);
                        // ValueListenableBuilder will handle UI update
                      }
                    },
                  ),
                ),
              );
            }
          ),
          const Divider(),
          if (_devOptionsEnabled) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                "Developer Options",
                style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.skip_next_outlined, color: Colors.orange),
              title: const Text("Force Next Devotional"),
              subtitle: const Text("Shows the next devotional on Home screen refresh."),
              onTap: _handleForceNextDevotional,
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt_outlined, color: Colors.redAccent),
              title: const Text("Reset All Reading Plan Progress"),
              subtitle: const Text("Resets streaks and all daily reading progress."),
              onTap: _handleResetAllPlanProgress,
            ),
            const Divider(),
          ],
        ],
      ),
    );
  }
}
