// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
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
import 'search_screen.dart';
import 'screens/reading_plans_list_screen.dart';
import 'theme/app_colors.dart';

class VotDDataBundle {
  final Map<String, dynamic>? verseData; // Contains the full verse info
  final bool isFavorite;
  final List<int> assignedFlagIds;

  VotDDataBundle({
    this.verseData,
    this.isFavorite = false,
    this.assignedFlagIds = const [],
  });

  // --- CORRECTED: copyWith method defined INSIDE the class ---
  VotDDataBundle copyWith({ // Method name should be camelCase by convention
    Map<String, dynamic>? verseData, // Allow verseData to be optionally updated too
    bool? isFavorite,
    List<int>? assignedFlagIds,
  }) {
    return VotDDataBundle(
      verseData: verseData ?? this.verseData, // Use new if provided, else old
      isFavorite: isFavorite ?? this.isFavorite,
      assignedFlagIds: assignedFlagIds ?? this.assignedFlagIds,
    );
  }
  // --- END CORRECTION ---
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late Future<Devotional?> _devotionalFuture;
  late Future<VotDDataBundle> _votdFuture;
  late Future<int> _streakFuture;
  List<Flag> _allAvailableFlags = [];

  VotDDataBundle? _currentVotDDataBundle;

  @override
  void initState() {
    super.initState();
    _loadAvailableFlags(); 
    _assignFutures();
  }

