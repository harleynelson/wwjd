// File: lib/models/verse_image_style.dart
// Path: lib/models/verse_image_style.dart
// Updated: Constructor defaults.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Enum for background types
enum BackgroundType { solid, gradient, image }

// Enum for predefined gradients
enum PredefinedGradient {
  none,
  sunset, // Orange to Pink
  oceanBlue, // Blue to LightBlueAccent
  softPink, // Light Pink to Lighter Pink
  mintGreen, // Light Green to Lighter Green
  lavenderMist, // Soft Periwinkle to Pale Lilac
  peachDream, // Soft Peach to Pale Yellow
  skyBlue, // Light Sky Blue to Pale Aqua
  roseGold, // Pinkish to Goldish
  monochromeGray, // Gray to White
  deepSpace, // Dark Blue to Black
  forestDew, // Dark Green to Light Green
  fieryCoral, // Coral to OrangeRed
  royalPurple, // Deep Purple to Lavender
  goldenHour, // Gold to Soft Orange
  springMeadow, // Light Green to Yellow Green
}

// Enum for image aspect ratio
enum ImageAspectRatio {
  square_1_1(1.0, "1:1 Square"), // Aspect ratio value and display name
  portrait_4_5(4 / 5, "4:5 Portrait"),
  story_9_16(9 / 16, "9:16 Story");

  const ImageAspectRatio(this.value, this.displayName);
  final double value;
  final String displayName;
}

// Enum for text vertical alignment within the image
enum ImageTextVerticalAlignment {
  top("Top"),
  center("Center"),
  bottom("Bottom");

  const ImageTextVerticalAlignment(this.displayName);
  final String displayName;
}


// Model to hold all style properties for the verse image
class VerseImageStyle {
  String verseText;
  String verseReference;

  // Verse Text Styling
  String verseFontFamily;
  double verseFontSize;
  Color verseFontColor;
  TextAlign verseTextAlign;
  FontWeight verseFontWeight;

  // Reference Text Styling
  String referenceFontFamily;
  double referenceFontSize;
  Color referenceFontColor;
  TextAlign referenceTextAlign;
  FontWeight referenceFontWeight;

  // Background Styling
  BackgroundType backgroundType;
  Color backgroundColor;
  PredefinedGradient predefinedGradient;
  String? backgroundImageAsset; // Path to asset image

  // Layout & Sizing
  double padding;
  ImageAspectRatio aspectRatio;
  ImageTextVerticalAlignment textVerticalAlignment;
  double textBlockScale; // To scale text block within preview area (0.5 to 1.0)

  VerseImageStyle({
    this.verseText = "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.",
    this.verseReference = "John 3:16",
    // UPDATED DEFAULTS:
    this.verseFontFamily = 'Quicksand',
    this.verseFontSize = 28.0,
    this.verseFontColor = Colors.black, // Consider a theme-aware default later
    this.verseTextAlign = TextAlign.center,
    this.verseFontWeight = FontWeight.normal,
    this.referenceFontFamily = 'Lato',
    this.referenceFontSize = 14.0,
    this.referenceFontColor = Colors.black54, // Consider a theme-aware default later
    this.referenceTextAlign = TextAlign.center, // Default, will be made effective
    this.referenceFontWeight = FontWeight.normal,
    this.backgroundType = BackgroundType.gradient,
    this.backgroundColor = Colors.white,
    this.predefinedGradient = PredefinedGradient.peachDream,
    this.backgroundImageAsset,
    this.padding = 20.0,
    this.aspectRatio = ImageAspectRatio.portrait_4_5,
    this.textVerticalAlignment = ImageTextVerticalAlignment.center,
    this.textBlockScale = 0.50, // Updated default
  });

  TextStyle getVerseTextStyle() {
    try {
      return GoogleFonts.getFont(
        verseFontFamily,
        fontSize: verseFontSize * textBlockScale, 
        color: verseFontColor,
        fontWeight: verseFontWeight,
        height: 1.3, 
      );
    } catch (e) {
      print("Error loading verse font '$verseFontFamily': $e. Falling back to Lato.");
      return GoogleFonts.lato( 
        fontSize: verseFontSize * textBlockScale,
        color: verseFontColor,
        fontWeight: verseFontWeight,
        height: 1.3,
      );
    }
  }

