// File: lib/main.dart
// Path: lib/main.dart
// Updated: Add IAPService provider and link it with AuthService.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

// Existing imports
import 'screens/home_screen.dart';
import 'helpers/prefs_helper.dart';
import 'theme/app_themes.dart';
import 'theme/theme_provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'models/app_user.dart';

// Prayer Wall Imports
import 'services/prayer_service.dart';
// import 'screens/prayer_wall/prayer_wall_screen.dart'; // Not directly used in main
// import 'screens/prayer_wall/submit_prayer_screen.dart'; // Not directly used in main
// import 'screens/prayer_wall/my_prayer_requests_screen.dart'; // Not directly used in main
// import 'screens/settings_screen.dart'; // Not directly used in main

// --- NEW IAP IMPORT ---
import 'services/iap_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity, // Or AndroidProvider.debug for emulators during dev
    appleProvider: AppleProvider.appAttest,       // Or AppleProvider.debug for simulators during dev
  );

  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1), // Adjust as needed for production
  ));
  await remoteConfig.setDefaults(const {
    "google_cloud_tts_api_key": "", // Ensure you have a default or it's set in console
  });
  try {
    await remoteConfig.fetchAndActivate();
    print("Remote Config fetched and activated successfully.");
  } catch (e) {
    print("Error fetching or activating Remote Config: $e");
  }

  await PrefsHelper.init();
  final authService = AuthService(); 
  await authService.signInAnonymouslyIfNeeded(); // Ensure user (even anonymous) exists

  // --- NEW: Initialize IAPService ---
  final iapService = IAPService();
  // Link AuthService to IAPService so IAPService can trigger AppUser updates
  iapService.setAuthService(authService, (isPremium) {
      // This callback is triggered by IAPService after a successful purchase/restore
      // It signals that AuthService should re-fetch/update its AppUser's premium status
      print("Main: Premium status updated to $isPremium by IAPService. Triggering AppUser refetch.");
      authService.triggerAppUserReFetch();
  });


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<AuthService>.value(value: authService),
        StreamProvider<AppUser?>(
          create: (context) => authService.user,
          initialData: authService.currentUser, 
          catchError: (_, error) {
            print("Error in AppUser stream provider: $error");
            return null;
          },
        ),
        StreamProvider<User?>( // Firebase User Stream
            create: (_) => FirebaseAuth.instance.authStateChanges(),
            initialData: FirebaseAuth.instance.currentUser,
        ),
        Provider<PrayerService>(
          create: (ctx) => PrayerService(),
        ),
        // --- NEW: Provide IAPService ---
        ChangeNotifierProvider<IAPService>.value(value: iapService),
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
      // Define routes if you want to use named navigation for specific screens like PremiumScreen
      // routes: {
      //   PremiumScreen.routeName: (ctx) => const PremiumScreen(),
      //   // ... other routes
      // },
      onGenerateRoute: (settings) {
        // If using named routes and a route is not defined, you can handle it here.
        // For direct MaterialPageRoute navigation, this might not be hit often unless
        // you explicitly use Navigator.pushNamed with an undefined route.
        print('Attempted to navigate to undefined named route: ${settings.name}');
        return MaterialPageRoute(
          builder: (ctx) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(child: Text('The page "${settings.name}" could not be found.')),
          ),
        );
      },
    );
  }
}

