// File: lib/widgets/prayer_wall/mystical_embers_background.dart
// Description: Multi-layer ember particles with sparkle bursts

import 'dart:math';
import 'package:flutter/material.dart';

class MysticalEmbersBackground extends StatefulWidget {
  const MysticalEmbersBackground({super.key});

  @override
  State<MysticalEmbersBackground> createState() =>
      _MysticalEmbersBackgroundState();
}

class _MysticalEmbersBackgroundState extends State<MysticalEmbersBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Ember> _slowEmbers = [];
  final List<_Ember> _fastEmbers = [];
  final List<_Sparkle> _sparkles = [];
  final Random _random = Random();

  final int _slowCount = 35;
  final int _fastCount = 20;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initAll(Size size) {
    if (_slowEmbers.isNotEmpty) return;

    // Slow layer — larger, drifting upward gently
    for (int i = 0; i < _slowCount; i++) {
      _slowEmbers.add(_generateEmber(size, fast: false, initialSpawn: true));
    }
    // Fast layer — smaller, quicker, more sparkly
    for (int i = 0; i < _fastCount; i++) {
      _fastEmbers.add(_generateEmber(size, fast: true, initialSpawn: true));
    }
  }

  _Ember _generateEmber(Size size,
      {bool fast = false, bool initialSpawn = false}) {
    final startY = initialSpawn
        ? _random.nextDouble() * size.height
        : size.height + 10.0;

    final colors = [
      const Color(0xFFFFD180), // Gold
      const Color(0xFFFFF9C4), // Pale yellow
      const Color(0xFFFFCC80), // Light amber
      const Color(0xFFBBDEFB), // Pale blue
      const Color(0xFFFFFDE7), // Warm white
    ];

    return _Ember(
      position: Offset(_random.nextDouble() * size.width, startY),
      speed: fast
          ? 0.5 + _random.nextDouble() * 1.0
          : 0.15 + _random.nextDouble() * 0.35,
      size: fast
          ? 0.8 + _random.nextDouble() * 2.0
          : 1.5 + _random.nextDouble() * 3.5,
      opacity: 0.0,
      maxOpacity: fast
          ? 0.3 + _random.nextDouble() * 0.5
          : 0.2 + _random.nextDouble() * 0.35,
      wobbleOffset: _random.nextDouble() * 2 * pi,
      color: colors[_random.nextInt(colors.length)],
      horizontalDriftSpeed: (_random.nextDouble() - 0.5) * 0.3,
    );
  }

  void _updateAll(Size size) {
    _updateEmberList(_slowEmbers, size, fast: false);
    _updateEmberList(_fastEmbers, size, fast: true);
    _updateSparkles(size);
  }

  void _updateEmberList(List<_Ember> embers, Size size,
      {required bool fast}) {
    for (int i = 0; i < embers.length; i++) {
      final ember = embers[i];

      // Rise upward
      ember.position = Offset(
        ember.position.dx +
            sin((ember.position.dy * 0.01) + ember.wobbleOffset) *
                (fast ? 0.8 : 0.4),
        ember.position.dy - ember.speed,
      );

      // Fade in near bottom, fade out near top
      if (ember.position.dy > size.height * 0.75) {
        ember.opacity += 0.02;
      } else if (ember.position.dy < size.height * 0.15) {
        ember.opacity -= 0.015;
      } else {
        if (ember.opacity < ember.maxOpacity) {
          ember.opacity += 0.01;
        }
      }
      ember.opacity = ember.opacity.clamp(0.0, ember.maxOpacity);

      // Respawn at bottom
      if (ember.position.dy < -20 ||
          (ember.position.dy < size.height * 0.3 && ember.opacity <= 0)) {
        embers[i] = _generateEmber(size, fast: fast);
      }
    }
  }

  void _updateSparkles(Size size) {
    // Random sparkle bursts
    if (_random.nextDouble() < 0.05 && _sparkles.length < 8) {
      _sparkles.add(_Sparkle(
        position: Offset(
          _random.nextDouble() * size.width,
          _random.nextDouble() * size.height,
        ),
        life: 0.0,
        maxLife: 0.4 + _random.nextDouble() * 0.4,
        size: 4.0 + _random.nextDouble() * 8.0,
      ));
    }

    _sparkles.removeWhere((s) {
      s.life += 0.016; // ~60fps equivalent
      return s.life >= s.maxLife;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initAll(size);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            _updateAll(size);
            return CustomPaint(
              painter: _EmbersPainter(
                slowEmbers: _slowEmbers,
                fastEmbers: _fastEmbers,
                sparkles: _sparkles,
              ),
              size: Size.infinite,
            );
          },
        );
      },
    );
  }
}

