// File: lib/widgets/prayer_wall/animated_prayer_mote.dart
// Description: Glowing prayer mote with comet trail & arrival burst

import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedPrayerMote extends StatelessWidget {
  final Animation<double> progress; // 0.0 to 1.0
  final Offset startPosition;
  final Offset endPosition;
  final String prayerText;

  const AnimatedPrayerMote({
    super.key,
    required this.progress,
    required this.startPosition,
    required this.endPosition,
    required this.prayerText,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final value = progress.value;
        final currentPos = Offset.lerp(startPosition, endPosition, value)!;

        // Scale: steady throughout, only shrink into the well at the end
        final double scale;
        if (value > 0.8) {
          scale = 1.0 - ((value - 0.8) / 0.2) * 0.92; // 100% → 8%
        } else {
          scale = 1.0;
        }

        // Opacity: fade in smoothly, hold, fade out
        final double opacity;
        if (value < 0.15) {
          opacity = value / 0.15;
        } else if (value > 0.85) {
          opacity = (1.0 - value) / 0.15;
        } else {
          opacity = 1.0;
        }

        final double baseSize = 14.0;
        final clampedScale = scale.clamp(0.04, 1.0);
        final clampedOpacity = opacity.clamp(0.0, 1.0);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // --- Comet Trail (trailing particles) ---
            if (value > 0.05 && value < 0.9)
              for (int i = 1; i <= 4; i++)
                _buildTrailParticle(
                  currentPos,
                  startPosition,
                  endPosition,
                  value,
                  i,
                  clampedOpacity,
                ),

            // --- Main Mote Core ---
            Positioned(
              left: currentPos.dx - (baseSize * clampedScale / 2),
              top: currentPos.dy - (baseSize * clampedScale / 2),
              child: Opacity(
                opacity: clampedOpacity,
                child: Transform.scale(
                  scale: clampedScale,
                  child: Container(
                    width: baseSize,
                    height: baseSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Warm golden-white core
                      gradient: RadialGradient(
                        colors: [
                          Colors.white,
                          const Color(0xFFFFF9C4).withOpacity(0.9),
                          const Color(0xFFFFB74D).withOpacity(0.6),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                      boxShadow: [
                        // Outer golden glow (subtle during flight)
                        BoxShadow(
                          color: const Color(0xFFFFD54F)
                              .withOpacity(0.35 * clampedOpacity),
                          blurRadius: 12.0 * clampedScale,
                          spreadRadius: 3.0 * clampedScale,
                        ),
                        // Inner bright white core
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5 * clampedOpacity),
                          blurRadius: 4.0 * clampedScale,
                          spreadRadius: 1.0 * clampedScale,
                        ),
                        // Soft amber halo
                        BoxShadow(
                          color: const Color(0xFFFF8A65)
                              .withOpacity(0.2 * clampedOpacity),
                          blurRadius: 18.0 * clampedScale,
                          spreadRadius: 5.0 * clampedScale,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrailParticle(
    Offset currentPos,
    Offset start,
    Offset end,
    double value,
    int index,
    double parentOpacity,
  ) {
    // Each trail particle lags behind the main mote
    final trailOffset = 0.04 * index;
    final trailValue = (value - trailOffset).clamp(0.0, 1.0);
    if (trailValue <= 0) return const SizedBox.shrink();

    final trailPos = Offset.lerp(start, end, trailValue)!;
    final trailOpacity = parentOpacity * (0.4 - index * 0.08).clamp(0.0, 1.0);
    final trailSize = (4.0 - index * 0.7).clamp(1.5, 4.0);

    return Positioned(
      left: trailPos.dx - trailSize / 2,
      top: trailPos.dy - trailSize / 2,
      child: Opacity(
        opacity: trailOpacity,
        child: Container(
          width: trailSize,
          height: trailSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFF9C4).withOpacity(0.7),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD54F).withOpacity(0.5 * trailOpacity),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
