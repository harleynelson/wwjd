// lib/main.dart
// Path: lib/main.dart
// Approximate line: 40 (MultiProvider setup)

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
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

// New Prayer Wall Imports
import 'services/prayer_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Removed: await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );

  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  await remoteConfig.setDefaults(const {
    "google_cloud_tts_api_key": "",
  });
  try {
    await remoteConfig.fetchAndActivate();
    print("Remote Config fetched and activated successfully.");
  } catch (e) {
    print("Error fetching or activating Remote Config: $e");
  }

  await PrefsHelper.init();
  final authService = AuthService(); // AuthService is instantiated here
  await authService.signInAnonymouslyIfNeeded();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // CORRECTED: Use ChangeNotifierProvider.value for an already instantiated ChangeNotifier
        ChangeNotifierProvider<AuthService>.value(value: authService),
        StreamProvider<AppUser?>(
          create: (context) => authService.user,
          initialData: authService.currentUser, 
          catchError: (_, error) {
            print("Error in AppUser stream provider: $error");
            return null;
          },
        ),
        StreamProvider<User?>(
            create: (_) => FirebaseAuth.instance.authStateChanges(),
            initialData: FirebaseAuth.instance.currentUser,
        ),
        Provider<PrayerService>(
          create: (ctx) => PrayerService(),
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
      // Removed routes map to stick to MaterialPageRoute navigation
      onGenerateRoute: (settings) {
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
