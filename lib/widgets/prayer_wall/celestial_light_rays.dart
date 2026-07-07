// File: lib/widgets/prayer_wall/celestial_light_rays.dart
// Description: Divine light rays emanating from behind the Well

import 'dart:math';
import 'package:flutter/material.dart';

class CelestialLightRays extends StatefulWidget {
  final int rayCount;
  final double maxRayLength;
  final double minOpacity;
  final double maxOpacity;

  const CelestialLightRays({
    super.key,
    this.rayCount = 12,
    this.maxRayLength = 350,
    this.minOpacity = 0.03,
    this.maxOpacity = 0.12,
  });

  @override
  State<CelestialLightRays> createState() => _CelestialLightRaysState();
}

class _CelestialLightRaysState extends State<CelestialLightRays>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40), // Slow, majestic rotation
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
          painter: _LightRaysPainter(
            rotation: _controller.value * 2 * pi * 0.3, // Slow partial rotation
            rayCount: widget.rayCount,
            maxRayLength: widget.maxRayLength,
            minOpacity: widget.minOpacity,
            maxOpacity: widget.maxOpacity,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _LightRaysPainter extends CustomPainter {
  final double rotation;
  final int rayCount;
  final double maxRayLength;
  final double minOpacity;
  final double maxOpacity;

  _LightRaysPainter({
    required this.rotation,
    required this.rayCount,
    required this.maxRayLength,
    required this.minOpacity,
    required this.maxOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // The light source is centered horizontally, about 40% down from top
    // (this should align with where the Well sits)
    final center = Offset(size.width / 2, size.height * 0.38);

    for (int i = 0; i < rayCount; i++) {
      // Slightly uneven spacing for organic feel
      final angle = rotation + (2 * pi / rayCount) * i;
      // Vary ray lengths
      final rayLen = maxRayLength * (0.6 + 0.4 * ((i * 3) % 7) / 7.0);

      final endX = center.dx + cos(angle) * rayLen;
      final endY = center.dy + sin(angle) * rayLen;

      // Only draw rays going upward/downward (not sideways — creates a beam effect)
      // Actually, let's draw all directions but fade those going too sideways
      final verticality =
          sin(angle).abs(); // 1.0 = straight up/down, 0 = horizontal

      // Warm golden light, fading with distance (soft blur for blending)
      final gradient = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF8E1)
                .withOpacity((maxOpacity * 0.7 * verticality).clamp(0.0, 1.0)),
            const Color(0xFFFFE082)
                .withOpacity((maxOpacity * 0.4 * verticality).clamp(0.0, 1.0)),
            const Color(0xFFFFD54F)
                .withOpacity((minOpacity * verticality).clamp(0.0, 1.0)),
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: rayLen))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      // Draw a triangle/cone for each ray — wider and softer for better blending
      final path = Path();
      final spreadAngle =
          0.13 + (i % 3) * 0.04; // Wider spread for softer blending
      path.moveTo(center.dx, center.dy);
      path.lineTo(
        center.dx + cos(angle - spreadAngle) * rayLen,
        center.dy + sin(angle - spreadAngle) * rayLen,
      );
      path.lineTo(
        center.dx + cos(angle + spreadAngle) * rayLen,
        center.dy + sin(angle + spreadAngle) * rayLen,
      );
      path.close();

      canvas.drawPath(path, gradient);
    }

    // Soft central glow (replaces the hard lines)
    final centerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFDE7).withOpacity(0.25),
          const Color(0xFFFFE082).withOpacity(0.10),
          const Color(0xFFFFD54F).withOpacity(0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.15, 0.4, 1.0],
      ).createShader(
          Rect.fromCircle(center: center, radius: maxRayLength * 0.25))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(center, maxRayLength * 0.25, centerGlow);
  }

  @override
  bool shouldRepaint(covariant _LightRaysPainter oldDelegate) =>
      (oldDelegate.rotation - rotation).abs() > 0.0001;
}
