// File: lib/widgets/prayer_wall/well_of_hope_widget.dart
// Path: lib/widgets/prayer_wall/well_of_hope_widget.dart
// Approximate line: 1 (Whole file)

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Helper class for individual motes
class _Mote {
  Offset position;
  double size;
  double opacity;
  Duration lifetime;
  Duration age;
  Offset speed; // For gentle drift

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
  final GlobalKey wellKey;
  final Function(Offset localAbsorptionPoint)? onAbsorbPrayer;

  const WellOfHopeWidget({
    required this.wellKey,
    this.onAbsorbPrayer,
    super.key,
  });

  @override
  State<WellOfHopeWidget> createState() => _WellOfHopeWidgetState();
}

class _WellOfHopeWidgetState extends State<WellOfHopeWidget>
    with TickerProviderStateMixin {
  // Main orb's gentle, random pulsing (intensity/scale)
  late AnimationController _gentlePulseController;
  late Animation<double> _gentlePulseAnimation;
  Timer? _randomGentlePulseTimer;

  // "Others Praying" shimmer (quick brightness flash)
  late AnimationController _shimmerEffectController;
  late Animation<double> _shimmerEffectAnimation;
  Timer? _randomShimmerTimer;

  // Absorption effect controllers
  Offset? _absorptionPoint;
  late AnimationController _absorptionImpactController;
  late Animation<double> _absorptionImpactAnimation;
  late AnimationController _absorptionRippleController;
  late Animation<double> _absorptionRippleAnimation;

  // Motes (internal particles)
  List<_Mote> _motes = [];
  late AnimationController _motesAnimationController;
  final int _maxMotes = 25; // Max number of motes
  final Random _random = Random();
  DateTime _lastMoteUpdateTime = DateTime.now();


  @override
  void initState() {
    super.initState();

    // Gentle, random pulsing for the orb's scale
    _gentlePulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));
    _gentlePulseAnimation = Tween<double>(begin: 1.0, end: 1.0).animate( // Initial static tween
        CurvedAnimation(parent: _gentlePulseController, curve: Curves.elasticInOut)); // Smooth curve

    // Shimmer effect for "others praying"
    _shimmerEffectController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700)); // Faster, distinct pulse
     _shimmerEffectAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _shimmerEffectController, curve: Curves.easeInOut)
    );


    // Absorption animations
    _absorptionImpactController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Quick impact
    );
    _absorptionImpactAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
       CurvedAnimation(parent: _absorptionImpactController, curve: Curves.easeOut)
    );
    
    _absorptionRippleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800)); // Longer ripple
    _absorptionRippleAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _absorptionRippleController,
      curve: Curves.easeOutCirc,
    ));

    // Motes animation controller
    _motesAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Drives updates, not lifespan
    )..addListener(_updateMotes)..repeat();


    _startRandomTimers();
    _initializeMotes(const Size(200,200)); // Initial size assumption
  }

  void _startRandomTimers() {
    _randomGentlePulseTimer = Timer.periodic(Duration(seconds: _random.nextInt(5) + 4), (timer) {
      if (mounted && !_gentlePulseController.isAnimating) {
        double newEndScale = 1.0 + (_random.nextDouble() * 0.06 - 0.03); // e.g., 0.97 to 1.03
        _gentlePulseAnimation = Tween<double>(begin: _gentlePulseAnimation.value, end: newEndScale).animate(
            CurvedAnimation(parent: _gentlePulseController, curve: Curves.easeInOut)
        );
        _gentlePulseController.forward(from: 0.0).then((_) => _gentlePulseController.reverse());
      }
    });

    _randomShimmerTimer = Timer.periodic(Duration(seconds: _random.nextInt(6) + 3), (timer) {
      if (mounted && !_shimmerEffectController.isAnimating) {
        _shimmerEffectController.forward(from: 0.0).then((_) => _shimmerEffectController.reset());
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
      size: 1.5 + _random.nextDouble() * 2.5, // Slightly smaller motes
      opacity: 0.0, // Start invisible, will fade in
      lifetime: Duration(seconds: 3 + _random.nextInt(4)), // Random lifespan
      speed: Offset(
        (_random.nextDouble() - 0.5) * 10, // Slow horizontal drift (pixels per second)
        (_random.nextDouble() - 0.5) * 10, // Slow vertical drift
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
    final double dt = delta.inMilliseconds / 1000.0; // Delta time in seconds

    Size? canvasSize;
    final RenderBox? renderBox = widget.wellKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      canvasSize = renderBox.size;
    } else {
      canvasSize = const Size(200,200); // Fallback if not yet laid out
    }


    for (int i = 0; i < _motes.length; i++) {
      _Mote mote = _motes[i];
      mote.age += delta;

      // Update position for gentle drift
      mote.position = Offset(
        mote.position.dx + mote.speed.dx * dt,
        mote.position.dy + mote.speed.dy * dt,
      );

      // Fade in/out logic
      double lifeRatio = mote.age.inMilliseconds / mote.lifetime.inMilliseconds;
      if (lifeRatio < 0.3) { // Fade in
        mote.opacity = (lifeRatio / 0.3) * 0.6; // Max opacity 0.6
      } else if (lifeRatio > 0.7) { // Fade out
        mote.opacity = ((1.0 - lifeRatio) / 0.3) * 0.6;
      } else {
        mote.opacity = 0.6;
      }
      mote.opacity = mote.opacity.clamp(0.0, 0.6);

      // Respawn if dead or out of bounds (loosely)
      bool outOfBounds = mote.position.dx < -mote.size ||
                         mote.position.dx > canvasSize.width + mote.size ||
                         mote.position.dy < -mote.size ||
                         mote.position.dy > canvasSize.height + mote.size;

      if (mote.age >= mote.lifetime || outOfBounds) {
        _spawnMote(i, canvasSize);
      }
    }
    // No need to call setState here if AnimatedBuilder is listening to _motesAnimationController
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
  }

  @override
  void dispose() {
    _gentlePulseController.dispose();
    _shimmerEffectController.dispose();
    _absorptionImpactController.dispose();
    _absorptionRippleController.dispose();
    _motesAnimationController.removeListener(_updateMotes);
    _motesAnimationController.dispose();
    _randomGentlePulseTimer?.cancel();
    _randomShimmerTimer?.cancel();
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
            _motesAnimationController // To repaint when motes update
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _gentlePulseAnimation.value,
            child: CustomPaint(
              key: widget.wellKey, 
              size: const Size(200, 200), 
              painter: _WellPainter(
                shimmerProgress: _shimmerEffectAnimation.value,
                absorptionImpactProgress: _absorptionImpactAnimation.value,
                absorptionRippleProgress: _absorptionRippleAnimation.value,
                absorptionPoint: _absorptionPoint,
                motes: _motes,
                gentlePulseScale: _gentlePulseAnimation.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WellPainter extends CustomPainter {
  final double shimmerProgress; 
  final double absorptionImpactProgress;
  final double absorptionRippleProgress;
  final Offset? absorptionPoint;
  final List<_Mote> motes;
  final double gentlePulseScale; // Current scale from the gentle pulse

  _WellPainter({
    required this.shimmerProgress,
    required this.absorptionImpactProgress,
    required this.absorptionRippleProgress,
    this.absorptionPoint,
    required this.motes,
    required this.gentlePulseScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    // --- Ethereal Orb Background ---
    // Create a softer, more layered look
    for (int i = 3; i >= 1; i--) {
      final double layerRadius = radius * (0.8 + i * 0.07 * gentlePulseScale); // Pulsing layers
      final layerPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.lightBlue.shade50.withOpacity(0.03 * i), // More transparent outer layers
            Colors.cyan.shade100.withOpacity(0.05 * i),
            Colors.deepPurple.shade100.withOpacity(0.02 * i),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: layerRadius))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15.0 + i * 5); // More blur for outer layers
      canvas.drawCircle(center, layerRadius, layerPaint);
    }
    
    // --- "Others Praying" Shimmer Effect ---
    // This is a quick, bright pulse overlaying the orb
    if (shimmerProgress > 0) {
      // Use sin to make it pulse in and out smoothly during its short animation
      double effectStrength = sin(shimmerProgress * pi); 
      final shimmerPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.5 * effectStrength), // Bright center
            Colors.cyanAccent.withOpacity(0.3 * effectStrength),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.8], // Adjust stops for spread
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.9));
      canvas.drawCircle(center, radius * 0.9, shimmerPaint);
    }


    // --- Motes (Floating Particles) ---
    final motePaint = Paint()..style = PaintingStyle.fill;
    for (final mote in motes) {
      if (mote.opacity > 0) {
        motePaint.color = Colors.white.withOpacity(mote.opacity * 0.8); // Make motes slightly less opaque
        motePaint.maskFilter = MaskFilter.blur(BlurStyle.normal, mote.size * 0.6); // Softer blur
        canvas.drawCircle(mote.position, mote.size, motePaint);
      }
    }

    // --- Absorption Effect ---
    if (absorptionPoint != null) {
      // 1. Point of Impact (quick, bright flash)
      if (absorptionImpactProgress > 0 && absorptionImpactProgress < 1.0) {
        double impactOpacity = sin(absorptionImpactProgress * pi); // Full cycle for fade in/out
        final impactFlashPaint = Paint()
          ..color = Colors.white.withOpacity(impactOpacity * 0.9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
        canvas.drawCircle(absorptionPoint!, radius * 0.05 + (radius * 0.1 * absorptionImpactProgress) , impactFlashPaint);
      }

      // 2. Outward Ripple (starts slightly after impact, fades)
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
           !listEquals(oldDelegate.motes, motes) || // Check if motes list changed
           oldDelegate.gentlePulseScale != gentlePulseScale;
  }
}