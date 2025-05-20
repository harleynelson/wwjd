// File: lib/screens/home_screen.dart
// Path: lib/screens/home_screen.dart
// Approximate line: 15 (add import), 175 & 195 (add callbacks)

import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:wwjd_app/widgets/verse_of_the_day_card.dart';
import 'package:wwjd_app/widgets/devotional_of_the_day_card.dart';
import '../helpers/daily_devotions.dart';
import '../helpers/database_helper.dart';
import '../models/models.dart';
import '../helpers/book_names.dart';
import '../helpers/prefs_helper.dart';
import '../dialogs/flag_selection_dialog.dart';
import '../models/user_prayer_profile_model.dart';
import '../theme/theme_provider.dart';
import '../models/reader_settings_enums.dart';
import '../services/prayer_service.dart';
import '../screens/verse_image_generator_screen.dart'; // <<< NEW IMPORT

// Screen imports
import 'full_bible_reader_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'search_screen.dart';
import 'reading_plans/reading_plans_list_screen.dart';
import 'prayer_wall/prayer_wall_screen.dart';

import '../widgets/home/reading_streak_card.dart';
import '../widgets/home/prayer_wall_promo_card.dart';
import '../widgets/home/home_navigation_button.dart';


class VotDDataBundle {
  final Map<String, dynamic>? verseData;
  final bool isFavorite;
  final List<int> assignedFlagIds;

  VotDDataBundle({
    this.verseData,
    this.isFavorite = false,
    this.assignedFlagIds = const [],
  });

  VotDDataBundle copyWith({
    Map<String, dynamic>? verseData,
    bool? isFavorite,
    List<int>? assignedFlagIds,
  }) {
    return VotDDataBundle(
      verseData: verseData ?? this.verseData,
      isFavorite: isFavorite ?? this.isFavorite,
      assignedFlagIds: assignedFlagIds ?? this.assignedFlagIds,
    );
  }
}


