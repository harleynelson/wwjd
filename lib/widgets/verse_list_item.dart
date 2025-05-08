// lib/widgets/verse_list_item.dart
import 'package:flutter/material.dart';
import '../models.dart'; // Access to Verse model

// A stateless widget to display a single verse item in the reader list.
class VerseListItem extends StatelessWidget {
  final Verse verse;
  final bool isFavorite;
  final List<String> assignedFlagNames;
  final VoidCallback onToggleFavorite; // Callback when heart is tapped
  final VoidCallback onManageFlags; // Callback when manage/add flags is tapped

  const VerseListItem({
    super.key,
    required this.verse,
    required this.isFavorite,
    required this.assignedFlagNames,
    required this.onToggleFavorite,
    required this.onManageFlags,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Spacing between verses
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row( // Main row for verse number, text, favorite button
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verse Number
              SizedBox(
                width: 35, // Space for verse number
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.0), // Align number better
                  child: Text(
                    verse.verseNumber, // Use verse number from Verse object
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 14, height: 1.5),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              const SizedBox(width: 5), // Space between number and text
              // Verse Text (selectable)
              Expanded(
                child: SelectableText(
                  verse.text, // Use verse text from Verse object
                  style: const TextStyle(fontSize: 17, height: 1.5, color: Colors.black87),
                ),
              ),
              // Favorite Button
              if (verse.verseID != null) // Only show if ID is available
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 0),
                  child: IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.redAccent : Colors.grey.shade400,),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: isFavorite ? "Remove from Favorites" : "Add to Favorites",
                    onPressed: onToggleFavorite, // Use passed callback
                  ),
                ),
            ],
          ),
          // Display Flags and Add/Manage Button if favorited
          if (isFavorite && verse.verseID != null)
             Padding(
               padding: const EdgeInsets.only(left: 40.0, top: 6.0), // Indent under verse text
               child: Row(
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                    Expanded(
                      child: assignedFlagNames.isEmpty
                        ? const SizedBox(height: 30) // Placeholder height
                        : Wrap( // Display assigned flags as Chips
                            spacing: 6.0,
                            runSpacing: 4.0,
                            children: assignedFlagNames.map((name) => Chip(
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
                     icon: Icon(assignedFlagNames.isNotEmpty ? Icons.edit_note_outlined : Icons.label_outline, size: 18),
                     label: Text(assignedFlagNames.isNotEmpty ? "Manage Flags" : "Add Flags", style: const TextStyle(fontSize: 11)),
                     onPressed: onManageFlags, // Use passed callback
                     style: TextButton.styleFrom(padding: const EdgeInsets.only(left: 8.0), minimumSize: const Size(50, 20), visualDensity: VisualDensity.compact ),
                   ),
                 ],
               ),
            ),
            // Add a subtle divider between verses (could be optional or handled by ListView separator)
            // Included here for self-contained item styling consistency
             Padding(
                 padding: const EdgeInsets.only(left: 40.0, top: 8.0), // Indent divider too
                 child: Divider(height: 1, thickness: 0.5, color: Colors.grey.shade300),
            ),
        ],
      ),
    );
  }
}