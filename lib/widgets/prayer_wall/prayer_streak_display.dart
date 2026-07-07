// File: lib/widgets/prayer_wall/prayer_streak_display.dart
// Description: Illuminated manuscript-style prayer streak banner

import 'package:flutter/material.dart';
import '../../models/user_prayer_profile_model.dart';

class PrayerStreakDisplay extends StatefulWidget {
  final bool isLoadingStreak;
  final UserPrayerProfile? currentUserPrayerProfile;
  final bool isUserLoggedIn;

  const PrayerStreakDisplay({
    Key? key,
    required this.isLoadingStreak,
    this.currentUserPrayerProfile,
    required this.isUserLoggedIn,
  }) : super(key: key);

  @override
  State<PrayerStreakDisplay> createState() => _PrayerStreakDisplayState();
}

class _PrayerStreakDisplayState extends State<PrayerStreakDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isLoadingStreak) {
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

    final streak = widget.currentUserPrayerProfile?.currentPrayerStreak ?? 0;
    final prayersToday =
        widget.currentUserPrayerProfile?.prayersSentOnStreakDay ?? 0;
    final totalPrayersSent =
        widget.currentUserPrayerProfile?.totalPrayersSent ?? 0;

    if (!widget.isUserLoggedIn || totalPrayersSent == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
        child: Text(
          widget.isUserLoggedIn
              ? "Tap a prayer below to send support and start your prayer streak!"
              : "Tap a prayer below to send support!",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFFFFF8E1).withOpacity(0.65),
            letterSpacing: 0.8,
          ),
        ),
      );
    }

    bool isTodayStreakDay = false;
    if (widget.currentUserPrayerProfile?.lastPrayerStreakTimestamp != null) {
      final lastStreakDate =
          widget.currentUserPrayerProfile!.lastPrayerStreakTimestamp!.toDate();
      final nowDate = DateTime.now();
      isTodayStreakDay = lastStreakDate.year == nowDate.year &&
          lastStreakDate.month == nowDate.month &&
          lastStreakDate.day == nowDate.day;
    }

    // Flame intensity based on streak length
    final streakTier = streak >= 30
        ? 3
        : streak >= 14
            ? 2
            : streak >= 7
                ? 1
                : 0;

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final shimmerValue = _shimmerController.value;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF3E2723).withOpacity(0.4),
                  const Color(0xFF5D4037).withOpacity(0.35),
                  const Color(0xFF3E2723).withOpacity(0.4),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFFFD180).withOpacity(0.2),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB74D)
                      .withOpacity(0.08 + streakTier * 0.03),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main streak row with decorative flames
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left decorative flame
                      _buildFlameIcon(streakTier, shimmerValue),
                      const SizedBox(width: 12),
                      // Streak text
                      Text(
                        "$streak",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: _getFlameColor(streakTier),
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: _getFlameColor(streakTier)
                                  .withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Day\nStreak",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFFFF8E1).withOpacity(0.8),
                          height: 1.3,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Right decorative flame
                      _buildFlameIcon(streakTier, 1.0 - shimmerValue),
                    ],
                  ),

                  // Subtle shimmer line
                  if (streakTier >= 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        height: 1,
                        width: 120 + streakTier * 20,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              _getFlameColor(streakTier)
                                  .withOpacity(0.3 + 0.2 * shimmerValue),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Subtitle with today's count and total
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      isTodayStreakDay && prayersToday > 0
                          ? "$prayersToday lifted today · $totalPrayersSent total"
                          : "$totalPrayersSent prayers lifted",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFFFF8E1).withOpacity(0.55),
                        fontSize: 11,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlameIcon(int tier, double shimmerValue) {
    final color = _getFlameColor(tier);
    final size = 18.0 + tier * 3.0;

    return Icon(
      Icons.local_fire_department_rounded,
      color: color.withOpacity(0.6 + 0.4 * shimmerValue),
      size: size,
      shadows: [
        Shadow(
          color: color.withOpacity(0.5 + 0.3 * shimmerValue),
          blurRadius: 8,
        ),
      ],
    );
  }

  Color _getFlameColor(int tier) {
    switch (tier) {
      case 3:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFFFAB40); // Deep amber
      case 1:
        return const Color(0xFFFF8A65); // Warm orange
      default:
        return const Color(0xFFFFCC80); // Soft amber
    }
  }
}