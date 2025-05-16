// lib/screens/settings_screen.dart
// Path: lib/screens/settings_screen.dart
// Updated to include navigation to MyPrayerRequestsScreen using MaterialPageRoute

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// Assuming your project structure, adjust paths if necessary
import 'package:wwjd_app/helpers/database_helper.dart';
import 'package:wwjd_app/helpers/prefs_helper.dart';
import 'package:wwjd_app/models/reader_settings_enums.dart';
import 'package:wwjd_app/helpers/daily_devotions.dart';
import 'package:wwjd_app/theme/theme_provider.dart';
import 'package:wwjd_app/services/text_to_speech_service.dart';
import 'package:wwjd_app/config/tts_voices.dart';
import 'package:wwjd_app/services/auth_service.dart';
import 'package:wwjd_app/models/app_user.dart';
import 'package:wwjd_app/widgets/account_section.dart';
import 'package:wwjd_app/config/constants.dart';

// Import for "My Submitted Prayers" screen
import 'prayer_wall/my_prayer_requests_screen.dart'; // Ensure this path is correct

class SettingsScreen extends StatefulWidget {
  // static const routeName = '/settings'; // Keep if you use named routes for other parts
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _devOptionsEnabled = false;
  int _devTapCount = 0;

  double _fontSizeDelta = 0.0;
  ReaderFontFamily _selectedFontFamily = ReaderFontFamily.systemDefault;
  ReaderThemeMode _selectedReaderTheme = ReaderThemeMode.light;

  bool _isLoadingSettings = true;
  bool _isAuthActionLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUpMode = false;

  final TextToSpeechService _ttsService = TextToSpeechService();
  List<AppTtsVoice> _availableAppTtsVoices = [];

  static const double _baseReaderFontSize = 18.0;

  bool _devPremiumEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadScreenSettings();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadScreenSettings() async {
    if (!mounted) return;
    setState(() {
      _isLoadingSettings = true;
    });

    // await PrefsHelper.init(); // Already called in main.dart
    await _ttsService.ensureInitialized(); 

    _fontSizeDelta = PrefsHelper.getReaderFontSizeDelta();
    _selectedFontFamily = PrefsHelper.getReaderFontFamily();
    _selectedReaderTheme = PrefsHelper.getReaderThemeMode();
    _availableAppTtsVoices = _ttsService.getCuratedAppVoices();

    _devPremiumEnabled = PrefsHelper.getDevPremiumEnabled();

    if (mounted) {
      setState(() {
        _isLoadingSettings = false;
      });
    }
  }

  TextStyle _getTextStyleForFontFamilyPreview(
      ReaderFontFamily family, BuildContext context) {
    final defaultStyle =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    switch (family) {
      case ReaderFontFamily.serif:
        return GoogleFonts.notoSerif(textStyle: defaultStyle);
      case ReaderFontFamily.sansSerif:
        return GoogleFonts.roboto(textStyle: defaultStyle);
      case ReaderFontFamily.systemDefault:
      default:
        return defaultStyle;
    }
  }

  void _showSnackBar(String message, {bool isError = false, BuildContext? ctx}) {
    final contextToShow = ctx ?? context;
    if (!mounted && ctx == null) return;

    ScaffoldMessenger.of(contextToShow).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(contextToShow).colorScheme.error
            : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Future<void> _handleForceNextDevotional() async {
    await forceNextDevotional(); 
    _showSnackBar("Next devotional will be shown on Home screen refresh.");
  }

  Future<void> _handleResetAllPlanProgress() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reset All Plan Progress?"),
        content: const Text(
            "This will reset ALL progress (streaks, completed days, current day) for ALL reading plans. This action cannot be undone."),
        actions: [
          TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(ctx).pop(false)),
          TextButton(
            child: Text("Reset All Progress",
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _dbHelper.resetAllStreaksAndProgress();
        _showSnackBar("All reading plan progress and streaks have been reset.");
      } catch (e) {
        _showSnackBar("Error resetting plan progress: ${e.toString()}",
            isError: true);
      }
    }
  }

  void _onAppVersionTap() {
    _devTapCount++;
    if (_devTapCount >= 7 && !_devOptionsEnabled) { // Standard 7 taps
      if (mounted) {
        setState(() { _devOptionsEnabled = true; });
        _showSnackBar("Developer Options Enabled!");
      }
    } else if (_devOptionsEnabled && _devTapCount >= 10) { 
      if (mounted) {
        setState(() { _devOptionsEnabled = false; });
        _showSnackBar("Developer Options Disabled.");
        _devTapCount = 0; 
      }
    }
  }
  
