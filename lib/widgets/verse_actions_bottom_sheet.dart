// File: lib/widgets/verse_actions_bottom_sheet.dart
// Path: lib/widgets/verse_actions_bottom_sheet.dart
// Updated: Entire file to ensure all parameters are correctly passed for image generator.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:share_plus/share_plus.dart'; // For sharing
import '../models/models.dart'; // For Verse
import '../helpers/book_names.dart'; // For getFullBookName
import '../screens/verse_image_generator_screen.dart';

class VerseActionsBottomSheet extends StatelessWidget {
  final Verse verse;
  final bool isFavorite;
  final List<String> assignedFlagNames;
  final VoidCallback onToggleFavorite;
  final VoidCallback onManageFlags;
  final String fullBookName; // Already exists, good.
  
  // These are important for passing precise verse context to the image generator
  final String? bookAbbr; 
  final String? chapter;  
  final String? verseNum; 

  const VerseActionsBottomSheet({
    super.key,
    required this.verse,
    required this.isFavorite,
    required this.assignedFlagNames,
    required this.onToggleFavorite,
    required this.onManageFlags,
    required this.fullBookName, // Keep this for display in the sheet itself
    this.bookAbbr, // For image generator
    this.chapter,  // For image generator
    this.verseNum, // For image generator
  });

  Future<void> _copyVerse(BuildContext context, Verse verseToCopy, String bookName) async {
    final String reference = "$bookName ${verseToCopy.chapter}:${verseToCopy.verseNumber}";
    final String textToCopy = '"${verseToCopy.text}" - $reference';
    await Clipboard.setData(ClipboardData(text: textToCopy));
    Navigator.pop(context); 
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
    final String textToShare = '"${verseToShare.text}" - $reference\n\nShared from WWJD App'; // App name added
    Navigator.pop(context); 
    await Share.share(textToShare, subject: 'Bible Verse: $reference');
  }

  void _navigateToImageGenerator(BuildContext context) {
    Navigator.pop(context); 
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerseImageGeneratorScreen(
          initialVerseText: verse.text,
          // Construct the reference string carefully for the generator screen title/default
          initialVerseReference: "$fullBookName ${chapter ?? verse.chapter}:${verseNum ?? verse.verseNumber}",
          initialBookAbbr: bookAbbr ?? verse.bookAbbr, 
          initialChapter: chapter ?? verse.chapter,
          initialVerseNum: verseNum ?? verse.verseNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    // Use the passed-in fullBookName, chapter, and verseNum if available for display,
    // otherwise fallback to verse object's properties.
    final String displayChapter = chapter ?? verse.chapter ?? "?";
    final String displayVerseNum = verseNum ?? verse.verseNumber;
    final String verseReferenceForDisplay = "$fullBookName $displayChapter:$displayVerseNum";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow, // Slightly different background for depth
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ]
      ),
      child: SafeArea( 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 12.0),
              child: Text(
                verseReferenceForDisplay, // Use the potentially more accurate reference
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                textAlign: TextAlign.center,
              ),
            ),
            ListTile(
              leading: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isFavorite ? Colors.red.shade400 : colorScheme.onSurfaceVariant),
              title: Text(isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () {
                Navigator.pop(context);
                onToggleFavorite();
              },
            ),
            if (isFavorite) 
              ListTile(
                leading: Icon(Icons.flag_outlined, color: colorScheme.onSurfaceVariant),
                title: const Text('Manage Flags'),
                onTap: () {
                  Navigator.pop(context); 
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
              title: const Text('Share Verse Text'),
              onTap: () => _shareVerse(context, verse, fullBookName),
            ),
            ListTile(
              leading: Icon(Icons.image_outlined, color: colorScheme.onSurfaceVariant),
              title: const Text('Create Shareable Image'),
              onTap: () => _navigateToImageGenerator(context),
            ),
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

