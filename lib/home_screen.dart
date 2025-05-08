// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:wwjd_app/widgets/verse_of_the_day_card.dart';
import 'database_helper.dart';
import 'models.dart'; // Includes Flag, Verse, Book, prebuiltFlags
import 'book_names.dart'; // For getFullBookName
import 'full_bible_reader_screen.dart'; // To navigate to the Bible reader
import 'favorites_screen.dart'; // To navigate to Favorites screen
import 'prefs_helper.dart'; // Import PrefsHelper for hidden flags
import 'dialogs/flag_selection_dialog.dart';
import 'search_screen.dart'; // Import the refactored dialog

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic>? _verseOfTheDayData; // Raw data from DB for VotD
  bool _isLoadingVotD = true;
  bool _isVotDFavorite = false;

  List<Flag> _allAvailableFlags = []; // Combined list (filtered pre-built + user)
  List<int> _votdSelectedFlagIds = []; // Only IDs for the current VotD

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadAvailableFlags(); // Load flags first
    await _loadVerseOfTheDay(); // Then load VotD and check its flag status
  }

  // Load flags (Combine pre-built from models.dart and user from DB, filtering hidden)
  Future<void> _loadAvailableFlags() async {
     if (!mounted) return;
     try {
        // 1. Get hidden flag IDs from prefs
        final Set<int> hiddenIds = PrefsHelper.getHiddenFlagIds();

        // 2. Filter prebuiltFlags (defined in models.dart)
        final List<Flag> visiblePrebuiltFlags = prebuiltFlags
            .where((flag) => !hiddenIds.contains(flag.id))
            .toList();

        // 3. Get user flags from DB
        final userFlagMaps = await _dbHelper.getUserFlags();
        // Map DB results to Flag objects
        final userFlags = userFlagMaps.map((map) => Flag(
            id: map[DatabaseHelper.flagsColId] as int,
            name: map[DatabaseHelper.flagsColName] as String,
            // isPrebuilt is implicitly false for user flags table
        )).toList();

        // 4. Combine and sort, update state
        setState(() {
          _allAvailableFlags = [...visiblePrebuiltFlags, ...userFlags];
          _allAvailableFlags.sort((a, b) => a.name.compareTo(b.name));
        });
     } catch (e) {
         print("Error loading available flags: $e");
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading flags: ${e.toString()}")));
     }
  }

  // Load Verse of the Day data and its favorite/flag status
  Future<void> _loadVerseOfTheDay() async {
     if (!mounted) return;
    setState(() { _isLoadingVotD = true; });
    try {
      _verseOfTheDayData = await _dbHelper.getVerseOfTheDay();
      if (_verseOfTheDayData != null && _verseOfTheDayData![DatabaseHelper.bibleColVerseID] != null) {
        String currentVotDVerseID = _verseOfTheDayData![DatabaseHelper.bibleColVerseID];
        _isVotDFavorite = await _dbHelper.isFavorite(currentVotDVerseID);
        if (_isVotDFavorite) {
          // Load the IDs of flags assigned to this VotD
          _votdSelectedFlagIds = await _dbHelper.getFlagIdsForFavorite(currentVotDVerseID);
        } else {
          _votdSelectedFlagIds = [];
        }
      } else {
        // Handle case where VotD data couldn't be fetched
        _isVotDFavorite = false;
        _votdSelectedFlagIds = [];
         print("Warning: Could not get Verse of the Day data or verseID.");
      }
    } catch (e) {
      print("Error loading Verse of the Day: $e");
      _isVotDFavorite = false; // Reset state on error
      _votdSelectedFlagIds = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not load Verse of the Day: ${e.toString()}")),
        );
      }
    }
    if (mounted) {
      setState(() { _isLoadingVotD = false; });
    }
  }

  // Toggle favorite status ONLY (no automatic dialog)
  Future<void> _toggleVotDFavorite() async {
    if (_verseOfTheDayData == null || _verseOfTheDayData![DatabaseHelper.bibleColVerseID] == null) {
        print("VotD data is null, cannot toggle favorite.");
        return;
    }

    String verseID = _verseOfTheDayData![DatabaseHelper.bibleColVerseID];
    bool newFavoriteState = !_isVotDFavorite;

    try {
      if (newFavoriteState) {
        // Prepare data map for adding favorite
        Map<String, dynamic> favData = {
          DatabaseHelper.bibleColVerseID: verseID,
          DatabaseHelper.bibleColBook: _verseOfTheDayData![DatabaseHelper.bibleColBook],
          DatabaseHelper.bibleColChapter: _verseOfTheDayData![DatabaseHelper.bibleColChapter],
          DatabaseHelper.bibleColStartVerse: _verseOfTheDayData![DatabaseHelper.bibleColStartVerse],
          DatabaseHelper.bibleColVerseText: _verseOfTheDayData![DatabaseHelper.bibleColVerseText],
        };
        await _dbHelper.addFavorite(favData);
        // Refresh assigned flags (might be empty initially) after adding
        _votdSelectedFlagIds = await _dbHelper.getFlagIdsForFavorite(verseID);
      } else {
        await _dbHelper.removeFavorite(verseID);
        _votdSelectedFlagIds = []; // Clear flags when unfavorited
      }
      // Update UI state
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

  // Method to call the refactored flag dialog
  void _openFlagManagerForVotD() {
     if (_verseOfTheDayData == null || _verseOfTheDayData![DatabaseHelper.bibleColVerseID] == null) return;
     final String verseID = _verseOfTheDayData![DatabaseHelper.bibleColVerseID];
     // Get reference string for dialog title
     String bookAbbr = _verseOfTheDayData![DatabaseHelper.bibleColBook] ?? "??";
     String chapter = _verseOfTheDayData![DatabaseHelper.bibleColChapter]?.toString() ?? "?";
     String verseNum = _verseOfTheDayData![DatabaseHelper.bibleColStartVerse]?.toString() ?? "?";
     String verseRef = "${getFullBookName(bookAbbr)} $chapter:$verseNum";

     showDialog(
         context: context,
         builder: (_) => FlagSelectionDialog(
             verseRef: verseRef,
             initialSelectedFlagIds: List<int>.from(_votdSelectedFlagIds), // Pass current selection
             allAvailableFlags: List<Flag>.from(_allAvailableFlags), // Pass available flags
             // Implement callbacks:
             onHideFlag: (flagId) async {
                 await PrefsHelper.hideFlagId(flagId);
                 await _loadAvailableFlags(); // Refresh available flags list in this screen
                 if (mounted) setState(() { _votdSelectedFlagIds.remove(flagId); }); // Update local selection state
             },
             onDeleteFlag: (flagId) async {
                 await _dbHelper.deleteUserFlag(flagId);
                 await _loadAvailableFlags(); // Refresh available flags list in this screen
                 if (mounted) setState(() { _votdSelectedFlagIds.remove(flagId); }); // Update local selection state
             },
             // --- CORRECTED onAddNewFlag Callback ---
             onAddNewFlag: (newName) async {
                 int newId = await _dbHelper.addUserFlag(newName);
                 await _loadAvailableFlags(); // Refresh available flags list
                 // Try to find the newly added flag in the refreshed list
                 try {
                    final newFlag = _allAvailableFlags.firstWhere((f) => f.id == newId);
                    return newFlag;
                 } catch (e) {
                    print("Error finding newly added flag $newId after loading: $e");
                    return null; // Return null if not found (shouldn't usually happen)
                 }
             },
             // --- End Correction ---
             onSave: (finalSelectedIds) async {
                 // --- Save logic (unchanged) ---
                 List<int> initialIds = List<int>.from(_votdSelectedFlagIds); Set<int> initialSet = initialIds.toSet(); Set<int> finalSet = finalSelectedIds.toSet();
                 for (int id in finalSet) { if (!initialSet.contains(id)) { await _dbHelper.assignFlagToFavorite(verseID, id); } }
                 for (int id in initialSet) { if (!finalSet.contains(id)) { await _dbHelper.removeFlagFromFavorite(verseID, id); } }
                 if (mounted) { setState(() { _votdSelectedFlagIds = finalSelectedIds; }); }
             },
         ),
     );
  }

  // Helper to get flag names for display for the VotD
  List<String> _getVotDFlagNames() {
      List<int> flagIds = _votdSelectedFlagIds;
      List<String> names = [];
      for (int id in flagIds) {
          // Find in the combined list (_allAvailableFlags)
          final flag = _allAvailableFlags.firstWhere((f) => f.id == id,
            orElse: () => Flag(id: 0, name: "Unknown") // Basic fallback
          );
          if (flag.id != 0) { // Avoid adding fallback if ID wasn't found
             names.add(flag.name);
          }
      }
      names.sort(); // Sort names alphabetically for display
      return names;
  }

  @override
Widget build(BuildContext context) {
  // Extract VotD data safely for passing to the card widget
  String votdText = "Loading verse...";
  String votdRef = "";
  String currentVerseIdForVotD = ""; // Still needed for flag manager button logic
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

  // Get flag names safely
  List<String> flagNamesForVotD = _isVotDFavorite ? _getVotDFlagNames() : [];

  return Scaffold(
    appBar: AppBar(
      title: const Text('Wake up With Jesus Daily'),
      centerTitle: true,
    ),
    body: Container( // Gradient Background
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
      child: RefreshIndicator( // Pull to refresh VotD & Flags
        onRefresh: _loadInitialData,
        child: ListView( // Main content scrolling
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            // --- Use the new VerseOfTheDayCard widget ---
            VerseOfTheDayCard(
              isLoading: _isLoadingVotD,
              verseText: votdText,
              verseRef: votdRef,
              isFavorite: _isVotDFavorite,
              assignedFlagNames: flagNamesForVotD,
              // Pass null callbacks if VotD isn't loaded or valid
              onToggleFavorite: canFavoriteVotD ? _toggleVotDFavorite : null,
              // Pass manage flags callback only if it's favorited and has a valid ID
              onManageFlags: _isVotDFavorite && currentVerseIdForVotD.isNotEmpty
                  ? () => _openFlagManagerForVotD()
                  : null,
            ),
            // --- End VerseOfTheDayCard ---

            const SizedBox(height: 24.0),

            // --- Navigation Buttons (remain the same) ---
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
                label: "Search", // Removed "(Coming Soon)"
                onTap: () {
                  // Navigate to the SearchScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );
                },
              ),
            // Add more navigation options here later...
          ],
        ),
      ),
    ),
  );
}

  // Helper for building consistent navigation buttons
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
} // End _HomeScreenState