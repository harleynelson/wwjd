// lib/widgets/reading_plan_list_item.dart
// Path: lib/widgets/reading_plan_list_item.dart

import 'package:flutter/material.dart';
import '../models/models.dart';

class ReadingPlanListItem extends StatelessWidget {
  final ReadingPlan plan;
  final UserReadingProgress? progress;
  final VoidCallback onTap;
  final List<Color> backgroundGradientColors;
  final Alignment beginGradientAlignment;
  final Alignment endGradientAlignment;
  final bool isPlanEffectivelyLocked;

  const ReadingPlanListItem({
    super.key,
    required this.plan,
    this.progress,
    required this.onTap,
    required this.backgroundGradientColors,
    this.beginGradientAlignment = Alignment.topRight,
    this.endGradientAlignment = Alignment.bottomLeft,
    required this.isPlanEffectivelyLocked,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    double progressValue = 0.0;
    String progressText = "Not Started";
    bool isCompleted = false;

    if (progress != null && progress!.isActive) {
      if (plan.durationDays > 0) {
        progressValue = progress!.completedDays.length / plan.durationDays;
      }
      if (progress!.completedDays.length >= plan.durationDays) {
        progressText = "Completed!";
        isCompleted = true;
      } else if (progress!.completedDays.isNotEmpty) {
        progressText = "${progress!.completedDays.length} / ${plan.durationDays} days";
      } else if (progress!.currentDayNumber > 1) {
         progressText = "In Progress";
      }
    } else if (progress != null && !progress!.isActive && progress!.completedDays.length >= plan.durationDays) {
      progressValue = 1.0;
      progressText = "Completed";
      isCompleted = true;
    // --- CORRECTED: Use 'isPlanEffectivelyLocked' directly ---
    } else if (isPlanEffectivelyLocked && progress == null) { 
        progressText = "Premium Plan";
    }
    // --- END CORRECTION ---


    Widget headerBackground;
    if (plan.headerImageAssetPath != null && plan.headerImageAssetPath!.isNotEmpty) {
      headerBackground = Image.asset(
        plan.headerImageAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
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
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  headerBackground,
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: const [0.0, 0.8],
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
                  // --- CORRECTED: Use 'plan.isPremium' and 'isPlanEffectivelyLocked' directly ---
                  if (plan.isPremium) 
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Chip(
                        label: Text(isPlanEffectivelyLocked ? "Premium" : "Premium (Dev)", style: TextStyle(fontSize: 9)),
                        backgroundColor: isPlanEffectivelyLocked
                                          ? Colors.amber.shade700.withOpacity(0.7) 
                                          : Colors.green.shade700.withOpacity(0.7), 
                        labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  // --- END CORRECTION ---
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
                    maxLines: 2,
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
                      if (progress != null && progress!.isActive || isCompleted)
                        Text(
                          progressText, 
                          style: textTheme.labelLarge?.copyWith(
                            color: isCompleted ? Colors.green.shade700 : colorScheme.tertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      // --- CORRECTED: Use 'isPlanEffectivelyLocked' directly ---
                      else if (isPlanEffectivelyLocked && progress == null)
                         Text("Premium Plan", style: textTheme.labelLarge?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold))
                      // --- END CORRECTION ---
                      else 
                         Text(progressText, style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (progress != null && progress!.isActive && !isCompleted && progressValue > 0) ...[
                    const SizedBox(height: 8.0),
                    LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
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