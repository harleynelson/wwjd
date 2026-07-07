// File: lib/widgets/reading_plans/reading_plan_action_button.dart
// Path: lib/widgets/reading_plans/reading_plan_action_button.dart
import 'package:flutter/material.dart';
import 'package:wwjd_app/models/models.dart'; // For ReadingPlan, UserReadingProgress, ReadingPlanDay
import 'plan_completion_dialog.dart';

typedef AsyncVoidCallback = Future<void> Function();
typedef ContinuePlanCallback = void Function(ReadingPlanDay day);

class ReadingPlanActionButton extends StatelessWidget {
  final bool isLoadingProgress;
  final UserReadingProgress? progress;
  final ReadingPlan plan;
  final bool devPremiumEnabled;
  final AsyncVoidCallback onStartPlan;
  final ContinuePlanCallback onContinuePlan;
  final AsyncVoidCallback onRestartPlan;

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
          // Celebratory completion banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2e7d32), Color(0xFF66bb6a)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Plan Completed!",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "You finished all ${plan.durationDays} days!",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Restart"),
                onPressed: onRestartPlan,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                icon: const Icon(Icons.celebration_outlined, size: 18),
                label: const Text("Celebrate!"),
                onPressed: () {
                  PlanCompletionDialog.show(
                    context,
                    planTitle: plan.title,
                    totalDays: plan.durationDays,
                    streakCount: progress?.streakCount ?? 0,
                    onRestart: onRestartPlan,
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.amber.shade700,
                ),
              ),
            ],
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

      final int completedCount = progress!.completedDays.length;
      final int totalDays = plan.durationDays;

      return Column(
        children: [
          // Progress indicator with encouraging text
          if (completedCount > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: completedCount / totalDays,
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "$completedCount of $totalDays days complete — you're doing great! 🙌",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
          ElevatedButton.icon(
            icon: const Icon(Icons.play_circle_outline),
            label: Text(currentDayReading != null ? "Continue: Day ${progress!.currentDayNumber}" : "Review Plan"),
            onPressed: currentDayReading != null ? () => onContinuePlan(currentDayReading!) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      );
    }
  }
}