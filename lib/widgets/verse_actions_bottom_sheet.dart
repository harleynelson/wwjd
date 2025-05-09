// File: lib/widgets/verse_actions_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:share_plus/share_plus.dart'; // For sharing
import '../models.dart'; // For Verse
import '../book_names.dart'; // For getFullBookName

class VerseActionsBottomSheet extends StatelessWidget {
  final Verse verse;
  final bool isFavorite;
  final List<String> assignedFlagNames; // For display if needed, or just for context
  final VoidCallback onToggleFavorite;
  final VoidCallback onManageFlags;
  final String fullBookName; // Pre-fetched full book name

  const VerseActionsBottomSheet({
    super.key,
    required this.verse,
    required this.isFavorite,
    required this.assignedFlagNames,
    required this.onToggleFavorite,
    required this.onManageFlags,
    required this.fullBookName,
  });

  Future<void> _copyVerse(BuildContext context, Verse verseToCopy, String bookName) async {
    final String reference = "$bookName ${verseToCopy.chapter}:${verseToCopy.verseNumber}";
    final String textToCopy = '"${verseToCopy.text}" - $reference';
    await Clipboard.setData(ClipboardData(text: textToCopy));
    Navigator.pop(context); // Close the bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verse copied to clipboard!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        margin: EdgeInsets.all(10),
      ),
    );
  }

  Future<void> _shareVerse(BuildContext context, Verse verseToShare, String bookName) async {
    final String reference = "$bookName ${verseToShare.chapter}:${verseToShare.verseNumber}";
    final String textToShare = '"${verseToShare.text}" - $reference\n\nShared from Wake up With Jesus Daily';
    Navigator.pop(context); // Close bottom sheet BEFORE sharing to avoid context issues on some platforms
    await Share.share(textToShare, subject: 'Bible Verse: $reference');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    final String verseReference = "$fullBookName ${verse.chapter}:${verse.verseNumber}";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surface, // Or surfaceContainerLow for more depth
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: SafeArea( // Ensures content is not obscured by system intrusions
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 12.0),
              child: Text(
                verseReference,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                textAlign: TextAlign.center,
              ),
            ),
            ListTile(
              leading: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isFavorite ? Colors.red.shade400 : colorScheme.onSurfaceVariant),
              title: Text(isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () {
                // Navigator.pop(context); // Close bottom sheet first
                onToggleFavorite();
                 // Optionally, keep sheet open or provide feedback. For now, callback handles UI update & sheet closing implicitly if screen rebuilds.
                 // If the action itself should close the sheet, then call Navigator.pop(context) here.
                 // Since _toggleFavorite in FullBibleReaderScreen causes a setState, it might rebuild and the sheet context might be lost.
                 // It's often better to pop *after* the action if the action doesn't involve navigation or heavy async work that relies on the sheet's context.
                 // However, for toggleFavorite, the parent screen will rebuild, so popping first is safer.
                Navigator.pop(context);
              },
            ),
            if (isFavorite) // Only show manage flags if it's a favorite
              ListTile(
                leading: Icon(Icons.flag_outlined, color: colorScheme.onSurfaceVariant),
                title: const Text('Manage Flags'),
                onTap: () {
                  Navigator.pop(context); // Close this sheet before opening dialog
                  onManageFlags();
                },
              ),
            ListTile(
              leading: Icon(Icons.copy_outlined, color: colorScheme.onSurfaceVariant),
              title: const Text('Copy Verse'),
              onTap: () => _copyVerse(context, verse, fullBookName),
            ),
            ListTile(
              leading: Icon(Icons.share_outlined, color: colorScheme.onSurfaceVariant),
              title: const Text('Share Verse'),
              onTap: () => _shareVerse(context, verse, fullBookName),
            ),
            // Potential future premium features:
            // ListTile(
            //   leading: Icon(Icons.edit_note_outlined, color: colorScheme.onSurfaceVariant),
            //   title: Text('Add Note (Premium)'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     // TODO: Implement or show premium upsell for notes
            //   },
            // ),
            // ListTile(
            //   leading: Icon(Icons.menu_book_outlined, color: colorScheme.onSurfaceVariant),
            //   title: Text('View Commentary (Premium)'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     // TODO: Implement or show premium upsell for commentary
            //   },
            // ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                child: const Text('Dismiss'),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}