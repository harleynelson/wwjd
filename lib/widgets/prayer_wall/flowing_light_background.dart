// File: lib/widgets/prayer_wall/flowing_light_background.dart
// Description: Flowing light river behind prayer cards

import 'dart:math';
import 'package:flutter/material.dart';

class FlowingLightBackground extends StatefulWidget {
  const FlowingLightBackground({super.key});

  @override
  State<FlowingLightBackground> createState() => _FlowingLightBackgroundState();
}

class _FlowingLightBackgroundState extends State<FlowingLightBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _FlowingLightPainter(progress: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _FlowingLightPainter extends CustomPainter {
  final double progress;

  _FlowingLightPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final riverHeight = size.height * 0.45;

    // Small floating light motes
    final moteCount = 30;
    final random = Random(42); // Seeded for consistency
    for (int i = 0; i < moteCount; i++) {
      final x = (random.nextDouble() * size.width + progress * size.width) %
          size.width;
      final y = centerY -
          riverHeight * 0.35 +
          random.nextDouble() * riverHeight * 0.7;
      final moteSize = 0.8 + random.nextDouble() * 1.5;
      final twinkle = 0.3 + 0.7 * sin(progress * 10 + i * 3.7);

      final motePaint = Paint()
        ..color = (i % 3 == 0
                ? const Color(0xFF4DD0E1)
                : i % 3 == 1
                    ? const Color(0xFFFFF9C4)
                    : const Color(0xFF80CBC4))
            .withOpacity(0.1 + twinkle * 0.15)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), moteSize, motePaint);

      // Glow for some
      if (twinkle > 0.7) {
        final glowPaint = Paint()
          ..color = const Color(0xFFB2EBF2).withOpacity(twinkle * 0.04);
        canvas.drawCircle(Offset(x, y), moteSize * 2, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FlowingLightPainter oldDelegate) => true;
}
