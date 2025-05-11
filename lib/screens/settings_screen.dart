// lib/screens/settings_screen.dart
// Path: lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // For FirebaseAuthException

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

class SettingsScreen extends StatefulWidget {
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

    await PrefsHelper.init();
    await _ttsService.ensureInitialized();

    _fontSizeDelta = PrefsHelper.getReaderFontSizeDelta();
    _selectedFontFamily = PrefsHelper.getReaderFontFamily();
    _selectedReaderTheme = PrefsHelper.getReaderThemeMode();
    _availableAppTtsVoices = _ttsService.getCuratedAppVoices();

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
            : Colors.green,
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
    if (_devTapCount >= 7 && !_devOptionsEnabled) {
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
        // Use WidgetsBinding.instance.addPostFrameCallback
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
        _emailController.clear(); _passwordController.clear();
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      if (mounted) {
        String message = "An error occurred.";
        if (e.code == 'weak-password') message = 'The password provided is too weak.';
        else if (e.code == 'email-already-in-use') message = 'An account already exists for that email. Try signing in, or link your Google account if you signed up with Google using this email.';
        else if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') message = 'Incorrect email or password.';
        else if (e.code == 'network-request-failed') message = 'Network error. Please check your connection.';
        else message = e.message ?? "Authentication failed.";
        _showSnackBar(message, isError: true);
      }
    } catch (e) {
      if (mounted) { _showSnackBar(e.toString(), isError: true); }
    } finally {
      if (mounted) {
        // Use WidgetsBinding.instance.addPostFrameCallback
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
        _emailController.clear(); _passwordController.clear();
      }
    } catch (e) {
      if (mounted) { _showSnackBar("Error signing out: ${e.toString()}", isError: true); }
    } finally {
      if (mounted) {
        // Use WidgetsBinding.instance.addPostFrameCallback
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final appUser = Provider.of<AppUser?>(context);

    Widget accountSectionContent;
    if (appUser != null && !appUser.isAnonymous) {
      accountSectionContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: appUser.photoURL != null && appUser.photoURL!.isNotEmpty
                  ? NetworkImage(appUser.photoURL!)
                  : null,
              child: appUser.photoURL == null || appUser.photoURL!.isEmpty
                  ? Icon(Icons.person_outline, size: 28, color: colorScheme.onPrimaryContainer)
                  : null,
              backgroundColor: colorScheme.primaryContainer,
            ),
            title: Text(appUser.displayName ?? appUser.email ?? "User Account", style: textTheme.titleMedium),
            subtitle: Text(appUser.email ?? "UID: ${appUser.uid}", style: textTheme.bodySmall),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded),
                label: const Text("Sign Out"),
                onPressed: _isAuthActionLoading ? null : () => _handleSignOut(authService),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.error),
                  foregroundColor: colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (_isAuthActionLoading) {
      accountSectionContent = const Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: CircularProgressIndicator(),
      ));
    }
    else {
      accountSectionContent = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.login_rounded),
              label: const Text("Sign in with Google"),
              onPressed: () => _handleGoogleSignIn(authService),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("OR", style: textTheme.bodySmall),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter your email.';
                      if (!value.contains('@') || !value.contains('.')) return 'Please enter a valid email.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outline)),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter your password.';
                      if (value.length < 6) return 'Password must be at least 6 characters.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _handleEmailPasswordAuth(authService),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                    child: Text(_isSignUpMode ? "Create Account" : "Sign In with Email"),
                  ),
                  TextButton(
                    onPressed: () { setState(() { _isSignUpMode = !_isSignUpMode; }); },
                    child: Text(_isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Create one"),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

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
                  child: accountSectionContent,
                ),
                const Divider(indent: 8, endIndent: 8),
                
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: const Icon(Icons.info_outline),
                  title: const Text("App Version"),
                  subtitle: const Text("1.0.0 (WWJD Daily)"),
                  onTap: _onAppVersionTap,
                ),
                const Divider(indent: 8, endIndent: 8),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Text("App Theme", style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
                ListTile( 
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode_outlined : themeProvider.themeMode == ThemeMode.light ? Icons.light_mode_outlined : Icons.brightness_auto_outlined),
                  title: const Text("Appearance"),
                  trailing: DropdownButtonHideUnderline(child: DropdownButton<ThemeMode>(value: themeProvider.themeMode,items: const [DropdownMenuItem(value: ThemeMode.system, child: Text("System Default")), DropdownMenuItem(value: ThemeMode.light, child: Text("Light")), DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark"))], onChanged: (ThemeMode? newValue) {if (newValue != null) {themeProvider.setThemeMode(newValue);}},)),
                ),
                const Divider(indent: 8, endIndent: 8),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Text("Reader Appearance", style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold,)),
                ),
                ListTile( 
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: const Icon(Icons.format_size_rounded),
                  title: const Text("Font Size"),
                  subtitle: Row(children: <Widget>[IconButton(icon: const Icon(Icons.remove_circle_outline_rounded),tooltip: "Decrease font size", onPressed: _fontSizeDelta > -4.0 ? () async {setState(() { _fontSizeDelta -= 1.0; }); await PrefsHelper.setReaderFontSizeDelta(_fontSizeDelta);} : null,), Expanded(child: Text("Aa (${(_baseReaderFontSize + _fontSizeDelta).toStringAsFixed(0)})", textAlign: TextAlign.center, style: textTheme.bodyMedium,)), IconButton(icon: const Icon(Icons.add_circle_outline_rounded), tooltip: "Increase font size", onPressed: _fontSizeDelta < 6.0 ? () async {setState(() { _fontSizeDelta += 1.0; }); await PrefsHelper.setReaderFontSizeDelta(_fontSizeDelta);} : null,),],),
                ),
                ListTile( 
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: const Icon(Icons.font_download_outlined),
                  title: const Text("Font Family"),
                  trailing: DropdownButtonHideUnderline(child: DropdownButton<ReaderFontFamily>(value: _selectedFontFamily, items: ReaderFontFamily.values.map((ReaderFontFamily family) {return DropdownMenuItem<ReaderFontFamily>(value: family, child: Text(family.displayName, style: _getTextStyleForFontFamilyPreview(family, context),),);}).toList(), onChanged: (ReaderFontFamily? newValue) async {if (newValue != null) {setState(() { _selectedFontFamily = newValue; }); await PrefsHelper.setReaderFontFamily(newValue);}},)),
                ),
                ListTile( 
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: const Icon(Icons.color_lens_outlined),
                  title: const Text("Reader Theme"),
                  trailing: DropdownButtonHideUnderline(child: DropdownButton<ReaderThemeMode>(value: _selectedReaderTheme, items: ReaderThemeMode.values.map((ReaderThemeMode themeMode) {return DropdownMenuItem<ReaderThemeMode>(value: themeMode, child: Text(themeMode.displayName),);}).toList(), onChanged: (ReaderThemeMode? newValue) async {if (newValue != null) {setState(() { _selectedReaderTheme = newValue; }); await PrefsHelper.setReaderThemeMode(newValue);}},)),
                ),
                const Divider(indent: 8, endIndent: 8),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Text("Narration Voice (Google Cloud TTS)", style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold,)),
                ),
                ValueListenableBuilder<AppTtsVoice?>( 
                    valueListenable: _ttsService.selectedAppVoiceNotifier,
                    builder: (context, currentSelectedVoice, child) {
                      if (_availableAppTtsVoices.isEmpty && _isLoadingSettings) { return const ListTile( contentPadding: EdgeInsets.symmetric(horizontal: 20.0), leading: Icon(Icons.record_voice_over_outlined), title: Text("Narration Voice"), subtitle: Text("Loading voice options..."),); }
                      if (_availableAppTtsVoices.isEmpty) { return const ListTile( contentPadding: EdgeInsets.symmetric(horizontal: 20.0), leading: Icon(Icons.record_voice_over_outlined), title: Text("Narration Voice"), subtitle: Text("No voices available or API key issue."),); }
                      AppTtsVoice? dropdownValue = currentSelectedVoice;
                      if (currentSelectedVoice != null && !_availableAppTtsVoices.any((v) => v.name == currentSelectedVoice.name)) { dropdownValue = _availableAppTtsVoices.isNotEmpty ? _availableAppTtsVoices.first : null; }
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                        leading: const Icon(Icons.record_voice_over_outlined),
                        title: const Text("Narration Voice"),
                        trailing: DropdownButtonHideUnderline(child: DropdownButton<AppTtsVoice>(value: dropdownValue, hint: const Text("Select Voice"), isExpanded: false, items: _availableAppTtsVoices.map((AppTtsVoice voice) {return DropdownMenuItem<AppTtsVoice>(value: voice, child: Text( voice.displayName, style: textTheme.bodyMedium, overflow: TextOverflow.ellipsis,),);}).toList(), onChanged: (AppTtsVoice? newValue) async {if (newValue != null) {await _ttsService.setAppVoice(newValue, savePreference: true);}},)),
                      );
                    }),
                const Divider(indent: 8, endIndent: 8),
                if (_devOptionsEnabled) ...[ 
                  Padding(padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), child: Text("Developer Options", style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold,))),
                  ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20.0), leading: const Icon(Icons.skip_next_outlined, color: Colors.orange), title: const Text("Force Next Devotional"), subtitle: const Text("Shows the next devotional on Home screen refresh."), onTap: _handleForceNextDevotional,),
                  ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20.0), leading: const Icon(Icons.restart_alt_outlined, color: Colors.redAccent), title: const Text("Reset All Reading Plan Progress"), subtitle: const Text("Resets streaks and all daily reading progress."), onTap: _handleResetAllPlanProgress,),
                  const Divider(indent: 8, endIndent: 8),
                ],
              ],
            ),
    );
  }
}
