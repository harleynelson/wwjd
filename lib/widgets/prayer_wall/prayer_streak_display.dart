// File: lib/widgets/prayer_wall/prayer_streak_display.dart
// Path: lib/widgets/prayer_wall/prayer_streak_display.dart
// New file: Contains the PrayerStreakDisplay widget.

import 'package:flutter/material.dart';
import '../../models/user_prayer_profile_model.dart'; // For UserPrayerProfile

class PrayerStreakDisplay extends StatelessWidget {
  final bool isLoadingStreak;
  final UserPrayerProfile? currentUserPrayerProfile;
  final bool isUserLoggedIn; // To differentiate between no profile and no logged-in user

  const PrayerStreakDisplay({
    Key? key,
    required this.isLoadingStreak,
    this.currentUserPrayerProfile,
    required this.isUserLoggedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoadingStreak) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.white70),
          ),
        ),
      );
    }

    if (!isUserLoggedIn) { // If no user (not even anonymous) is available
        return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 0),
        child: Text(
          "Tap a prayer below to send support!",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: Colors.white.withOpacity(0.6)),
        ),
      );
    }
    
    // At this point, we assume isUserLoggedIn is true, so currentUserPrayerProfile *could* be null
    // if the profile hasn't been created yet (e.g., first time anonymous user)
    // or if there was an error fetching it.

    final streak = currentUserPrayerProfile?.currentPrayerStreak ?? 0;
    final prayersToday = currentUserPrayerProfile?.prayersSentOnStreakDay ?? 0;
    final totalPrayersSent = currentUserPrayerProfile?.totalPrayersSent ?? 0;

    if (totalPrayersSent == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 0),
        child: Text(
          "Tap a prayer below to send support and start your prayer streak!",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: Colors.white.withOpacity(0.6)),
        ),
      );
    }

    // If they have prayed before, show streak (even if current streak is 0)
    // This condition also covers the case where currentUserPrayerProfile might be null but totalPrayersSent > 0 (though less likely)
    if (streak > 0 || prayersToday > 0 || totalPrayersSent > 0) {
      bool isTodayStreakDay = false;
      if (currentUserPrayerProfile?.lastPrayerStreakTimestamp != null) {
        final lastStreakDate =
            currentUserPrayerProfile!.lastPrayerStreakTimestamp!.toDate();
        final nowDate = DateTime.now();
        isTodayStreakDay = lastStreakDate.year == nowDate.year &&
            lastStreakDate.month == nowDate.month &&
            lastStreakDate.day == nowDate.day;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_fire_department_rounded,
                color: streak > 0
                    ? Colors.orangeAccent.shade100
                    : Colors.white54,
                size: 22),
            const SizedBox(width: 8),
            Text(
              "$streak Day Prayer Streak",
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (prayersToday > 0 && isTodayStreakDay) ...[
              const SizedBox(width: 4),
              Text(
                "($prayersToday today)",
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.white70),
              ),
            ]
          ],
        ),
      );
    }
    // Fallback if conditions not met (e.g., data inconsistency)
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 0),
      child: Text(
        "Keep the prayers flowing to build your streak!",
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall
            ?.copyWith(color: Colors.white.withOpacity(0.6)),
      ),
    );
  }
}