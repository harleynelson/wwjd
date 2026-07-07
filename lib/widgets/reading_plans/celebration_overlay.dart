// File: lib/widgets/reading_plans/celebration_overlay.dart
// Description: Confetti celebration overlay widget

import 'dart:math';
import 'package:flutter/material.dart';

class CelebrationOverlay extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onDismiss;
  final Duration duration;

  const CelebrationOverlay({
    super.key,
    this.title,
    this.subtitle,
    this.onDismiss,
    this.duration = const Duration(seconds: 3),
  });

  /// Shows a celebration overlay on top of the current screen.
  static void show(
    BuildContext context, {
    String? title,
    String? subtitle,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 3),
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) => CelebrationOverlay(
        title: title,
        subtitle: subtitle,
        onDismiss: onDismiss,
        duration: duration,
      ),
    );
  }

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final Random _random = Random();
  bool _showParticles = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _showParticles = false;
        setState(() {});
        _controller.reverse().then((_) {
          if (mounted) {
            Navigator.of(context).maybePop();
            widget.onDismiss?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Confetti particles
          if (_showParticles) ..._buildConfettiParticles(),
          // Center card
          Center(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) => Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                ),
              ),
              child: _buildCelebrationCard(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConfettiParticles() {
    final List<Widget> particles = [];
    const colors = [
      Colors.red, Colors.orange, Colors.yellow, Colors.green,
      Colors.blue, Colors.purple, Colors.pink, Colors.amber,
      Colors.teal, Colors.indigo, Colors.cyan, Colors.deepOrange,
    ];
    const shapes = [
      BoxShape.rectangle, BoxShape.circle,
    ];

    for (int i = 0; i < 60; i++) {
      final color = colors[_random.nextInt(colors.length)];
      final shape = shapes[_random.nextInt(shapes.length)];
      final left = _random.nextDouble();
      final size = 6.0 + _random.nextDouble() * 10;
      final delay = _random.nextDouble() * 0.5;
      final duration = 1.5 + _random.nextDouble() * 2.0;

      particles.add(
        TweenAnimationBuilder<double>(
          tween: Tween(begin: -0.1, end: 1.1),
          duration: Duration(milliseconds: (duration * 1000).toInt()),
          builder: (context, value, child) {
            final top = -0.1 + value * 1.2;
            final wobble = sin(value * pi * 4 + i) * 0.05;
            return Positioned(
              left: (left + wobble) * MediaQuery.of(context).size.width,
              top: top * MediaQuery.of(context).size.height,
              child: Transform.rotate(
                angle: value * pi * 6,
                child: Container(
                  width: size,
                  height: shape == BoxShape.rectangle ? size * 0.6 : size,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.9),
                    shape: shape,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    return particles;
  }

  Widget _buildCelebrationCard() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
        border: Border.all(
          color: Colors.amber.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji/icon celebration
          const Text(
            '🙌✨🔥',
            style: TextStyle(fontSize: 48),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            widget.title ?? 'Amazing!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.subtitle!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          // Dismiss button
          TextButton(
            onPressed: () {
              _showParticles = false;
              setState(() {});
              _controller.reverse().then((_) {
                if (mounted) {
                  Navigator.of(context).maybePop();
                  widget.onDismiss?.call();
                }
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Continue 🙏',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
