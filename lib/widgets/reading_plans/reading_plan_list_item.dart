// lib/widgets/reading_plan_list_item.dart
// Path: lib/widgets/reading_plan_list_item.dart
// This is the version consistent with your initially uploaded ReadingPlansListScreen

import 'package:flutter/material.dart';
import '../../models/models.dart'; // For ReadingPlan and UserReadingProgress
import '../../theme/app_colors.dart'; // For AppColors.getReadingPlanGradient

class ReadingPlanListItem extends StatelessWidget {
  final ReadingPlan plan;
  final UserReadingProgress? progress;
  final VoidCallback onTap;
  final List<Color> backgroundGradientColors;
  final Alignment beginGradientAlignment;
  final Alignment endGradientAlignment;
  final bool isPlanEffectivelyLocked; // This was a parameter we added later in discussion

  const ReadingPlanListItem({
    super.key,
    required this.plan,
    this.progress,
    required this.onTap,
    required this.backgroundGradientColors, // This was expected by the calling screen
    this.beginGradientAlignment = Alignment.topLeft, // Default if not specified earlier
    this.endGradientAlignment = Alignment.bottomRight, // Default if not specified earlier
    required this.isPlanEffectivelyLocked, // This was expected by the calling screen
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    double progressValue = 0.0;
    String progressText = "Not Started"; // Default text
    bool isCompleted = false;
    int completedDaysCount = 0;

    if (progress != null && progress!.isActive) {
      completedDaysCount = progress!.completedDays.length;
      if (plan.durationDays > 0) {
        progressValue = completedDaysCount / plan.durationDays;
      }
      if (completedDaysCount >= plan.durationDays) {
        progressText = "Completed!";
        isCompleted = true;
      } else if (completedDaysCount > 0) {
        progressText = "$completedDaysCount / ${plan.durationDays} days";
      } else if (progress!.currentDayNumber > 1 && completedDaysCount == 0) {
         // Started but no days marked complete yet beyond day 1 not being the current
         progressText = "In Progress";
      }
    } else if (progress != null && !progress!.isActive && progress!.completedDays.length >= plan.durationDays) {
      // Case where plan was completed and then perhaps made inactive (though less common)
      progressValue = 1.0;
      progressText = "Completed";
      isCompleted = true;
    } else if (isPlanEffectivelyLocked && progress == null) {
        progressText = "Premium Plan";
    }


    Widget headerBackground;
    if (plan.headerImageAssetPath != null && plan.headerImageAssetPath!.isNotEmpty) {
      headerBackground = Image.asset(
        plan.headerImageAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
          // Fallback gradient if image fails to load
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: backgroundGradientColors,
                begin: beginGradientAlignment,
                end: endGradientAlignment,
              ),
            ),
          );
        },
      );
    } else {
      // Default gradient if no image path is provided
      headerBackground = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: backgroundGradientColors,
            begin: beginGradientAlignment,
            end: endGradientAlignment,
          ),
        ),
      );
    }

    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap, // Use the passed onTap callback
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120, // Fixed height for the header image/gradient area
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  headerBackground,
                  // Scrim for text readability on image
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: const [0.0, 0.8], // Adjust scrim intensity and spread
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        plan.title,
                        style: textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            const Shadow(blurRadius: 2.0, color: Colors.black54, offset: Offset(1,1))
                          ]
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (plan.isPremium) // Check the plan's own premium status
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Chip(
                        label: Text(
                          isPlanEffectivelyLocked ? "Premium" : "Premium (Dev Unlocked)", // Differentiate based on effective lock status
                          style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                        backgroundColor: isPlanEffectivelyLocked
                                          ? Colors.amber.shade700.withOpacity(0.7) 
                                          : Colors.green.shade700.withOpacity(0.7), 
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.category,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    plan.description,
                    style: textTheme.bodyMedium?.copyWith(color: textTheme.bodySmall?.color?.withOpacity(0.8)),
                    maxLines: 2, // Limit description lines in list view
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${plan.durationDays} Days",
                        style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        progressText, 
                        style: textTheme.labelLarge?.copyWith(
                          color: isCompleted ? Colors.green.shade700 : ( (progress != null && progress!.isActive) ? colorScheme.tertiary : colorScheme.onSurface.withOpacity(0.7) ),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  if (progress != null && progress!.isActive && !isCompleted && progressValue > 0) ...[
                    const SizedBox(height: 8.0),
                    LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5), // Lighter background for progress
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary), // Use primary color for progress
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}