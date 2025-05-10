// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Import provider
import 'home_screen.dart';
import 'prefs_helper.dart';
import 'theme/app_themes.dart'; // Import your AppThemes
import 'theme/theme_provider.dart'; // Import your ThemeProvider

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefsHelper.init(); // Ensure PrefsHelper is initialized
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(), // Create ThemeProvider instance
      child: const WWJDApp(),
    ),
  );
}

class WWJDApp extends StatelessWidget {
  const WWJDApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Wake up with Jesus',
      theme: AppThemes.lightTheme, // Your defined light theme
      darkTheme: AppThemes.darkTheme, // Your defined dark theme
      themeMode: themeProvider.themeMode, // Controlled by ThemeProvider
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false, // Optional: remove debug banner
    );
  }
}