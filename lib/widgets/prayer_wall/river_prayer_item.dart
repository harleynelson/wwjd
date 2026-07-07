// File: lib/widgets/prayer_wall/river_prayer_item.dart
// Description: Floating prayer lantern with orbiting motes

import 'dart:math';
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

class _RiverPrayerItemState extends State<RiverPrayerItem>
    with TickerProviderStateMixin {
  AnimationController? _breathingController;
  Animation<double>? _breathingAnimation;
  AnimationController? _bobController;
  Animation<double>? _bobAnimation;
  AnimationController? _orbitalController;
  final Random _random = Random();

  // Generate 3 orbiting mote angles, seeded per instance
  late final List<double> _moteAngles = List.generate(
    3,
    (i) => _random.nextDouble() * 2 * pi,
  );
  late final List<double> _moteSpeeds = List.generate(
    3,
    (i) => 0.5 + _random.nextDouble() * 0.8,
  );
  late final List<double> _moteRadii = List.generate(
    3,
    (i) => 3.0 + _random.nextDouble() * 3.0,
  );
  late final List<double> _moteOrbitRadii = List.generate(
    3,
    (i) => 55 + _random.nextDouble() * 30,
  );

  @override
  void initState() {
    super.initState();

    // Breathing glow
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _breathingAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
          parent: _breathingController!, curve: Curves.easeInOutSine),
    );

    // Gentle bobbing (floating on water)
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _bobAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _bobController!, curve: Curves.easeInOutSine),
    );

    // Orbiting motes
    _orbitalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _breathingController?.dispose();
    _bobController?.dispose();
    _orbitalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale = widget.playExitAnimation ? 0.0 : 1.0;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeIn,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _breathingAnimation!,
            _bobAnimation!,
            _orbitalController!,
          ]),
          builder: (context, child) {
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // --- Orbiting Light Motes ---
                for (int i = 0; i < 3; i++) _buildOrbitingMote(i),

                // --- Main Lantern Card ---
                Transform.translate(
                  offset: Offset(0, _bobAnimation!.value),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      // Warm parchment-like gradient
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF3E2723)
                              .withOpacity(0.85), // Dark warm brown top
                          const Color(0xFF5D4037).withOpacity(0.7), // Mid brown
                          const Color(0xFF8D6E63).withOpacity(0.5 *
                              _breathingAnimation!
                                  .value), // Warm amber bottom glow
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB74D)
                              .withOpacity(0.25 * _breathingAnimation!.value),
                          blurRadius: 25,
                          spreadRadius: 4,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: const Color(0xFFFF8A65)
                              .withOpacity(0.15 * _breathingAnimation!.value),
                          blurRadius: 15,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFFFD180)
                            .withOpacity(0.25 * _breathingAnimation!.value),
                        width: 1.2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // Inner parchment glow at bottom
                          Positioned(
                            left: 0, right: 0, bottom: 0, height: 50,
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFFFFB74D)
                                          .withOpacity(0.06 * _breathingAnimation!.value),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Candle flame icon (inline — no nested AnimatedBuilder)
                                  _buildFlameIcon(),
                                const SizedBox(height: 10),
                                // Prayer Text (auto-scales to fit)
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      widget.prayerRequest.prayerText,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: const Color(0xFFFFF8E1)
                                                .withOpacity(0.95),
                                            height: 1.5,
                                            fontSize: 17,
                                            shadows: [
                                              Shadow(
                                                color: const Color(0xFFFFB74D)
                                                    .withOpacity(0.4),
                                                offset: const Offset(0, 0),
                                                blurRadius: 10,
                                              ),
                                              Shadow(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                offset: const Offset(0, 2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                            fontFamily: 'Serif',
                                          ),
                                      maxLines: 6,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // "Tap to Pray" hint
                                AnimatedOpacity(
                                  opacity: widget.playExitAnimation ? 0.0 : 0.7,
                                  duration: const Duration(milliseconds: 200),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.touch_app,
                                          size: 16,
                                          color: const Color(0xFFFFD180)
                                              .withOpacity(0.7)),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Tap to lift this prayer",
                                        style: TextStyle(
                                          color: const Color(0xFFFFF8E1)
                                              .withOpacity(0.7),
                                          fontSize: 12,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
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
              ]
            );
          },
        ),
      ),
    );
  }

  Widget _buildFlameIcon() {
    final breathingAnim = _breathingAnimation;
    if (breathingAnim == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: breathingAnim,
      builder: (context, _) {
        final flameScale = 0.85 + 0.15 * breathingAnim.value;
        return Transform.scale(
          scale: flameScale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFB74D)
                      .withOpacity(0.3 * breathingAnim.value),
                ),
              ),
              // const Icon(
              //   Icons.auto_awesome,
              //   color: Color(0xFFFFF8E1),
              //   size: 28,
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrbitingMote(int index) {
    final orbController = _orbitalController;
    final bobAnim = _bobAnimation;
    if (orbController == null || bobAnim == null)
      return const SizedBox.shrink();

    final time = orbController.value * 2 * pi;
    final angle = _moteAngles[index] + time * _moteSpeeds[index];
    final radius = _moteOrbitRadii[index];
    final dx = cos(angle) * radius;
    final dy = sin(angle) * radius + bobAnim.value;

    // Vary opacity with orbit position
    final verticalFactor = (sin(angle) + 1) / 2; // 0 to 1
    final twinkle = 0.4 + 0.6 * sin(orbController.value * 7 + index * 2.4);

    return Positioned(
      left: dx,
      top: dy + 60, // Offset to center of card roughly
      child: Container(
        width: _moteRadii[index],
        height: _moteRadii[index],
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (index == 0
                  ? const Color(0xFFFFF9C4)
                  : index == 1
                      ? const Color(0xFFFFCC80)
                      : const Color(0xFFB3E5FC))
              .withOpacity(
                  ((0.3 + 0.5 * verticalFactor) * twinkle).clamp(0.0, 1.0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFF9C4)
                  .withOpacity((0.4 * twinkle).clamp(0.0, 1.0)),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
