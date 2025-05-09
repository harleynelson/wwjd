// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for SystemUiOverlayStyle
import 'home_screen.dart'; 
import 'prefs_helper.dart';
import 'theme/app_colors.dart'; // Import your AppColors

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefsHelper.init(); 
  runApp(const WWJDApp());
}

class WWJDApp extends StatelessWidget {
  const WWJDApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the new AppBar background color
    var AppBarBackgroundColor = AppColors.sereneSkyGradient[1]; // Amber: Color(0xFFFFD180)
    // Define the foreground color for text and icons on the AppBar
    const AppBarForegroundColor = AppColors.textPrimary; // A dark color for contrast on amber

    return MaterialApp(
      title: 'Wake up with Jesus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple.shade700), // Keep or adjust seed
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          // Set new background color
          backgroundColor: AppBarBackgroundColor,
          // Set new foreground color (for title text and icons like back arrow)
          foregroundColor: AppBarForegroundColor, 
          // Ensure title text style uses the new foreground color
          titleTextStyle: const TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: AppBarForegroundColor,
          ),
          // Explicitly set icon theme for actions and leading icons
          iconTheme: const IconThemeData(
            color: AppBarForegroundColor,
          ),
          // Adjust elevation if desired (Material 3 AppBars often have less or no elevation by default when scrolled)
          elevation: 1.0, 
          scrolledUnderElevation: 2.0, // Elevation when content scrolls under the AppBar
          // Optional: Adjust status bar brightness based on AppBar color
          // If AppBarBackgroundColor is light, use Brightness.dark for status bar icons
          // If AppBarBackgroundColor is dark, use Brightness.light for status bar icons
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // Usually best for modern look
            statusBarIconBrightness: Brightness.dark, // For light AppBar backgrounds
            statusBarBrightness: Brightness.light, // For iOS (deprecated but good fallback)
          ),
        ),
        // You might want to define other theme elements here too, like textTheme, buttonTheme, etc.
      ),
      home: const HomeScreen(), 
    );
  }
}
