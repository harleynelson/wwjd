// File: lib/widgets/prayer_wall/river_prayer_item.dart
import 'dart:ui'; // REQUIRED for ImageFilter
import 'package:flutter/material.dart';
import '../../models/prayer_request_model.dart';

class RiverPrayerItem extends StatefulWidget {
  final PrayerRequest prayerRequest;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Animation<double>? animation;
  final bool playExitAnimation;

  const RiverPrayerItem({
    super.key,
    required this.prayerRequest,
    required this.onTap,
    required this.onLongPress,
    this.animation,
    this.playExitAnimation = false,
  });

  @override
  State<RiverPrayerItem> createState() => _RiverPrayerItemState();
}

class _RiverPrayerItemState extends State<RiverPrayerItem> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    // Creates a subtle "living" pulse effect (breathing light)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale = widget.playExitAnimation ? 0.0 : 1.0;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInBack,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: _breathingAnimation,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                // The "Lantern" Gradient
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    // Glassy dark top
                    const Color(0xFF2C3E50).withOpacity(0.6),
                    // Warm amber glow at the bottom (The "Flame")
                    const Color(0xFFE67E22).withOpacity(0.5 * _breathingAnimation.value), 
                  ],
                  stops: const [0.3, 1.0],
                ),
                boxShadow: [
                  // Outer Glow (Reflection on water)
                  BoxShadow(
                    color: const Color(0xFFE67E22).withOpacity(0.2 * _breathingAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                  // Subtle rim shadow for depth
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                // A thin border to define the "glass" edge
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  // FIXED: Added valid ImageFilter blur
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon or Symbol at top
                        Icon(
                          Icons.light_mode_outlined,
                          color: const Color(0xFFFFD180).withOpacity(0.8),
                          size: 28,
                        ),
                        const SizedBox(height: 16),
                        
                        // Prayer Text
                        Text(
                          widget.prayerRequest.prayerText,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.95),
                            height: 1.5,
                            fontSize: 18,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              )
                            ],
                            fontFamily: 'Serif', 
                          ),
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // "Tap to Pray" hint (subtle)
                        AnimatedOpacity(
                          opacity: widget.playExitAnimation ? 0.0 : 0.7,
                          duration: const Duration(milliseconds: 200),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.touch_app, size: 16, color: Colors.white.withOpacity(0.6)),
                              const SizedBox(width: 8),
                              Text(
                                "Tap to lift this prayer",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}