// File: lib/widgets/prayer_wall/animated_prayer_mote.dart
// Path: lib/widgets/prayer_wall/animated_prayer_mote.dart
// Approximate line: 1 (Whole file)

import 'package:flutter/material.dart';
import 'dart:math';

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
        
        // Scale: starts small, grows slightly, then shrinks significantly at the end
        final double scale;
        if (value < 0.3) { // Initial growth phase
          scale = 0.3 + (value / 0.3) * 0.7; // From 30% to 100%
        } else if (value > 0.85) { // Final shrink phase
          scale = 1.0 - ((value - 0.85) / 0.15) * 0.95; // From 100% down to 5%
        } else {
          scale = 1.0; // Middle phase at full (relative) size
        }

        // Opacity: fades in, stays, then fades out quickly
        final double opacity;
        if (value < 0.15) {
          opacity = value / 0.15; 
        } else if (value > 0.9) {
          opacity = (1.0 - value) / 0.1; 
        } else {
          opacity = 1.0;
        }

        double baseSize = 12.0; // Base size of the mote's core

        return Positioned(
          left: currentPos.dx - (baseSize * scale / 2), 
          top: currentPos.dy - (baseSize * scale / 2),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale.clamp(0.05, 1.0), // Clamp scale to avoid zero or negative
              child: Container(
                width: baseSize, 
                height: baseSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Core bright color
                  color: Colors.cyanAccent.withOpacity(0.9),
                  boxShadow: [
                    // Larger, softer outer glow
                    BoxShadow(
                      color: Colors.lightBlue.shade200.withOpacity(0.7 * opacity),
                      blurRadius: 15.0 * scale, 
                      spreadRadius: 5.0 * scale,
                    ),
                    // Smaller, more intense inner glow
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8 * opacity),
                      blurRadius: 5.0 * scale,
                      spreadRadius: 1.0 * scale,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}