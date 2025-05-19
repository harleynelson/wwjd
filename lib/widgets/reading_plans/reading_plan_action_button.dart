// File: lib/widgets/reading_plans/reading_plan_action_button.dart
// Path: lib/widgets/reading_plans/reading_plan_action_button.dart
import 'package:flutter/material.dart';
import 'package:wwjd_app/models/models.dart'; // For ReadingPlan, UserReadingProgress, ReadingPlanDay

typedef AsyncVoidCallback = Future<void> Function();
typedef ContinuePlanCallback = void Function(ReadingPlanDay day);

class ReadingPlanActionButton extends StatelessWidget {
  final bool isLoadingProgress;
  final UserReadingProgress? progress;
  final ReadingPlan plan;
  final bool devPremiumEnabled; // To determine if a premium plan is effectively unlocked
  final AsyncVoidCallback onStartPlan;
  final ContinuePlanCallback onContinuePlan;
  final AsyncVoidCallback onRestartPlan; // Callback for restarting the plan

  const ReadingPlanActionButton({
    super.key,
    required this.isLoadingProgress,
    required this.progress,
    required this.plan,
    required this.devPremiumEnabled,
    required this.onStartPlan,
    required this.onContinuePlan,
    required this.onRestartPlan,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingProgress) {
      return const Center(child: CircularProgressIndicator());
    }

    bool isFullyCompleted = progress != null && progress!.completedDays.length >= plan.durationDays;
    bool effectivelyHasPremiumAccess = devPremiumEnabled || !plan.isPremium; 
    bool planRequiresPremiumAndNotOwned = plan.isPremium && !effectivelyHasPremiumAccess;


    if (progress == null || (!progress!.isActive && !isFullyCompleted)) {
      return ElevatedButton.icon(
        icon: Icon(planRequiresPremiumAndNotOwned ? Icons.lock_outline : Icons.play_arrow),
        label: Text(planRequiresPremiumAndNotOwned ? "Unlock Premium" : "Start Plan"),
        onPressed: onStartPlan, 
        style: ElevatedButton.styleFrom(
          backgroundColor: planRequiresPremiumAndNotOwned
                           ? Colors.grey.shade600 
                           : Theme.of(context).colorScheme.primary,
          foregroundColor: planRequiresPremiumAndNotOwned
                           ? Colors.white70
                           : Theme.of(context).colorScheme.onPrimary,
        ),

      );
    } else if (isFullyCompleted) {
      return Column(
        children: [
          Text("Plan Completed!", style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("Restart Plan (Deletes Progress)"),
            onPressed: onRestartPlan,
             style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
             ),
          ),
        ],
      );
    } else { 
      ReadingPlanDay? currentDayReading;
      if (progress!.currentDayNumber > 0 && progress!.currentDayNumber <= plan.dailyReadings.length) {
        try {
          currentDayReading = plan.dailyReadings.firstWhere((day) => day.dayNumber == progress!.currentDayNumber);
        } catch (e) {
          print("Error finding current day reading in ReadingPlanActionButton: $e");
        }
      }

      return ElevatedButton.icon(
        icon: const Icon(Icons.play_circle_outline),
        label: Text(currentDayReading != null ? "Continue: Day ${progress!.currentDayNumber}" : "Review Plan"),
        onPressed: currentDayReading != null ? () => onContinuePlan(currentDayReading!) : null,
        style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary),
      );
    }
  }
}