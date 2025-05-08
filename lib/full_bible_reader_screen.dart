// lib/full_bible_reader_screen.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models.dart'; // Includes Flag, Verse, Book, prebuiltFlags
import 'book_names.dart';
import 'prefs_helper.dart'; // Needed for hiding flags
import 'dialogs/flag_selection_dialog.dart';
import 'widgets/verse_list_item.dart'; // Import the refactored dialog

enum BibleReaderView { books, chapters, verses }

class FullBibleReaderScreen extends StatefulWidget {
  const FullBibleReaderScreen({super.key});
  @override
  State<FullBibleReaderScreen> createState() => _FullBibleReaderScreenState();
}

class _FullBibleReaderScreenState extends State<FullBibleReaderScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // View State
  BibleReaderView _currentView = BibleReaderView.books;
  bool _isLoading = true;
  String _appBarTitle = "Select a Book";

  // Data Holders
  List<Book> _books = [];
  List<String> _chapters = [];
  List<Verse> _verses = []; // Includes verseID, bookAbbr, chapter
  Book? _selectedBook;
  String? _selectedChapter;

  // Flags and Favorites State (relevant for current view)
  List<Flag> _allAvailableFlags = []; // Combined list (filtered pre-built + user)
  Set<String> _favoritedVerseIdsInChapter = {}; // Stores verseIDs of favorites in the current chapter view
  Map<String, List<int>> _flagAssignmentsForChapter = {}; // verseID -> List<flagId> for current chapter view


  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadAvailableFlags(); // Load flags first
    _loadBooks(); // Then load book list
  }

  // Load flags (Combine pre-built from models.dart and user from DB, filtering hidden)
  Future<void> _loadAvailableFlags() async {
     if (!mounted) return;
     try {
        final Set<int> hiddenIds = PrefsHelper.getHiddenFlagIds();
        final List<Flag> visiblePrebuiltFlags = prebuiltFlags
            .where((flag) => !hiddenIds.contains(flag.id))
            .toList();
        final userFlagMaps = await _dbHelper.getUserFlags();
        final userFlags = userFlagMaps.map((map) => Flag.fromUserDbMap(map)).toList();
        // Update the state list used by dialogs
        // No need for setState here if only used by dialogs triggered later
        _allAvailableFlags = [...visiblePrebuiltFlags, ...userFlags];
        _allAvailableFlags.sort((a, b) => a.name.compareTo(b.name));
     } catch (e) {
        print("Error loading available flags in reader: $e");
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading flags: ${e.toString()}")));
     }
  }

  // Load books, chapters, or verses, including favorite/flag status for verses
  Future<void> _loadData({Book? book, String? chapter}) async {
    if (!mounted) return;
    setState(() { _isLoading = true; });

    try {
      if (book == null) { // Load books view
        final List<Map<String, dynamic>> bookMaps = await _dbHelper.getBookAbbreviations();
        _books = bookMaps.map((map) {
            String abbr = map[DatabaseHelper.bibleColBook] as String;
            String order = map['c_order'] as String? ?? 'zzz'; // Get canon order for Book model
            return Book(abbreviation: abbr, fullName: getFullBookName(abbr), canonOrder: order);
          }).toList();
        _currentView = BibleReaderView.books; _appBarTitle = "Select a Book"; _selectedBook = null; _selectedChapter = null; _chapters = []; _verses = []; _favoritedVerseIdsInChapter = {}; _flagAssignmentsForChapter = {};
      } else if (chapter == null) { // Load chapters view
        _chapters = await _dbHelper.getChaptersForBook(book.abbreviation);
        _selectedBook = book; _currentView = BibleReaderView.chapters; _appBarTitle = book.fullName; _selectedChapter = null; _verses = []; _favoritedVerseIdsInChapter = {}; _flagAssignmentsForChapter = {};
      } else { // Load verses view and their favorite/flag status
        final List<Map<String, dynamic>> verseMaps = await _dbHelper.getVersesForChapter(book.abbreviation, chapter);
        _verses = verseMaps.map((map) => Verse( verseID: map[DatabaseHelper.bibleColVerseID] as String?, bookAbbr: map[DatabaseHelper.bibleColBook] as String?, chapter: map[DatabaseHelper.bibleColChapter]?.toString(), verseNumber: map[DatabaseHelper.bibleColStartVerse].toString(), text: map[DatabaseHelper.bibleColVerseText] as String,)).toList();

        // Load favorite status and flags for only these verses
        _favoritedVerseIdsInChapter = {};
        _flagAssignmentsForChapter = {};
        for (Verse verse in _verses) {
            if (verse.verseID != null) {
                bool isFav = await _dbHelper.isFavorite(verse.verseID!);
                if (isFav) {
                    _favoritedVerseIdsInChapter.add(verse.verseID!);
                    _flagAssignmentsForChapter[verse.verseID!] = await _dbHelper.getFlagIdsForFavorite(verse.verseID!);
                }
            }
        }
        _selectedBook = book; _selectedChapter = chapter; _currentView = BibleReaderView.verses; _appBarTitle = "${book.fullName} $chapter";
      }
    } catch (e) {
      print("Error loading Bible reader data: $e");
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading data: ${e.toString()}")));
         // Attempt to recover gracefully
         if (_currentView != BibleReaderView.books) { _goBackToBooks(); } else { setState(() { _isLoading = false; }); }
      }
    }
    if (mounted) { setState(() { _isLoading = false; }); }
  }

  // Navigation helpers
  void _loadBooks() { _loadData(); }
  void _loadChapters(Book book) { _loadData(book: book); }
  void _loadVerses(String chapter) { if (_selectedBook != null) { _loadData(book: _selectedBook!, chapter: chapter); } }

  // Back navigation within the reader screen
  void _goBack() {
    if (!mounted) return;
    setState(() {
      if (_currentView == BibleReaderView.verses) {
        _currentView = BibleReaderView.chapters;
        _appBarTitle = _selectedBook!.fullName;
        _selectedChapter = null;
        _verses = []; // Clear verse data
        _favoritedVerseIdsInChapter = {}; // Clear favorite status cache
        _flagAssignmentsForChapter = {};
      } else if (_currentView == BibleReaderView.chapters) {
        _goBackToBooks();
      }
    });
  }

   void _goBackToBooks() {
     if (!mounted) return;
    setState(() {
      _currentView = BibleReaderView.books;
      _appBarTitle = "Select a Book";
      _selectedBook = null;
      _chapters = [];
    });
  }

  // Toggle favorite status ONLY for a verse in the reader
  Future<void> _toggleFavorite(Verse verse) async {
    if (verse.verseID == null || verse.bookAbbr == null || verse.chapter == null) {
        print("Error: Verse data incomplete, cannot toggle favorite.");
        return;
    }

    String verseID = verse.verseID!;
    bool isCurrentlyFavorite = _favoritedVerseIdsInChapter.contains(verseID);
    bool newFavoriteState = !isCurrentlyFavorite;

    try {
      if (newFavoriteState) {
        Map<String, dynamic> favData = {
          DatabaseHelper.bibleColVerseID: verseID,
          DatabaseHelper.bibleColBook: verse.bookAbbr,
          DatabaseHelper.bibleColChapter: verse.chapter,
          DatabaseHelper.bibleColStartVerse: verse.verseNumber,
          DatabaseHelper.bibleColVerseText: verse.text,
        };
        await _dbHelper.addFavorite(favData);
        // Get flags (likely none initially)
        List<int> currentFlagIds = await _dbHelper.getFlagIdsForFavorite(verseID);
        if (mounted) {
          setState(() {
            _favoritedVerseIdsInChapter.add(verseID);
            _flagAssignmentsForChapter[verseID] = currentFlagIds; // Store assigned flags
          });
        }
      } else {
        await _dbHelper.removeFavorite(verseID);
        if (mounted) {
          setState(() {
            _favoritedVerseIdsInChapter.remove(verseID);
            _flagAssignmentsForChapter.remove(verseID); // Remove flag assignments too
          });
        }
      }
    } catch (e) {
        print("Error toggling favorite in reader: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating favorite: ${e.toString()}")));
        }
    }
  }

  // Method to call the refactored flag dialog for a verse
  // NOTE: Duplicated callback implementation logic. Refactor Recommended!
  void _openFlagManagerForVerse(Verse verse) {
     if (verse.verseID == null) return;
     final String verseID = verse.verseID!;
     final String verseRef = "${verse.bookAbbr ?? '?'} ${verse.chapter ?? '?'}:${verse.verseNumber}";
     final List<int> currentSelection = _flagAssignmentsForChapter[verseID] ?? [];

     showDialog(
         context: context,
         builder: (_) => FlagSelectionDialog(
             verseRef: verseRef,
             initialSelectedFlagIds: currentSelection,
             allAvailableFlags: List<Flag>.from(_allAvailableFlags),
             // Implement callbacks:
             onHideFlag: (flagId) async {
                 await PrefsHelper.hideFlagId(flagId);
                 await _loadAvailableFlags(); // Refresh available flags list
                 if(mounted) setState(() { _flagAssignmentsForChapter[verseID]?.remove(flagId); }); // Update local state map
             },
             onDeleteFlag: (flagId) async {
                 await _dbHelper.deleteUserFlag(flagId);
                 await _loadAvailableFlags(); // Refresh available flags list
                 if(mounted) setState(() { _flagAssignmentsForChapter[verseID]?.remove(flagId); }); // Update local state map
             },
             // --- CORRECTED onAddNewFlag Callback ---
             onAddNewFlag: (newName) async {
                 int newId = await _dbHelper.addUserFlag(newName);
                 await _loadAvailableFlags();
                 // Try to find the newly added flag
                 try {
                    final newFlag = _allAvailableFlags.firstWhere((f) => f.id == newId);
                    return newFlag;
                 } catch (e) {
                    print("Error finding newly added flag $newId after loading: $e");
                    return null;
                 }
             },
             // --- End Correction ---
             onSave: (finalSelectedIds) async {
                // --- Save logic (unchanged) ---
                 List<int> initialIds = List<int>.from(currentSelection); Set<int> initialSet = initialIds.toSet(); Set<int> finalSet = finalSelectedIds.toSet();
                 for (int id in finalSet) { if (!initialSet.contains(id)) { await _dbHelper.assignFlagToFavorite(verseID, id); } }
                 for (int id in initialSet) { if (!finalSet.contains(id)) { await _dbHelper.removeFlagFromFavorite(verseID, id); } }
                 if (mounted) { setState(() { _flagAssignmentsForChapter[verseID] = finalSelectedIds; }); }
             },
         ),
     );
  }


  // Helper to get flag names for display for a specific verse ID
  List<String> _getFlagNamesForVerse(String verseID) {
      List<int> flagIds = _flagAssignmentsForChapter[verseID] ?? [];
      List<String> names = [];
      for (int id in flagIds) {
          // Find in the combined list (_allAvailableFlags)
          final flag = _allAvailableFlags.firstWhere((f) => f.id == id, orElse: () => Flag(id: 0, name: "Unknown"));
          if (flag.id != 0) { names.add(flag.name); }
      }
      names.sort(); // Sort names alphabetically for display
      return names;
  }

  // --- Build Methods ---
  Widget _buildBody() {
    if (_isLoading) { return const Center(child: CircularProgressIndicator()); }

    switch (_currentView) {
      case BibleReaderView.books:
        if (_books.isEmpty) return const Center(child: Text("No books found."));
        return ListView.builder(
          itemCount: _books.length,
          itemBuilder: (context, index) {
            final book = _books[index];
            return ListTile(
              title: Text(book.fullName),
              onTap: () => _loadChapters(book),
            );
          },
        );

      case BibleReaderView.chapters:
        if (_chapters.isEmpty) return Center(child: Text("No chapters found for ${_selectedBook?.fullName ?? 'this book'}."));
        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, crossAxisSpacing: 8.0, mainAxisSpacing: 8.0,
          ),
          itemCount: _chapters.length,
          itemBuilder: (context, index) {
            final chapterNum = _chapters[index];
            return InkWell(
              onTap: () => _loadVerses(chapterNum),
              child: Card(
                elevation: 1.5,
                child: Center(
                  child: Text(chapterNum, style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
            );
          },
        );

      case BibleReaderView.verses:
        if (_verses.isEmpty) return const Center(child: Text("No verses found for this chapter."));
        // --- Use ListView.separated for automatic dividers ---
        return ListView.separated(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 80.0), // Padding for list
          itemCount: _verses.length,
          itemBuilder: (context, index) {
            final verse = _verses[index];
            // Determine favorite status and flags from state maps
            final bool isFavorite = _favoritedVerseIdsInChapter.contains(verse.verseID);
            final List<String> flagNames = _getFlagNamesForVerse(verse.verseID ?? "");

            // --- USE THE NEW WIDGET ---
            return VerseListItem(
              verse: verse,
              isFavorite: isFavorite,
              assignedFlagNames: flagNames,
              // Pass the toggle favorite callback, bound to this verse
              onToggleFavorite: () => _toggleFavorite(verse),
              // Pass the manage flags callback, bound to this verse
              onManageFlags: () => _openFlagManagerForVerse(verse),
            );
            // --- END USING THE NEW WIDGET ---
          },
          // Add a separator between items (instead of putting Divider inside VerseListItem)
          separatorBuilder: (context, index) => const SizedBox(height: 4), // Or return Divider();
        ); // End ListView.separated
    } // End switch
  } // End _buildBody

  @override
  Widget build(BuildContext context) {
    // Scaffold structure
     return Scaffold(
       appBar: AppBar(
         title: Text(_appBarTitle),
         leading: _currentView != BibleReaderView.books || Navigator.canPop(context)
           ? IconButton(
               icon: const Icon(Icons.arrow_back),
               onPressed: () {
                 // Handle back navigation: either internal state or pop screen
                 if (_currentView != BibleReaderView.books) {
                   _goBack(); // Navigate up within the reader (verses->chapters, chapters->books)
                 } else if (Navigator.canPop(context)){
                   Navigator.of(context).pop(); // Pop the whole screen if at book level
                 }
               },
             )
           : null, // No back button if it's the root view and can't pop
       ),
       body: _buildBody(), // Build the body based on the current view state
     );
  }
} // End _FullBibleReaderScreenState