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
  final ThemeData theme = Theme.of(context);
  final ColorScheme colorScheme = theme.colorScheme;

  return InkWell(
    onTap: onVerseTap,
    splashColor: colorScheme.primaryContainer.withOpacity(0.3),
    highlightColor: colorScheme.primaryContainer.withOpacity(0.15),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isHighlighted ? verseHighlightColor : null,
        borderRadius: BorderRadius.circular(isHighlighted ? 8.0 : 0.0),
      ),
      // --- MODIFIED PADDING ---
      // Reduced horizontal padding to 0.0. Vertical padding remains.
      // The parent ListView/SingleChildScrollView will primarily control side padding.
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0), 
      // --- END MODIFIED PADDING ---
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38, // This width is for the verse number
                padding: const EdgeInsets.only(top: 3.0, right: 4.0), // Added right padding for number
                child: Text(
                  verse.verseNumber,
                  style: verseNumberStyle, 
                  textAlign: TextAlign.right,
                ),
              ),
              // Removed the SizedBox(width: 8) here, as the number container's right padding handles it
              Expanded(
                child: SelectableText(
                  verse.text,
                  style: verseTextStyle, 
                ),
              ),
              if (verse.verseID != null)
                Padding(
                  // Keep some left padding for the favorite icon so it doesn't hug the text too much
                  padding: const EdgeInsets.only(left: 8.0, right: 4.0), // Added right padding for icon
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
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
              // Adjust left padding to align with verse text approximately
              // It was 46 (38 for num + 8 space). Now it's based on the verse number container width.
              padding: const EdgeInsets.only(left: 38.0 + 4.0, top: 8.0, right: 8.0), // 38 (num width) + 4 (num right_padding)
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
                              label: Text(name, style: flagChipStyle), 
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: flagChipBackgroundColor, 
                              side: BorderSide(color: flagChipBorderColor), 
                            )).toList(),
                          ),
                  ),
                  TextButton.icon(
                    icon: Icon(
                      assignedFlagNames.isNotEmpty ? Icons.edit_note_outlined : Icons.add_circle_outline_rounded,
                      size: 18,
                      color: flagManageButtonColor, 
                    ),
                    label: Text(
                      assignedFlagNames.isNotEmpty ? "Manage" : "Add Flags",
                      style: theme.textTheme.labelMedium?.copyWith(color: flagManageButtonColor), 
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
            // Adjust left padding for divider as well
            padding: const EdgeInsets.only(left: 38.0 + 4.0, top: 10.0, right: 8.0),
            child: Divider(height: 1, thickness: 0.5, color: dividerColor), 
          ),
        ],
      ),
    ),
  );
}
}