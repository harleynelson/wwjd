// lib/widgets/reading_plan_list_item.dart
import 'package:flutter/material.dart';
import '../models.dart'; // For ReadingPlan and UserReadingProgress
import '../helpers/ui_helpers.dart'; // We'll create this for the gradient

class ReadingPlanListItem extends StatelessWidget {
  final ReadingPlan plan;
  final UserReadingProgress? progress;
  final VoidCallback onTap;

  const ReadingPlanListItem({
    super.key,
    required this.plan,
    this.progress,
    required this.onTap,
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
      } else if (progress!.currentDayNumber > 1) { // Started but no days marked complete yet
         progressText = "In Progress";
      }
    } else if (progress != null && !progress!.isActive && progress!.completedDays.length >= plan.durationDays) {
      // Plan was completed and then perhaps marked inactive
      progressValue = 1.0;
      progressText = "Completed";
      isCompleted = true;
    }


    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      clipBehavior: Clip.antiAlias, // Ensures gradient corners are rounded
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120, // Height for the gradient/image placeholder
              decoration: BoxDecoration(
                gradient: UiHelper.generateGradient(plan.id), // Use helper
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      alignment: Alignment.bottomLeft,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
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
                  if (plan.isPremium)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Chip(
                        label: const Text("Premium"),
                        backgroundColor: colorScheme.secondaryContainer,
                        labelStyle: TextStyle(color: colorScheme.onSecondaryContainer, fontSize: 10, fontWeight: FontWeight.bold),
                        padding: EdgeInsets.zero,
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
                      else if (plan.isPremium && progress == null) // Show premium status if not started
                         Text("Premium Plan", style: textTheme.labelLarge?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold))
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