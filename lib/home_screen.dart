// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'dart:math'; // For random devotional selection
import 'package:wwjd_app/widgets/verse_of_the_day_card.dart';
import 'package:wwjd_app/widgets/devotional_of_the_day_card.dart'; // Import new card
import 'daily_devotions.dart';
import 'database_helper.dart';
import 'models.dart'; // Includes Flag, Verse, Book, prebuiltFlags
import 'book_names.dart'; // For getFullBookName
import 'full_bible_reader_screen.dart'; // To navigate to the Bible reader
import 'favorites_screen.dart'; // To navigate to Favorites screen
import 'prefs_helper.dart'; // Import PrefsHelper for hidden flags
import 'dialogs/flag_selection_dialog.dart';
import 'screens/reading_plans_list_screen.dart';
import 'search_screen.dart'; // Import the refactored dialog

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic>? _verseOfTheDayData;
  bool _isLoadingVotD = true;
  bool _isVotDFavorite = false;

  List<Flag> _allAvailableFlags = [];
  List<int> _votdSelectedFlagIds = [];

  Devotional? _devotionalOfTheDay; // State for devotional
  bool _isLoadingDevotional = true; // Loading state for devotional

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingVotD = true;
      _isLoadingDevotional = true;
    });
    await _loadAvailableFlags();
    await _loadVerseOfTheDay();
    _loadDevotionalOfTheDay(); // Load devotional
    // No need to await _loadDevotionalOfTheDay if it's synchronous or updates UI internally
    if(mounted) {
      // Consolidate setState calls if possible, or ensure they are well-managed
      // The individual load methods now handle their own isLoading flags and setState.
    }
  }

  Future<void> _loadDevotionalOfTheDay() async {
    if (!mounted) return;
    setState(() {
      _isLoadingDevotional = true;
    });

    // Simulate a small delay if needed, or directly assign
    // This simple random pick will change on every refresh.
    // For a true "devotional of the day", you might want to persist the choice for 24 hours.
    if (allDevotionals.isNotEmpty) {
      final random = Random();
      _devotionalOfTheDay = allDevotionals[random.nextInt(allDevotionals.length)];
    } else {
      // Fallback if the list is somehow empty
      _devotionalOfTheDay = const Devotional(
        title: "Content Coming Soon",
        coreMessage: "Our team is preparing inspiring devotionals for you.",
        scriptureFocus: "",
        scriptureReference: "",
        reflection: "Please check back a little later for our daily reflections. We're excited to share them with you!",
        prayerDeclaration: "May your day be blessed!",
      );
    }

    if (mounted) {
      setState(() {
        _isLoadingDevotional = false;
      });
    }
  }

  Future<void> _loadAvailableFlags() async {
     // ... (existing code - no changes)
     if (!mounted) return;
     try {
        final Set<int> hiddenIds = PrefsHelper.getHiddenFlagIds();
        final List<Flag> visiblePrebuiltFlags = prebuiltFlags
            .where((flag) => !hiddenIds.contains(flag.id))
            .toList();
        final userFlagMaps = await _dbHelper.getUserFlags();
        final userFlags = userFlagMaps.map((map) => Flag(
            id: map[DatabaseHelper.flagsColId] as int,
            name: map[DatabaseHelper.flagsColName] as String,
        )).toList();
        setState(() {
          _allAvailableFlags = [...visiblePrebuiltFlags, ...userFlags];
          _allAvailableFlags.sort((a, b) => a.name.compareTo(b.name));
        });
     } catch (e) {
         print("Error loading available flags: $e");
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading flags: ${e.toString()}")));
     }
  }

  Future<void> _loadVerseOfTheDay() async {
    // ... (existing code - no changes other than managing its own isLoading and setState)
    if (!mounted) return;
    setState(() { _isLoadingVotD = true; }); // Manage its own loading state
    try {
      _verseOfTheDayData = await _dbHelper.getVerseOfTheDay();
      if (_verseOfTheDayData != null && _verseOfTheDayData![DatabaseHelper.bibleColVerseID] != null) {
        String currentVotDVerseID = _verseOfTheDayData![DatabaseHelper.bibleColVerseID];
        _isVotDFavorite = await _dbHelper.isFavorite(currentVotDVerseID);
        if (_isVotDFavorite) {
          _votdSelectedFlagIds = await _dbHelper.getFlagIdsForFavorite(currentVotDVerseID);
        } else {
          _votdSelectedFlagIds = [];
        }
      } else {
        _isVotDFavorite = false;
        _votdSelectedFlagIds = [];
         print("Warning: Could not get Verse of the Day data or verseID.");
      }
    } catch (e) {
      print("Error loading Verse of the Day: $e");
      _isVotDFavorite = false;
      _votdSelectedFlagIds = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not load Verse of the Day: ${e.toString()}")),
        );
      }
    }
    if (mounted) {
      setState(() { _isLoadingVotD = false; }); // Manage its own loading state
    }
  }

  Future<void> _toggleVotDFavorite() async {
    // ... (existing code - no changes)
    if (_verseOfTheDayData == null || _verseOfTheDayData![DatabaseHelper.bibleColVerseID] == null) {
        print("VotD data is null, cannot toggle favorite.");
        return;
    }
    String verseID = _verseOfTheDayData![DatabaseHelper.bibleColVerseID];
    bool newFavoriteState = !_isVotDFavorite;
    try {
      if (newFavoriteState) {
        Map<String, dynamic> favData = {
          DatabaseHelper.bibleColVerseID: verseID,
          DatabaseHelper.bibleColBook: _verseOfTheDayData![DatabaseHelper.bibleColBook],
          DatabaseHelper.bibleColChapter: _verseOfTheDayData![DatabaseHelper.bibleColChapter],
          DatabaseHelper.bibleColStartVerse: _verseOfTheDayData![DatabaseHelper.bibleColStartVerse],
          DatabaseHelper.bibleColVerseText: _verseOfTheDayData![DatabaseHelper.bibleColVerseText],
        };
        await _dbHelper.addFavorite(favData);
        _votdSelectedFlagIds = await _dbHelper.getFlagIdsForFavorite(verseID);
      } else {
        await _dbHelper.removeFavorite(verseID);
        _votdSelectedFlagIds = [];
      }
      if (mounted) {
        setState(() {
          _isVotDFavorite = newFavoriteState;
        });
      }
    } catch (e) {
        print("Error toggling favorite: $e");
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error updating favorite: ${e.toString()}"))
            );
        }
    }
  }

  void _openFlagManagerForVotD() {
    // ... (existing code - no changes)
     if (_verseOfTheDayData == null || _verseOfTheDayData![DatabaseHelper.bibleColVerseID] == null) return;
     final String verseID = _verseOfTheDayData![DatabaseHelper.bibleColVerseID];
     String bookAbbr = _verseOfTheDayData![DatabaseHelper.bibleColBook] ?? "??";
     String chapter = _verseOfTheDayData![DatabaseHelper.bibleColChapter]?.toString() ?? "?";
     String verseNum = _verseOfTheDayData![DatabaseHelper.bibleColStartVerse]?.toString() ?? "?";
     String verseRef = "${getFullBookName(bookAbbr)} $chapter:$verseNum";
     showDialog(
         context: context,
         builder: (_) => FlagSelectionDialog(
             verseRef: verseRef,
             initialSelectedFlagIds: List<int>.from(_votdSelectedFlagIds),
             allAvailableFlags: List<Flag>.from(_allAvailableFlags),
             onHideFlag: (flagId) async {
                 await PrefsHelper.hideFlagId(flagId);
                 await _loadAvailableFlags();
                 if (mounted) setState(() { _votdSelectedFlagIds.remove(flagId); });
             },
             onDeleteFlag: (flagId) async {
                 await _dbHelper.deleteUserFlag(flagId);
                 await _loadAvailableFlags();
                 if (mounted) setState(() { _votdSelectedFlagIds.remove(flagId); });
             },
             onAddNewFlag: (newName) async {
                 int newId = await _dbHelper.addUserFlag(newName);
                 await _loadAvailableFlags();
                 try {
                    final newFlag = _allAvailableFlags.firstWhere((f) => f.id == newId);
                    return newFlag;
                 } catch (e) {
                    print("Error finding newly added flag $newId after loading: $e");
                    return null;
                 }
             },
             onSave: (finalSelectedIds) async {
                 List<int> initialIds = List<int>.from(_votdSelectedFlagIds); Set<int> initialSet = initialIds.toSet(); Set<int> finalSet = finalSelectedIds.toSet();
                 for (int id in finalSet) { if (!initialSet.contains(id)) { await _dbHelper.assignFlagToFavorite(verseID, id); } }
                 for (int id in initialSet) { if (!finalSet.contains(id)) { await _dbHelper.removeFlagFromFavorite(verseID, id); } }
                 if (mounted) { setState(() { _votdSelectedFlagIds = finalSelectedIds; }); }
             },
         ),
     );
  }

  List<String> _getVotDFlagNames() {
    // ... (existing code - no changes)
      List<int> flagIds = _votdSelectedFlagIds;
      List<String> names = [];
      for (int id in flagIds) {
          final flag = _allAvailableFlags.firstWhere((f) => f.id == id,
            orElse: () => Flag(id: 0, name: "Unknown")
          );
          if (flag.id != 0) {
             names.add(flag.name);
          }
      }
      names.sort();
      return names;
  }

  @override
