// File: lib/widgets/prayer_wall/well_of_hope_widget.dart
// Path: lib/widgets/prayer_wall/well_of_hope_widget.dart
// Approximate line: 60 (triggerUserPrayerShimmer method)

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../config/constants.dart'; 

// _Mote class (no changes)
class _Mote {
  Offset position;
  double size;
  double opacity;
  Duration lifetime;
  Duration age;
  Offset speed;

  _Mote({
    required this.position,
    required this.size,
    required this.opacity,
    required this.lifetime,
    required this.speed,
    this.age = Duration.zero,
  });
}


class WellOfHopeWidget extends StatefulWidget {
  final GlobalKey wellKey; // This key is for the CustomPaint widget itself if needed by parent
  // Removed key parameter for _WellOfHopeWidgetState as it's not directly passed like this.
  // The state's methods are accessed via a GlobalKey targeting the state, as done in PrayerWallScreen.

  final Function(Offset localAbsorptionPoint)? onAbsorbPrayer;

  const WellOfHopeWidget({
    required this.wellKey, // Keep this for the CustomPaint
    this.onAbsorbPrayer,
    super.key, // Use super.key for the Widget itself
  });

  @override
  State<WellOfHopeWidget> createState() => _WellOfHopeWidgetState();
}

class _WellOfHopeWidgetState extends State<WellOfHopeWidget>
    with TickerProviderStateMixin {
  late AnimationController _gentlePulseController;
  late Animation<double> _gentlePulseAnimation;

  late AnimationController _shimmerEffectController;
  late Animation<double> _shimmerEffectAnimation;
  Timer? _nextAmbientShimmerTimer;

  Offset? _absorptionPoint;
  late AnimationController _absorptionImpactController;
  late Animation<double> _absorptionImpactAnimation;
  late AnimationController _absorptionRippleController;
  late Animation<double> _absorptionRippleAnimation;

  List<_Mote> _motes = [];
  late AnimationController _motesAnimationController;
  final int _maxMotes = 25;
  final Random _random = Random();
  DateTime _lastMoteUpdateTime = DateTime.now();


  @override
  void initState() {
    super.initState();

    _gentlePulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: wellGentlePulseDurationMs));
    _gentlePulseAnimation = Tween<double>(
            begin: wellGentlePulseMinScale, end: wellGentlePulseMaxScale)
        .animate(
            CurvedAnimation(parent: _gentlePulseController, curve: Curves.easeInOut));
    _gentlePulseController.repeat(reverse: true);

    _shimmerEffectController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: wellShimmerBaseControllerDurationMs));
     _shimmerEffectAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _shimmerEffectController, curve: Curves.easeOut));

    _absorptionImpactController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _absorptionImpactAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
       CurvedAnimation(parent: _absorptionImpactController, curve: Curves.easeOut)
    );

    _absorptionRippleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _absorptionRippleAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _absorptionRippleController,
      curve: Curves.easeOutCirc,
    ));

    _motesAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateMotes)..repeat();

    _scheduleNextAmbientShimmer();
    _initializeMotes(const Size(200,200));
  }

  void triggerUserPrayerShimmer() {
    if (!mounted) return;

    // If an ambient shimmer timer is pending, cancel it.
    // The user's prayer shimmer takes precedence and will restart the ambient schedule.
    _nextAmbientShimmerTimer?.cancel();

    if (_shimmerEffectController.isAnimating) {
      _shimmerEffectController.stop(); // Stop current animation immediately
    }

    final userPrayerFlashDurationMs =
        (wellShimmerMinFlashDurationMs * 1.1).round() + // 10% longer base
        _random.nextInt((wellShimmerRandomFlashDurationRangeMs * 0.7).round() + 1); 

    _shimmerEffectController.duration = Duration(milliseconds: userPrayerFlashDurationMs);
    
    _shimmerEffectController.forward(from: 0.0).then((_) {
        if(mounted) {
          _shimmerEffectController.reset();
          // CRITICAL FIX: After user prayer shimmer, restart the ambient shimmer schedule.
          _scheduleNextAmbientShimmer(); 
        }
    });
  }

  void _scheduleNextAmbientShimmer() {
    _nextAmbientShimmerTimer?.cancel(); 
    if (!mounted) return;

    final randomPauseMilliseconds =
        wellShimmerMinPauseMs + _random.nextInt(wellShimmerRandomPauseRangeMs + 1);

    _nextAmbientShimmerTimer = Timer(Duration(milliseconds: randomPauseMilliseconds), () {
      if (mounted && !_shimmerEffectController.isAnimating) { 
        final flashDurationMs = wellShimmerMinFlashDurationMs +
            _random.nextInt(wellShimmerRandomFlashDurationRangeMs + 1);
        _shimmerEffectController.duration = Duration(milliseconds: flashDurationMs);

        _shimmerEffectController.forward(from: 0.0).then((_) {
            if(mounted) {
              _shimmerEffectController.reset();
              _scheduleNextAmbientShimmer(); 
            }
        });
      } else if (mounted) {
        _scheduleNextAmbientShimmer(); 
      }
    });
  }
  
  void _initializeMotes(Size canvasSize, {bool initialSpawn = false}) {
    if (canvasSize.isEmpty) return;
    for (int i = 0; i < _maxMotes; i++) {
      if (initialSpawn || _motes.length <= i || _motes[i].age >= _motes[i].lifetime) {
         _spawnMote(i, canvasSize);
      }
    }
  }

  void _spawnMote(int index, Size canvasSize) {
    if (canvasSize.isEmpty) return;
    final position = Offset(
      _random.nextDouble() * canvasSize.width,
      _random.nextDouble() * canvasSize.height,
    );
    final newMote = _Mote(
      position: position,
      size: 1.5 + _random.nextDouble() * 2.5,
      opacity: 0.0,
      lifetime: Duration(seconds: 3 + _random.nextInt(4)),
      speed: Offset(
        (_random.nextDouble() - 0.5) * 10,
        (_random.nextDouble() - 0.5) * 10,
      ),
      age: Duration.zero,
    );
    if (index < _motes.length) {
      _motes[index] = newMote;
    } else {
      _motes.add(newMote);
    }
  }

  void _updateMotes() {
    if (!mounted) return;
    final now = DateTime.now();
    final delta = now.difference(_lastMoteUpdateTime);
    _lastMoteUpdateTime = now;
    final double dt = delta.inMilliseconds / 1000.0;

    Size? canvasSize;
    final RenderBox? renderBox = widget.wellKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      canvasSize = renderBox.size;
    } else {
      canvasSize = const Size(200,200);
    }

    for (int i = 0; i < _motes.length; i++) {
      _Mote mote = _motes[i];
      mote.age += delta;

      mote.position = Offset(
        mote.position.dx + mote.speed.dx * dt,
        mote.position.dy + mote.speed.dy * dt,
      );

      double lifeRatio = mote.age.inMilliseconds / mote.lifetime.inMilliseconds;
      if (lifeRatio < 0.3) { 
        mote.opacity = (lifeRatio / 0.3) * 0.6; 
      } else if (lifeRatio > 0.7) { 
        mote.opacity = ((1.0 - lifeRatio) / 0.3) * 0.6;
      } else {
        mote.opacity = 0.6;
      }
      mote.opacity = mote.opacity.clamp(0.0, 0.6);

      bool outOfBounds = mote.position.dx < -mote.size ||
                         mote.position.dx > canvasSize.width + mote.size ||
                         mote.position.dy < -mote.size ||
                         mote.position.dy > canvasSize.height + mote.size;

      if (mote.age >= mote.lifetime || outOfBounds) {
        _spawnMote(i, canvasSize);
      }
    }
  }

  void triggerAbsorptionEffect(Offset globalMoteEndPosition) {
    if (!mounted) return;
    
    final RenderBox? renderBox = widget.wellKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
        print("WellOfHopeWidget: CustomPaint RenderBox not available for absorption effect via widget.wellKey.");
        final RenderBox? selfRenderBox = context.findRenderObject() as RenderBox?;
        if (selfRenderBox == null || !selfRenderBox.hasSize) {
            print("WellOfHopeWidget: Self RenderBox also not available.");
            return;
        }
        final localPosition = selfRenderBox.globalToLocal(globalMoteEndPosition);
        setState(() { _absorptionPoint = localPosition; });
    } else {
        final localPosition = renderBox.globalToLocal(globalMoteEndPosition);
        setState(() { _absorptionPoint = localPosition; });
    }
    
    _absorptionImpactController.forward(from: 0.0).then((_)=> _absorptionImpactController.reset());
    _absorptionRippleController.forward(from:0.0).then((_) => _absorptionRippleController.reset());
    widget.onAbsorbPrayer?.call(_absorptionPoint!);

    triggerUserPrayerShimmer();
  }

  @override
  void dispose() {
    _gentlePulseController.dispose();
    _shimmerEffectController.dispose();
    _nextAmbientShimmerTimer?.cancel(); 
    _absorptionImpactController.dispose();
    _absorptionRippleController.dispose();
    _motesAnimationController.removeListener(_updateMotes);
    _motesAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([
            _gentlePulseAnimation,
            _shimmerEffectAnimation,
            _absorptionImpactAnimation,
            _absorptionRippleAnimation,
            _motesAnimationController
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _gentlePulseAnimation.value,
            child: CustomPaint(
              key: widget.wellKey, // Use the widget's wellKey for the CustomPaint
              size: const Size(200, 200),
              painter: _WellPainter(
                shimmerProgress: _shimmerEffectAnimation.value,
                absorptionImpactProgress: _absorptionImpactAnimation.value,
                absorptionRippleProgress: _absorptionRippleAnimation.value,
                absorptionPoint: _absorptionPoint,
                motes: _motes,
                gentlePulseScale: _gentlePulseAnimation.value,
                randomInstance: _random,
              ),
            ),
          );
        },
      ),
    );
  }
}

