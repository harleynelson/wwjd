// lib/full_bible_reader_screen.dart
import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart'; // Import
import 'database_helper.dart';
import 'models.dart'; // Includes Flag, Verse, Book, prebuiltFlags
import 'book_names.dart';
import 'prefs_helper.dart'; // Needed for hiding flags
import 'dialogs/flag_selection_dialog.dart'; // Import the refactored dialog
import 'widgets/verse_list_item.dart'; // Import the refactored list item
import 'widgets/verse_actions_bottom_sheet.dart'; // Import the bottom sheet

enum BibleReaderView { books, chapters, verses }

class FullBibleReaderScreen extends StatefulWidget {
  // Optional parameters to navigate directly to a specific verse
  final String? targetBookAbbr;
  final String? targetChapter;
  final String? targetVerseNumber;

  const FullBibleReaderScreen({
    super.key,
    this.targetBookAbbr,
    this.targetChapter,
    this.targetVerseNumber,
  });

  @override
  State<FullBibleReaderScreen> createState() => _FullBibleReaderScreenState();
}

class _FullBibleReaderScreenState extends State<FullBibleReaderScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Scroll controllers for jumping to a verse
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

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

  // Flags and Favorites State
  List<Flag> _allAvailableFlags = []; // Combined list (filtered pre-built + user)
  Set<String> _favoritedVerseIdsInChapter = {}; // Stores verseIDs of favorites in the current chapter view
  Map<String, List<int>> _flagAssignmentsForChapter = {}; // verseID -> List<flagId> for current chapter view

  bool _initialScrollDone = false; // Track if initial scroll (if any) has been attempted
  String? _verseToHighlight; // State variable to hold the verse number to highlight
  Timer? _highlightTimer;   // Timer to clear the highlight


  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _highlightTimer?.cancel(); // Important to cancel timer to prevent memory leaks
    super.dispose();
  }

  // Determines initial loading based on whether a target verse was provided
  Future<void> _loadInitialData() async {
    // Always load available flags first
    await _loadAvailableFlags();

    // Check if navigation parameters were passed
    if (widget.targetBookAbbr != null && widget.targetChapter != null && widget.targetVerseNumber != null) {
      // A target verse is specified, attempt to load it directly
      print("Target specified: ${widget.targetBookAbbr} ${widget.targetChapter}:${widget.targetVerseNumber}");
      // Find the target Book object (needed for subsequent loads)
      Book? targetBook = await _findBookByAbbr(widget.targetBookAbbr!);
      if (targetBook != null) {
        // Set state to directly show verses view for the target
        setState(() {
           _selectedBook = targetBook;
           _selectedChapter = widget.targetChapter!;
           _currentView = BibleReaderView.verses;
           _appBarTitle = "${_selectedBook!.fullName} ${_selectedChapter!}";
           _isLoading = true; // Set loading while fetching verses
        });
        // Now load the specific verse data (will trigger scroll when done)
        await _loadData(book: _selectedBook, chapter: _selectedChapter);
      } else {
        print("Target book ${widget.targetBookAbbr} not found. Loading default book list.");
        _loadBooks(); // Fallback to loading all books if target book not found
      }
    } else {
      // Default behavior: load book list
      _loadBooks();
    }
  }

  // Helper to find a Book object by abbreviation (loads all if needed)
  Future<Book?> _findBookByAbbr(String abbr) async {
    // Ensure _books list is populated if not already
    if (_books.isEmpty) {
      final List<Map<String, dynamic>> bookMaps = await _dbHelper.getBookAbbreviations();
       _books = bookMaps.map((map) {
            String bAbbr = map[DatabaseHelper.bibleColBook] as String;
            String order = map['c_order'] as String? ?? 'zzz'; // Default order if null
            return Book(abbreviation: bAbbr, fullName: getFullBookName(bAbbr), canonOrder: order);
          }).toList();
    }
    // Find the book in the loaded list
    try {
      return _books.firstWhere((b) => b.abbreviation == abbr);
    } catch (e) {
      return null; // Book abbreviation not found
    }
  }


  // Load available flags (Combine pre-built from models.dart and user from DB, filtering hidden)
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
        _allAvailableFlags = [...visiblePrebuiltFlags, ...userFlags];
        _allAvailableFlags.sort((a, b) => a.name.compareTo(b.name));
     } catch (e) {
        print("Error loading available flags in reader: $e");
        // Don't necessarily need to show snackbar here unless flags are critical on load
     }
     // No setState needed here as it's usually called before build or dialogs use it directly
  }

  // Load books, chapters, or verses, including favorite/flag status for verses
  Future<void> _loadData({Book? book, String? chapter}) async {
    if (!mounted) return;
    // Reset scroll flag only when navigating to a new view
    bool enteringVerseView = (chapter != null && _currentView != BibleReaderView.verses);
    setState(() {
       _isLoading = true;
       if(enteringVerseView) {
         _initialScrollDone = false;
         _verseToHighlight = null; // Clear previous highlight when view changes
         _highlightTimer?.cancel();
       }
    });

    try {
      if (book == null) { // === Load books view ===
        final List<Map<String, dynamic>> bookMaps = await _dbHelper.getBookAbbreviations();
        _books = bookMaps.map((map) {
            String abbr = map[DatabaseHelper.bibleColBook] as String;
            String order = map['c_order'] as String? ?? 'zzz';
            return Book(abbreviation: abbr, fullName: getFullBookName(abbr), canonOrder: order);
          }).toList();
        _currentView = BibleReaderView.books; _appBarTitle = "Select a Book"; _selectedBook = null; _selectedChapter = null; _chapters = []; _verses = []; _favoritedVerseIdsInChapter = {}; _flagAssignmentsForChapter = {};

      } else if (chapter == null) { // === Load chapters view ===
        _chapters = await _dbHelper.getChaptersForBook(book.abbreviation);
        _selectedBook = book; _currentView = BibleReaderView.chapters; _appBarTitle = book.fullName; _selectedChapter = null; _verses = []; _favoritedVerseIdsInChapter = {}; _flagAssignmentsForChapter = {};

      } else { // === Load verses view ===
        final List<Map<String, dynamic>> verseMaps = await _dbHelper.getVersesForChapter(book.abbreviation, chapter);
        _verses = verseMaps.map((map) => Verse( verseID: map[DatabaseHelper.bibleColVerseID] as String?, bookAbbr: map[DatabaseHelper.bibleColBook] as String?, chapter: map[DatabaseHelper.bibleColChapter]?.toString(), verseNumber: map[DatabaseHelper.bibleColStartVerse].toString(), text: map[DatabaseHelper.bibleColVerseText] as String,)).toList();

        // Load favorite status and flags for only these verses
        _favoritedVerseIdsInChapter = {};
        _flagAssignmentsForChapter = {};
        for (Verse v in _verses) {
            if (v.verseID != null) {
                bool isFav = await _dbHelper.isFavorite(v.verseID!);
                if (isFav) {
                    _favoritedVerseIdsInChapter.add(v.verseID!);
                    _flagAssignmentsForChapter[v.verseID!] = await _dbHelper.getFlagIdsForFavorite(v.verseID!);
                }
            }
        }
        // Ensure state reflects current view (even if loaded directly via initState)
        _selectedBook = book;
        _selectedChapter = chapter;
        _currentView = BibleReaderView.verses;
        _appBarTitle = "${book.fullName} $chapter";

        // Trigger scroll AFTER verses are loaded and state is set, IF target was specified for THIS view
        bool shouldScrollAndHighlight = widget.targetBookAbbr == book.abbreviation &&
                            widget.targetChapter == chapter &&
                            widget.targetVerseNumber != null &&
                            !_initialScrollDone;

        if (shouldScrollAndHighlight) {
           // Use addPostFrameCallback to ensure the list has been built before scrolling
           WidgetsBinding.instance.addPostFrameCallback((_) {
             // Check mount status again inside callback
             if (mounted) {
               _scrollToTargetVerse(widget.targetVerseNumber); // Pass target verse number
             }
           });
        }
      }
    } catch (e) {
      print("Error loading Bible reader data: $e");
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading data: ${e.toString()}")));
         // Attempt to recover gracefully
         if (_currentView != BibleReaderView.books) { _goBackToBooks(); } else { setState(() { _isLoading = false; }); }
      }
    }
    // Ensure loading state is turned off regardless of success/error if mounted
    if (mounted) { setState(() { _isLoading = false; }); }
  }

  // Scroll to the target verse if specified in widget parameters
  void _scrollToTargetVerse(String? targetVerseNumToScroll) { // Modified to accept targetVerseNum
    if (targetVerseNumToScroll == null || _verses.isEmpty || !_itemScrollController.isAttached) {
      print("Scroll condition not met: targetVerse=$targetVerseNumToScroll, versesEmpty=${_verses.isEmpty}, controllerAttached=${_itemScrollController.isAttached}");
      if (targetVerseNumToScroll != null) { // If we intended to scroll, mark it as "done" attempt
          setState(() { _initialScrollDone = true; });
      }
      return;
    }

    final index = _verses.indexWhere((v) => v.verseNumber == targetVerseNumToScroll);

    if (index != -1) {
      print("Scrolling to index: $index (Verse: $targetVerseNumToScroll)");
      setState(() {
        _initialScrollDone = true;
        _verseToHighlight = targetVerseNumToScroll; // Set the verse to highlight
        _highlightTimer?.cancel(); // Cancel any existing timer
        _highlightTimer = Timer(const Duration(seconds: 2), () { // Highlight for 2 seconds
          if (mounted) {
            setState(() {
              _verseToHighlight = null; // Clear highlight
            });
          }
        });
      });
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 600), // Slightly longer duration
        curve: Curves.easeInOutCubic,
        alignment: 0.1, // Scroll so the item is near the top (10% from top)
      );
    } else {
        print("Target verse $targetVerseNumToScroll not found in loaded chapter for scrolling.");
         setState(() { _initialScrollDone = true; }); // Mark as done even if not found
    }
  }

  // Navigation helpers
  // Triggers loading the book list and updates state
  void _loadBooks() {
      _loadData(); // Calling _loadData with no arguments loads books
  }

  // Triggers loading the chapter list for a book and updates state
  void _loadChapters(Book book) {
      _loadData(book: book); // Calling _loadData with book loads chapters
  }
  void _loadVerses(String chapter) { if (_selectedBook != null) { _loadData(book: _selectedBook!, chapter: chapter); } }

  // Back navigation within the reader screen state
  void _goBack() {
    if (!mounted) return;
    // No need for setState around the whole block, let the load methods handle it
    if (_currentView == BibleReaderView.verses) {
      // From Verses -> Chapters
      // Need to reload chapters for the current _selectedBook
      if (_selectedBook != null) {
         print("Going back from Verses to Chapters for: ${_selectedBook!.fullName}");
         _loadChapters(_selectedBook!);
      } else {
         _goBackToBooks();
      }
    } else if (_currentView == BibleReaderView.chapters) {
      // From Chapters -> Books
      print("Going back from Chapters to Books");
      _goBackToBooks();
    }
  }

   // Navigate back to the main book list view
   void _goBackToBooks() {
     if (!mounted) return;
     print("Going back to Books view, reloading books...");
     _loadBooks();
   }

  // Toggle favorite status for a verse
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
        List<int> currentFlagIds = await _dbHelper.getFlagIdsForFavorite(verseID);
        if (mounted) {
          setState(() {
            _favoritedVerseIdsInChapter.add(verseID);
            _flagAssignmentsForChapter[verseID] = currentFlagIds;
          });
        }
      } else {
        await _dbHelper.removeFavorite(verseID);
        if (mounted) {
          setState(() {
            _favoritedVerseIdsInChapter.remove(verseID);
            _flagAssignmentsForChapter.remove(verseID);
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

  // Method to call the refactored flag dialog for a specific verse
  void _openFlagManagerForVerse(Verse verse) {
     if (verse.verseID == null || !mounted) return;
     final String verseID = verse.verseID!;
     final String verseRef = "${getFullBookName(verse.bookAbbr ?? '?')} ${verse.chapter ?? '?'}:${verse.verseNumber}";
     // Get current selection for this verse from the state map
     final List<int> currentSelection = _flagAssignmentsForChapter[verseID] ?? [];

     showDialog(
         context: context,
         builder: (_) => FlagSelectionDialog(
             verseRef: verseRef,
             initialSelectedFlagIds: currentSelection,
             allAvailableFlags: List<Flag>.from(_allAvailableFlags), // Pass available flags
             onHideFlag: (flagId) async {
                 await PrefsHelper.hideFlagId(flagId);
                 await _loadAvailableFlags(); // Refresh available flags list
                 if(mounted) setState(() { _flagAssignmentsForChapter[verseID]?.remove(flagId); });
             },
             onDeleteFlag: (flagId) async {
                 await _dbHelper.deleteUserFlag(flagId);
                 await _loadAvailableFlags();
                 if(mounted) setState(() { _flagAssignmentsForChapter[verseID]?.remove(flagId); });
             },
             onAddNewFlag: (newName) async {
                 int newId = await _dbHelper.addUserFlag(newName);
                 await _loadAvailableFlags();
                 try {
                    final newFlag = _allAvailableFlags.firstWhere((f) => f.id == newId);
                    return newFlag;
                 } catch (e) {
                    print("Error finding newly added flag ID $newId after loading: $e");
                    return null;
                 }
             },
             onSave: (finalSelectedIds) async {
                 List<int> initialIds = List<int>.from(currentSelection);
                 Set<int> initialSet = initialIds.toSet();
                 Set<int> finalSet = finalSelectedIds.toSet();
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
          final flag = _allAvailableFlags.firstWhere((f) => f.id == id, orElse: () => Flag(id: 0, name: "Unknown"));
          if (flag.id != 0) { names.add(flag.name); }
      }
      names.sort();
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
            crossAxisCount: 5, crossAxisSpacing: 8.0, mainAxisSpacing: 8.0, childAspectRatio: 1.5
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
        return ScrollablePositionedList.builder(
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          itemCount: _verses.length,
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 80.0),
          itemBuilder: (context, index) {
            final verse = _verses[index];
            final bool isFavorite = _favoritedVerseIdsInChapter.contains(verse.verseID);
            final List<String> flagNames = _getFlagNamesForVerse(verse.verseID ?? "");
            final bool shouldHighlight = verse.verseNumber == _verseToHighlight;

            return VerseListItem(
              verse: verse,
              isFavorite: isFavorite,
              assignedFlagNames: flagNames,
              isHighlighted: shouldHighlight, // Pass highlight status
              onToggleFavorite: () => _toggleFavorite(verse),
              onManageFlags: () => _openFlagManagerForVerse(verse),
              onVerseTap: () {
                final String bookName = getFullBookName(verse.bookAbbr ?? "Unknown Book");
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext bContext) { // Use a different context name
                    return VerseActionsBottomSheet(
                      verse: verse,
                      isFavorite: isFavorite,
                      assignedFlagNames: flagNames,
                      onToggleFavorite: () {
                        _toggleFavorite(verse);
                      },
                      onManageFlags: () {
                        _openFlagManagerForVerse(verse);
                      },
                      fullBookName: bookName,
                    );
                  },
                );
              },
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: Text(_appBarTitle),
         leading: _currentView != BibleReaderView.books || Navigator.canPop(context) || (widget.targetBookAbbr != null)
           ? IconButton(
               icon: const Icon(Icons.arrow_back),
               onPressed: () {
                 if (_currentView != BibleReaderView.books) {
                   _goBack();
                 } else if (Navigator.canPop(context)){
                   Navigator.of(context).pop();
                 }
               },
             )
           : null,
       ),
       body: _buildBody(),
     );
  }
}