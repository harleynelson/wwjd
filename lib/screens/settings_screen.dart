// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wwjd_app/helpers/database_helper.dart';
import 'package:wwjd_app/helpers/prefs_helper.dart';
import 'package:wwjd_app/models/reader_settings_enums.dart';
import '../helpers/daily_devotions.dart';
import '../theme/theme_provider.dart';

// Make sure this class name is spelled exactly "SettingsScreen"
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  // And ensure "SettingsScreen" is spelled correctly here in State<SettingsScreen>
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// And also ensure "SettingsScreen" is spelled correctly here in State<SettingsScreen>
class _SettingsScreenState extends State<SettingsScreen> {
  // ... rest of the _SettingsScreenState class from the previous response
  // (The content of this class related to loading settings and building the UI
  // should be correct from the last step, the error is about the class declaration line itself)

  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _devOptionsEnabled = false;
  int _devTapCount = 0;

  double _fontSizeDelta = 0.0;
  ReaderFontFamily _selectedFontFamily = ReaderFontFamily.systemDefault;
  ReaderThemeMode _selectedReaderTheme = ReaderThemeMode.light;
  bool _isLoadingReaderSettings = true;

  static const double _baseReaderFontSize = 18.0;

  @override
  void initState() {
    super.initState();
    _loadReaderSettings();
  }

  Future<void> _loadReaderSettings() async {
    if (!mounted) return;
    setState(() {
      _isLoadingReaderSettings = true;
    });
    _fontSizeDelta = PrefsHelper.getReaderFontSizeDelta();
    _selectedFontFamily = PrefsHelper.getReaderFontFamily();
    _selectedReaderTheme = PrefsHelper.getReaderThemeMode();
    if (mounted) {
      setState(() {
        _isLoadingReaderSettings = false;
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
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

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
    } else if (_devOptionsEnabled && _devTapCount >=10) {
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
      body: ListView(
        children: <Widget>[

          
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("App Version"),
            subtitle: const Text("1.0.0 (WWJD Daily)"),
            onTap: _onAppVersionTap,
          ),
          const Divider(),
          // --- NEW: App Theme Mode Setting ---
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
            // Use a Dropdown or SegmentedButton for more options (System, Light, Dark)
            // For a simple toggle, a Switch can work well for Light/Dark.
            // Here's an example with a dropdown:
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<ThemeMode>(
                value: themeProvider.themeMode,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text("System Default"),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text("Light"),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text("Dark"),
                  ),
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
          if (_isLoadingReaderSettings)
            const ListTile(title: Center(child: CircularProgressIndicator()))
          else ...[
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
          ],
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