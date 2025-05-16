// File: lib/screens/home_screen.dart
// Updated to include Prayer Wall navigation and necessary checks.

import 'package:flutter/material.dart';
import 'dart:math'; // For Random in _fetchCurrentStreak (if that logic remains) - Not directly used in provided snippet but kept for context
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for User check

// Existing imports from your file
import 'package:wwjd_app/widgets/verse_of_the_day_card.dart';
import 'package:wwjd_app/widgets/devotional_of_the_day_card.dart';
import '../helpers/daily_devotions.dart';
import '../helpers/database_helper.dart';
import '../models/models.dart'; // This likely contains Flag, UserReadingProgress, Devotional
import '../helpers/book_names.dart';
import '../helpers/prefs_helper.dart';
import '../dialogs/flag_selection_dialog.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../models/reader_settings_enums.dart';

// Screen imports
import 'full_bible_reader_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'search_screen.dart';
import 'reading_plans/reading_plans_list_screen.dart';

// New Prayer Wall Screen Imports
import 'prayer_wall/prayer_wall_screen.dart';
import 'prayer_wall/submit_prayer_screen.dart';
// import 'my_prayer_requests_screen.dart'; // This is usually accessed from Settings

// VotDDataBundle class definition (ensure this is correctly placed or imported)
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
  static const routeName = '/home'; // Added for consistency
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // MINIMAL FIX: Initialize late Future variables with default completed Futures
  // This prevents LateInitializationError when FutureBuilders access them initially.
  late Future<Devotional?> _devotionalFuture = Future.value(null);
  late Future<VotDDataBundle> _votdFuture = Future.value(VotDDataBundle(verseData: null));
  late Future<int> _streakFuture = Future.value(0); // Default to 0 streak

  List<Flag> _allAvailableFlags = [];
  VotDDataBundle? _currentVotDDataBundle;

  double _fontSizeDelta = 0.0;
  ReaderFontFamily _selectedFontFamily = ReaderFontFamily.systemDefault;

  @override
  void initState() {
    super.initState();
    _loadReaderPreferencesAndAllData();
  }

  Future<void> _loadReaderPreferencesAndAllData() async {
    // It's good practice to check if mounted before async operations that might call setState
    if (!mounted) return;
    await _loadReaderPreferences();
    if (!mounted) return;
    await _loadAvailableFlags();
    if (!mounted) return;
    
    // Assign the actual data fetching futures. 
    // These will replace the default Future.value() assignments.
    _assignFutures(); 
    
    if (mounted) {
      setState(() {
        // This setState is to ensure the UI rebuilds after preferences are loaded
        // and futures are re-assigned, so FutureBuilders pick up the new futures.
      });
    }
  }

  Future<void> _loadReaderPreferences() async {
    _fontSizeDelta = PrefsHelper.getReaderFontSizeDelta();
    _selectedFontFamily = PrefsHelper.getReaderFontFamily();
  }

  void _assignFutures() {
    // These assignments will replace the initial Future.value() ones.
    _devotionalFuture = _fetchDevotionalOfTheDay();
    if (_currentVotDDataBundle == null || _currentVotDDataBundle!.verseData == null) {
      _votdFuture = _fetchNewRandomVotDBundle();
    } else {
      _votdFuture = _refreshFavoriteStatusForCurrentVotD();
    }
    _streakFuture = _fetchCurrentStreak();
  }

  Future<void> _loadAvailableFlags() async {
    try {
      final Set<int> hiddenIds = PrefsHelper.getHiddenFlagIds();
      final List<Flag> visiblePrebuiltFlags = prebuiltFlags.where((f) => !hiddenIds.contains(f.id)).toList();
      final userFlagMaps = await _dbHelper.getUserFlags();
      final userFlags = userFlagMaps.map((map) => Flag.fromUserDbMap(map)).toList();
      if (!mounted) return;
      // Only call setState if _allAvailableFlags directly influences the build method
      // or if its change needs to trigger a rebuild for other reasons.
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
        if (isFavorite) {
          assignedFlagIds = await _dbHelper.getFlagIdsForFavorite(currentVotDVerseID);
        }
        _currentVotDDataBundle = VotDDataBundle(
            verseData: verseData,
            isFavorite: isFavorite,
            assignedFlagIds: assignedFlagIds
        );
        return _currentVotDDataBundle!;
      }
    } catch (e) {
      print("Error fetching new random VotD bundle: $e");
    }
    _currentVotDDataBundle = VotDDataBundle(verseData: null);
    return _currentVotDDataBundle!;
  }

  Future<VotDDataBundle> _refreshFavoriteStatusForCurrentVotD() async {
    if (_currentVotDDataBundle == null || _currentVotDDataBundle!.verseData == null) {
      return _fetchNewRandomVotDBundle();
    }

    final String verseID = _currentVotDDataBundle!.verseData![DatabaseHelper.bibleColVerseID];
    try {
      bool isFavorite = await _dbHelper.isFavorite(verseID);
      List<int> assignedFlagIds = [];
      if (isFavorite) {
        assignedFlagIds = await _dbHelper.getFlagIdsForFavorite(verseID);
      }
      _currentVotDDataBundle = _currentVotDDataBundle!.copyWith(
        isFavorite: isFavorite,
        assignedFlagIds: assignedFlagIds,
      );
      return _currentVotDDataBundle!;
    } catch (e) {
      print("Error refreshing favorite status for VotD $verseID: $e");
      return _currentVotDDataBundle!;
    }
  }

  Future<int> _fetchCurrentStreak() async {
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
      print("Error fetching current streak: $e");
      return 0; // Return a default value on error
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
    if (bundleToToggle.verseData == null || bundleToToggle.verseData![DatabaseHelper.bibleColVerseID] == null) {
      return;
    }
    String verseID = bundleToToggle.verseData![DatabaseHelper.bibleColVerseID];
    Map<String, dynamic> verseDataMap = Map<String, dynamic>.from(bundleToToggle.verseData!);
    bool newFavoriteState = !bundleToToggle.isFavorite;

    try {
      if (newFavoriteState) {
        await _dbHelper.addFavorite(verseDataMap);
      } else {
        await _dbHelper.removeFavorite(verseID);
      }
      if (mounted) {
        setState(() {
          _votdFuture = _refreshFavoriteStatusForCurrentVotD();
        });
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating favorite: ${e.toString()}")));
    }
  }

  void _openFlagManagerForVotD(VotDDataBundle bundleForFlags) {
      if (bundleForFlags.verseData == null || bundleForFlags.verseData![DatabaseHelper.bibleColVerseID] == null || !bundleForFlags.isFavorite) return;

      final String verseID = bundleForFlags.verseData![DatabaseHelper.bibleColVerseID];
      String ref = "${getFullBookName(bundleForFlags.verseData![DatabaseHelper.bibleColBook] ?? "??")} ${bundleForFlags.verseData![DatabaseHelper.bibleColChapter]?.toString() ?? "?"}:${bundleForFlags.verseData![DatabaseHelper.bibleColStartVerse]?.toString() ?? "?"}";

      showDialog(
        context: context,
        builder: (_) => FlagSelectionDialog(
            verseRef: ref,
            initialSelectedFlagIds: bundleForFlags.assignedFlagIds,
            allAvailableFlags: _allAvailableFlags,
            onHideFlag: (flagId) async {
              await PrefsHelper.hideFlagId(flagId);
              await _loadAvailableFlags(); 
              if (mounted) {
                setState((){ 
                   _votdFuture = _refreshFavoriteStatusForCurrentVotD(); 
                });
              }
            },
            onDeleteFlag: (flagId) async {
              await _dbHelper.deleteUserFlag(flagId);
              await _loadAvailableFlags();
              if (mounted) {
                 setState((){
                   _votdFuture = _refreshFavoriteStatusForCurrentVotD();
                });
              }
            },
            onAddNewFlag: (String newName) async {
              int newId = await _dbHelper.addUserFlag(newName);
              await _loadAvailableFlags(); 
              Flag? foundFlag;
              try {
                foundFlag = _allAvailableFlags.firstWhere((f) => f.id == newId);
              } catch (e) {
                print("Error finding newly added flag with ID $newId in _openFlagManagerForVotD: $e");
                foundFlag = null;
              }
              return foundFlag;
            },
            onSave: (finalSelectedIds) async {
              Set<int> initSet = bundleForFlags.assignedFlagIds.toSet();
              Set<int> finalSet = finalSelectedIds.toSet();
              for (int id in finalSet.difference(initSet)) {
                await _dbHelper.assignFlagToFavorite(verseID, id);
              }
              for (int id in initSet.difference(finalSet)) {
                await _dbHelper.removeFlagFromFavorite(verseID, id);
              }
              if (mounted) {
                setState((){
                   _votdFuture = _refreshFavoriteStatusForCurrentVotD();
                });
              }
            },
        ),
    ).then((_) {
        if (mounted) {
          _loadAvailableFlags(); 
        }
      });
  }

  Widget _buildStreakDisplay(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return FutureBuilder<int>(
      future: _streakFuture, // This future is now initialized at declaration
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData && !snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))),
          );
        }
        
        int streakCount = 0; 
        if (snapshot.hasError) {
          print("Error in _streakFuture FutureBuilder: ${snapshot.error}");
        } else if (snapshot.hasData) {
          streakCount = snapshot.data!;
        }

        const String mainCtaText = "Guided Readings";
        const IconData mainCtaIcon = Icons.checklist_rtl_outlined;
        final Color mainCtaTextColor = Colors.black.withOpacity(0.8);

        return Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ReadingPlansListScreen()))
                    .then((_) => _refreshAllData());
              },
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.sereneSkyGradient,
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(mainCtaIcon, color: mainCtaTextColor, size: 26),
                              const SizedBox(width: 10.0),
                              Text(mainCtaText, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: mainCtaTextColor)),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 18, color: mainCtaTextColor.withOpacity(0.8))
                        ],
                      ),
                      if (streakCount > 0) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                          child: Divider(color: mainCtaTextColor.withOpacity(0.3), height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department_rounded, color: Colors.redAccent.shade400, size: 20),
                            const SizedBox(width: 6.0),
                            Text(
                              "$streakCount Day Streak!",
                              style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.85), 
                                  shadows: [ Shadow(blurRadius: 1.0, color: Colors.black.withOpacity(0.1), offset: const Offset(0.5, 0.5)) ]
                                ),
                            ),
                          ],
                        ),
                      ] else ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              "Start a plan to build your streak!",
                              style: textTheme.bodyMedium?.copyWith(color: mainCtaTextColor.withOpacity(0.85)),
                            ),
                          )
                        ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final Brightness currentBrightness = Theme.of(context).brightness;
    // final currentUser = Provider.of<User?>(context); // Already declared in your original code

    final Gradient lightGradient = LinearGradient(
      colors: [ Colors.deepPurple.shade100.withOpacity(0.6), Colors.purple.shade50.withOpacity(0.8), Colors.white, ],
      begin: Alignment.topLeft, end: Alignment.bottomRight, stops: const [0.0, 0.3, 1.0],
    );
    final Gradient darkGradient = LinearGradient(
      colors: [ Colors.grey.shade800, Colors.grey.shade900, Colors.black ], 
      begin: Alignment.topLeft, end: Alignment.bottomRight, stops: const [0.0, 0.4, 1.0],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wake up with Jesus'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark || (themeProvider.themeMode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark)
                  ? Icons.light_mode_outlined 
                  : Icons.dark_mode_outlined,   
            ),
            tooltip: "Toggle Theme",
            onPressed: () {
              ThemeMode currentEffectiveMode = themeProvider.themeMode;
              if (currentEffectiveMode == ThemeMode.system) {
                currentEffectiveMode = (MediaQuery.platformBrightnessOf(context) == Brightness.dark) 
                                     ? ThemeMode.dark 
                                     : ThemeMode.light;
              }
              if (currentEffectiveMode == ThemeMode.dark) {
                themeProvider.setThemeMode(ThemeMode.light);
              } else {
                themeProvider.setThemeMode(ThemeMode.dark);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: "Settings",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())).then((_) => _refreshAllData());
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: currentBrightness == Brightness.dark ? darkGradient : lightGradient,
        ),
        child: RefreshIndicator(
          onRefresh: _refreshAllData,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              _buildStreakDisplay(context),
              
              // MODIFIED: Replaced the two prayer buttons with the new promo card
              _buildPrayerWallPromoCard(context), // New promo card
              const SizedBox(height: 16.0), 

              FutureBuilder<Devotional?>(
                future: _devotionalFuture, 
                builder: (context, snapshot) {
                  // ... (FutureBuilder logic for Devotional remains the same)
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData && !snapshot.hasError) {
                    return DevotionalOfTheDayCard(
                        devotional: Devotional(title: "", coreMessage: "", scriptureFocus: "", scriptureReference: "", reflection: "", prayerDeclaration: ""),
                        isLoading: true,
                        fontSizeDelta: _fontSizeDelta, 
                        readerFontFamily: _selectedFontFamily, 
                    );
                  }
                  if (snapshot.hasError) {
                     print("Error in _devotionalFuture FutureBuilder: ${snapshot.error}");
                     return DevotionalOfTheDayCard(
                        devotional: Devotional(title: "Error", coreMessage: "Could not load devotional.", scriptureFocus: "", scriptureReference: "", reflection: "Please try again later.", prayerDeclaration: ""),
                        isLoading: false,
                        fontSizeDelta: _fontSizeDelta, 
                        readerFontFamily: _selectedFontFamily, 
                    );
                  }
                  final devotionalData = snapshot.data; 
                  if (devotionalData == null && snapshot.connectionState != ConnectionState.waiting) {
                     return DevotionalOfTheDayCard( 
                        devotional: Devotional(title: "Not Available", coreMessage: "Today's devotional is not available.", scriptureFocus: "", scriptureReference: "", reflection: "", prayerDeclaration: ""),
                        isLoading: false,
                        fontSizeDelta: _fontSizeDelta, 
                        readerFontFamily: _selectedFontFamily, 
                    );
                  }
                  
                  return DevotionalOfTheDayCard(
                    devotional: devotionalData ?? Devotional(title: "", coreMessage: "Loading...", scriptureFocus: "", scriptureReference: "", reflection: "", prayerDeclaration: ""), 
                    isLoading: snapshot.connectionState == ConnectionState.waiting, 
                    enableCardAnimations: true,
                    speckCount: 15,
                    fontSizeDelta: _fontSizeDelta, 
                    readerFontFamily: _selectedFontFamily, 
                  );
                },
              ),
              const SizedBox(height: 20.0),
              FutureBuilder<VotDDataBundle>(
                future: _votdFuture, 
                builder: (context, snapshot) {
                  // ... (FutureBuilder logic for VotD remains the same)
                  VotDDataBundle? bundleForDisplay;
                  bool showAsLoading = snapshot.connectionState == ConnectionState.waiting && 
                                       (!snapshot.hasData || snapshot.data?.verseData == null) && 
                                       (_currentVotDDataBundle == null || _currentVotDDataBundle!.verseData == null);


                  if (snapshot.hasData && snapshot.data!.verseData != null) {
                    _currentVotDDataBundle = snapshot.data!; 
                    bundleForDisplay = _currentVotDDataBundle;
                  } else if (_currentVotDDataBundle != null && _currentVotDDataBundle!.verseData != null) {
                    bundleForDisplay = _currentVotDDataBundle;
                  } else if (snapshot.hasError) {
                      print("Error in _votdFuture FutureBuilder: ${snapshot.error}");
                      return VerseOfTheDayCard(isLoading: false, verseText: "Could not load verse.", verseRef: "Error", isFavorite: false, assignedFlagNames: const [], enableCardAnimations: false, fontSizeDelta: _fontSizeDelta, readerFontFamily: _selectedFontFamily);
                  } else if (snapshot.connectionState != ConnectionState.waiting && (snapshot.data == null || snapshot.data!.verseData == null)) {
                      return VerseOfTheDayCard(isLoading: false, verseText: "Verse not available.", verseRef: "", isFavorite: false, assignedFlagNames: const [], enableCardAnimations: false, fontSizeDelta: _fontSizeDelta, readerFontFamily: _selectedFontFamily);
                  }
                 
                  if (bundleForDisplay == null || bundleForDisplay.verseData == null) {
                      return VerseOfTheDayCard(isLoading: true, verseText: "Loading...", verseRef: "", isFavorite: false, assignedFlagNames: const [], enableCardAnimations: true, speckCount: 10, fontSizeDelta: _fontSizeDelta, readerFontFamily: _selectedFontFamily);
                  }

                  final VotDDataBundle currentBundle = bundleForDisplay;
                  String votdText = currentBundle.verseData![DatabaseHelper.bibleColVerseText] ?? "Error: Text missing.";
                  String bookAbbr = currentBundle.verseData![DatabaseHelper.bibleColBook] ?? "??";
                  String chapterStr = currentBundle.verseData![DatabaseHelper.bibleColChapter]?.toString() ?? "?";
                  String verseNum = currentBundle.verseData![DatabaseHelper.bibleColStartVerse]?.toString() ?? "?";
                  String votdRef = "${getFullBookName(bookAbbr)} $chapterStr:$verseNum";
                  
                  List<String> flagNamesForVotD = [];
                  if (currentBundle.isFavorite && currentBundle.assignedFlagIds.isNotEmpty) {
                    flagNamesForVotD = currentBundle.assignedFlagIds.map((id) {
                        final flag = _allAvailableFlags.firstWhere((f) => f.id == id, orElse: () => Flag(id: 0, name: "Unknown"));
                        return flag.name;
                    }).where((name) => name != "Unknown").toList();
                    flagNamesForVotD.sort();
                  }

                  return VerseOfTheDayCard(
                    isLoading: showAsLoading, 
                    verseText: votdText,
                    verseRef: votdRef,
                    isFavorite: currentBundle.isFavorite,
                    assignedFlagNames: flagNamesForVotD,
                    onToggleFavorite: () => _toggleVotDFavorite(currentBundle),
                    onManageFlags: currentBundle.isFavorite ? () => _openFlagManagerForVotD(currentBundle) : null,
                    enableCardAnimations: true,
                    speckCount: 10,
                    fontSizeDelta: _fontSizeDelta,
                    readerFontFamily: _selectedFontFamily,
                  );
                },
              ),
              const SizedBox(height: 24.0),
              _buildNavigationButton(context, icon: Icons.menu_book_outlined, label: "Read Full Bible", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FullBibleReaderScreen())).then((_) => _refreshAllData())),
              const SizedBox(height: 16.0),
              _buildNavigationButton(context, icon: Icons.favorite_border_outlined, label: "My Favorites", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())).then((_) => _refreshAllData())),
              const SizedBox(height: 16.0),
              _buildNavigationButton(context, icon: Icons.search_outlined, label: "Search", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()))),
              const SizedBox(height: 16.0), 
              // The "Submit a Prayer" button was removed from here as it's now part of the PrayerWallScreen's FAB.
              // If you want a direct link from home, you can add it back or integrate it into the new promo card's tap action logic.
            ],
          ),
        ),
      ),
    );
  }

  // NEW Helper method for the Prayer Wall promo card
  Widget _buildPrayerWallPromoCard(BuildContext context) {
    final theme = Theme.of(context);
    // final currentUser = Provider.of<User?>(context, listen: false); // Not needed for this card's navigation

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias, // Important for Image to respect rounded corners
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Add some margin
      child: InkWell(
        onTap: () {
          // Navigate directly to the PrayerWallScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrayerWallScreen()),
          );
        },
        child: Stack(
          alignment: Alignment.bottomLeft, // Align text content to the bottom left
          children: [
            // Background Image
            Ink.image(
              image: const AssetImage('assets/images/home/home_prayer_wall.png'), // Your image path
              height: 180, // Adjust height as needed
              fit: BoxFit.cover,
              // Optional: Add a color filter for better text visibility
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.35), // Darken the image slightly
                BlendMode.darken,
              ),
            ),
            // Text Overlay Content
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  // Optional: Add a subtle gradient overlay from bottom to top for text readability
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6), // Darker at the bottom
                      Colors.black.withOpacity(0.0), // Fades to transparent at the top
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.0, 0.7], // Adjust stops for gradient extent
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end, // Align text to the bottom
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Community Prayer Wall",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(blurRadius: 2.0, color: Colors.black54, offset: Offset(1,1)),
                        ]
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Share your requests & pray for others.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                         shadows: [
                          const Shadow(blurRadius: 1.0, color: Colors.black38, offset: Offset(1,1)),
                        ]
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2.0, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), 
      child: ListTile(
        leading: Icon(icon, size: 28, color: theme.colorScheme.primary), 
        title: Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)), 
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant), 
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), 
      ),
    );
  }
}
