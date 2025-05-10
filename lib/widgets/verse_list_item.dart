// File: lib/widgets/verse_list_item.dart
import 'package:flutter/material.dart';
import '../models/models.dart'; // Access to Verse model

class VerseListItem extends StatelessWidget {
  final Verse verse;
  final bool isFavorite;
  final List<String> assignedFlagNames;
  final VoidCallback onToggleFavorite;
  final VoidCallback onManageFlags;
  final VoidCallback? onVerseTap;
  final bool isHighlighted;

  // --- NEW: Accept TextStyles and theme-related colors ---
  final TextStyle verseNumberStyle;
  final TextStyle verseTextStyle;
  final TextStyle flagChipStyle;
  final Color favoriteIconColor;
  final Color flagManageButtonColor;
  final Color flagChipBackgroundColor;
  final Color flagChipBorderColor;
  final Color dividerColor;
  final Color? verseHighlightColor; // Can be null if not highlighted

  const VerseListItem({
    super.key,
    required this.verse,
    required this.isFavorite,
    required this.assignedFlagNames,
    required this.onToggleFavorite,
    required this.onManageFlags,
    this.onVerseTap,
    this.isHighlighted = false,
    // --- NEW: Required style parameters ---
    required this.verseNumberStyle,
    required this.verseTextStyle,
    required this.flagChipStyle,
    required this.favoriteIconColor,
    required this.flagManageButtonColor,
    required this.flagChipBackgroundColor,
    required this.flagChipBorderColor,
    required this.dividerColor,
    this.verseHighlightColor,
  });

  @override
  Widget build(BuildContext context) {
    // ThemeData and ColorScheme are still useful for general theme access if needed
    // but specific styles are now passed in.
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme; // Keep for fallback or non-text elements

    return InkWell(
      onTap: onVerseTap,
      splashColor: colorScheme.primaryContainer.withOpacity(0.3),
      highlightColor: colorScheme.primaryContainer.withOpacity(0.15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isHighlighted ? verseHighlightColor : null, // Use passed highlight color
          borderRadius: BorderRadius.circular(isHighlighted ? 8.0 : 0.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Text(
                    verse.verseNumber,
                    style: verseNumberStyle, // Use passed style
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    verse.text,
                    style: verseTextStyle, // Use passed style
                  ),
                ),
                if (verse.verseID != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 0),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        // Use passed color for favorite icon, fallback if needed
                        color: isFavorite ? Colors.red.shade400 : favoriteIconColor,
                      ),
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: isFavorite ? "Remove from Favorites" : "Add to Favorites",
                      onPressed: onToggleFavorite,
                    ),
                  ),
              ],
            ),
            if (isFavorite && verse.verseID != null)
              Padding(
                padding: const EdgeInsets.only(left: 46.0, top: 8.0, right: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: assignedFlagNames.isEmpty
                          ? const SizedBox(height: 30)
                          : Wrap(
                              spacing: 6.0,
                              runSpacing: 4.0,
                              children: assignedFlagNames.map((name) => Chip(
                                label: Text(name, style: flagChipStyle), // Use passed style
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: flagChipBackgroundColor, // Use passed color
                                side: BorderSide(color: flagChipBorderColor), // Use passed color
                              )).toList(),
                            ),
                    ),
                    TextButton.icon(
                      icon: Icon(
                        assignedFlagNames.isNotEmpty ? Icons.edit_note_outlined : Icons.add_circle_outline_rounded,
                        size: 18,
                        color: flagManageButtonColor, // Use passed color
                      ),
                      label: Text(
                        assignedFlagNames.isNotEmpty ? "Manage" : "Add Flags",
                        style: theme.textTheme.labelMedium?.copyWith(color: flagManageButtonColor), // Use passed color
                      ),
                      onPressed: onManageFlags,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        minimumSize: const Size(50, 30),
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 46.0, top: 10.0, right: 8.0),
              child: Divider(height: 1, thickness: 0.5, color: dividerColor), // Use passed color
            ),
          ],
        ),
      ),
    );
  }
}