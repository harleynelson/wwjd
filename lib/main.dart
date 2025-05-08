// lib/main.dart
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Changed from bible_screen.dart
import 'prefs_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefsHelper.init(); // Initialize SharedPreferences
  runApp(const WWJDApp());
}

class WWJDApp extends StatelessWidget {
  const WWJDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wake up With Jesus Daily',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme( // Consistent AppBar styling
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        )
      ),
      home: const HomeScreen(), // Points to the new HomeScreen
    );
  }
}