// lib/widgets/animated_religious_background_card.dart
import 'package:flutter/material.dart';
import 'dart:math'; 
import 'dart:ui' as ui; 
import '../theme/app_colors.dart';

// AnimatedReligiousBackgroundCard StatefulWidget and its State class
// (Keep these exactly as in the previous successful version)
class AnimatedReligiousBackgroundCard extends StatefulWidget {
  final Widget child; 
  final List<Color>? gradientColors;
  final Alignment beginGradientAlignment;
  final Alignment endGradientAlignment;
  final bool enableGodRays;
  final bool enableLightSpecks;
  final BorderRadius borderRadius;
  final double elevation;
  final EdgeInsetsGeometry margin;
  final int numberOfSpecks;

  const AnimatedReligiousBackgroundCard({
    super.key,
    required this.child, 
    this.gradientColors,
    this.beginGradientAlignment = Alignment.topLeft,
    this.endGradientAlignment = Alignment.bottomRight,
    this.enableGodRays = true, 
    this.enableLightSpecks = true, 
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
    this.elevation = 4.0,
    this.margin = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
    this.numberOfSpecks = 20, 
  });

  @override
  State<AnimatedReligiousBackgroundCard> createState() => _AnimatedReligiousBackgroundCardState();
}

class _AnimatedReligiousBackgroundCardState extends State<AnimatedReligiousBackgroundCard>
    with TickerProviderStateMixin {
  late final AnimationController _godRaysController;
  late final AnimationController _lightSpecksController;
  List<Color> _actualGradientColors = [];

  @override
  void initState() {
    super.initState();

    if (widget.gradientColors != null && widget.gradientColors!.length >= 2) {
      _actualGradientColors = widget.gradientColors!;
    } else {
      _actualGradientColors = AppColors.devotionalCardTwoColorGradient; 
    }

    _godRaysController = AnimationController(
      duration: const Duration(seconds: 15), 
      vsync: this,
    );
    if (widget.enableGodRays) {
      _godRaysController.repeat(reverse: true);
    }

    _lightSpecksController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );
    if (widget.enableLightSpecks) {
      _lightSpecksController.repeat();
    }
  }
  
  @override
  void didUpdateWidget(AnimatedReligiousBackgroundCard oldWidget) {
    super.didUpdateWidget(oldWidget);
     if (widget.gradientColors != null && widget.gradientColors!.length >=2 && widget.gradientColors != oldWidget.gradientColors) {
        _actualGradientColors = widget.gradientColors!;
    } else if (widget.gradientColors == null && oldWidget.gradientColors != null) {
        _actualGradientColors = AppColors.devotionalCardTwoColorGradient;
    }
    
    if (widget.enableGodRays != oldWidget.enableGodRays) {
      if (widget.enableGodRays && !_godRaysController.isAnimating) {
        _godRaysController.repeat(reverse: true);
      } else if (!widget.enableGodRays && _godRaysController.isAnimating) {
        _godRaysController.stop();
      }
    }
    if (widget.enableLightSpecks != oldWidget.enableLightSpecks) {
      if (widget.enableLightSpecks && !_lightSpecksController.isAnimating) {
        _lightSpecksController.repeat();
      } else if (!widget.enableLightSpecks && _lightSpecksController.isAnimating) {
        _lightSpecksController.stop();
      }
    }
  }

  @override
  void dispose() {
    _godRaysController.dispose();
    _lightSpecksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.elevation,
      margin: widget.margin,
      shape: RoundedRectangleBorder(borderRadius: widget.borderRadius),
      clipBehavior: Clip.antiAlias,
      child: Stack( 
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _actualGradientColors,
                  begin: widget.beginGradientAlignment,
                  end: widget.endGradientAlignment,
                ),
              ),
            ),
          ),
          
          if (widget.enableGodRays)
            Positioned.fill(
              child: RepaintBoundary( 
                child: CustomPaint(
                  painter: GodRaysPainter(animation: _godRaysController),
                ),
              ),
            ),
          
          if (widget.enableLightSpecks)
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: LightSpecksPainter(
                    animation: _lightSpecksController,
                    numberOfSpecks: widget.numberOfSpecks,
                  ),
                ),
              ),
            ),
          widget.child,
        ],
      ),
    );
  }
}