  Future<void> _handleGoogleSignIn(AuthService authService) async {
    if (!mounted) return;
    setState(() { _isAuthActionLoading = true; });
    AppUser? userFromAuthService;
    try {
      userFromAuthService = await authService.signInWithGoogle();
      if (mounted && (userFromAuthService != null && !userFromAuthService.isAnonymous)) {
        _showSnackBar("Successfully signed in as ${userFromAuthService.displayName ?? userFromAuthService.email ?? 'User'}.");
        _emailController.clear(); _passwordController.clear();
      } else if (mounted && userFromAuthService == null) {
        print("SettingsScreen: Google Sign-In returned null (likely cancelled or handled error in service).");
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      if (mounted) {
        if (e.code == 'link-google-to-email-erforderlich' && e.email != null) {
          final String? password = await _promptForPassword(e.email!);
          if (password != null && password.isNotEmpty && mounted) {
            setState(() { _isAuthActionLoading = true; });
            try {
              final GoogleSignInAccount? googleUserAgain = await GoogleSignIn().signInSilently() ?? await GoogleSignIn().signIn();
              if (googleUserAgain != null) {
                  final GoogleSignInAuthentication googleAuthAgain = await googleUserAgain.authentication;
                  if (googleAuthAgain.idToken != null) {
                      final fb_auth.AuthCredential credentialToLink = fb_auth.GoogleAuthProvider.credential(
                          accessToken: googleAuthAgain.accessToken,
                          idToken: googleAuthAgain.idToken,
                      );
                      userFromAuthService = await authService.reauthenticateAndLinkCredential(e.email!, password, credentialToLink);
                      if (userFromAuthService != null && !userFromAuthService.isAnonymous && mounted) {
                          _showSnackBar("Google account successfully linked to ${userFromAuthService.email}.", ctx: context);
                      }
                  } else {
                      _showSnackBar("Could not re-obtain Google token for linking.", isError: true, ctx: context);
                  }
              } else {
                  _showSnackBar("Google account linking cancelled.", isError: false, ctx: context);
              }
            } catch (linkError) { 
                _showSnackBar("Failed to link Google account: ${linkError.toString()}", isError: true, ctx: context);
            }
          } else if (password != null && mounted) { 
            _showSnackBar("Google account linking cancelled.", isError: false, ctx: context);
          }
        } else {
          String errorMessage = "Google Sign-In Error: ${e.message ?? e.code}";
          if (e.code == 'network-request-failed') {
            errorMessage = "Network error. Please check your internet connection.";
          } else if (e.code == 'credential-already-in-use' || e.code == 'account-exists-with-different-credential'){
              errorMessage = "This Google account is already linked to another user or a different sign-in method. Try signing in with that method or use a different Google Account.";
          }
          _showSnackBar(errorMessage, isError: true);
        }
      }
    } catch (e) { 
      if (mounted) {
        _showSnackBar(e.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() { _isAuthActionLoading = false; });
          }
        });
      }
    }
  }

  Future<String?> _promptForPassword(String email) async {
    final passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Link Google to Existing Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('To link your Google account with your existing account for $email, please enter your password.'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                autofocus: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(null); 
              },
            ),
            TextButton(
              child: const Text('Link Account'),
              onPressed: () {
                Navigator.of(dialogContext).pop(passwordController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleEmailPasswordAuth(AuthService authService) async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;
    setState(() { _isAuthActionLoading = true; });
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    AppUser? user;
    try {
      if (_isSignUpMode) {
        user = await authService.signUpWithEmailPassword(email, password);
        if (user != null && mounted) {
          _showSnackBar("Account created and signed in as ${user.email}.");
        }
      } else {
        user = await authService.signInWithEmailPassword(email, password);
        if (user != null && mounted) {
          _showSnackBar("Successfully signed in as ${user.email}.");
        }
      }
      if (user != null && mounted) {
        _emailController.clear();
        _passwordController.clear();
        if (_isSignUpMode) {
          setState(() { _isSignUpMode = false; });
        }
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      if (mounted) {
        String message = "An error occurred.";
        if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          message = 'An account already exists for that email. Try signing in, or link your Google account if you signed up with Google using this email.';
        } else if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          message = 'Incorrect email or password.';
        } else if (e.code == 'network-request-failed') {
          message = 'Network error. Please check your connection.';
        } else {
          message = e.message ?? "Authentication failed.";
        }
        _showSnackBar(message, isError: true);
      }
    } catch (e) {
      if (mounted) { _showSnackBar(e.toString(), isError: true); }
    } finally {
      if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
                setState(() { _isAuthActionLoading = false; });
            }
          });
      }
    }
  }

  Future<void> _handleSignOut(AuthService authService) async {
    if (!mounted) return;
    setState(() { _isAuthActionLoading = true; });
    try {
      await authService.signOut();
      if (mounted) {
        _showSnackBar("Successfully signed out.");
        _emailController.clear(); 
        _passwordController.clear();
      }
    } catch (e) {
      if (mounted) { _showSnackBar("Error signing out: ${e.toString()}", isError: true); }
    } finally {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
                setState(() { _isAuthActionLoading = false; });
            }
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context); // listen: true for theme changes
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final appUser = Provider.of<AppUser?>(context); 

    Widget appVersionTile = ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      leading: const Icon(Icons.info_outline),
      title: const Text("App Version"),
      subtitle: const Text(appVersion), 
      onTap: _onAppVersionTap,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: _isLoadingSettings
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                  child: Text("Account", style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  elevation: 1,
                  child: AccountSection(
                    key: ValueKey('${appUser?.uid}_${appUser?.isAnonymous.toString()}'), 
                    appUser: appUser,
                    isAuthActionLoading: _isAuthActionLoading,
                    onSignOut: () => _handleSignOut(authService),
                    onSignInWithGoogle: () => _handleGoogleSignIn(authService),
                    onSignInWithEmail: () => _handleEmailPasswordAuth(authService),
                    onToggleSignUpMode: () {
                      if (mounted) { 
                        setState(() { _isSignUpMode = !_isSignUpMode; });
                      }
                    },
                    isSignUpMode: _isSignUpMode,
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),
                ),
                const Divider(indent: 8, endIndent: 8),
                
                // --- Community Prayers Section ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Text("Community Prayers", style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: Icon(Icons.playlist_add_check_circle_outlined, color: colorScheme.secondary),
                  title: const Text('My Submitted Prayers'),
                  subtitle: const Text('View prayers you submitted anonymously'),
                  trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                  onTap: () {
                    // Navigate to MyPrayerRequestsScreen using MaterialPageRoute
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyPrayerRequestsScreen()),
                    );
                  },
                ),
                const Divider(indent: 8, endIndent: 8),
                // --- End of Community Prayers Section ---

                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Text("App Theme", style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: Icon(
                    themeProvider.themeMode == ThemeMode.light ? Icons.light_mode_outlined
                        : themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode_outlined
                        : (MediaQuery.platformBrightnessOf(context) == Brightness.dark ? Icons.brightness_auto_outlined
                            : Icons.brightness_auto_outlined),
                    color: colorScheme.primary,
                  ),
                  title: const Text("Mood"),
                  trailing: SegmentedButton<ThemeMode>(
                    segments: const <ButtonSegment<ThemeMode>>[
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        tooltip: "Light Theme",
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        tooltip: "Dark Theme",
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        icon: Icon(Icons.phone_iphone), 
                        tooltip: "System Default",
                      ),
                    ],
                    selected: <ThemeMode>{themeProvider.themeMode},
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      if (newSelection.isNotEmpty) {
                        themeProvider.setThemeMode(newSelection.first);
                      }
                    },
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.comfortable,
                    ),
                    showSelectedIcon: false, 
                  ),
                ),
                const Divider(indent: 8, endIndent: 8),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Text("Reader Appearance", style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold,)),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  title: Row(
                    children: <Widget>[
                      const Icon(Icons.format_size_rounded),
                      const SizedBox(width: 16), 
                      Expanded(
                        child: Text("Font Size", style: textTheme.titleMedium),
                      ), 
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        tooltip: "Decrease font size",
                        onPressed: _fontSizeDelta > -4.0 ? () async { if (mounted) setState(() { _fontSizeDelta -= 1.0; }); await PrefsHelper.setReaderFontSizeDelta(_fontSizeDelta);} : null,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0), 
                        constraints: const BoxConstraints(),
                      ),
                      Container(
                        width: 50, 
                        alignment: Alignment.center,
                        child: Text(
                          "Aa (${(_baseReaderFontSize + _fontSizeDelta).toStringAsFixed(0)})",
                          style: textTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        tooltip: "Increase font size",
                        onPressed: _fontSizeDelta < 6.0 ? () async { if (mounted) setState(() { _fontSizeDelta += 1.0; }); await PrefsHelper.setReaderFontSizeDelta(_fontSizeDelta);} : null,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0), 
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                ListTile( 
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: const Icon(Icons.font_download_outlined),
                  title: const Text("Font Type"),
                  trailing: DropdownButtonHideUnderline(child: DropdownButton<ReaderFontFamily>(value: _selectedFontFamily, items: ReaderFontFamily.values.map((ReaderFontFamily family) {return DropdownMenuItem<ReaderFontFamily>(value: family, child: Text(family.displayName, style: _getTextStyleForFontFamilyPreview(family, context),),);}).toList(), onChanged: (ReaderFontFamily? newValue) async {if (newValue != null) { if (mounted) setState(() { _selectedFontFamily = newValue; }); await PrefsHelper.setReaderFontFamily(newValue);}},)),
                ),
                ListTile( 
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: const Icon(Icons.color_lens_outlined),
                  title: const Text("Reading Background"),
                  trailing: DropdownButtonHideUnderline(child: DropdownButton<ReaderThemeMode>(value: _selectedReaderTheme, items: ReaderThemeMode.values.map((ReaderThemeMode themeMode) {return DropdownMenuItem<ReaderThemeMode>(value: themeMode, child: Text(themeMode.displayName),);}).toList(), onChanged: (ReaderThemeMode? newValue) async {if (newValue != null) { if (mounted) setState(() { _selectedReaderTheme = newValue; }); await PrefsHelper.setReaderThemeMode(newValue);}},)),
                ),
                const Divider(indent: 8, endIndent: 8),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Text("Narration Voice", style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold,)),
                ),
                ValueListenableBuilder<AppTtsVoice?>( 
                    valueListenable: _ttsService.selectedAppVoiceNotifier,
                    builder: (context, currentSelectedVoice, child) {
                      if (_availableAppTtsVoices.isEmpty && _isLoadingSettings) { return const ListTile( contentPadding: EdgeInsets.symmetric(horizontal: 20.0), leading: Icon(Icons.record_voice_over_outlined), title: Text("Narration Voice"), subtitle: Text("Loading voice options..."),); }
                      if (_availableAppTtsVoices.isEmpty) { return const ListTile( contentPadding: EdgeInsets.symmetric(horizontal: 20.0), leading: Icon(Icons.record_voice_over_outlined), title: Text("Narration Voice"), subtitle: Text("No voices available or API key issue."),); }
                      
                      AppTtsVoice? dropdownValue = currentSelectedVoice;
                      if (dropdownValue == null || !_availableAppTtsVoices.any((v) => v.name == dropdownValue?.name)) {
                          String? preferredName = PrefsHelper.getSelectedVoiceName();
                          dropdownValue = _availableAppTtsVoices.firstWhere(
                              (v) => v.name == preferredName, 
                              orElse: () => _availableAppTtsVoices.first 
                          );
                      }

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                        leading: const Icon(Icons.record_voice_over_outlined),
                        title: const Text("Selected Voice"), 
                        trailing: Container( 
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55), 
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<AppTtsVoice>(
                              value: dropdownValue, 
                              hint: const Text("Select", overflow: TextOverflow.ellipsis), 
                              isExpanded: true, 
                              items: _availableAppTtsVoices.map((AppTtsVoice voice) {
                                return DropdownMenuItem<AppTtsVoice>(
                                  value: voice,
                                  child: Text( 
                                    voice.displayName, 
                                    style: textTheme.bodyMedium, 
                                    overflow: TextOverflow.ellipsis, 
                                  ),
                                );
                              }).toList(),
                              onChanged: (AppTtsVoice? newValue) async {
                                if (newValue != null) {
                                  await _ttsService.setAppVoice(newValue, savePreference: true);
                                }
                              },
                            )
                          ),
                        ),
                      );
                    }
                ),
                const Divider(indent: 8, endIndent: 8),

                appVersionTile,
                const Divider(indent: 8, endIndent: 8),

                if (_devOptionsEnabled) ...[ 
                  Padding(padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), child: Text("Developer Options", style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold,))),
                  ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20.0), leading: const Icon(Icons.skip_next_outlined, color: Colors.orange), title: const Text("Force Next Devotional"), subtitle: const Text("Shows the next devotional on Home screen refresh."), onTap: _handleForceNextDevotional,),
                  ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20.0), leading: const Icon(Icons.restart_alt_outlined, color: Colors.redAccent), title: const Text("Reset All Reading Plan Progress"), subtitle: const Text("Resets streaks and all daily reading progress."), onTap: _handleResetAllPlanProgress,),
                  
                  SwitchListTile(
                    title: const Text("Developer: Premium Enabled"),
                    subtitle: const Text("Simulates premium access for testing."),
                    value: _devPremiumEnabled,
                    onChanged: (bool newValue) async {
                      setState(() {
                        _devPremiumEnabled = newValue;
                      });
                      await PrefsHelper.setDevPremiumEnabled(newValue);
                      _showSnackBar(
                        "Dev Premium ${newValue ? 'Enabled' : 'Disabled'}. Restart or re-navigate to see full effect.",
                      );
                       final authService = Provider.of<AuthService>(context, listen: false);
                       authService.triggerAppUserReFetch(); 
                    },
                    secondary: Icon(
                        _devPremiumEnabled ? Icons.workspace_premium_rounded : Icons.workspace_premium_outlined,
                        color: _devPremiumEnabled ? Colors.amber.shade700 : null,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  ),
                  const Divider(indent: 8, endIndent: 8),
                ],
              ],
            ),
    );
  }
}
