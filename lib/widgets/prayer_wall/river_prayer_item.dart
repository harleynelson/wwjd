// File: lib/widgets/prayer_wall/river_prayer_item.dart
// Path: lib/widgets/prayer_wall/river_prayer_item.dart

import 'package:flutter/material.dart';
import 'dart:math'; 

import '../../models/prayer_request_model.dart';

class RiverPrayerItem extends StatefulWidget {
  final PrayerRequest prayerRequest;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Animation<double>? animation; 
  final bool playExitAnimation; 

  const RiverPrayerItem({
    Key? key,
    required this.prayerRequest,
    required this.onTap,
    required this.onLongPress,
    this.animation,
    this.playExitAnimation = false, 
  }) : super(key: key);

  @override
  State<RiverPrayerItem> createState() => _RiverPrayerItemState();
}

class _RiverPrayerItemState extends State<RiverPrayerItem> with TickerProviderStateMixin { // Changed to TickerProviderStateMixin
  final Random _random = Random();
  late AnimationController _exitAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  // NEW: Pulse Animation for "Sending" feel
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _glowColorAnimation;

  bool _isAnimatingExit = false;

  @override
  void initState() {
    super.initState();
    _exitAnimationController = AnimationController(
      duration: const Duration(milliseconds: 350), 
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitAnimationController, curve: Curves.easeOutQuint)
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitAnimationController, curve: Curves.easeOut)
    );
    
    // NEW: Initialize Pulse Controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 12.0).animate( // Glow radius
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutQuad)
    );
    _glowColorAnimation = ColorTween(
      begin: Colors.white.withOpacity(0.0), 
      end: Colors.white.withOpacity(0.6)
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

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
    }
  }

  @override
  void dispose() {
    _exitAnimationController.dispose();
    _pulseController.dispose(); // NEW: Dispose pulse
    super.dispose();
  }

  void _handleTap() {
    if (_isAnimatingExit) return;
    
    // Trigger the "Holy Glow" effect
    _pulseController.forward().then((_) => _pulseController.reverse());
    
    widget.onTap();
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
      ],
    );

    // NEW: Wrapped in AnimatedBuilder for the pulse glow
    Widget cardContent = AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
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
              // The "Holy Glow" Shadow
              if (_pulseController.isAnimating)
                BoxShadow(
                  color: _glowColorAnimation.value ?? Colors.transparent,
                  blurRadius: _pulseAnimation.value * 2,
                  spreadRadius: _pulseAnimation.value,
                ),
            ],
            border: Border.all(
              // Border lights up too
              color: Colors.white.withOpacity(0.20 + (_pulseController.value * 0.5)),
              width: 0.6 + (_pulseController.value * 1.0),
            )
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap, // Use new handler
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
    if (_isAnimatingExit) {
      animatedCard = AnimatedBuilder(
        animation: _exitAnimationController,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              alignment: Alignment.center,
              child: child,
            ),
          );
        },
        child: cardContent,
      );
    }

    if (widget.animation != null && !_isAnimatingExit) {
      return FadeTransition(
        opacity: Tween<double>(begin: 0.4, end: 1.0).animate(
          CurvedAnimation(parent: widget.animation!, curve: Curves.easeInSine)
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: widget.animation!, curve: Curves.easeOutExpo)
          ),
          child: animatedCard,
        )
      );
    }
    return animatedCard;
  }
}