  TextStyle getReferenceTextStyle() {
    try {
      return GoogleFonts.getFont(
        referenceFontFamily,
        fontSize: referenceFontSize * textBlockScale, 
        color: referenceFontColor,
        fontWeight: referenceFontWeight,
      );
    } catch (e) {
      print("Error loading reference font '$referenceFontFamily': $e. Falling back to Lato.");
      return GoogleFonts.lato( 
        fontSize: referenceFontSize * textBlockScale,
        color: referenceFontColor,
        fontWeight: referenceFontWeight,
      );
    }
  }

  BoxDecoration getBackgroundDecoration() {
    if (backgroundType == BackgroundType.gradient && predefinedGradient != PredefinedGradient.none) {
      return BoxDecoration(gradient: getGradient(predefinedGradient));
    } else if (backgroundType == BackgroundType.image && backgroundImageAsset != null && backgroundImageAsset!.isNotEmpty) {
      return BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImageAsset!),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.15), BlendMode.darken),
        ),
      );
    }
    return BoxDecoration(color: backgroundColor);
  }

  static Gradient getGradient(PredefinedGradient gradient) {
    // Gradient definitions remain the same as previous version
    switch (gradient) {
      case PredefinedGradient.sunset:
        return const LinearGradient(colors: [Color(0xFFFF7E5F), Color(0xFFFEB47B)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case PredefinedGradient.oceanBlue:
        return const LinearGradient(colors: [Color(0xFF0072ff), Color(0xFF00c6ff)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case PredefinedGradient.softPink:
        return const LinearGradient(colors: [Color(0xFFFBC7D4), Color(0xFFFDD7E4)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case PredefinedGradient.mintGreen:
        return const LinearGradient(colors: [Color(0xFFB2F5EA), Color(0xFFD4FFF3)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case PredefinedGradient.lavenderMist:
        return const LinearGradient(colors: [Color(0xFFD1C4E9), Color(0xFFEAE6F3)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case PredefinedGradient.peachDream:
        return const LinearGradient(colors: [Color(0xFFFFE0B2), Color(0xFFFFF3E0)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case PredefinedGradient.skyBlue:
        return const LinearGradient(colors: [Color(0xFF90CAF9), Color(0xFFBBDEFB)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case PredefinedGradient.roseGold:
        return const LinearGradient(colors: [Color(0xFFF48FB1), Color(0xFFFFD180)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case PredefinedGradient.monochromeGray:
        return const LinearGradient(colors: [Color(0xFFBDBDBD), Color(0xFFF5F5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case PredefinedGradient.deepSpace:
        return const LinearGradient(colors: [Color(0xFF2C3E50), Color(0xFF000000)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case PredefinedGradient.forestDew:
        return const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case PredefinedGradient.fieryCoral:
        return const LinearGradient(colors: [Color(0xFFFF7043), Color(0xFFFFAB91)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case PredefinedGradient.royalPurple:
        return const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case PredefinedGradient.goldenHour:
        return const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFFD54F)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case PredefinedGradient.springMeadow:
        return const LinearGradient(colors: [Color(0xFF9CCC65), Color(0xFFC5E1A5)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case PredefinedGradient.none:
      default:
        return const LinearGradient(colors: [Colors.white, Colors.white70]);
    }
  }

  VerseImageStyle copyWith({
    String? verseText,
    String? verseReference,
    String? verseFontFamily,
    double? verseFontSize,
    Color? verseFontColor,
    TextAlign? verseTextAlign,
    FontWeight? verseFontWeight,
    String? referenceFontFamily,
    double? referenceFontSize,
    Color? referenceFontColor,
    TextAlign? referenceTextAlign,
    FontWeight? referenceFontWeight,
    BackgroundType? backgroundType,
    Color? backgroundColor,
    PredefinedGradient? predefinedGradient,
    String? backgroundImageAsset,
    bool clearBackgroundImage = false,
    double? padding,
    ImageAspectRatio? aspectRatio,
    ImageTextVerticalAlignment? textVerticalAlignment,
    double? textBlockScale,
  }) {
    return VerseImageStyle(
      verseText: verseText ?? this.verseText,
      verseReference: verseReference ?? this.verseReference,
      verseFontFamily: verseFontFamily ?? this.verseFontFamily,
      verseFontSize: verseFontSize ?? this.verseFontSize,
      verseFontColor: verseFontColor ?? this.verseFontColor,
      verseTextAlign: verseTextAlign ?? this.verseTextAlign,
      verseFontWeight: verseFontWeight ?? this.verseFontWeight,
      referenceFontFamily: referenceFontFamily ?? this.referenceFontFamily,
      referenceFontSize: referenceFontSize ?? this.referenceFontSize,
      referenceFontColor: referenceFontColor ?? this.referenceFontColor,
      referenceTextAlign: referenceTextAlign ?? this.referenceTextAlign,
      referenceFontWeight: referenceFontWeight ?? this.referenceFontWeight,
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      predefinedGradient: predefinedGradient ?? this.predefinedGradient,
      backgroundImageAsset: clearBackgroundImage ? null : (backgroundImageAsset ?? this.backgroundImageAsset),
      padding: padding ?? this.padding,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      textVerticalAlignment: textVerticalAlignment ?? this.textVerticalAlignment,
      textBlockScale: textBlockScale ?? this.textBlockScale,
    );
  }
}

const List<String> kChicFonts = [
  'Lato', 'Montserrat', 'Raleway', 'Playfair Display', 'Dancing Script',
  'Quicksand', 'Open Sans', 'Roboto', 'Merriweather', 'Pacifico',
  'Great Vibes', 'Josefin Sans', 'Comfortaa', 'Sacramento', 'Poiret One',
  'Lobster', 'Satisfy', 'Caveat', 'Amatic SC', 'Cinzel', 'Cormorant Garamond',
  'EB Garamond', 'Exo 2', 'Nunito', 'Oswald', 'PT Sans', 
  'Source Sans 3', 
  'Tangerine', 'Yellowtail', 'Parisienne', 'Alex Brush', 'Marck Script',
  'Allura', 'Petit Formal Script', 'Julius Sans One', 'Advent Pro', 'Philosopher',
];

const List<String> kSampleBackgroundImages = [
  // 'assets/images/backgrounds/paper_texture.png',
  // 'assets/images/backgrounds/watercolor_blush.png',
  // 'assets/images/backgrounds/soft_gradient_1.png',
  // 'assets/images/backgrounds/minimal_leaves.png',
  // 'assets/images/backgrounds/gold_geometric.png',
  // 'assets/images/backgrounds/pastel_sky.png',
  // 'assets/images/backgrounds/subtle_marble.png',
  // 'assets/images/backgrounds/linen_texture.png',
  // 'assets/images/backgrounds/abstract_waves.png',
  // 'assets/images/backgrounds/floral_overlay.png',
];

String getGradientDisplayName(PredefinedGradient gradient) {
  // Display names remain the same as previous version
  switch (gradient) {
    case PredefinedGradient.none: return 'None (Use Solid)';
    case PredefinedGradient.sunset: return 'Sunset Glow';
    case PredefinedGradient.oceanBlue: return 'Ocean Blue';
    case PredefinedGradient.softPink: return 'Soft Pink';
    case PredefinedGradient.mintGreen: return 'Mint Green';
    case PredefinedGradient.lavenderMist: return 'Lavender Mist';
    case PredefinedGradient.peachDream: return 'Peach Dream';
    case PredefinedGradient.skyBlue: return 'Sky Blue';
    case PredefinedGradient.roseGold: return 'Rose Gold';
    case PredefinedGradient.monochromeGray: return 'Monochrome';
    case PredefinedGradient.deepSpace: return 'Deep Space';
    case PredefinedGradient.forestDew: return 'Forest Dew';
    case PredefinedGradient.fieryCoral: return 'Fiery Coral';
    case PredefinedGradient.royalPurple: return 'Royal Purple';
    case PredefinedGradient.goldenHour: return 'Golden Hour';
    case PredefinedGradient.springMeadow: return 'Spring Meadow';
    default: return 'Gradient';
  }
}