// _WellPainter class (no changes)
class _WellPainter extends CustomPainter {
  final double shimmerProgress;
  final double absorptionImpactProgress;
  final double absorptionRippleProgress;
  final Offset? absorptionPoint;
  final List<_Mote> motes;
  final double gentlePulseScale;
  final Random randomInstance;

  _WellPainter({
    required this.shimmerProgress,
    required this.absorptionImpactProgress,
    required this.absorptionRippleProgress,
    this.absorptionPoint,
    required this.motes,
    required this.gentlePulseScale,
    required this.randomInstance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    // --- MODIFIED: Ethereal Orb Background for Brighter Baseline ---
    for (int i = 3; i >= 1; i--) {
      final double layerRadius = radius * (0.8 + i * 0.07 * gentlePulseScale);
      final layerPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            // Increased opacities and slightly brighter core colors
            Colors.lightBlue.shade100.withOpacity(0.12 * i), // Was lightBlue.shade50.withOpacity(0.03 * i)
            Colors.cyan.shade200.withOpacity(0.16 * i),   // Was cyan.shade100.withOpacity(0.05 * i)
            Colors.deepPurple.shade100.withOpacity(0.08 * i), // Was deepPurple.shade100.withOpacity(0.02 * i)
          ],
          // You can experiment with stops for a larger bright center if desired
          stops: const [0.0, 0.55, 1.0], // Original: [0.0, 0.6, 1.0] - slightly faster falloff for outer colors
        ).createShader(Rect.fromCircle(center: center, radius: layerRadius))
        // Slightly reduced blur for a bit more definition, which can also make it appear brighter
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12.0 + i * 4); // Original: 15.0 + i * 5
      canvas.drawCircle(center, layerRadius, layerPaint);
    }
    
    // --- "Others Praying" Shimmer Effect (No changes here from previous version) ---
    if (shimmerProgress > 0) {
      double effectStrength = sin(shimmerProgress * pi);

      double flashIntensityMultiplier = wellShimmerMinIntensityMultiplier +
          randomInstance.nextDouble() * wellShimmerRandomIntensityMultiplierRange;
      
      double spreadFactor = wellShimmerMinSpreadFactor +
          randomInstance.nextDouble() * wellShimmerRandomSpreadFactorRange;
      
      double coreSizeFactor = wellShimmerMinCoreSizeFactor +
          randomInstance.nextDouble() * wellShimmerRandomCoreSizeFactorRange;
      
      List<double> stops = [
          0.0, 
          (coreSizeFactor * 0.6).clamp(0.1, 0.4), 
          (coreSizeFactor).clamp(0.3, 0.6), 
          1.0 
      ];
      if (stops[1] >= stops[2]) stops[1] = stops[2] - 0.05;

      final shimmerPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity((wellShimmerColor1BaseOpacity * effectStrength * flashIntensityMultiplier).clamp(0.0, 1.0)), 
            Colors.cyanAccent.withOpacity((wellShimmerColor2BaseOpacity * effectStrength * flashIntensityMultiplier).clamp(0.0, 0.8)),
            Colors.lightBlue.shade100.withOpacity((wellShimmerColor3BaseOpacity * effectStrength * flashIntensityMultiplier).clamp(0.0, 0.5)),
            Colors.transparent,
          ],
          stops: stops, 
        ).createShader(Rect.fromCircle(center: center, radius: radius * spreadFactor.clamp(0.8, 1.0)));
      canvas.drawCircle(center, radius * spreadFactor.clamp(0.8, 1.0), shimmerPaint);
    }

    // --- Motes (Floating Particles) ---
    final motePaint = Paint()..style = PaintingStyle.fill;
    for (final mote in motes) {
      if (mote.opacity > 0) {
        motePaint.color = Colors.white.withOpacity(mote.opacity * 0.8); 
        motePaint.maskFilter = MaskFilter.blur(BlurStyle.normal, mote.size * 0.6); 
        canvas.drawCircle(mote.position, mote.size, motePaint);
      }
    }

    // --- Absorption Effect ---
    if (absorptionPoint != null) {
      if (absorptionImpactProgress > 0 && absorptionImpactProgress < 1.0) {
        double impactOpacity = sin(absorptionImpactProgress * pi); 
        final impactFlashPaint = Paint()
          ..color = Colors.white.withOpacity(impactOpacity * 0.9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
        canvas.drawCircle(absorptionPoint!, radius * 0.05 + (radius * 0.1 * absorptionImpactProgress) , impactFlashPaint);
      }

      if (absorptionRippleProgress > 0 && absorptionRippleProgress < 1.0) {
        final ripplePaint = Paint()
          ..color = Colors.tealAccent.shade100.withOpacity(0.6 * (1.0 - absorptionRippleProgress)) 
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 * (1.0 - absorptionRippleProgress); 
        canvas.drawCircle(absorptionPoint!, radius * 0.7 * absorptionRippleProgress, ripplePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WellPainter oldDelegate) {
    return oldDelegate.shimmerProgress != shimmerProgress ||
           oldDelegate.absorptionImpactProgress != absorptionImpactProgress ||
           oldDelegate.absorptionRippleProgress != absorptionRippleProgress ||
           oldDelegate.absorptionPoint != absorptionPoint ||
           !listEquals(oldDelegate.motes, motes) || 
           oldDelegate.gentlePulseScale != gentlePulseScale;
  }
}