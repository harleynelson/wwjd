// lib/main.dart
// Path: lib/main.dart
// Approximate line: 7, 14-22

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
// Remove dotenv import if no longer used for other keys
// import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'screens/home_screen.dart';
import 'helpers/prefs_helper.dart';
import 'theme/app_themes.dart';
import 'theme/theme_provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'models/app_user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Removed: await dotenv.load(fileName: ".env"); 

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check
  // Note: For web, you'd use ReCaptchaV3Provider.
  // For debug builds, you might use AndroidProvider.debug or AppleProvider.debug initially.
  // Ensure you have properly configured Play Integrity (Android) and App Attest/DeviceCheck (iOS) in the Firebase console.
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity, // Or AndroidProvider.debug for testing .. AndroidProvider.playIntegrity for release
    appleProvider: AppleProvider.appAttest,       // Or AppleProvider.deviceCheck or AppleProvider.debug for testing
    // webProvider: ReCaptchaV3Provider('YOUR_RECAPTCHA_V3_SITE_KEY'), // If using for web
  );

  // Initialize Firebase Remote Config
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1), // Timeout for fetching config
    minimumFetchInterval: const Duration(hours: 1), // How often to fetch new config
  ));
  // Set default values (optional, but good practice)
  await remoteConfig.setDefaults(const {
    "google_cloud_tts_api_key": "", // Default to empty if not found
  });
  // Fetch and activate the configuration
  try {
    await remoteConfig.fetchAndActivate();
    print("Remote Config fetched and activated successfully.");
    // You can log the fetched key here for debugging if needed, but remove for production.
    // print("Fetched API Key: ${remoteConfig.getString('google_cloud_tts_api_key')}");
  } catch (e) {
    print("Error fetching or activating Remote Config: $e");
    // Handle error, maybe use a default/fallback or show an error message
  }

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