// File: lib/widgets/home/prayer_wall_promo_card.dart
// Path: lib/widgets/home/prayer_wall_promo_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Added for Provider
import '../../models/user_prayer_profile_model.dart';
import '../../services/prayer_service.dart'; // Added for PrayerService

class PrayerWallPromoCard extends StatelessWidget {
  final Future<UserPrayerProfile?> prayerStreakProfileFuture;
  final VoidCallback onTap;

  const PrayerWallPromoCard({
    super.key,
    required this.prayerStreakProfileFuture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Get the service to fetch the goal
    final prayerService = Provider.of<PrayerService>(context, listen: false);

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Ink.image(
              image:
                  const AssetImage('assets/images/home/home_prayer_wall.png'),
              height: 220, // Increased height slightly to accommodate the goal
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.35),
                BlendMode.darken,
              ),
            ),
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8), // Darkened slightly for readability
                      Colors.black.withOpacity(0.0),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.0, 0.8],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Community Prayer Wall",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(
                              blurRadius: 2.0,
                              color: Colors.black54,
                              offset: Offset(1, 1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Share your requests & pray for others.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        shadows: [
                          const Shadow(
                              blurRadius: 1.0,
                              color: Colors.black38,
                              offset: Offset(1, 1)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // --- Community Prayer Goal Section (Merged) ---
                    StreamBuilder<Map<String, dynamic>>(
                      stream: prayerService.getGlobalPrayerGoal(),
                      builder: (context, snapshot) {
                        int current = 7430;
                        int target = 10000;
                        String label = "Prayers for Peace";

                        if (snapshot.hasData) {
                          current = snapshot.data!['current'] ?? current;
                          target = snapshot.data!['target'] ?? target;
                          label = snapshot.data!['label'] ?? label;
                        }

                        double progress = (current / target).clamp(0.0, 1.0);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  label,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "$current / $target",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.orangeAccent.shade100,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.orangeAccent.shade100),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    // --- End Community Goal ---

                    const SizedBox(height: 12),
                    
                    // --- Prayer Streak Display ---
                    FutureBuilder<UserPrayerProfile?>(
                      future: prayerStreakProfileFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const SizedBox(
                              height: 18,
                              child: Center(
                                  child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white70),
                                      ))));
                        }
                        final profile = snapshot.data;
                        final streak = profile?.currentPrayerStreak ?? 0;
                        final totalPrayersSent =
                            profile?.totalPrayersSent ?? 0;

                        if (totalPrayersSent == 0) {
                          return Text(
                            "Join the community in prayer!",
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.75),
                                fontStyle: FontStyle.italic),
                          );
                        }

                        if (streak > 0) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department_rounded,
                                  color: Colors.orangeAccent.shade100,
                                  size: 18),
                              const SizedBox(width: 6.0),
                              Text(
                                "$streak Day Prayer Streak",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.95),
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    const Shadow(
                                        blurRadius: 1.0,
                                        color: Colors.black38,
                                        offset: Offset(0.5, 0.5))
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return Text(
                          "Your prayers make a difference!",
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.75),
                              fontStyle: FontStyle.italic),
                        );
                      },
                    ),
                    // --- End Prayer Streak Display ---
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}