class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late Future<Devotional?> _devotionalFuture = Future.value(null);
  late Future<VotDDataBundle> _votdFuture = Future.value(VotDDataBundle(verseData: null));
  late Future<int> _readingStreakFuture = Future.value(0);
  late Future<UserPrayerProfile?> _prayerStreakProfileFuture = Future.value(null);

  List<Flag> _allAvailableFlags = [];
  VotDDataBundle? _currentVotDDataBundle;

  double _fontSizeDelta = 0.0;
  ReaderFontFamily _selectedFontFamily = ReaderFontFamily.systemDefault;
  StreamSubscription? _userAuthSubscription;

  @override
  void initState() {
    super.initState();
    _loadReaderPreferencesAndAllData();

    _userAuthSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        // No need to call setState here if _assignFutures itself calls setState
        // or if the FutureBuilders will naturally rebuild.
        // However, if you want to ensure an immediate rebuild when auth changes,
        // you might wrap _assignFutures in setState or call setState after it.
        _assignFutures(); 
      }
    });
  }

  @override
  void dispose() {
    _userAuthSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadReaderPreferencesAndAllData() async {
    if (!mounted) return;
    await _loadReaderPreferences();
    if (!mounted) return;
    await _loadAvailableFlags();
    if (!mounted) return;

    _assignFutures(); // This will set the futures

    // No need to call setState here if _assignFutures triggers rebuilds
    // or if FutureBuilders handle it.
  }

  Future<void> _loadReaderPreferences() async {
    _fontSizeDelta = PrefsHelper.getReaderFontSizeDelta();
    _selectedFontFamily = PrefsHelper.getReaderFontFamily();
  }

  void _assignFutures() {
    // Use setState to ensure FutureBuilders pick up the new Future instances
    // This is crucial if you want the UI to show loading indicators again.
    if (mounted) {
      setState(() {
        _devotionalFuture = _fetchDevotionalOfTheDay();
        if (_currentVotDDataBundle == null || _currentVotDDataBundle!.verseData == null) {
          _votdFuture = _fetchNewRandomVotDBundle();
        } else {
          _votdFuture = _refreshFavoriteStatusForCurrentVotD();
        }
        _readingStreakFuture = _fetchCurrentReadingStreak();
        _prayerStreakProfileFuture = _fetchCurrentPrayerActivityStreak();
      });
    }
  }

  Future<void> _loadAvailableFlags() async {
     if (!mounted) return;
     try {
        final Set<int> hiddenIds = PrefsHelper.getHiddenFlagIds();
        final List<Flag> visiblePrebuiltFlags = prebuiltFlags.where((f) => !hiddenIds.contains(f.id)).toList();
        final userFlagMaps = await _dbHelper.getUserFlags();
        final userFlags = userFlagMaps.map((map) => Flag.fromUserDbMap(map)).toList();
        if (!mounted) return; // Check again before setState
        setState(() {
           _allAvailableFlags = [...visiblePrebuiltFlags, ...userFlags]..sort((a, b) => a.name.compareTo(b.name));
        });
     } catch (e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading flags: ${e.toString()}")));
     }
  }

  Future<Devotional?> _fetchDevotionalOfTheDay() async {
    return await getDevotionalOfTheDay();
  }

  Future<VotDDataBundle> _fetchNewRandomVotDBundle() async {
     try {
      final verseData = await _dbHelper.getVerseOfTheDay();
      if (verseData != null && verseData[DatabaseHelper.bibleColVerseID] != null) {
        String currentVotDVerseID = verseData[DatabaseHelper.bibleColVerseID];
        bool isFavorite = await _dbHelper.isFavorite(currentVotDVerseID);
        List<int> assignedFlagIds = [];
        if (isFavorite) { assignedFlagIds = await _dbHelper.getFlagIdsForFavorite(currentVotDVerseID); }
        _currentVotDDataBundle = VotDDataBundle( verseData: verseData, isFavorite: isFavorite, assignedFlagIds: assignedFlagIds );
        return _currentVotDDataBundle!;
      }
    } catch (e) { print("Error fetching new random VotD bundle: $e"); }
    _currentVotDDataBundle = VotDDataBundle(verseData: null);
    return _currentVotDDataBundle!;
  }

  Future<VotDDataBundle> _refreshFavoriteStatusForCurrentVotD() async {
    if (_currentVotDDataBundle == null || _currentVotDDataBundle!.verseData == null) { return _fetchNewRandomVotDBundle(); }
    final String verseID = _currentVotDDataBundle!.verseData![DatabaseHelper.bibleColVerseID];
    try {
      bool isFavorite = await _dbHelper.isFavorite(verseID);
      List<int> assignedFlagIds = [];
      if (isFavorite) { assignedFlagIds = await _dbHelper.getFlagIdsForFavorite(verseID); }
      _currentVotDDataBundle = _currentVotDDataBundle!.copyWith( isFavorite: isFavorite, assignedFlagIds: assignedFlagIds,);
      return _currentVotDDataBundle!;
    } catch (e) { print("Error refreshing favorite status for VotD $verseID: $e"); return _currentVotDDataBundle!; }
  }

  Future<int> _fetchCurrentReadingStreak() async {
    try {
      List<UserReadingProgress> activeProgresses = await _dbHelper.getActiveReadingPlanProgresses();
      int maxStreak = 0;
      for (var progress in activeProgresses) {
        bool isValid = true;
        if (progress.lastCompletionDate != null) {
          DateTime today = DateTime.now();
          DateTime todayDate = DateTime(today.year, today.month, today.day);
          DateTime lastCompletedDate = DateTime(progress.lastCompletionDate!.year, progress.lastCompletionDate!.month, progress.lastCompletionDate!.day);
          if (todayDate.difference(lastCompletedDate).inDays > 1) {
            isValid = false;
          }
        } else if (progress.streakCount > 0) {
          isValid = false;
        }
        if (isValid && progress.streakCount > maxStreak) {
          maxStreak = progress.streakCount;
        }
      }
      return maxStreak;
    } catch (e) {
      print("Error fetching current reading streak: $e");
      return 0;
    }
  }

  Future<UserPrayerProfile?> _fetchCurrentPrayerActivityStreak() async {
    final currentUser = Provider.of<User?>(context, listen: false);
    if (currentUser == null) return null;

    final prayerService = Provider.of<PrayerService>(context, listen: false);
    try {
      return await prayerService.getUserPrayerProfile(currentUser.uid);
    } catch (e) {
      print("Error fetching prayer streak profile on HomeScreen: $e");
      return null;
    }
  }

  Future<void> _refreshAllData() async {
    if (!mounted) return;
    await _loadReaderPreferences();
    if (!mounted) return;
    await _loadAvailableFlags();
    if (!mounted) return;

    setState(() {
      _currentVotDDataBundle = null; 
      _assignFutures();
    });
  }

  Future<void> _toggleVotDFavorite(VotDDataBundle bundleToToggle) async {
    if (bundleToToggle.verseData == null || bundleToToggle.verseData![DatabaseHelper.bibleColVerseID] == null) { return; }
    String verseID = bundleToToggle.verseData![DatabaseHelper.bibleColVerseID];
    Map<String, dynamic> verseDataMap = Map<String, dynamic>.from(bundleToToggle.verseData!);
    bool newFavoriteState = !bundleToToggle.isFavorite;
    try {
      if (newFavoriteState) { await _dbHelper.addFavorite(verseDataMap); } else { await _dbHelper.removeFavorite(verseID); }
      if (mounted) { setState(() { _votdFuture = _refreshFavoriteStatusForCurrentVotD(); }); }
    } catch (e) { if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating favorite: ${e.toString()}"))); }
  }

  void _openFlagManagerForVotD(VotDDataBundle bundleForFlags) {
      if (bundleForFlags.verseData == null || bundleForFlags.verseData![DatabaseHelper.bibleColVerseID] == null || !bundleForFlags.isFavorite) return;
      final String verseID = bundleForFlags.verseData![DatabaseHelper.bibleColVerseID];
      String ref = "${getFullBookName(bundleForFlags.verseData![DatabaseHelper.bibleColBook] ?? "??")} ${bundleForFlags.verseData![DatabaseHelper.bibleColChapter]?.toString() ?? "?"}:${bundleForFlags.verseData![DatabaseHelper.bibleColStartVerse]?.toString() ?? "?"}";
      showDialog( context: context, builder: (_) => FlagSelectionDialog( verseRef: ref, initialSelectedFlagIds: bundleForFlags.assignedFlagIds, allAvailableFlags: _allAvailableFlags,
            onHideFlag: (flagId) async { await PrefsHelper.hideFlagId(flagId); await _loadAvailableFlags();  if (mounted) { setState((){  _votdFuture = _refreshFavoriteStatusForCurrentVotD();  }); } },
            onDeleteFlag: (flagId) async { await _dbHelper.deleteUserFlag(flagId); await _loadAvailableFlags(); if (mounted) {  setState((){ _votdFuture = _refreshFavoriteStatusForCurrentVotD(); }); } },
            onAddNewFlag: (String newName) async { int newId = await _dbHelper.addUserFlag(newName); await _loadAvailableFlags();  Flag? foundFlag; try { foundFlag = _allAvailableFlags.firstWhere((f) => f.id == newId); } catch (e) { print("Error finding newly added flag with ID $newId in _openFlagManagerForVotD: $e"); foundFlag = null; } return foundFlag; },
            onSave: (finalSelectedIds) async { Set<int> initSet = bundleForFlags.assignedFlagIds.toSet(); Set<int> finalSet = finalSelectedIds.toSet(); for (int id in finalSet.difference(initSet)) { await _dbHelper.assignFlagToFavorite(verseID, id); } for (int id in initSet.difference(finalSet)) { await _dbHelper.removeFlagFromFavorite(verseID, id); } if (mounted) { setState((){ _votdFuture = _refreshFavoriteStatusForCurrentVotD(); }); } },
        ),).then((_) { if (mounted) { _loadAvailableFlags();  } });
  }
  
  // --- NEW: Navigate to Image Generator for Verse of the Day ---
  void _shareVotDAsImage(VotDDataBundle? bundle) {
    if (bundle?.verseData == null) return;
    final verseData = bundle!.verseData!;
    final String verseText = verseData[DatabaseHelper.bibleColVerseText] ?? "No text";
    final String bookAbbr = verseData[DatabaseHelper.bibleColBook] ?? "";
    final String chapter = verseData[DatabaseHelper.bibleColChapter]?.toString() ?? "";
    final String verseNum = verseData[DatabaseHelper.bibleColStartVerse]?.toString() ?? "";
    final String fullBookName = getFullBookName(bookAbbr);
    final String reference = "$fullBookName $chapter:$verseNum";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerseImageGeneratorScreen(
          initialVerseText: verseText,
          initialVerseReference: reference,
          initialBookAbbr: bookAbbr,
          initialChapter: chapter,
          initialVerseNum: verseNum,
        ),
      ),
    );
  }

  // --- NEW: Navigate to Image Generator for Devotional Scripture ---
  void _shareDevotionalScriptureAsImage(Devotional? devotional) {
    if (devotional == null || devotional.scriptureFocus.isEmpty) return;
    
    // Attempt to parse book, chapter, verse from scriptureReference
    // This is a simple parser, might need to be more robust
    String bookAbbr = "";
    String chapter = "";
    String verseNum = "";

    // Example: "John 3:16 NIV" or "Psalm 23"
    String ref = devotional.scriptureReference.trim();
    // Remove version if present
    final versions = ["NIV", "ESV", "KJV", "NKJV", "NLT", "MSG"];
    for (var v in versions) {
      if (ref.toUpperCase().endsWith(" $v")) {
        ref = ref.substring(0, ref.length - (v.length + 1)).trim();
        break;
      }
    }
    
    final parts = ref.split(' ');
    if (parts.isNotEmpty) {
      String potentialBookName = "";
      int chapterVerseSplitIndex = -1;

      for(int i=0; i<parts.length; ++i) {
        if (RegExp(r'^\d+:\d+$').hasMatch(parts[i]) || RegExp(r'^\d+$').hasMatch(parts[i])) { // Chapter:Verse or just Chapter
            chapterVerseSplitIndex = i;
            break;
        }
        potentialBookName += (potentialBookName.isEmpty ? "" : " ") + parts[i];
      }
      
      bookAbbr = bookNameToAbbr(potentialBookName); // You'll need a reverse lookup or smarter parsing

      if(chapterVerseSplitIndex != -1 && chapterVerseSplitIndex < parts.length) {
          final chapterVersePart = parts[chapterVerseSplitIndex];
          final cvParts = chapterVersePart.split(':');
          chapter = cvParts[0];
          if (cvParts.length > 1) {
              verseNum = cvParts[1].split('-')[0]; // Take first verse if it's a range
          }
      }
    }


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerseImageGeneratorScreen(
          initialVerseText: devotional.scriptureFocus,
          initialVerseReference: devotional.scriptureReference, // Pass the original full reference
          initialBookAbbr: bookAbbr.isNotEmpty ? bookAbbr : null, // Pass parsed if available
          initialChapter: chapter.isNotEmpty ? chapter : null,
          initialVerseNum: verseNum.isNotEmpty ? verseNum : null,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final Brightness currentBrightness = Theme.of(context).brightness;

    final Gradient lightGradient = LinearGradient( colors: [ Colors.deepPurple.shade100.withOpacity(0.6), Colors.purple.shade50.withOpacity(0.8), Colors.white, ], begin: Alignment.topLeft, end: Alignment.bottomRight, stops: const [0.0, 0.3, 1.0],);
    final Gradient darkGradient = LinearGradient( colors: [ Colors.grey.shade800, Colors.grey.shade900, Colors.black ],  begin: Alignment.topLeft, end: Alignment.bottomRight, stops: const [0.0, 0.4, 1.0],);

    return Scaffold(
      appBar: AppBar( title: const Text('Wake up with Jesus'), centerTitle: true,
        actions: [
          IconButton( icon: Icon( themeProvider.themeMode == ThemeMode.dark || (themeProvider.themeMode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark) ? Icons.light_mode_outlined  : Icons.dark_mode_outlined,    ), tooltip: "Toggle Theme",
            onPressed: () {
                ThemeMode currentEffectiveMode = themeProvider.themeMode;
                if (currentEffectiveMode == ThemeMode.system) { currentEffectiveMode = (MediaQuery.platformBrightnessOf(context) == Brightness.dark) ? ThemeMode.dark : ThemeMode.light; }
                if (currentEffectiveMode == ThemeMode.dark) { themeProvider.setThemeMode(ThemeMode.light); } else { themeProvider.setThemeMode(ThemeMode.dark); }
            },),
          IconButton( icon: const Icon(Icons.settings_outlined), tooltip: "Settings", onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())).then((_) => _refreshAllData());},),],),
      body: Container(
        decoration: BoxDecoration( gradient: currentBrightness == Brightness.dark ? darkGradient : lightGradient,),
        child: RefreshIndicator( onRefresh: _refreshAllData,
          child: ListView( padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              ReadingStreakCard(
                readingStreakFuture: _readingStreakFuture,
                onTap: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ReadingPlansListScreen()))
                      .then((_) => _refreshAllData());
                },
              ),
              PrayerWallPromoCard(
                prayerStreakProfileFuture: _prayerStreakProfileFuture,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PrayerWallScreen()),
                  ).then((_) => _refreshAllData());
                },
              ),
              const SizedBox(height: 16.0),
              FutureBuilder<Devotional?>( future: _devotionalFuture,  builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData && !snapshot.hasError) { return DevotionalOfTheDayCard( devotional: Devotional(title: "", coreMessage: "", scriptureFocus: "", scriptureReference: "", reflection: "", prayerDeclaration: ""), isLoading: true, fontSizeDelta: _fontSizeDelta,  readerFontFamily: _selectedFontFamily, ); }
                  if (snapshot.hasError) { print("Error in _devotionalFuture FutureBuilder: ${snapshot.error}"); return DevotionalOfTheDayCard( devotional: Devotional(title: "Error", coreMessage: "Could not load devotional.", scriptureFocus: "", scriptureReference: "", reflection: "Please try again later.", prayerDeclaration: ""), isLoading: false, fontSizeDelta: _fontSizeDelta,  readerFontFamily: _selectedFontFamily, );}
                  final devotionalData = snapshot.data;  if (devotionalData == null && snapshot.connectionState != ConnectionState.waiting) { return DevotionalOfTheDayCard(  devotional: Devotional(title: "Not Available", coreMessage: "Today's devotional is not available.", scriptureFocus: "", scriptureReference: "", reflection: "", prayerDeclaration: ""), isLoading: false, fontSizeDelta: _fontSizeDelta,  readerFontFamily: _selectedFontFamily, ); }
                  return DevotionalOfTheDayCard( devotional: devotionalData ?? Devotional(title: "", coreMessage: "Loading...", scriptureFocus: "", scriptureReference: "", reflection: "", prayerDeclaration: ""),  isLoading: snapshot.connectionState == ConnectionState.waiting,  enableCardAnimations: true, speckCount: 15, fontSizeDelta: _fontSizeDelta,  readerFontFamily: _selectedFontFamily, onShareScriptureAsImage: () => _shareDevotionalScriptureAsImage(devotionalData), ); // <<< ADDED CALLBACK
              },),
              const SizedBox(height: 20.0),
              FutureBuilder<VotDDataBundle>( future: _votdFuture,  builder: (context, snapshot) {
                  VotDDataBundle? bundleForDisplay; bool showAsLoading = snapshot.connectionState == ConnectionState.waiting &&  (!snapshot.hasData || snapshot.data?.verseData == null) &&  (_currentVotDDataBundle == null || _currentVotDDataBundle!.verseData == null);
                  if (snapshot.hasData && snapshot.data!.verseData != null) { _currentVotDDataBundle = snapshot.data!;  bundleForDisplay = _currentVotDDataBundle; } else if (_currentVotDDataBundle != null && _currentVotDDataBundle!.verseData != null) { bundleForDisplay = _currentVotDDataBundle; } else if (snapshot.hasError) { print("Error in _votdFuture FutureBuilder: ${snapshot.error}"); return VerseOfTheDayCard(isLoading: false, verseText: "Could not load verse.", verseRef: "Error", isFavorite: false, assignedFlagNames: const [], enableCardAnimations: false, fontSizeDelta: _fontSizeDelta, readerFontFamily: _selectedFontFamily); } else if (snapshot.connectionState != ConnectionState.waiting && (snapshot.data == null || snapshot.data!.verseData == null)) { return VerseOfTheDayCard(isLoading: false, verseText: "Verse not available.", verseRef: "", isFavorite: false, assignedFlagNames: const [], enableCardAnimations: false, fontSizeDelta: _fontSizeDelta, readerFontFamily: _selectedFontFamily); }
                  if (bundleForDisplay == null || bundleForDisplay.verseData == null) { return VerseOfTheDayCard(isLoading: true, verseText: "Loading...", verseRef: "", isFavorite: false, assignedFlagNames: const [], enableCardAnimations: true, speckCount: 10, fontSizeDelta: _fontSizeDelta, readerFontFamily: _selectedFontFamily); }
                  final VotDDataBundle currentBundle = bundleForDisplay; String votdText = currentBundle.verseData![DatabaseHelper.bibleColVerseText] ?? "Error: Text missing."; String bookAbbr = currentBundle.verseData![DatabaseHelper.bibleColBook] ?? "??"; String chapterStr = currentBundle.verseData![DatabaseHelper.bibleColChapter]?.toString() ?? "?"; String verseNum = currentBundle.verseData![DatabaseHelper.bibleColStartVerse]?.toString() ?? "?"; String votdRef = "${getFullBookName(bookAbbr)} $chapterStr:$verseNum"; List<String> flagNamesForVotD = []; if (currentBundle.isFavorite && currentBundle.assignedFlagIds.isNotEmpty) { flagNamesForVotD = currentBundle.assignedFlagIds.map((id) { final flag = _allAvailableFlags.firstWhere((f) => f.id == id, orElse: () => Flag(id: 0, name: "Unknown")); return flag.name; }).where((name) => name != "Unknown").toList(); flagNamesForVotD.sort(); }
                  return VerseOfTheDayCard( isLoading: showAsLoading,  verseText: votdText, verseRef: votdRef, isFavorite: currentBundle.isFavorite, assignedFlagNames: flagNamesForVotD, onToggleFavorite: () => _toggleVotDFavorite(currentBundle), onManageFlags: currentBundle.isFavorite ? () => _openFlagManagerForVotD(currentBundle) : null, enableCardAnimations: true, speckCount: 10, fontSizeDelta: _fontSizeDelta, readerFontFamily: _selectedFontFamily, onShareAsImage: () => _shareVotDAsImage(currentBundle),); // <<< ADDED CALLBACK
              },),
              const SizedBox(height: 24.0),
              HomeNavigationButton(icon: Icons.menu_book_outlined, label: "Read Full Bible", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FullBibleReaderScreen())).then((_) => _refreshAllData())),
              const SizedBox(height: 16.0),
              HomeNavigationButton(icon: Icons.favorite_border_outlined, label: "My Favorites", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())).then((_) => _refreshAllData())),
              const SizedBox(height: 16.0),
              HomeNavigationButton(icon: Icons.search_outlined, label: "Search", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()))),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
