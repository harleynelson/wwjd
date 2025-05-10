// lib/widgets/favorite_list_item_card.dart
import 'package:flutter/material.dart';
import '../models/models.dart'; // Includes FavoriteVerse, Flag models

// A stateless widget to display a single favorite verse item.
class FavoriteListItemCard extends StatelessWidget {
  final FavoriteVerse favoriteVerse;
  final VoidCallback onRemove; // Callback when delete is tapped
  final VoidCallback onManageFlags; // Callback when manage/add flags is tapped
  // Function passed down to get the full book name from abbreviation
  final String Function(String) getFullBookName;

  const FavoriteListItemCard({
    super.key,
    required this.favoriteVerse,
    required this.onRemove,
    required this.onManageFlags,
    required this.getFullBookName,
  });

  @override
  Widget build(BuildContext context) {
    final reference = favoriteVerse.getReference(getFullBookName);
    final List<String> flagNames = favoriteVerse.assignedFlags.map((f) => f.name).toList();
    // Sort names for consistent display
    flagNames.sort();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), // Slightly less rounded
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for Reference and Remove Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    reference,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Remove Favorite Button
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: "Remove from Favorites",
                  onPressed: onRemove, // Call the passed callback
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Verse Text (Selectable)
            SelectableText(
              favoriteVerse.verseText,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 10),
            // Row for Flags and Manage Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Align button vertically
              children: [
                Expanded(
                  child: favoriteVerse.assignedFlags.isEmpty
                    ? const SizedBox(height: 30) // Placeholder height to align button
                    : Wrap( // Display assigned flags as Chips
                        spacing: 6.0,
                        runSpacing: 4.0,
                        children: flagNames.map((name) => Chip(
                          label: Text(name, style: const TextStyle(fontSize: 10)),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
                        )).toList(),
                      ),
                ),
                // Add/Manage Flags Button
                TextButton.icon(
                  icon: Icon(favoriteVerse.assignedFlags.isNotEmpty ? Icons.edit_note_outlined : Icons.label_outline, size: 18),
                  label: Text(favoriteVerse.assignedFlags.isNotEmpty ? "Manage Flags" : "Add Flags", style: const TextStyle(fontSize: 12)),
                  onPressed: onManageFlags, // Call the passed callback
                  style: TextButton.styleFrom(padding: const EdgeInsets.only(left: 8.0), minimumSize: const Size(50, 20), visualDensity: VisualDensity.compact ),
                ),
              ],
            ),
          ],
        ),
      ),
    ); // End Card
  }
}