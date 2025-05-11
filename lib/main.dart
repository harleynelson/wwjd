// lib/main.dart
// Path: lib/main.dart
// Key change is in Firebase.initializeApp()

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'helpers/prefs_helper.dart';
import 'theme/app_themes.dart';
import 'theme/theme_provider.dart';
// IMPORTANT: This now refers to your manually created or CLI-generated file
import 'firebase_options.dart';

import 'services/auth_service.dart';
import 'models/app_user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    // This uses the class you manually created (or that flutterfire would generate)
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await PrefsHelper.init();
  final authService = AuthService();
  await authService.signInAnonymouslyIfNeeded();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AuthService>.value(value: authService),
        StreamProvider<AppUser?>(
          create: (context) => authService.user,
          initialData: authService.currentUser,
          catchError: (_, error) {
            print("Error in auth stream: $error");
            return null;
          },
        ),
      ],
      child: const WWJDApp(),
    ),
  );
}

// WWJDApp class remains the same
class WWJDApp extends StatelessWidget {
  const WWJDApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Wake up with Jesus Daily',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}