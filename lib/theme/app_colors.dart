// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // --- Single Colors ---
  static const Color primaryBrand = Colors.amber;
  static const Color secondaryBrand = Colors.amber;
  static const Color accentBrand = Colors.pinkAccent;

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.black;

  // --- Gradient Color Lists ---
  static const List<Color> devotionalCardGradient = [
    Color(0xFF7E57C2), 
    Color(0xFF5C6BC0), 
    Color(0xFF8E24AA), 
    Color(0xFFAB47BC), 
  ];

  static const List<Color> devotionalCardTwoColorGradient = [
    Color(0xFFFFD180),
    Color(0xFFCE93D8),
  ];

  static const List<Color> sunriseHopeGradient = [
    Color(0xFFFFD180), 
    Color(0xFFFFAB91), 
    Color(0xFFCE93D8), 
  ];

  static const List<Color> loadingPlaceholderGradient = [
    Color(0xFFE0E0E0), 
    Color(0xFFBDBDBD), 
  ];

  static const List<Color> mutedPlaceholderGradient = [
    Color(0xFFB0BEC5), 
    Color(0xFF90A4AE), 
  ];

  // Serene Sky
  static const List<Color> sereneSkyGradient = [
    Color(0xFFA1C4FD), // Light Sky Blue
    Color(0xFFC2E9FB), // Pale Aqua
  ];

  // Gentle Dawn
  static const List<Color> gentleDawnGradient = [
    Color(0xFFFFE0B2), // Soft Peach (from Colors.orange.shade100)
    Color(0xFFFFF9C4), // Pale Yellow (from Colors.yellow.shade100)
  ];

  // Misty Rose
  static const List<Color> mistyRoseGradient = [
    Color(0xFFF48FB1), // Soft Pink (from Colors.pink.shade200)
    Color(0xFFE1BEE7), // Light Lavender (from Colors.purple.shade100)
  ];

  // Quiet Grove
  static const List<Color> quietGroveGradient = [
    Color(0xFFA5D6A7), // Pale Sage Green (from Colors.green.shade200)
    Color(0xFFFFFDE7), // Light Cream (from Colors.lime.shade50)
  ];

  // Evening Calm
  static const List<Color> eveningCalmGradient = [
    Color(0xFFB39DDB), // Soft Periwinkle (from Colors.deepPurple.shade200)
    Color(0xFFD1C4E9), // Pale Lilac (from Colors.deepPurple.shade100)
  ];
  
  // Soft Teal to Mint
  static const List<Color> tealMintGradient = [
    Color(0xFF80CBC4), // Soft Teal (Colors.teal.shade200)
    Color(0xFFA7FFEB), // Pale Mint (Colors.teal.accent[100] or similar)
  ];
}