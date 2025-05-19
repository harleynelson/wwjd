// File: lib/widgets/home/reading_streak_card.dart
// Path: lib/widgets/home/reading_streak_card.dart
import 'package:flutter/material.dart';

class ReadingStreakCard extends StatelessWidget {
  final Future<int> readingStreakFuture;
  final VoidCallback onTap;

  const ReadingStreakCard({
    super.key,
    required this.readingStreakFuture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const String mainCtaText = "Guided Readings";
    const IconData mainCtaIcon = Icons.checklist_rtl_outlined;

    return FutureBuilder<int>(
      future: readingStreakFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData &&
            !snapshot.hasError) {
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 120,
              child: Center(
                  child: CircularProgressIndicator(
                      color: theme.colorScheme.primary)),
            ),
          );
        }
        int streakCount = 0;
        if (snapshot.hasError) {
          print("Error in readingStreakFuture FutureBuilder: ${snapshot.error}");
        } else if (snapshot.hasData) {
          streakCount = snapshot.data!;
        }

        return Card(
          elevation: 3.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
          child: InkWell(
            onTap: onTap,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Ink.image(
                  image:
                      const AssetImage('assets/images/home/home_reading_plan.png'),
                  height: 120,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.45),
                    BlendMode.darken,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        stops: const [0.0, 0.8],
                      ),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(mainCtaIcon,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 24),
                                const SizedBox(width: 8.0),
                                Text(
                                  mainCtaText,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      const Shadow(
                                          blurRadius: 1.0,
                                          color: Colors.black54,
                                          offset: Offset(1, 1))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 18, color: Colors.white.withOpacity(0.8))
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (streakCount > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department_rounded,
                                  color: Colors.orangeAccent.shade100,
                                  size: 18),
                              const SizedBox(width: 6.0),
                              Text(
                                "$streakCount Day Reading Streak!",
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
                          )
                        else
                          Text(
                            "Start a plan to build your streak!",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              shadows: [
                                const Shadow(
                                    blurRadius: 1.0,
                                    color: Colors.black38,
                                    offset: Offset(0.5, 0.5))
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}