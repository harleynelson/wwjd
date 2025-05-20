// File: lib/widgets/reading_plans/daily_reading_passage_display.dart
// Path: lib/widgets/reading_plans/daily_reading_passage_display.dart
import 'package:flutter/material.dart';
import 'package:wwjd_app/models/models.dart';
import 'package:wwjd_app/models/reader_settings_enums.dart';
import 'package:wwjd_app/helpers/book_names.dart';
import 'package:wwjd_app/widgets/verse_list_item.dart';

class DailyReadingPassageDisplay extends StatelessWidget {
  final BiblePassagePointer passagePointer;
  final List<Verse> verses;
  final ReaderViewMode viewMode;
  final bool isLoading;
  final TextStyle passageTitleStyle;
  final TextStyle verseTextStyle;
  final TextStyle verseNumberStyle;
  final Color textColor; // General text color, especially for prose

  // VerseListItem specific parameters (for verse-by-verse mode)
  final Map<String, bool> isVerseFavoriteMap;
  final Map<String, List<int>> assignedFlagIdsMap;
  final List<Flag> allAvailableFlags;
  final Function(Verse) onToggleFavorite;
  final Function(Verse) onManageFlags;
  final Function(Verse) onVerseTap;
  final ReaderThemeMode readerThemeMode;
  final Color flagChipBackgroundColor;
  final Color flagChipBorderColor;
  final Color dividerColor;
  final Color favoriteIconColor;
  final Color flagManageButtonColor;
  final TextStyle flagChipStyle;

  const DailyReadingPassageDisplay({
    super.key,
    required this.passagePointer,
    required this.verses,
    required this.viewMode,
    required this.isLoading,
    required this.passageTitleStyle,
    required this.verseTextStyle,
    required this.verseNumberStyle,
    required this.textColor,
    required this.isVerseFavoriteMap,
    required this.assignedFlagIdsMap,
    required this.allAvailableFlags,
    required this.onToggleFavorite,
    required this.onManageFlags,
    required this.onVerseTap,
    required this.readerThemeMode,
    required this.flagChipBackgroundColor,
    required this.flagChipBorderColor,
    required this.dividerColor,
    required this.favoriteIconColor,
    required this.flagManageButtonColor,
    required this.flagChipStyle,
  });

  Widget _buildProseView(BuildContext context) {
    if (verses.isEmpty && !isLoading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text("No text found for ${passagePointer.displayText}.",
            style: verseTextStyle.copyWith(
                fontStyle: FontStyle.italic,
                color: textColor.withOpacity(0.7))),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            "${getFullBookName(passagePointer.bookAbbr)} ${passagePointer.displayText.replaceFirst(RegExp(r'^[A-Za-z\s]+'), '').trim()}",
            style: passageTitleStyle,
          ),
        ),
        SelectableText.rich(
          TextSpan(
            children: verses.map((verse) {
              return TextSpan(
                children: [
                  TextSpan(
                    text: "${verse.verseNumber} ",
                    style: verseNumberStyle,
                  ),
                  TextSpan(
                    text: "${verse.text} ", // Add space after verse text
                    style: verseTextStyle,
                  ),
                ],
              );
            }).toList(),
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildVerseByVerseView(BuildContext context) {
    List<Widget> passageWidgets = [];
    passageWidgets.add(
      Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
        child: Text(
          "${getFullBookName(passagePointer.bookAbbr)} ${passagePointer.displayText.replaceFirst(RegExp(r'^[A-Za-z\s]+'), '').trim()}",
          style: passageTitleStyle,
        ),
      ),
    );

    if (verses.isEmpty && !isLoading) {
      passageWidgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
        child: Text("No text found for ${passagePointer.displayText}.",
            style: verseTextStyle.copyWith( // Use the main verseTextStyle passed
                fontStyle: FontStyle.italic,
                color: textColor.withOpacity(0.7))), // Use general textColor
      ));
    } else {
      for (var verse in verses) {
        bool isFavorite = isVerseFavoriteMap[verse.verseID] ?? false;
        List<String> flagNames = [];
        List<int> currentFlagIds = assignedFlagIdsMap[verse.verseID] ?? [];
        for (int id in currentFlagIds) {
          try {
            final flag = allAvailableFlags.firstWhere((f) => f.id == id);
            flagNames.add(flag.name);
          } catch (e) { /* Flag not found, skip */ }
        }
        flagNames.sort();

        passageWidgets.add(
          VerseListItem(
            verse: verse,
            isFavorite: isFavorite,
            assignedFlagNames: flagNames,
            onToggleFavorite: () => onToggleFavorite(verse),
            onManageFlags: () => onManageFlags(verse),
            onVerseTap: () => onVerseTap(verse),
            verseTextStyle: verseTextStyle, // Pass down the specific style
            verseNumberStyle: verseNumberStyle, // Pass down the specific style
            flagChipStyle: flagChipStyle,
            favoriteIconColor: favoriteIconColor,
            flagManageButtonColor: flagManageButtonColor,
            flagChipBackgroundColor: flagChipBackgroundColor,
            flagChipBorderColor: flagChipBorderColor,
            dividerColor: dividerColor,
          ),
        );
      }
    }
    passageWidgets.add(const SizedBox(height: 8.0));
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: passageWidgets);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(color: passageTitleStyle.color ?? Theme.of(context).colorScheme.primary),
        ),
      );
    }

    if (viewMode == ReaderViewMode.prose) {
      return _buildProseView(context);
    } else {
      // Default to verseByVerse
      return _buildVerseByVerseView(context);
    }
  }
}