// --- God Rays Painter (MODIFIED for More Parallel, Spread Out Rays) ---
class GodRaysPainter extends CustomPainter {
  final Animation<double> animation;

  GodRaysPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Brightness and pulse (can be tweaked further if needed)
    final double baseOpacity = 0.2; 
    final double pulseStrength = 0.2; 
    final double opacityFactor = sin(animation.value * pi); 
    final double animatedOpacity = baseOpacity + (pulseStrength * opacityFactor);

    // Define a common angle for all rays to make them parallel
    // 135 degrees = down and to the left.
    // 125 degrees = a bit more downwards.
    // 145 degrees = a bit more leftwards.
    // Let's use a slightly varied set for a little character, but very close.
    const double mainAngleRad = 105 * pi / 180.0; // Central direction
    const double angleSpread = 5 * pi / 180.0;   // Max +/- 5 degrees from main angle

    // Define properties for each ray strip:
    // - 'startAnchorXFactor': Horizontal anchor on card width (e.g., 0.8 = 80% from left)
    // - 'startAnchorYOffset': Vertical offset from top edge (negative is above)
    // - 'width': Width of the ray.
    // - 'angleOffsetRad': Small offset from mainAngleRad for this specific ray.
    // - 'length': A large fixed length to ensure it crosses the card.
    // - 'opacityMultiplier': Individual brightness tweak.
    List<Map<String, double>> rayDefinitions = [
      { 'startAnchorXFactor': 0.55, 'startAnchorYOffset': -30.0, 'width': 30.0, 'angleOffsetRad': -angleSpread * 0.5, 'length': size.height + 200, 'opacityMult': 1.0},
      { 'startAnchorXFactor': 0.95, 'startAnchorYOffset': -20.0, 'width': 40.0, 'angleOffsetRad': 0.0,               'length': size.height + 250, 'opacityMult': 0.95},
      { 'startAnchorXFactor': 1.05, 'startAnchorYOffset': -20.0, 'width': 50.0, 'angleOffsetRad': 0.0,  'length': size.height + 220, 'opacityMult': 0.85},
      // Add a fainter, slightly more offset one for depth
      { 'startAnchorXFactor': 0.75, 'startAnchorYOffset': -40.0, 'width': 25.0, 'angleOffsetRad': 0, 'length': size.height + 180, 'opacityMult': 0.7},
    ];

