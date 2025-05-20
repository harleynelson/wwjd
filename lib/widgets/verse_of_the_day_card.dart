// File: lib/widgets/verse_of_the_day_card.dart
// Path: lib/widgets/verse_of_the_day_card.dart
// Approximate line: 20 (add onShareAsImage), 83 (add IconButton)

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
  final VoidCallback? onShareAsImage; // <<< NEW CALLBACK
  final bool enableCardAnimations;
  final int speckCount;

  final double fontSizeDelta;
  final ReaderFontFamily readerFontFamily;

  static const double _baseVerseTextFontSize = 17.0;
  static const double _baseVerseRefFontSize = 12.0;
  static const double _baseLabelFontSize = 12.0;
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
    this.onShareAsImage, // <<< NEW PARAMETER
    this.enableCardAnimations = true,
    this.speckCount = 3,
    this.fontSizeDelta = 0.0,
    this.readerFontFamily = ReaderFontFamily.systemDefault,
  });

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
    final Color primaryDarkTextOnCard = Colors.black.withOpacity(0.87); 
    final Color secondaryDarkTextOnCard = Colors.black.withOpacity(0.65); 
    final Color accentColorForRefOnCard = Color.lerp(primaryDarkTextOnCard, Colors.teal.shade800, 0.4) ?? Colors.teal.shade800;
    final Color flagChipDarkTextColor = Colors.black.withOpacity(0.75);
    final Color manageFlagsDarkButtonTextColor = accentColorForRefOnCard; 
    final Color favoriteIconColorOnCard = isFavorite ? Colors.redAccent.shade400 : Colors.grey.shade700;
    final Color flagButtonIconColorOnCard = accentColorForRefOnCard; 
    final Color shareIconColorOnCard = accentColorForRefOnCard; // Using accent color for share icon


    final TextStyle votdLabelStyle = _getTextStyle(
        ReaderFontFamily.systemDefault,
        _baseLabelFontSize, FontWeight.w600, secondaryDarkTextOnCard, letterSpacing: 0.5);

    final TextStyle verseTextStyle = _getTextStyle(
        readerFontFamily, _baseVerseTextFontSize, FontWeight.normal, primaryDarkTextOnCard, fontStyle: FontStyle.italic, height: 1.5);

    final TextStyle verseRefStyle = _getTextStyle(
        readerFontFamily, _baseVerseRefFontSize, FontWeight.bold, accentColorForRefOnCard);

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
              if (!isLoading && onShareAsImage != null) // <<< ADDED SHARE BUTTON
                IconButton(
                  icon: Icon(
                    Icons.image_outlined, // Or Icons.share_outlined if preferred for general share
                    color: shareIconColorOnCard,
                    size: 24, // Slightly smaller than favorite
                  ),
                  padding: const EdgeInsets.only(left: 8, right: 4), // Adjust padding
                  constraints: const BoxConstraints(),
                  tooltip: "Create Shareable Image",
                  onPressed: onShareAsImage,
                ),
              if (!isLoading && onToggleFavorite != null)
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: favoriteIconColorOnCard, 
                    size: 28,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: isFavorite ? "Remove from Favorites" : "Add to Favorites",
                  onPressed: onToggleFavorite,
                )
              else if (isLoading)
                const SizedBox(width: 28 + 24 + 12, height: 28), // Space for both icons
            ],
          ),
          const SizedBox(height: 12.0),
          isLoading
              ? Center(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
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
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.8), 
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.6)),
                )).toList(),
              ),
            TextButton.icon(
                icon: Icon(
                    assignedFlagNames.isNotEmpty ? Icons.edit_note_outlined : Icons.label_outline,
                    size: 18,
                    color: flagButtonIconColorOnCard 
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
        height: 180, // Adjust height if needed based on content
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
      gradientColors: AppColors.eveningCalmGradient, 
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