class _Sparkle {
  Offset position;
  double life;
  final double maxLife;
  final double size;

  _Sparkle({
    required this.position,
    required this.life,
    required this.maxLife,
    required this.size,
  });
}

class _Ember {
  Offset position;
  final double speed;
  final double size;
  double opacity;
  final double maxOpacity;
  final double wobbleOffset;
  final Color color;
  final double horizontalDriftSpeed;

  _Ember({
    required this.position,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.maxOpacity,
    required this.wobbleOffset,
    required this.color,
    this.horizontalDriftSpeed = 0.0,
  });
}

class _EmbersPainter extends CustomPainter {
  final List<_Ember> slowEmbers;
  final List<_Ember> fastEmbers;
  final List<_Sparkle> sparkles;

  _EmbersPainter({
    required this.slowEmbers,
    required this.fastEmbers,
    required this.sparkles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Slow layer — soft glow
    for (final ember in slowEmbers) {
      if (ember.opacity > 0.01) {
        final paint = Paint()
          ..color = ember.color.withOpacity(ember.opacity)
          ..style = PaintingStyle.fill
          ..maskFilter =
              const MaskFilter.blur(BlurStyle.normal, 2.5);
        canvas.drawCircle(ember.position, ember.size, paint);
      }
    }

    // Fast layer — sharper, brighter
    for (final ember in fastEmbers) {
      if (ember.opacity > 0.01) {
        // Brighter core
        final corePaint = Paint()
          ..color = ember.color.withOpacity(ember.opacity)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(ember.position, ember.size * 0.6, corePaint);

        // Soft halo
        final haloPaint = Paint()
          ..color = ember.color.withOpacity(ember.opacity * 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter =
              const MaskFilter.blur(BlurStyle.normal, 3.0);
        canvas.drawCircle(ember.position, ember.size * 1.5, haloPaint);
      }
    }

    // Sparkle bursts
    for (final sparkle in sparkles) {
      final lifeRatio = sparkle.life / sparkle.maxLife;
      // Sparkle fades in fast then fades out
      final sparkleOpacity = lifeRatio < 0.3
          ? lifeRatio / 0.3
          : (1.0 - lifeRatio) / 0.7;
      final scale = lifeRatio < 0.2
          ? lifeRatio / 0.2
          : 1.0 - (lifeRatio - 0.2) * 0.3;

      if (sparkleOpacity > 0.01) {
        // Cross-shaped sparkle
        final crossPaint = Paint()
          ..color = const Color(0xFFFFF9C4)
              .withOpacity(sparkleOpacity.clamp(0.0, 1.0))
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

        final halfSize = sparkle.size * scale / 2;
        canvas.drawLine(
          Offset(sparkle.position.dx - halfSize, sparkle.position.dy),
          Offset(sparkle.position.dx + halfSize, sparkle.position.dy),
          crossPaint,
        );
        canvas.drawLine(
          Offset(sparkle.position.dx, sparkle.position.dy - halfSize),
          Offset(sparkle.position.dx, sparkle.position.dy + halfSize),
          crossPaint,
        );

        // Center dot
        final dotPaint = Paint()
          ..color = Colors.white
              .withOpacity(sparkleOpacity.clamp(0.0, 1.0) * 0.9)
          ..style = PaintingStyle.fill
          ..maskFilter =
              const MaskFilter.blur(BlurStyle.normal, 2.0);
        canvas.drawCircle(
          sparkle.position,
          sparkle.size * scale * 0.2,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}