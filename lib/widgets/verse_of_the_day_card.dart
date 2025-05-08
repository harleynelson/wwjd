// lib/widgets/verse_of_the_day_card.dart
import 'package:flutter/material.dart';

class VerseOfTheDayCard extends StatelessWidget {
  final bool isLoading;
  final String verseText;
  final String verseRef;
  final bool isFavorite;
  final List<String> assignedFlagNames;
  final VoidCallback? onToggleFavorite; // Null if VotD not loaded
  final VoidCallback? onManageFlags; // Null if VotD not favorited or not loaded

  const VerseOfTheDayCard({
    super.key,
    required this.isLoading,
    required this.verseText,
    required this.verseRef,
    required this.isFavorite,
    required this.assignedFlagNames,
    this.onToggleFavorite,
    this.onManageFlags,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row( // Title and Favorite Icon
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Title
                  child: Text(
                    "Verse of the Day",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                // Show favorite icon only when not loading and callback is available
                if (!isLoading && onToggleFavorite != null)
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.redAccent : Colors.grey,
                      size: 28,
                    ),
                    tooltip: isFavorite ? "Remove from Favorites" : "Add to Favorites",
                    onPressed: onToggleFavorite,
                  )
              ],
            ),
            const SizedBox(height: 12.0),
            // Verse Text Area
            isLoading
                ? const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: CircularProgressIndicator(),
                  ))
                : SelectableText( // Verse text (allow selection)
                    '"$verseText"',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.5, // Line spacing
                        ),
                  ),
            const SizedBox(height: 8.0),
            // Verse Reference
            if (!isLoading && verseRef.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  verseRef,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            // --- Flag Display / Add/Manage Button ---
            // Only show if favorited
            if (isFavorite) ...[
              const SizedBox(height: 10),
              // Display chips if flags exist
              if (assignedFlagNames.isNotEmpty)
                Wrap(
                  spacing: 6.0, runSpacing: 4.0,
                  children: assignedFlagNames.map((name) => Chip(
                    label: Text(name, style: const TextStyle(fontSize: 10)),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.6),
                  )).toList(),
                ),
              // Show "Manage Flags" or "Add Flags" button
              TextButton.icon(
                  icon: Icon(assignedFlagNames.isNotEmpty ? Icons.edit_note_outlined : Icons.label_outline, size: 18),
                  label: Text(assignedFlagNames.isNotEmpty ? "Manage Flags" : "Add Flags", style: const TextStyle(fontSize: 12)),
                  // Use the passed callback
                  onPressed: onManageFlags,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                )
            ]
            // --- END Flag Display/Button ---
          ],
        ),
      ),
    ); // End Card
  }
}