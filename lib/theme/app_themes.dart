// lib/theme/app_themes.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart'; // Your existing AppColors

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple.shade700, // Your primary seed color
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.grey.shade100, // Lighter background
    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromARGB(255, 22, 34, 68), // Dark appbar
      foregroundColor: Colors.white.withOpacity(0.9), // Light text on dark appbar
      elevation: 1.0,
      scrolledUnderElevation: 2.0,
      titleTextStyle: GoogleFonts.lato(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white.withOpacity(0.9),
      ),
      iconTheme: IconThemeData(
        color: Colors.white.withOpacity(0.9),
      ),
    ),
    textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme).copyWith(
      bodyLarge: TextStyle(color: AppColors.textPrimary.withOpacity(0.85)),
      bodyMedium: TextStyle(color: AppColors.textPrimary.withOpacity(0.75)),
      titleMedium: TextStyle(color: AppColors.textPrimary.withOpacity(0.9)),
      // Define other text styles as needed
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Colors.white, // Light card background
    ),
    listTileTheme: ListTileThemeData(
      iconColor: Colors.deepPurple.shade700,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
  builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(), // Uses iOS-style slide for Android
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),     // Default iOS slide
    // Or use OpenUpwardsPageTransitionsBuilder, ZoomPageTransitionsBuilder, FadeUpwardsPageTransitionsBuilder
    // Or create your own custom PageTransitionsBuilder
  },
),
    // Define other component themes
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple.shade700, // Same seed
      brightness: Brightness.dark, // Important for dark scheme generation
    ),
    scaffoldBackgroundColor: Colors.grey.shade900, // Dark background
    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromARGB(255, 22, 34, 68), // Dark appbar
      foregroundColor: Colors.white.withOpacity(0.9), // Light text on dark appbar
      elevation: 1.0,
      scrolledUnderElevation: 2.0,
      titleTextStyle: GoogleFonts.lato(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white.withOpacity(0.9),
      ),
      iconTheme: IconThemeData(
        color: Colors.white.withOpacity(0.9),
      ),
    ),
    textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyLarge: TextStyle(color: Colors.white.withOpacity(0.85)),
      bodyMedium: TextStyle(color: Colors.white.withOpacity(0.75)),
      titleMedium: TextStyle(color: Colors.white.withOpacity(0.9)),
      // Define other text styles as needed
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Colors.grey.shade800, // Darker card background
    ),
    listTileTheme: ListTileThemeData(
      iconColor: Colors.purple.shade200,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
  builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(), // Uses iOS-style slide for Android
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),     // Default iOS slide
    // Or use OpenUpwardsPageTransitionsBuilder, ZoomPageTransitionsBuilder, FadeUpwardsPageTransitionsBuilder
    // Or create your own custom PageTransitionsBuilder
  },
),
    // Define other component themes
  );
}