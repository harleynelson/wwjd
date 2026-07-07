// File: lib/widgets/prayer_wall/starfield_background.dart
// Description: Twinkling star particles background

import 'dart:math';
import 'package:flutter/material.dart';

class StarfieldBackground extends StatefulWidget {
  final int starCount;
  final double minSize;
  final double maxSize;
  final double minOpacity;
  final double maxOpacity;

  const StarfieldBackground({
    super.key,
    this.starCount = 80,
    this.minSize = 0.5,
    this.maxSize = 2.5,
    this.minOpacity = 0.15,
    this.maxOpacity = 0.8,
  });

  @override
  State<StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<StarfieldBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Star> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initStars(Size size) {
    if (_stars.isNotEmpty) return;
    for (int i = 0; i < widget.starCount; i++) {
      _stars.add(_Star(
        position: Offset(
          _random.nextDouble() * size.width,
          _random.nextDouble() * size.height * 0.6, // Upper 60% of screen
        ),
        size: widget.minSize + _random.nextDouble() * (widget.maxSize - widget.minSize),
        baseOpacity: widget.minOpacity +
            _random.nextDouble() * (widget.maxOpacity - widget.minOpacity),
        twinkleSpeed: 0.5 + _random.nextDouble() * 2.5,
        twinklePhase: _random.nextDouble() * 2 * pi,
        colorIndex: _random.nextInt(3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initStars(size);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: size,
              painter: _StarfieldPainter(
                stars: _stars,
                time: _controller.value * 2 * pi,
              ),
            );
          },
        );
      },
    );
  }
}

class _Star {
  final Offset position;
  final double size;
  final double baseOpacity;
  final double twinkleSpeed;
  final double twinklePhase;
  final int colorIndex; // 0 = white, 1 = gold, 2 = pale blue

  _Star({
    required this.position,
    required this.size,
    required this.baseOpacity,
    required this.twinkleSpeed,
    required this.twinklePhase,
    required this.colorIndex,
  });
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double time;

  _StarfieldPainter({required this.stars, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle =
          0.5 + 0.5 * sin(time * star.twinkleSpeed + star.twinklePhase);
      final opacity = star.baseOpacity * (0.3 + 0.7 * twinkle);

      Color starColor;
      switch (star.colorIndex) {
        case 1:
          starColor = const Color(0xFFFFD700); // Gold
          break;
        case 2:
          starColor = const Color(0xFFB0D4FF); // Pale blue
          break;
        default:
          starColor = Colors.white;
      }

      // Core dot
      final corePaint = Paint()
        ..color = starColor.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(star.position, star.size, corePaint);

      // Soft glow (only for brighter twinkle phases)
      if (twinkle > 0.7) {
        final glowPaint = Paint()
          ..color = starColor.withOpacity(opacity * 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(star.position, star.size * 2.5, glowPaint);
      }

      // Occasional cross-flare on brightest stars
      if (twinkle > 0.85 && star.size > 1.5) {
        final flarePaint = Paint()
          ..color = starColor.withOpacity(opacity * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
        const flareLength = 6.0;
        canvas.drawLine(
          Offset(star.position.dx - flareLength, star.position.dy),
          Offset(star.position.dx + flareLength, star.position.dy),
          flarePaint,
        );
        canvas.drawLine(
          Offset(star.position.dx, star.position.dy - flareLength),
          Offset(star.position.dx, star.position.dy + flareLength),
          flarePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) => true;
}
