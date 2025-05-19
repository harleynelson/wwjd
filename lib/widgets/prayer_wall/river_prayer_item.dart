// File: lib/widgets/prayer_wall/river_prayer_item.dart
// Path: lib/widgets/prayer_wall/river_prayer_item.dart
// New file: Contains the RiverPrayerItem widget, moved from prayer_request_card.dart

import 'package:flutter/material.dart';
import 'dart:math'; // For random gradient alignment in RiverPrayerItem

import '../../models/prayer_request_model.dart';

// --- RiverPrayerItem ---
class RiverPrayerItem extends StatefulWidget {
  final PrayerRequest prayerRequest;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Animation<double>? animation; // For list add/remove
  final bool playExitAnimation; // New: To trigger exit animation

  const RiverPrayerItem({
    Key? key,
    required this.prayerRequest,
    required this.onTap,
    required this.onLongPress,
    this.animation,
    this.playExitAnimation = false, // Default to false
  }) : super(key: key);

  @override
  State<RiverPrayerItem> createState() => _RiverPrayerItemState();
}

class _RiverPrayerItemState extends State<RiverPrayerItem> with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late AnimationController _exitAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isAnimatingExit = false;

  @override
  void initState() {
    super.initState();
    _exitAnimationController = AnimationController(
      duration: const Duration(milliseconds: 350), // Duration of shrink/fade
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitAnimationController, curve: Curves.easeOutQuint)
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitAnimationController, curve: Curves.easeOut)
    );

    if (widget.playExitAnimation) {
      _isAnimatingExit = true;
      _exitAnimationController.forward();
    }
  }

  @override
  void didUpdateWidget(RiverPrayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playExitAnimation && !oldWidget.playExitAnimation && !_isAnimatingExit) {
      setState(() {
        _isAnimatingExit = true;
      });
      _exitAnimationController.forward(from: 0.0);
    } else if (!widget.playExitAnimation && oldWidget.playExitAnimation && _isAnimatingExit) {
      // This case might be needed if the parent could cancel the exit animation
      // For now, we assume it plays to completion once triggered.
    }
  }

  @override
  void dispose() {
    _exitAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Color> cardGradientColors = [
      Colors.lightBlue.shade300.withOpacity(0.15),
      Colors.purple.shade300.withOpacity(0.20),
      Colors.teal.shade300.withOpacity(0.15),
    ];

    final cardTextColor = Colors.white.withOpacity(0.9);

    final prayerTextStyle = theme.textTheme.bodyMedium?.copyWith(
      color: cardTextColor,
      height: 1.35,
      fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) * 0.92,
      shadows: [
        Shadow(
          blurRadius: 8.0,
          color: Colors.cyanAccent.withOpacity(0.5),
          offset: const Offset(0, 0),
        ),
        Shadow(
          blurRadius: 4.0,
          color: Colors.white.withOpacity(0.3),
          offset: const Offset(0, 0),
        ),
      ],
    );

    Widget cardContent = Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardGradientColors,
          begin: Alignment(_random.nextDouble() * 2 - 1, _random.nextDouble() * 2 - 1),
          end: Alignment(_random.nextDouble() * 2 - 1, _random.nextDouble() * 2 - 1),
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.30),
            blurRadius: 10,
            spreadRadius: 0.5,
            offset: const Offset(0, 0),
          ),
           BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 2,
            offset: const Offset(1, 1),
          )
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.20),
          width: 0.6,
        )
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isAnimatingExit ? null : widget.onTap, // Disable tap while animating out
          onLongPress: _isAnimatingExit ? null : widget.onLongPress,
          splashColor: Colors.lightBlue.withOpacity(0.3),
          highlightColor: Colors.lightBlue.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Center(
              child: Text(
                widget.prayerRequest.prayerText,
                style: prayerTextStyle,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );

    Widget animatedCard = cardContent;
    // Apply exit animation if triggered
    if (_isAnimatingExit) {
      animatedCard = AnimatedBuilder(
        animation: _exitAnimationController,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              alignment: Alignment.center, // Shrink towards center
              child: child,
            ),
          );
        },
        child: cardContent,
      );
    }

    // Apply list add/remove animation if provided
    if (widget.animation != null && !_isAnimatingExit) { // Don't apply list animation if exit animation is playing
      return FadeTransition(
        opacity: Tween<double>(begin: 0.4, end: 1.0).animate(
          CurvedAnimation(parent: widget.animation!, curve: Curves.easeInSine)
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: widget.animation!, curve: Curves.easeOutExpo)
          ),
          child: animatedCard, // Use the potentially exit-animated card here
        )
      );
    }
    return animatedCard; // Return the card, possibly wrapped in exit animation
  }
}