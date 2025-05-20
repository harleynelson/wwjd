// File: lib/widgets/favorite_list_item_card.dart
// Path: lib/widgets/favorite_list_item_card.dart
// Updated: Added onShareAsImage callback, share image button, and onTap for the card.

import 'package:flutter/material.dart';
import '../models/models.dart'; // Includes FavoriteVerse, Flag models

class FavoriteListItemCard extends StatelessWidget {
  final FavoriteVerse favoriteVerse;
  final VoidCallback onRemove;
  final VoidCallback onManageFlags;
  final VoidCallback? onShareAsImage; // <<< NEW: Callback for sharing as image
  final VoidCallback? onTap;          // <<< NEW: Callback for tapping the card
  final String Function(String) getFullBookName;

  const FavoriteListItemCard({
    super.key,
    required this.favoriteVerse,
    required this.onRemove,
    required this.onManageFlags,
    this.onShareAsImage, // <<< NEW
    this.onTap,          // <<< NEW
    required this.getFullBookName,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    final String reference = favoriteVerse.getReference(getFullBookName);
    final List<String> flagNames = favoriteVerse.assignedFlags.map((f) => f.name).toList();
    flagNames.sort();

    final Color iconColor = colorScheme.onSurfaceVariant.withOpacity(0.7);
    final Color shareIconColor = colorScheme.primary; // Make share icon stand out a bit

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Adjusted vertical margin
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // Consistent rounding
      clipBehavior: Clip.antiAlias, // Ensures InkWell splash is clipped
      child: InkWell( // <<< NEW: Make the whole card tappable
        onTap: onTap,
        splashColor: colorScheme.primaryContainer.withOpacity(0.2),
        highlightColor: colorScheme.primaryContainer.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Increased padding slightly
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      reference,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Row for action icons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onShareAsImage != null) // <<< NEW: Share as Image Button
                        IconButton(
                          icon: Icon(Icons.image_outlined, color: shareIconColor, size: 22),
                          padding: const EdgeInsets.all(4), // Reduced padding
                          constraints: const BoxConstraints(),
                          tooltip: "Create Shareable Image",
                          onPressed: onShareAsImage,
                        ),
                      const SizedBox(width: 4), // Spacing between icons
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 22),
                        padding: const EdgeInsets.all(4), // Reduced padding
                        constraints: const BoxConstraints(),
                        tooltip: "Remove from Favorites",
                        onPressed: onRemove,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SelectableText(
                favoriteVerse.verseText,
                style: textTheme.bodyLarge?.copyWith(height: 1.45), // Slightly increased line height
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: favoriteVerse.assignedFlags.isEmpty
                        ? const SizedBox(height: 32) // Placeholder height to align button if no flags
                        : Wrap(
                            spacing: 6.0,
                            runSpacing: 4.0,
                            children: flagNames.map((name) => Chip(
                              label: Text(name, style: textTheme.labelSmall),
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: colorScheme.secondaryContainer.withOpacity(0.7),
                              side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                            )).toList(),
                          ),
                  ),
                  TextButton.icon(
                    icon: Icon(
                      favoriteVerse.assignedFlags.isNotEmpty ? Icons.edit_note_outlined : Icons.label_outline,
                      size: 18,
                      color: iconColor,
                    ),
                    label: Text(
                      favoriteVerse.assignedFlags.isNotEmpty ? "Manage Flags" : "Add Flags",
                      style: textTheme.labelMedium?.copyWith(color: iconColor),
                    ),
                    onPressed: onManageFlags,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      minimumSize: const Size(50, 30),
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
