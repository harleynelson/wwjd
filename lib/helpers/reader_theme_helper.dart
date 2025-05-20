// File: lib/helpers/reader_theme_helper.dart
// Path: lib/helpers/reader_theme_helper.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wwjd_app/models/reader_settings_enums.dart';

class ReaderThemeHelper {
  static TextStyle getTextStyle({
    required ReaderFontFamily fontFamily,
    required double baseSize,
    required FontWeight fontWeight,
    required Color color,
    required double fontSizeDelta,
    double height = 1.5,
    FontStyle? fontStyle,
  }) {
    double currentSize = baseSize + fontSizeDelta;
    TextStyle defaultStyle = TextStyle(
      fontSize: currentSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      fontStyle: fontStyle,
    );
    switch (fontFamily) {
      case ReaderFontFamily.serif:
        return GoogleFonts.notoSerif(textStyle: defaultStyle);
      case ReaderFontFamily.sansSerif:
        return GoogleFonts.roboto(textStyle: defaultStyle);
      case ReaderFontFamily.systemDefault:
      default:
        return defaultStyle;
    }
  }

  static Color getBackgroundColor(ReaderThemeMode themeMode) {
    switch (themeMode) {
      case ReaderThemeMode.dark:
        return Colors.black87;
      case ReaderThemeMode.sepia:
        return const Color(0xFFFBF0D9);
      case ReaderThemeMode.light:
      default:
        return Colors.white;
    }
  }

  static Color getTextColor(ReaderThemeMode themeMode) {
    switch (themeMode) {
      case ReaderThemeMode.dark:
        return Colors.grey.shade300;
      case ReaderThemeMode.sepia:
        return Colors.brown.shade800;
      case ReaderThemeMode.light:
      default:
        return Colors.black87;
    }
  }

  static Color getAccentColor(ReaderThemeMode themeMode, BuildContext context) {
    switch (themeMode) {
      case ReaderThemeMode.dark:
        return Colors.tealAccent.shade100;
      case ReaderThemeMode.sepia:
        return Colors.brown.shade800;
      case ReaderThemeMode.light:
      default:
        final appPrimaryColor = Theme.of(context).colorScheme.primary;
        return Color.lerp(appPrimaryColor, Colors.black, 0.6) ??
            Colors.black.withOpacity(0.8);
    }
  }

  static Color getSecondaryAccentColor(ReaderThemeMode themeMode, BuildContext context) {
     // Added context although not used in current logic, for consistency if needed later
    switch (themeMode) {
      case ReaderThemeMode.dark:
        return Colors.cyanAccent.shade200.withOpacity(0.9);
      case ReaderThemeMode.sepia:
        return Colors.brown.shade700;
      case ReaderThemeMode.light:
      default:
        return Colors.black.withOpacity(0.65);
    }
  }

  static Color getReflectionBoxColor(ReaderThemeMode themeMode, BuildContext context) {
    switch (themeMode) {
      case ReaderThemeMode.dark:
        return Colors.grey.shade800;
      case ReaderThemeMode.sepia:
        return const Color(0xFFEFEBE2);
      case ReaderThemeMode.light:
      default:
        return Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5);
    }
  }

  static Color getReflectionBoxBorderColor(ReaderThemeMode themeMode, BuildContext context) {
    switch (themeMode) {
      case ReaderThemeMode.dark:
        return Colors.grey.shade700;
      case ReaderThemeMode.sepia:
        return Colors.brown.withOpacity(0.3);
      case ReaderThemeMode.light:
      default:
        return Theme.of(context).colorScheme.outlineVariant;
    }
  }

  // Helper for VerseListItem specific colors, could be expanded
   static Color getVerseListItemFavoriteIconColor(ReaderThemeMode themeMode, BuildContext context) {
    return (themeMode == ReaderThemeMode.dark) ? Colors.grey.shade400 : Theme.of(context).colorScheme.outline;
  }

  static Color getVerseListItemFlagManageButtonColor(ReaderThemeMode themeMode, BuildContext context) {
    return (themeMode == ReaderThemeMode.dark) ? Colors.cyanAccent.shade200 : Theme.of(context).colorScheme.primary;
  }

  static Color getVerseListItemFlagChipBackgroundColor(ReaderThemeMode themeMode, BuildContext context) {
    return (themeMode == ReaderThemeMode.dark) ? Colors.grey.shade700.withOpacity(0.6) : Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.6);
  }

  static Color getVerseListItemFlagChipBorderColor(ReaderThemeMode themeMode, BuildContext context) {
     return (themeMode == ReaderThemeMode.dark) ? Colors.grey.shade600 : Theme.of(context).colorScheme.secondaryContainer;
  }
    static Color getVerseListItemDividerColor(ReaderThemeMode themeMode, BuildContext context) {
    return (themeMode == ReaderThemeMode.dark) ? Colors.grey.shade700 : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5);
  }
}