Widget build(BuildContext context) {
  String votdText = "Loading verse...";
  String votdRef = "";
  String currentVerseIdForVotD = "";
  bool canFavoriteVotD = !_isLoadingVotD && _verseOfTheDayData != null && _verseOfTheDayData![DatabaseHelper.bibleColVerseID] != null;

  if (canFavoriteVotD) {
    votdText = _verseOfTheDayData![DatabaseHelper.bibleColVerseText] ?? "Error: Text missing.";
    String bookAbbr = _verseOfTheDayData![DatabaseHelper.bibleColBook] ?? "??";
    String chapter = _verseOfTheDayData![DatabaseHelper.bibleColChapter]?.toString() ?? "?";
    String verseNum = _verseOfTheDayData![DatabaseHelper.bibleColStartVerse]?.toString() ?? "?";
    votdRef = "${getFullBookName(bookAbbr)} $chapter:$verseNum";
    currentVerseIdForVotD = _verseOfTheDayData![DatabaseHelper.bibleColVerseID]!;
  } else if (!_isLoadingVotD) {
    votdText = "Could not load Verse of the Day.";
    votdRef = "Pull down to refresh.";
  }

  List<String> flagNamesForVotD = _isVotDFavorite ? _getVotDFlagNames() : [];

  return Scaffold(
    appBar: AppBar(
      title: const Text('Wake up With Jesus Daily'),
      centerTitle: true,
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade100.withOpacity(0.6),
            Colors.purple.shade50.withOpacity(0.8),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _loadInitialData, // This will now also refresh devotional
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            // --- Devotional of the Day Card ---
            if (_isLoadingDevotional || _devotionalOfTheDay == null)
              DevotionalOfTheDayCard(
                devotional: _devotionalOfTheDay ?? const Devotional(title: "", coreMessage: "", scriptureFocus: "", scriptureReference: "", reflection: "", prayerDeclaration: ""), // Provide a dummy to avoid null, isLoading handles UI
                isLoading: true,
              )
            else
              DevotionalOfTheDayCard(
                devotional: _devotionalOfTheDay!,
                isLoading: false,
              ),
            const SizedBox(height: 20.0), // Spacing after devotional

            // --- Verse of the Day Card ---
            VerseOfTheDayCard(
              isLoading: _isLoadingVotD,
              verseText: votdText,
              verseRef: votdRef,
              isFavorite: _isVotDFavorite,
              assignedFlagNames: flagNamesForVotD,
              onToggleFavorite: canFavoriteVotD ? _toggleVotDFavorite : null,
              onManageFlags: _isVotDFavorite && currentVerseIdForVotD.isNotEmpty
                  ? () => _openFlagManagerForVotD()
                  : null,
            ),
            const SizedBox(height: 16.0),
            _buildNavigationButton(
              context,
              icon: Icons.checklist_rtl_outlined, // Example Icon
              label: "Reading Plans",
              onTap: () {
                Navigator.push( context, MaterialPageRoute(builder: (context) => const ReadingPlansListScreen()),);
              },
            ),
            const SizedBox(height: 24.0),

            _buildNavigationButton(
              context,
              icon: Icons.menu_book,
              label: "Read Full Bible",
              onTap: () {
                Navigator.push( context, MaterialPageRoute(builder: (context) => const FullBibleReaderScreen()),);
              },
            ),
            const SizedBox(height: 16.0),
            _buildNavigationButton(
              context,
              icon: Icons.favorite,
              label: "My Favorites",
              onTap: () {
                Navigator.push( context, MaterialPageRoute(builder: (context) => const FavoritesScreen()),);
              },
            ),
            const SizedBox(height: 16.0),
            _buildNavigationButton(
                context,
                icon: Icons.search,
                label: "Search",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );
                },
              ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildNavigationButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    // ... (existing code - no changes)
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