  void _assignFutures() {
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
      _allAvailableFlags = [...visiblePrebuiltFlags, ...userFlags]..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading flags: ${e.toString()}")));
    }
  }

  Future<Devotional?> _fetchDevotionalOfTheDay() async {
    if (allDevotionals.isNotEmpty) return allDevotionals[Random().nextInt(allDevotionals.length)];
    return const Devotional(title: "N/A", coreMessage: "N/A", scriptureFocus: "", scriptureReference: "", reflection: "N/A", prayerDeclaration: "");
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
      // Use the corrected copyWith method
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
          if (todayDate.difference(lastCompletedDate).inDays > 1) isValid = false;
        } else if (progress.streakCount > 0) isValid = false;
        if (isValid && progress.streakCount > maxStreak) maxStreak = progress.streakCount;
      }
      return maxStreak;
    } catch (e) { return 0; }
  }
  
  Future<void> _refreshAllData() async {
    await _loadAvailableFlags(); 
    if (mounted) {
      setState(() {
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
        if (_currentVotDDataBundle != null && _currentVotDDataBundle!.verseData![DatabaseHelper.bibleColVerseID] == verseID) {
            bool updatedIsFavorite = await _dbHelper.isFavorite(verseID);
            List<int> updatedFlagIds = [];
            if (updatedIsFavorite) {
                updatedFlagIds = await _dbHelper.getFlagIdsForFavorite(verseID);
            }
            // Use the corrected copyWith method
            _currentVotDDataBundle = _currentVotDDataBundle!.copyWith(
                isFavorite: updatedIsFavorite,
                assignedFlagIds: updatedFlagIds,
            );
        }
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
                  // Use block body for setState
                  setState(() { 
                    _votdFuture = _refreshFavoriteStatusForCurrentVotD(); 
                  });
                }
            }, 
            onDeleteFlag: (flagId) async { 
                await _dbHelper.deleteUserFlag(flagId); 
                await _loadAvailableFlags(); 
                if (mounted) {
                  // Use block body for setState
                  setState(() { 
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
                // Perform DB operations
                for (int id in finalSet.difference(initSet)) {
                  await _dbHelper.assignFlagToFavorite(verseID, id);
                } 
                for (int id in initSet.difference(finalSet)) {
                  await _dbHelper.removeFlagFromFavorite(verseID, id);
                } 
                // After all async DB work is done, then update state
                if (mounted) {
                  // Use block body for setState
                  setState(() { 
                    _votdFuture = _refreshFavoriteStatusForCurrentVotD(); 
                  });
                }
            }, 
        ), 
    ).then((_) {
        // After dialog closes, ensure _allAvailableFlags is up-to-date
        // as the dialog might have changed them (hide, delete, add).
        _loadAvailableFlags();
     });
  }

  Widget _buildStreakDisplay(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
        
        // Text and icon for the main CTA part (Guided Reading Plans)
        const String mainCtaText = "Guided Reading Plans";
        const IconData mainCtaIcon = Icons.checklist_rtl_outlined;
        // Use textOnPrimary for text on this new gradient button
        final Color mainCtaTextColor = AppColors.textOnSecondary; 


        return Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
          child: Card( // The Card provides elevation, shape, and clipping
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            clipBehavior: Clip.antiAlias, // Important for gradient to be clipped
            child: InkWell( // InkWell should be a direct child of Material or inside a Material widget
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ReadingPlansListScreen()))
                    .then((_) => _refreshAllData()); 
              },
              // borderRadius: BorderRadius.circular(12.0), // Redundant if Card clips
              child: Ink( // Use Ink widget for decoration if InkWell is not direct child of Material
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.sereneSkyGradient,
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  // borderRadius: BorderRadius.circular(12.0), // Already handled by Card's shape
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Main CTA: "Guided Reading Plans"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row( 
                            children: [
                              Icon(
                                mainCtaIcon, 
                                color: mainCtaTextColor, // Use textOnPrimary
                                size: 26,
                              ),
                              const SizedBox(width: 10.0),
                              Text(
                                mainCtaText,
                                style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: mainCtaTextColor, // Use textOnPrimary
                                    ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded, 
                            size: 18, 
                            color: mainCtaTextColor.withOpacity(0.8) // Use textOnPrimary
                          )
                        ],
                      ),
                      
                      // Divider and Streak Info (conditional)
                      if (streakCount > 0) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0), // Adjusted padding
                          child: Divider(
                            color: mainCtaTextColor.withOpacity(0.3), // Divider color on gradient
                            height: 1,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              color: Colors.redAccent.shade400, // Keep streak color distinct
                              size: 20, 
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              "$streakCount Day Streak!",
                              style: textTheme.bodyLarge?.copyWith( 
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black, // Make streak text white for contrast on dark gradient
                                    shadows: [ // Optional shadow for better readability
                                      Shadow(
                                        blurRadius: 1.0,
                                        color: Colors.redAccent.withOpacity(0.3),
                                        offset: const Offset(0.5, 0.5),
                                      )
                                    ]
                                  ),
                            ),
                          ],
                        ),
                      ] else ...[
                         Padding(
                           padding: const EdgeInsets.only(top: 6.0),
                           child: Text(
                             "Start a plan to build your streak!",
                             style: textTheme.bodyMedium?.copyWith(
                               color: mainCtaTextColor.withOpacity(0.85), // Use textOnPrimary
                             ),
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
  return Scaffold(
    appBar: AppBar( title: const Text('Wake up With Jesus Daily'), centerTitle: true,),
    body: Container(
      decoration: BoxDecoration( gradient: LinearGradient( colors: [Colors.deepPurple.shade100.withOpacity(0.6), Colors.purple.shade50.withOpacity(0.8), Colors.white, ], begin: Alignment.topLeft, end: Alignment.bottomRight, stops: const [0.0, 0.3, 1.0],),),
      child: RefreshIndicator( onRefresh: _refreshAllData,
        child: ListView( padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            _buildStreakDisplay(context),
            FutureBuilder<Devotional?>( future: _devotionalFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return DevotionalOfTheDayCard(devotional: const Devotional(title: "", coreMessage: "", scriptureFocus: "", scriptureReference: "", reflection: "", prayerDeclaration: ""), isLoading: true);
                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) return DevotionalOfTheDayCard(devotional: const Devotional(title: "Error", coreMessage: "Could not load devotional.", scriptureFocus: "", scriptureReference: "", reflection: "Please try again later.", prayerDeclaration: ""), isLoading: false);
                return DevotionalOfTheDayCard(devotional: snapshot.data!, isLoading: false, enableCardAnimations: true, speckCount: 15);
              },
            ),
            const SizedBox(height: 20.0),
            FutureBuilder<VotDDataBundle>(
              future: _votdFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  final VotDDataBundle? initialBundle = _currentVotDDataBundle; // Use the stored bundle
                  List<String> flagNames = []; // Default to empty list
                  if (initialBundle?.assignedFlagIds != null && initialBundle!.assignedFlagIds.isNotEmpty) {
                    flagNames = initialBundle.assignedFlagIds.map((id) {
                        final flag = _allAvailableFlags.firstWhere((f) => f.id == id, orElse: () => Flag(id: 0, name: "Unknown"));
                        return flag.name;
                    }).where((name) => name != "Unknown").toList();
                    flagNames.sort(); // Sort here on a non-null list
                  }

                  return VerseOfTheDayCard(
                      isLoading: true, 
                      verseText: initialBundle?.verseData?[DatabaseHelper.bibleColVerseText] ?? "Loading...", 
                      verseRef: initialBundle?.verseData != null ? "${getFullBookName(initialBundle!.verseData![DatabaseHelper.bibleColBook] ?? "??")} ${initialBundle.verseData![DatabaseHelper.bibleColChapter]?.toString() ?? "?"}:${initialBundle.verseData![DatabaseHelper.bibleColStartVerse]?.toString() ?? "?"}" : "", 
                      isFavorite: initialBundle?.isFavorite ?? false, 
                      assignedFlagNames: flagNames, // Pass the processed, non-null list
                      enableCardAnimations: true, 
                      speckCount: 10
                  ); // Corrected closing parenthesis
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.verseData == null) {
                  return const VerseOfTheDayCard(isLoading: false, verseText: "Could not load verse.", verseRef: "Error", isFavorite: false, assignedFlagNames: [], enableCardAnimations: false);
                }
                
                final VotDDataBundle bundle = snapshot.data!;
                // Update _currentVotDDataBundle if the future resolved with different verse data
                // This ensures that if a new random verse was fetched, _currentVotDDataBundle is updated.
                if (_currentVotDDataBundle?.verseData?[DatabaseHelper.bibleColVerseID] != bundle.verseData![DatabaseHelper.bibleColVerseID]) {
                    _currentVotDDataBundle = bundle;
                } else if (_currentVotDDataBundle != null) {
                    // If it's the same verse, update its favorite status from the potentially refreshed bundle
                    _currentVotDDataBundle = _currentVotDDataBundle!.copyWith(
                        isFavorite: bundle.isFavorite,
                        assignedFlagIds: bundle.assignedFlagIds
                    );
                }


                String votdText = bundle.verseData![DatabaseHelper.bibleColVerseText] ?? "Error: Text missing.";
                String bookAbbr = bundle.verseData![DatabaseHelper.bibleColBook] ?? "??";
                String chapter = bundle.verseData![DatabaseHelper.bibleColChapter]?.toString() ?? "?";
                String verseNum = bundle.verseData![DatabaseHelper.bibleColStartVerse]?.toString() ?? "?";
                String votdRef = "${getFullBookName(bookAbbr)} $chapter:$verseNum";
                bool canFavoriteVotD = true; 
                
                List<String> flagNamesForVotD = [];
                if (bundle.isFavorite && bundle.assignedFlagIds.isNotEmpty) {
                  flagNamesForVotD = bundle.assignedFlagIds.map((id) {
                      final flag = _allAvailableFlags.firstWhere((f) => f.id == id, orElse: () => Flag(id: 0, name: "Unknown"));
                      return flag.name;
                  }).where((name) => name != "Unknown").toList();
                  flagNamesForVotD.sort(); // Sort here on a non-null list
                }

                return VerseOfTheDayCard( 
                  isLoading: false, 
                  verseText: votdText, 
                  verseRef: votdRef, 
                  isFavorite: bundle.isFavorite, 
                  assignedFlagNames: flagNamesForVotD, // Pass the processed, non-null list
                  onToggleFavorite: canFavoriteVotD ? () => _toggleVotDFavorite(bundle) : null, 
                  onManageFlags: canFavoriteVotD && bundle.isFavorite ? () => _openFlagManagerForVotD(bundle) : null,
                  enableCardAnimations: true, 
                  speckCount: 10, 
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
     return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
        title: Text(label, style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
