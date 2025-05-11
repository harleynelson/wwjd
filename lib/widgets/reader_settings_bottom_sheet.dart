// lib/widgets/reader_settings_bottom_sheet.dart
// Path: lib/widgets/reader_settings_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wwjd_app/models/reader_settings_enums.dart';
import 'package:wwjd_app/helpers/prefs_helper.dart'; // For saving preferences

// Callback signature for when settings are changed and should be saved
typedef ReaderSettingsCallback = void Function(
  double newFontSizeDelta,
  ReaderFontFamily newFontFamily,
  ReaderThemeMode newThemeMode,
);

class ReaderSettingsBottomSheet extends StatefulWidget {
  final double initialFontSizeDelta;
  final ReaderFontFamily initialFontFamily;
  final ReaderThemeMode initialThemeMode;
  final ReaderSettingsCallback onSettingsChanged;

  // Base font size for previewing font family changes
  static const double _basePreviewFontSize = 16.0;
  // Base font size for calculating the "Aa (XX)" display
  static const double _baseReaderControlFontSize = 18.0;


  const ReaderSettingsBottomSheet({
    super.key,
    required this.initialFontSizeDelta,
    required this.initialFontFamily,
    required this.initialThemeMode,
    required this.onSettingsChanged,
  });

  @override
  State<ReaderSettingsBottomSheet> createState() => _ReaderSettingsBottomSheetState();
}

class _ReaderSettingsBottomSheetState extends State<ReaderSettingsBottomSheet> {
  late double _currentFontSizeDelta;
  late ReaderFontFamily _currentFontFamily;
  late ReaderThemeMode _currentThemeMode;

  @override
  void initState() {
    super.initState();
    _currentFontSizeDelta = widget.initialFontSizeDelta;
    _currentFontFamily = widget.initialFontFamily;
    _currentThemeMode = widget.initialThemeMode;
  }

  // Helper to get text style for font family dropdown preview
  TextStyle _getFontFamilyPreviewStyle(ReaderFontFamily family, BuildContext context) {
    final Color textColor = _getPreviewTextColorForTheme(_currentThemeMode, context);
    final defaultStyle = TextStyle(fontSize: ReaderSettingsBottomSheet._basePreviewFontSize, color: textColor);

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

  Color _getPreviewTextColorForTheme(ReaderThemeMode themeMode, BuildContext context) {
    // Determine text color based on the *sheet's* current theme, not the reader's theme,
    // to ensure dropdown text is visible against the sheet's background.
    return Theme.of(context).colorScheme.onSurface;
  }


  @override
  Widget build(BuildContext context) {
    // Use the context provided by StatefulBuilder for theme access within the sheet
    final Color currentSheetTextColor = Theme.of(context).colorScheme.onSurface;
    final Color currentSheetIconColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Wrap(
          runSpacing: 15,
          children: <Widget>[
            Text("Reader Settings", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: currentSheetTextColor)),
            const Divider(height: 10),

            // Font Size
            Text("Font Size", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: currentSheetTextColor)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: currentSheetIconColor),
                  tooltip: "Decrease font size",
                  onPressed: _currentFontSizeDelta > -4.0
                      ? () {
                          setState(() {
                            _currentFontSizeDelta -= 1.0;
                          });
                          widget.onSettingsChanged(_currentFontSizeDelta, _currentFontFamily, _currentThemeMode);
                        }
                      : null,
                ),
                Text(
                  "Aa (${(ReaderSettingsBottomSheet._baseReaderControlFontSize + _currentFontSizeDelta).toStringAsFixed(0)})",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: currentSheetTextColor),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: currentSheetIconColor),
                  tooltip: "Increase font size",
                  onPressed: _currentFontSizeDelta < 6.0
                      ? () {
                          setState(() {
                            _currentFontSizeDelta += 1.0;
                          });
                          widget.onSettingsChanged(_currentFontSizeDelta, _currentFontFamily, _currentThemeMode);
                        }
                      : null,
                ),
              ],
            ),

            // Font Family
            Text("Font Family", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: currentSheetTextColor)),
            DropdownButtonFormField<ReaderFontFamily>(
              value: _currentFontFamily,
              items: ReaderFontFamily.values.map((ReaderFontFamily family) {
                return DropdownMenuItem<ReaderFontFamily>(
                  value: family,
                  child: Text(family.displayName, style: _getFontFamilyPreviewStyle(family, context)),
                );
              }).toList(),
              onChanged: (ReaderFontFamily? newValue) {
                if (newValue != null) {
                  setState(() {
                    _currentFontFamily = newValue;
                  });
                  widget.onSettingsChanged(_currentFontSizeDelta, _currentFontFamily, _currentThemeMode);
                }
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest, // Example
                filled: true,
              ),
              dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest, // Match dropdown bg
            ),

            // Reader Theme
            Text("Reading Background", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: currentSheetTextColor)),
            DropdownButtonFormField<ReaderThemeMode>(
              value: _currentThemeMode,
              items: ReaderThemeMode.values.map((ReaderThemeMode themeMode) {
                return DropdownMenuItem<ReaderThemeMode>(
                  value: themeMode,
                  child: Text(themeMode.displayName, style: TextStyle(color: currentSheetTextColor)),
                );
              }).toList(),
              onChanged: (ReaderThemeMode? newValue) {
                if (newValue != null) {
                  setState(() {
                    _currentThemeMode = newValue;
                  });
                  widget.onSettingsChanged(_currentFontSizeDelta, _currentFontFamily, _currentThemeMode);
                }
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                filled: true,
              ),
              dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                child: Text("Done", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }
}