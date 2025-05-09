// lib/widgets/devotional_of_the_day_card.dart
import 'package:flutter/material.dart';
import '../daily_devotions.dart';
import 'animated_religious_background_card.dart';
import '../theme/app_colors.dart'; // Assuming AppColors is used for gradients

class DevotionalOfTheDayCard extends StatefulWidget {
  final Devotional devotional;
  final bool isLoading;
  final bool enableCardAnimations;
  final int speckCount;

  const DevotionalOfTheDayCard({
    super.key,
    required this.devotional,
    this.isLoading = false,
    this.enableCardAnimations = true, 
    this.speckCount = 15,             
  });

  @override
  State<DevotionalOfTheDayCard> createState() => _DevotionalOfTheDayCardState();
}

class _DevotionalOfTheDayCardState extends State<DevotionalOfTheDayCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.isLoading) {
      return SizedBox( 
        height: 200, 
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
    
    if (widget.devotional.title == "No Devotional Available" || widget.devotional.title == "Content Coming Soon") {
      return AnimatedReligiousBackgroundCard( 
        gradientColors: AppColors.mutedPlaceholderGradient,
        enableGodRays: false,
        enableLightSpecks: false,
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding( 
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Daily Reflection", style: textTheme.headlineSmall?.copyWith( fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant, ), ),
              const SizedBox(height: 12.0),
              Text( widget.devotional.coreMessage, style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center, ),
              const SizedBox(height: 8.0),
              Text( widget.devotional.reflection, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.8)), textAlign: TextAlign.center, ),
            ],
          ),
        ),
      );
    }

    // --- Content construction with new layout ---
    Widget devotionalContent = Material( 
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.all(16.0), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // For the "Daily Reflection" label
            mainAxisSize: MainAxisSize.min, 
            children: [
              // 1. "Daily Reflection" Label
              Text(
                "Daily Reflection",
                style: textTheme.labelMedium?.copyWith( // Smaller font
                      color: colorScheme.onSurface.withOpacity(0.7), // Muted color
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 10.0),

              // 2. Title (Centered, smaller)
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // Ensure some padding if title is long
                  child: Text(
                    widget.devotional.title,
                    style: textTheme.headlineSmall?.copyWith( // Was headlineSmall, maybe titleLarge or adjust fontSize
                          fontWeight: FontWeight.bold,
                          fontSize: textTheme.headlineSmall!.fontSize! * 0.9, // Slightly smaller
                          color: colorScheme.onPrimaryContainer, 
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2, // Allow for two lines if absolutely necessary
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // 3. Body texts (slightly smaller)
              Text(
                widget.devotional.coreMessage,
                style: textTheme.titleMedium?.copyWith( // Was titleLarge
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSecondaryContainer, 
                    ),
                maxLines: _isExpanded ? null : 3,
                overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12.0),

              if (widget.devotional.scriptureFocus.isNotEmpty) ...[
                RichText(
                  text: TextSpan( 
                    // Base style for scripture - was bodyLarge
                    style: textTheme.bodyMedium?.copyWith(height: 1.5, color: colorScheme.onSurface.withOpacity(0.9)), 
                    children: [
                      TextSpan(
                        text: '"${widget.devotional.scriptureFocus}" ',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      TextSpan(
                        text: widget.devotional.scriptureReference,
                        style: TextStyle( 
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary 
                            ),
                      ),
                    ],
                  ),
                  maxLines: _isExpanded ? null : 2,
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12.0),
              ],

              AnimatedCrossFade( 
                firstChild: const SizedBox.shrink(), 
                secondChild: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(color: colorScheme.outline.withOpacity(0.5)),
                    const SizedBox(height: 12.0),
                    SelectableText(
                      widget.devotional.reflection,
                      // Was bodyMedium, consider bodySmall or slightly smaller bodyMedium
                      style: textTheme.bodyMedium?.copyWith(height: 1.6, fontSize: textTheme.bodyMedium!.fontSize! * 0.95, color: colorScheme.onSurface.withOpacity(0.85)),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 16.0),
                    Divider(color: colorScheme.outline.withOpacity(0.5)),
                    const SizedBox(height: 12.0),
                    Text(
                      "Today's Declaration:",
                      style: textTheme.titleSmall?.copyWith( // Was titleMedium
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 8.0),
                    SelectableText(
                      widget.devotional.prayerDeclaration,
                      // Was bodyLarge, consider bodyMedium or slightly smaller bodyLarge
                      style: textTheme.bodyMedium?.copyWith( // Was bodyLarge
                            fontStyle: FontStyle.italic,
                            color: colorScheme.tertiary, 
                            fontWeight: FontWeight.w500,
                             fontSize: textTheme.bodyMedium!.fontSize! * 0.95,
                          ),
                    ),
                  ],
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
              InkWell( 
                onTap: () { setState(() { _isExpanded = !_isExpanded; }); },
                child: Padding( 
                  padding: const EdgeInsets.only(top: 12.0, bottom: 4.0), 
                  child: Row( 
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text( _isExpanded ? "Show Less" : "Read More", style: textTheme.labelLarge?.copyWith( color: colorScheme.primary, fontWeight: FontWeight.bold, ), ),
                      const SizedBox(width: 4.0),
                      Icon( _isExpanded ? Icons.expand_less : Icons.expand_more, color: colorScheme.primary, size: 20.0, ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

    return AnimatedReligiousBackgroundCard(
      gradientColors: AppColors.devotionalCardTwoColorGradient, // Or your preferred gradient
      beginGradientAlignment: Alignment.topRight,
      endGradientAlignment: Alignment.bottomLeft,
      enableGodRays: widget.enableCardAnimations,
      enableLightSpecks: widget.enableCardAnimations,
      numberOfSpecks: widget.speckCount,
      elevation: 4.0, 
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: devotionalContent,
    );
  }
}