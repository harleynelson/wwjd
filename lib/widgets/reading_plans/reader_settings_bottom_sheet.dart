// lib/widgets/reader_settings_bottom_sheet.dart
// Path: lib/widgets/reader_settings_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wwjd_app/models/reader_settings_enums.dart';
// PrefsHelper is not directly used here anymore, parent screens handle saving.

typedef ReaderSettingsCallback = void Function(
  double newFontSizeDelta,
  ReaderFontFamily newFontFamily,
  ReaderThemeMode newThemeMode,
  ReaderViewMode newViewMode, // <<< ADDED
);

class ReaderSettingsBottomSheet extends StatefulWidget {
  final double initialFontSizeDelta;
  final ReaderFontFamily initialFontFamily;
  final ReaderThemeMode initialThemeMode;
  final ReaderViewMode initialReaderViewMode; // <<< ADDED
  final ReaderSettingsCallback onSettingsChanged;

  static const double _basePreviewFontSize = 16.0;
  static const double _baseReaderControlFontSize = 18.0;

  const ReaderSettingsBottomSheet({
    super.key,
    required this.initialFontSizeDelta,
    required this.initialFontFamily,
    required this.initialThemeMode,
    required this.initialReaderViewMode, // <<< ADDED
    required this.onSettingsChanged,
  });

  @override
  State<ReaderSettingsBottomSheet> createState() => _ReaderSettingsBottomSheetState();
}

class _ReaderSettingsBottomSheetState extends State<ReaderSettingsBottomSheet> {
  late double _currentFontSizeDelta;
  late ReaderFontFamily _currentFontFamily;
  late ReaderThemeMode _currentThemeMode;
  late ReaderViewMode _currentReaderViewMode; // <<< ADDED

  @override
  void initState() {
    super.initState();
    _currentFontSizeDelta = widget.initialFontSizeDelta;
    _currentFontFamily = widget.initialFontFamily;
    _currentThemeMode = widget.initialThemeMode;
    _currentReaderViewMode = widget.initialReaderViewMode; // <<< ADDED
  }

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
    return Theme.of(context).colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
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
                          widget.onSettingsChanged(_currentFontSizeDelta, _currentFontFamily, _currentThemeMode, _currentReaderViewMode);
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
                          widget.onSettingsChanged(_currentFontSizeDelta, _currentFontFamily, _currentThemeMode, _currentReaderViewMode);
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
                  widget.onSettingsChanged(_currentFontSizeDelta, _currentFontFamily, _currentThemeMode, _currentReaderViewMode);
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
                  widget.onSettingsChanged(_currentFontSizeDelta, _currentFontFamily, _currentThemeMode, _currentReaderViewMode);
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

            // --- NEW: Reader View Mode ---
            Text("View Style", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: currentSheetTextColor)),
            SegmentedButton<ReaderViewMode>(
              segments: ReaderViewMode.values.map((ReaderViewMode mode) {
                return ButtonSegment<ReaderViewMode>(
                  value: mode,
                  label: Text(mode.displayName, style: TextStyle(color: currentSheetTextColor.withOpacity(_currentReaderViewMode == mode ? 1.0 : 0.7))),
                  icon: Icon(
                    mode == ReaderViewMode.prose ? Icons.notes_rounded : Icons.view_list_rounded,
                    color: currentSheetIconColor.withOpacity(_currentReaderViewMode == mode ? 1.0 : 0.7),
                  ),
                );
              }).toList(),
              selected: <ReaderViewMode>{_currentReaderViewMode},
              onSelectionChanged: (Set<ReaderViewMode> newSelection) {
                if (newSelection.isNotEmpty) {
                  setState(() {
                    _currentReaderViewMode = newSelection.first;
                  });
                  widget.onSettingsChanged(_currentFontSizeDelta, _currentFontFamily, _currentThemeMode, _currentReaderViewMode);
                }
              },
              style: SegmentedButton.styleFrom(
                // backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                // foregroundColor: currentSheetTextColor,
                // selectedForegroundColor: Theme.of(context).colorScheme.primary,
                // selectedBackgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              ),
              showSelectedIcon: true,
              multiSelectionEnabled: false,
            ),
            // --- END NEW ---
            
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