    for (var def in rayDefinitions) {
      Path path = Path();
      
      // Calculate the actual starting point of the ray's center
      double rayStartX = size.width * def['startAnchorXFactor']!;
      double rayStartY = def['startAnchorYOffset']!;
      double rayWidth = def['width']!;
      double rayAngle = mainAngleRad + def['angleOffsetRad']!;
      double rayLength = def['length']!; // Use defined length

      // Vector for ray direction
      double dirX = cos(rayAngle);
      double dirY = sin(rayAngle);

      // Vector perpendicular to ray direction (for width)
      double perpX = -dirY; 
      double perpY = dirX;  

      // Define the 4 corners of the ray strip
      // Corner 1 (Top-Left of the strip's starting edge)
      path.moveTo(rayStartX + perpX * rayWidth / 2, 
                  rayStartY + perpY * rayWidth / 2);
      // Corner 2 (Bottom-Left of the strip - far end)
      path.lineTo(rayStartX + perpX * rayWidth / 2 + dirX * rayLength, 
                  rayStartY + perpY * rayWidth / 2 + dirY * rayLength);
      // Corner 3 (Bottom-Right of the strip - far end)
      path.lineTo(rayStartX - perpX * rayWidth / 2 + dirX * rayLength, 
                  rayStartY - perpY * rayWidth / 2 + dirY * rayLength);
      // Corner 4 (Top-Right of the strip's starting edge)
      path.lineTo(rayStartX - perpX * rayWidth / 2, 
                  rayStartY - perpY * rayWidth / 2);
      path.close();

      paint.shader = ui.Gradient.linear(
        Offset(rayStartX, rayStartY), // Gradient starts at the ray's defined origin
        Offset(rayStartX + dirX * rayLength * 0.7, // Fades out along its length
               rayStartY + dirY * rayLength * 0.7),    
        [
          Colors.white.withOpacity(animatedOpacity * def['opacityMult']!),        
          Colors.white.withOpacity(animatedOpacity * def['opacityMult']! * 0.5),  
          Colors.white.withOpacity(0.0)                     
        ],
        [0.0, 0.35, 1.0] // Brighter core, then fades. Adjust stops for sharpness.
      );
      
      // Slightly reduced blur for a bit more definition, but still soft
      paint.maskFilter = ui.MaskFilter.blur(BlurStyle.normal, 5.0); 

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GodRaysPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}


// --- Light Specks Painter and LightSpeck class ---
// (Keep these exactly as they were in the previous successful response)
class LightSpeck {
  Offset position; double size; double opacity; Offset speed; 
  final Color color; final Duration lifetime; Duration age; double initialPhase; 
  LightSpeck({ required this.position, required this.size, required this.opacity, required this.speed, this.color = Colors.white, required this.lifetime, this.age = Duration.zero, this.initialPhase = 0.0 });
}

class LightSpecksPainter extends CustomPainter {
  final Animation<double> animation; final int numberOfSpecks;
  final List<LightSpeck?> _specks; final Random _random = Random();
  bool _specksInitialized = false; DateTime _lastFrameTime; 
  LightSpecksPainter({required this.animation, required this.numberOfSpecks})
      : _specks = List<LightSpeck?>.filled(numberOfSpecks, null), _lastFrameTime = DateTime.now(), super(repaint: animation);
  void _initializeSpeck(int index, Size canvasSize, {bool initialPlacement = false}) {
    double startX, startY;
    if (initialPlacement) { startX = _random.nextDouble() * canvasSize.width; startY = _random.nextDouble() * canvasSize.height; } 
    else { startX = canvasSize.width * (_random.nextDouble() * 0.5 - 0.25); startY = canvasSize.height * (0.8 + _random.nextDouble() * 0.4); }
    _specks[index] = LightSpeck( position: Offset(startX, startY), size: 0.8 + _random.nextDouble() * 2.0, opacity: 0.0, 
      speed: Offset((10 + _random.nextDouble() * 15), -(10 + _random.nextDouble() * 15)),
      color: Colors.white.withOpacity(0.4 + _random.nextDouble() * 0.4), 
      lifetime: Duration(seconds: 5 + _random.nextInt(6)), age: Duration.zero, initialPhase: _random.nextDouble() * pi);
  }
  @override void paint(Canvas canvas, Size size) {
    if (size.isEmpty) { _lastFrameTime = DateTime.now(); return; }
    DateTime currTime = DateTime.now(); double dt = currTime.difference(_lastFrameTime).inMilliseconds / 1000.0;
    _lastFrameTime = currTime; dt = dt.clamp(0.001, 0.05);
    if (!_specksInitialized && size.width > 0 && size.height > 0) {
      for (int i = 0; i < numberOfSpecks; i++) { _initializeSpeck(i, size, initialPlacement: true); } _specksInitialized = true;
    }
    final Paint p = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < numberOfSpecks; i++) {
      LightSpeck? speck = _specks[i]; if (speck == null) continue;
      speck.age += Duration(microseconds: (dt * 1000000).toInt());
      speck.position = Offset(speck.position.dx + speck.speed.dx * dt, speck.position.dy + speck.speed.dy * dt);
      double lifeProg = (speck.age.inMilliseconds / speck.lifetime.inMilliseconds.toDouble()).clamp(0.0, 1.0);
      speck.opacity = sin(lifeProg * pi + speck.initialPhase).abs(); speck.opacity = pow(speck.opacity, 2).toDouble(); speck.opacity = speck.opacity.clamp(0.0, 0.8); 
      p.color = speck.color.withOpacity(speck.opacity);
      p.maskFilter = ui.MaskFilter.blur(BlurStyle.normal, speck.size * 0.4); 
      canvas.drawCircle(speck.position, speck.size, p);
      bool offX = speck.position.dx > size.width + speck.size * 2 || speck.position.dx < -speck.size * 2;
      bool offY = speck.position.dy < -speck.size * 2 || speck.position.dy > size.height + speck.size * 2;
      if (speck.age >= speck.lifetime || offX || offY) { _initializeSpeck(i, size); }
    }
  }
  @override bool shouldRepaint(covariant LightSpecksPainter old) => old.animation != animation || old.numberOfSpecks != numberOfSpecks;
}