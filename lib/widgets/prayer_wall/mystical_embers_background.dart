// File: lib/widgets/prayer_wall/mystical_embers_background.dart

import 'dart:math';
import 'package:flutter/material.dart';

class MysticalEmbersBackground extends StatefulWidget {
  const MysticalEmbersBackground({super.key});

  @override
  State<MysticalEmbersBackground> createState() => _MysticalEmbersBackgroundState();
}

class _MysticalEmbersBackgroundState extends State<MysticalEmbersBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Ember> _embers = [];
  final Random _random = Random();
  final int _emberCount = 45; // Adjust for density

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Arbitrary long duration for loop
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initEmbers(Size size) {
    if (_embers.isNotEmpty) return;
    for (int i = 0; i < _emberCount; i++) {
      _embers.add(_generateEmber(size, initialSpawn: true));
    }
  }

  _Ember _generateEmber(Size size, {bool initialSpawn = false}) {
    // If initial spawn, scatter randomly vertically. 
    // If respawning, start at the very bottom.
    double startY = initialSpawn 
        ? _random.nextDouble() * size.height 
        : size.height + 10.0;

    return _Ember(
      position: Offset(_random.nextDouble() * size.width, startY),
      speed: 0.2 + _random.nextDouble() * 0.5, // Slow rising speed
      size: 1.0 + _random.nextDouble() * 3.0, // Varying small sizes
      opacity: 0.0, // Starts invisible, fades in
      maxOpacity: 0.3 + _random.nextDouble() * 0.4, // Random max brightness
      wobbleOffset: _random.nextDouble() * 2 * pi, // Random start phase for sine wave
      color: _random.nextBool() 
          ? const Color(0xFFFFD180) // Gold/Amber
          : const Color(0xFFFFF9C4), // Pale Yellow
    );
  }

  void _updateEmbers(Size size) {
    for (int i = 0; i < _embers.length; i++) {
      final ember = _embers[i];
      
      // Move up
      double newY = ember.position.dy - ember.speed;
      
      // Horizontal drift (sine wave)
      double wobble = sin((newY * 0.01) + ember.wobbleOffset) * 0.5;
      double newX = ember.position.dx + wobble;

      ember.position = Offset(newX, newY);

      // Fade logic
      if (ember.position.dy > size.height * 0.8) {
        // Fading in at the bottom
        ember.opacity += 0.02;
      } else if (ember.position.dy < size.height * 0.2) {
        // Fading out at the top
        ember.opacity -= 0.01;
      } else {
        // Hold max opacity in the middle
        if (ember.opacity < ember.maxOpacity) {
            ember.opacity += 0.01;
        }
      }
      
      // Clamp opacity
      ember.opacity = ember.opacity.clamp(0.0, ember.maxOpacity);

      // Respawn if off top or fully faded out near top
      if (ember.position.dy < -20 || (ember.position.dy < size.height * 0.5 && ember.opacity <= 0)) {
        _embers[i] = _generateEmber(size);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _initEmbers(Size(constraints.maxWidth, constraints.maxHeight));
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            _updateEmbers(Size(constraints.maxWidth, constraints.maxHeight));
            return CustomPaint(
              painter: _EmbersPainter(_embers),
              size: Size.infinite,
            );
          },
        );
      },
    );
  }
}

class _Ember {
  Offset position;
  final double speed;
  final double size;
  double opacity;
  final double maxOpacity;
  final double wobbleOffset;
  final Color color;

  _Ember({
    required this.position,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.maxOpacity,
    required this.wobbleOffset,
    required this.color,
  });
}

class _EmbersPainter extends CustomPainter {
  final List<_Ember> embers;

  _EmbersPainter(this.embers);

  @override
  void paint(Canvas canvas, Size size) {
    for (final ember in embers) {
      final paint = Paint()
        ..color = ember.color.withOpacity(ember.opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0); // Soft glow

      canvas.drawCircle(ember.position, ember.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}