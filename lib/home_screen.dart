// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'dart:math'; // For Random in _fetchCurrentStreak (if that logic remains)
import 'package:provider/provider.dart'; // For ThemeProvider
import 'package:wwjd_app/widgets/verse_of_the_day_card.dart';
import 'package:wwjd_app/widgets/devotional_of_the_day_card.dart';
import 'daily_devotions.dart';
import 'database_helper.dart';
import 'models.dart';
import 'book_names.dart';
import 'full_bible_reader_screen.dart';
import 'favorites_screen.dart';
import 'prefs_helper.dart';
import 'dialogs/flag_selection_dialog.dart';
import 'screens/settings_screen.dart';
import 'search_screen.dart';
import 'screens/reading_plans_list_screen.dart';
import 'theme/app_colors.dart'; // For gradients if used directly
import 'theme/theme_provider.dart'; // For theme toggling
import 'models/reader_settings_enums.dart'; // For ReaderFontFamily

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
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late Future<Devotional?> _devotionalFuture = Future.value(null);
  late Future<VotDDataBundle> _votdFuture = Future.value(VotDDataBundle(verseData: null)); // Default empty bundle
  late Future<int> _streakFuture = Future.value(0); // Default to 0 streak
  List<Flag> _allAvailableFlags = [];

  VotDDataBundle? _currentVotDDataBundle;

  // Reader settings state for HomeScreen cards
  double _fontSizeDelta = 0.0;
  ReaderFontFamily _selectedFontFamily = ReaderFontFamily.systemDefault;

  @override
  void initState() {
    super.initState();
    _loadReaderPreferencesAndAllData();
  }

  Future<void> _loadReaderPreferencesAndAllData() async {
    await _loadReaderPreferences();
    await _loadAvailableFlags();
    _assignFutures(); // Assign data futures after settings are loaded
    if (mounted) {
      // This setState ensures the build method runs once preferences are loaded,
      // making them available to FutureBuilders immediately if they build synchronously
      // or use these values in their initial loading widget.
      setState(() {});
    }
  }

  Future<void> _loadReaderPreferences() async {
    // No setState needed here if called before build or as part of a sequence
    // that will eventually call setState.
    // These values will be used by the build method.
    _fontSizeDelta = PrefsHelper.getReaderFontSizeDelta();
    _selectedFontFamily = PrefsHelper.getReaderFontFamily();
  }

  void _assignFutures() {
    _devotionalFuture = _fetchDevotionalOfTheDay();
    // Initialize _votdFuture carefully. If _currentVotDDataBundle is null, fetch new.
    // Otherwise, refresh its status.
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
      _allAvailableFlags = [...visiblePrebuiltFlags, ...userFlags]..sort((a, b) => a.name.compareTo(b.name));
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
        // Update _currentVotDDataBundle here as well
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
    _currentVotDDataBundle = VotDDataBundle(verseData: null); // Ensure it's non-null
    return _currentVotDDataBundle!;
  }

  Future<VotDDataBundle> _refreshFavoriteStatusForCurrentVotD() async {
    if (_currentVotDDataBundle == null || _currentVotDDataBundle!.verseData == null) {
      // This case should ideally be handled by fetching a new bundle if current is null
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
      return _currentVotDDataBundle!; // Return existing bundle on error
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
        } else if (progress.streakCount > 0) { // Streak > 0 but no last completion date means streak is broken
          isValid = false;
        }
        if (isValid && progress.streakCount > maxStreak) {
          maxStreak = progress.streakCount;
        }
      }
      return maxStreak;
    } catch (e) {
      print("Error fetching current streak: $e");
      return 0;
    }
  }

  Future<void> _refreshAllData() async {
    // Reload preferences first, then other data
    await _loadReaderPreferences();
    await _loadAvailableFlags();
    if (mounted) {
      setState(() {
        // Re-assign futures to trigger FutureBuilders to re-fetch data
        // Reset _currentVotDDataBundle to null to force _fetchNewRandomVotDBundle if desired,
        // or handle refresh logic more granularly within _assignFutures or the fetch methods.
        // For simplicity, let's ensure a fresh VotD if user pulls to refresh everything.
        _currentVotDDataBundle = null;
        _assignFutures();
      });
    }
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
        // Refresh the specific VotD bundle and trigger rebuild
        _votdFuture = _refreshFavoriteStatusForCurrentVotD();
        setState(() {}); // Rebuild to reflect the new future
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
                await _loadAvailableFlags(); // Reload available flags
                if (mounted) {
                  _votdFuture = _refreshFavoriteStatusForCurrentVotD(); // Refresh VotD data
                  setState(() {});
                }
            },
            onDeleteFlag: (flagId) async {
                await _dbHelper.deleteUserFlag(flagId);
                await _loadAvailableFlags();
                if (mounted) {
                  _votdFuture = _refreshFavoriteStatusForCurrentVotD();
                  setState(() {});
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
                  _votdFuture = _refreshFavoriteStatusForCurrentVotD();
                  setState(() {});
                }
            },
        ),
    ).then((_) {
        // After dialog closes, ensure _allAvailableFlags is up-to-date
        // as the dialog might have changed them (hide, delete, add).
        // This is a good place for it if dialog changes flags that VotD might use.
        _loadAvailableFlags();
     });
  }

  Widget _buildStreakDisplay(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // final colorScheme = Theme.of(context).colorScheme; // Not directly used in this version

    return FutureBuilder<int>(
      future: _streakFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))),
          );
        }
        int streakCount = snapshot.data ?? 0;

        const String mainCtaText = "Guided Reading Plans";
        const IconData mainCtaIcon = Icons.checklist_rtl_outlined;
        // Text color for main CTA on its gradient - assuming light text for AppColors.sereneSkyGradient
        final Color mainCtaTextColor = Colors.black.withOpacity(0.8); // Or a theme-aware color

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
                  gradient: LinearGradient( // This gradient is specific to this card
                    colors: AppColors.sereneSkyGradient, // Example: [Color(0xFFA1C4FD), Color(0xFFC2E9FB)]
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
                                    color: Colors.black.withOpacity(0.85), // Ensure contrast on sereneSky
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

    final Gradient lightGradient = LinearGradient(
      colors: [ Colors.deepPurple.shade100.withOpacity(0.6), Colors.purple.shade50.withOpacity(0.8), Colors.white, ],
      begin: Alignment.topLeft, end: Alignment.bottomRight, stops: const [0.0, 0.3, 1.0],
    );
    final Gradient darkGradient = LinearGradient(
      colors: [ Colors.grey.shade800, Colors.grey.shade900, Colors.black ], // Darker, distinct from cards
      begin: Alignment.topLeft, end: Alignment.bottomRight, stops: const [0.0, 0.4, 1.0],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wake up With Jesus Daily'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark || (themeProvider.themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark)
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            tooltip: "Toggle Theme",
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: "Settings",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()),).then((_) => _refreshAllData());
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
              FutureBuilder<Devotional?>(
                future: _devotionalFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return DevotionalOfTheDayCard(
                        devotional: Devotional(title: "", coreMessage: "", scriptureFocus: "", scriptureReference: "", reflection: "", prayerDeclaration: ""),
                        isLoading: true,
                        fontSizeDelta: _fontSizeDelta, // Pass loaded setting
                        readerFontFamily: _selectedFontFamily, // Pass loaded setting
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                    return DevotionalOfTheDayCard(
                        devotional: Devotional(title: "Error", coreMessage: "Could not load devotional.", scriptureFocus: "", scriptureReference: "", reflection: "Please try again later.", prayerDeclaration: ""),
                        isLoading: false,
                        fontSizeDelta: _fontSizeDelta, // Pass loaded setting
                        readerFontFamily: _selectedFontFamily, // Pass loaded setting
                    );
                  }
                  return DevotionalOfTheDayCard(
                    devotional: snapshot.data!,
                    isLoading: false,
                    enableCardAnimations: true,
                    speckCount: 15,
                    fontSizeDelta: _fontSizeDelta, // Pass loaded setting
                    readerFontFamily: _selectedFontFamily, // Pass loaded setting
                  );
                },
              ),
              const SizedBox(height: 20.0),
              FutureBuilder<VotDDataBundle>(
                future: _votdFuture,
                builder: (context, snapshot) {
                  VotDDataBundle? bundleForDisplay;
                  bool showAsLoading = true;

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    if (_currentVotDDataBundle != null && _currentVotDDataBundle!.verseData != null) {
                      bundleForDisplay = _currentVotDDataBundle;
                      showAsLoading = true;
                    } else {
                       return VerseOfTheDayCard(isLoading: true, verseText: "Loading...", verseRef: "", isFavorite: false, assignedFlagNames: const [], enableCardAnimations: true, speckCount: 10, fontSizeDelta: _fontSizeDelta, readerFontFamily: _selectedFontFamily);
                    }
                  } else if (snapshot.hasError) {
                     return VerseOfTheDayCard(isLoading: false, verseText: "Could not load verse.", verseRef: "Error", isFavorite: false, assignedFlagNames: const [], enableCardAnimations: false, fontSizeDelta: _fontSizeDelta, readerFontFamily: _selectedFontFamily);
                  } else if (snapshot.hasData && snapshot.data!.verseData != null) {
                    _currentVotDDataBundle = snapshot.data!;
                    bundleForDisplay = _currentVotDDataBundle;
                    showAsLoading = false;
                  } else if (_currentVotDDataBundle != null && _currentVotDDataBundle!.verseData != null) {
                    bundleForDisplay = _currentVotDDataBundle;
                    showAsLoading = false;
                  } else {
                    return VerseOfTheDayCard(isLoading: false, verseText: "Verse not available.", verseRef: "", isFavorite: false, assignedFlagNames: const [], enableCardAnimations: false, fontSizeDelta: _fontSizeDelta, readerFontFamily: _selectedFontFamily);
                  }

                  if (bundleForDisplay == null || bundleForDisplay.verseData == null) {
                     return VerseOfTheDayCard(isLoading: false, verseText: "Verse not available.", verseRef: "", isFavorite: false, assignedFlagNames: const [], enableCardAnimations: false, fontSizeDelta: _fontSizeDelta, readerFontFamily: _selectedFontFamily);
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    // This widget should also adapt to the app's theme (Light/Dark)
    // For now, relying on default ListTile/Card theming from AppThemes.
    return Card(
      // Card color will come from AppThemes.lightTheme.cardTheme or AppThemes.darkTheme.cardTheme
      // elevation: from cardTheme
      // shape: from cardTheme
      child: ListTile(
        leading: Icon(icon, size: 30 /*, color: from listTileTheme or colorScheme.primary */),
        title: Text(label, style: Theme.of(context).textTheme.titleMedium), // Will use themed text color
        trailing: Icon(Icons.arrow_forward_ios, size: 16 /*, color: from listTileTheme or onSurfaceVariant */),
        onTap: onTap,
      ),
    );
  }
}