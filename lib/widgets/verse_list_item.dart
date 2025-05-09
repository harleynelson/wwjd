// File: lib/widgets/verse_list_item.dart
// Approximate line: 12 (add new parameter and update constructor)
// Approximate line: 36 (update build method)

import 'package:flutter/material.dart';
import '../models.dart'; // Access to Verse model

// A stateless widget to display a single verse item in the reader list.
class VerseListItem extends StatelessWidget {
  final Verse verse;
  final bool isFavorite;
  final List<String> assignedFlagNames;
  final VoidCallback onToggleFavorite;
  final VoidCallback onManageFlags;
  final VoidCallback? onVerseTap;
  final bool isHighlighted; // New parameter

  const VerseListItem({
    super.key,
    required this.verse,
    required this.isFavorite,
    required this.assignedFlagNames,
    required this.onToggleFavorite,
    required this.onManageFlags,
    this.onVerseTap,
    this.isHighlighted = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    // Define styles for better readability and modern look
    final TextStyle verseNumberStyle = textTheme.bodySmall!.copyWith(
      fontWeight: FontWeight.bold,
      color: colorScheme.primary.withOpacity(0.8),
      fontSize: 12,
    );

    final TextStyle verseTextStyle = textTheme.bodyLarge!.copyWith(
      height: 1.6,
      fontSize: 18,
      color: colorScheme.onBackground.withOpacity(0.85),
    );

    final TextStyle flagChipStyle = textTheme.labelSmall!.copyWith(
      color: colorScheme.onSecondaryContainer,
    );

    // Define highlight color
    final Color? highlightColor = isHighlighted
        ? colorScheme.primaryContainer.withOpacity(0.4) // Or a distinct highlight color like Colors.yellow.withOpacity(0.3)
        : null;

    return InkWell(
      onTap: onVerseTap,
      splashColor: colorScheme.primaryContainer.withOpacity(0.3),
      highlightColor: colorScheme.primaryContainer.withOpacity(0.15),
      child: AnimatedContainer( // Wrap with AnimatedContainer for smooth highlight transition
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: highlightColor,
          borderRadius: BorderRadius.circular(isHighlighted ? 8.0 : 0.0), // Optional: round corners when highlighted
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
                    style: verseNumberStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    verse.text,
                    style: verseTextStyle,
                  ),
                ),
                if (verse.verseID != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 0),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFavorite ? Colors.red.shade400 : colorScheme.outline,
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
                                label: Text(name, style: flagChipStyle),
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: colorScheme.secondaryContainer.withOpacity(0.6),
                                side: BorderSide(color: colorScheme.secondaryContainer),
                              )).toList(),
                            ),
                    ),
                    TextButton.icon(
                      icon: Icon(
                        assignedFlagNames.isNotEmpty ? Icons.edit_note_outlined : Icons.add_circle_outline_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      label: Text(
                        assignedFlagNames.isNotEmpty ? "Manage" : "Add Flags",
                        style: textTheme.labelMedium?.copyWith(color: colorScheme.primary),
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
              child: Divider(height: 1, thickness: 0.5, color: colorScheme.outlineVariant.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }
}