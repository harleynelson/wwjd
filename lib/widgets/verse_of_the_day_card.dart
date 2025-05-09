// lib/widgets/verse_of_the_day_card.dart
import 'package:flutter/material.dart';
import 'animated_religious_background_card.dart'; // Import the animated background
import '../theme/app_colors.dart'; // Import your color constants

class VerseOfTheDayCard extends StatelessWidget {
  final bool isLoading;
  final String verseText;
  final String verseRef;
  final bool isFavorite;
  final List<String> assignedFlagNames;
  final VoidCallback? onToggleFavorite; 
  final VoidCallback? onManageFlags;
  final bool enableCardAnimations; // To control animations for this instance
  final int speckCount;           // To control speck count

  const VerseOfTheDayCard({
    super.key,
    required this.isLoading,
    required this.verseText,
    required this.verseRef,
    required this.isFavorite,
    required this.assignedFlagNames,
    this.onToggleFavorite,
    this.onManageFlags,
    this.enableCardAnimations = true, // Default to animations enabled
    this.speckCount = 3,             // Default speck count for VotD (can be less than devotional)
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Content of the card
    Widget cardContent = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Important for the content to define its size
        children: [
          Row( 
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Verse of the Day",
                style: textTheme.labelMedium?.copyWith( 
                      color: colorScheme.onSurface.withOpacity(0.8), // Adjusted for potential gradient
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(), 
              if (!isLoading && onToggleFavorite != null)
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.redAccent.shade400 : colorScheme.onSurface.withOpacity(0.7), // Adjusted
                    size: 28,
                  ),
                  padding: EdgeInsets.zero, 
                  constraints: const BoxConstraints(), 
                  tooltip: isFavorite ? "Remove from Favorites" : "Add to Favorites",
                  onPressed: onToggleFavorite,
                )
              else if (isLoading)
                const SizedBox(width: 28, height: 28), 
            ],
          ),
          const SizedBox(height: 12.0),
          isLoading
              ? const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: CircularProgressIndicator(),
                ))
              : SelectableText( 
                  '"$verseText"',
                  style: textTheme.titleMedium?.copyWith( 
                        fontStyle: FontStyle.italic,
                        height: 1.5, 
                        color: colorScheme.onSurface.withOpacity(0.9) // Adjusted
                      ),
                ),
          const SizedBox(height: 8.0),
          if (!isLoading && verseRef.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                verseRef,
                style: textTheme.bodySmall?.copyWith( 
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary, // Keep primary for emphasis
                    ),
              ),
            ),
          if (isFavorite && !isLoading) ...[
            const SizedBox(height: 10),
            if (assignedFlagNames.isNotEmpty)
              Wrap(
                spacing: 6.0, runSpacing: 4.0,
                children: assignedFlagNames.map((name) => Chip(
                  label: Text(name, style: TextStyle(fontSize: 10, color: colorScheme.onSecondaryContainer)),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: colorScheme.secondaryContainer.withOpacity(0.7), // Adjusted opacity
                )).toList(),
              ),
            TextButton.icon(
                icon: Icon(assignedFlagNames.isNotEmpty ? Icons.edit_note_outlined : Icons.label_outline, size: 18, color: colorScheme.primary),
                label: Text(assignedFlagNames.isNotEmpty ? "Manage Flags" : "Add Flags", style: TextStyle(fontSize: 12, color: colorScheme.primary)),
                onPressed: onManageFlags,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0), 
                  minimumSize: const Size(0, 0), 
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
          ]
        ],
      ),
    );

    if (isLoading) {
      // For loading state, use a simpler background or the placeholder gradient
      return SizedBox(
        // Provide a typical height for loading placeholder to avoid layout jumps
        // This height should roughly match the expected height of the loaded card.
        // You might need to adjust this based on typical content.
        height: 180, // Example height
        child: AnimatedReligiousBackgroundCard(
          gradientColors: AppColors.loadingPlaceholderGradient,
          enableGodRays: false,
          enableLightSpecks: false,
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AnimatedReligiousBackgroundCard(
      gradientColors: AppColors.eveningCalmGradient, // Using one of the new gradients
      beginGradientAlignment: Alignment.topRight,   // As requested
      endGradientAlignment: Alignment.bottomLeft, // As requested
      enableGodRays: false,
      enableLightSpecks: enableCardAnimations,
      numberOfSpecks: speckCount, // Use the passed speck count
      elevation: 3.0, // Slightly less elevation than devotional card, or same
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Consistent margin
      child: Material( // Ensures InkWell splashes, etc., render correctly on custom background
        type: MaterialType.transparency,
        child: cardContent,
      ),
    );
  }
}
