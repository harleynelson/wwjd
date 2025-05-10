// lib/widgets/verse_of_the_day_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'animated_religious_background_card.dart';
import '../theme/app_colors.dart';
import '../models/reader_settings_enums.dart'; // For ReaderFontFamily enum

class VerseOfTheDayCard extends StatelessWidget {
  final bool isLoading;
  final String verseText;
  final String verseRef;
  final bool isFavorite;
  final List<String> assignedFlagNames;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onManageFlags;
  final bool enableCardAnimations;
  final int speckCount;

  // --- NEW: Font settings parameters ---
  final double fontSizeDelta;
  final ReaderFontFamily readerFontFamily;

  // Base font sizes
  static const double _baseVerseTextFontSize = 17.0;
  static const double _baseVerseRefFontSize = 12.0;
  static const double _baseLabelFontSize = 12.0; // For "Verse of the Day" label
  static const double _baseFlagChipFontSize = 10.0;
  static const double _baseManageFlagsButtonFontSize = 12.0;

  const VerseOfTheDayCard({
    super.key,
    required this.isLoading,
    required this.verseText,
    required this.verseRef,
    required this.isFavorite,
    required this.assignedFlagNames,
    this.onToggleFavorite,
    this.onManageFlags,
    this.enableCardAnimations = true,
    this.speckCount = 3,
    // --- NEW: Initialize font settings ---
    this.fontSizeDelta = 0.0,
    this.readerFontFamily = ReaderFontFamily.systemDefault,
  });

  // Helper to get text style based on reader settings
  TextStyle _getTextStyle(
      ReaderFontFamily family, double baseSize, FontWeight fontWeight, Color color,
      {FontStyle? fontStyle, double? letterSpacing, double? height}) {
    double currentSize = baseSize + fontSizeDelta;
    TextStyle defaultStyle = TextStyle(
      fontSize: currentSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      height: height,
    );

    switch (family) {
      case ReaderFontFamily.serif:
        return GoogleFonts.notoSerif(textStyle: defaultStyle);
      case ReaderFontFamily.sansSerif:
        return GoogleFonts.roboto(textStyle: defaultStyle);
      case ReaderFontFamily.systemDefault:
      default:
        return defaultStyle;
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- UPDATED: Define DARK text colors for this card's light gradient background ---
    final Color primaryDarkTextOnCard = Colors.black.withOpacity(0.87); // Standard dark primary text
    final Color secondaryDarkTextOnCard = Colors.black.withOpacity(0.65); // Standard dark secondary text
    final Color accentColorForRef = Theme.of(context).colorScheme.primary; // Use app's primary for ref, likely dark enough or theme-aware
    final Color flagChipDarkTextColor = Colors.black.withOpacity(0.75);
    final Color manageFlagsDarkButtonTextColor = Theme.of(context).colorScheme.primary; // App's primary for button text

    // Icon colors on this card's light gradient (should be dark or a contrasting color)
    final Color favoriteIconColorOnCard = isFavorite ? Colors.redAccent.shade400 : Colors.grey.shade700;
    final Color flagButtonIconColorOnCard = Theme.of(context).colorScheme.primary; // App's primary for icon


    // Compute TextStyles using the helper and updated dark text colors
    final TextStyle votdLabelStyle = _getTextStyle(
        ReaderFontFamily.systemDefault,
        _baseLabelFontSize, FontWeight.w600, secondaryDarkTextOnCard, letterSpacing: 0.5);

    final TextStyle verseTextStyle = _getTextStyle(
        readerFontFamily, _baseVerseTextFontSize, FontWeight.normal, primaryDarkTextOnCard, fontStyle: FontStyle.italic, height: 1.5);

    final TextStyle verseRefStyle = _getTextStyle(
        readerFontFamily, _baseVerseRefFontSize, FontWeight.bold, accentColorForRef);

    final TextStyle flagChipStyle = _getTextStyle(
        ReaderFontFamily.systemDefault,
        _baseFlagChipFontSize, FontWeight.normal, flagChipDarkTextColor);

    final TextStyle manageFlagsButtonStyle = _getTextStyle(
        ReaderFontFamily.systemDefault,
        _baseManageFlagsButtonFontSize, FontWeight.normal, manageFlagsDarkButtonTextColor
    );


    Widget cardContent = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Verse of the Day", style: votdLabelStyle),
              const Spacer(),
              if (!isLoading && onToggleFavorite != null)
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: favoriteIconColorOnCard, // Updated icon color
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
              ? Center(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  // Use a theme-aware progress indicator if the card bg is very light
                  child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                ))
              : SelectableText(
                  '"$verseText"',
                  style: verseTextStyle,
                ),
          const SizedBox(height: 8.0),
          if (!isLoading && verseRef.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                verseRef,
                style: verseRefStyle,
              ),
            ),
          if (isFavorite && !isLoading) ...[
            const SizedBox(height: 10),
            if (assignedFlagNames.isNotEmpty)
              Wrap(
                spacing: 6.0, runSpacing: 4.0,
                children: assignedFlagNames.map((name) => Chip(
                  label: Text(name, style: flagChipStyle),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  // Chip background can be light/neutral if text is dark
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                )).toList(),
              ),
            TextButton.icon(
                icon: Icon(
                    assignedFlagNames.isNotEmpty ? Icons.edit_note_outlined : Icons.label_outline,
                    size: 18,
                    color: flagButtonIconColorOnCard // Updated icon color
                ),
                label: Text(
                    assignedFlagNames.isNotEmpty ? "Manage Flags" : "Add Flags",
                    style: manageFlagsButtonStyle
                ),
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
      return SizedBox(
        height: 180,
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
      gradientColors: AppColors.eveningCalmGradient, // Card's specific background
      beginGradientAlignment: Alignment.topRight,
      endGradientAlignment: Alignment.bottomLeft,
      enableGodRays: false,
      enableLightSpecks: enableCardAnimations,
      numberOfSpecks: speckCount,
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        type: MaterialType.transparency,
        child: cardContent,
      ),
    );
  }
}