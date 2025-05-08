// lib/full_bible_reader_screen.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models.dart'; // Brings in Flag class and prebuiltFlags list
import 'book_names.dart';
import 'prefs_helper.dart'; // Import PrefsHelper

enum BibleReaderView { books, chapters, verses }

class FullBibleReaderScreen extends StatefulWidget {
  const FullBibleReaderScreen({super.key});
  @override
  State<FullBibleReaderScreen> createState() => _FullBibleReaderScreenState();
}

class _FullBibleReaderScreenState extends State<FullBibleReaderScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  BibleReaderView _currentView = BibleReaderView.books;
  List<Book> _books = [];
  List<String> _chapters = [];
  List<Verse> _verses = []; // Includes verseID, bookAbbr, chapter
  Book? _selectedBook;
  String? _selectedChapter;
  bool _isLoading = true;
  String _appBarTitle = "Select a Book";

  List<Flag> _allAvailableFlags = []; // Combined list (filtered pre-built + user)
  // State for favorites/flags within the currently viewed chapter
  Set<String> _favoritedVerseIdsInChapter = {};
  Map<String, List<int>> _flagAssignmentsForChapter = {}; // verseID -> List<flagId>

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadAvailableFlags();
    _loadBooks(); // Start by loading book list
  }

  // Load flags (Combine pre-built from models.dart and user from DB, filtering hidden)
  Future<void> _loadAvailableFlags() async {
     if (!mounted) return;
     try {
        final Set<int> hiddenIds = PrefsHelper.getHiddenFlagIds();
        final List<Flag> visiblePrebuiltFlags = prebuiltFlags.where((flag) => !hiddenIds.contains(flag.id)).toList();
        final userFlagMaps = await _dbHelper.getUserFlags();
        final userFlags = userFlagMaps.map((map) => Flag.fromUserDbMap(map)).toList();
        // Update the state list used by dialogs
        // No need for setState if only used by dialogs triggered later
        _allAvailableFlags = [...visiblePrebuiltFlags, ...userFlags];
        _allAvailableFlags.sort((a, b) => a.name.compareTo(b.name));
     } catch (e) {
         print("Error loading available flags: $e");
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading flags: ${e.toString()}")));
     }
  }

  // Load books, chapters, or verses, including favorite/flag status for verses
  Future<void> _loadData({Book? book, String? chapter}) async {
    if (!mounted) return;
    setState(() { _isLoading = true; });

    try {
      if (book == null) { // Load books
        final List<Map<String, dynamic>> bookMaps = await _dbHelper.getBookAbbreviations();
        _books = bookMaps.map((map) => Book(abbreviation: map[DatabaseHelper.bibleColBook] as String, fullName: getFullBookName(map[DatabaseHelper.bibleColBook] as String))).toList();
        _currentView = BibleReaderView.books; _appBarTitle = "Select a Book"; _selectedBook = null; _selectedChapter = null; _chapters = []; _verses = []; _favoritedVerseIdsInChapter = {}; _flagAssignmentsForChapter = {};
      } else if (chapter == null) { // Load chapters
        _chapters = await _dbHelper.getChaptersForBook(book.abbreviation);
        _selectedBook = book; _currentView = BibleReaderView.chapters; _appBarTitle = book.fullName; _selectedChapter = null; _verses = []; _favoritedVerseIdsInChapter = {}; _flagAssignmentsForChapter = {};
      } else { // Load verses and their favorite/flag status
        final List<Map<String, dynamic>> verseMaps = await _dbHelper.getVersesForChapter(book.abbreviation, chapter);
        _verses = verseMaps.map((map) => Verse( verseID: map[DatabaseHelper.bibleColVerseID] as String?, bookAbbr: map[DatabaseHelper.bibleColBook] as String?, chapter: map[DatabaseHelper.bibleColChapter]?.toString(), verseNumber: map[DatabaseHelper.bibleColStartVerse].toString(), text: map[DatabaseHelper.bibleColVerseText] as String,)).toList();

        // Load favorite status and flags for these specific verses
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
        // From Verses -> Chapters
        _currentView = BibleReaderView.chapters;
        _appBarTitle = _selectedBook!.fullName;
        _selectedChapter = null;
        _verses = []; // Clear verse data
        _favoritedVerseIdsInChapter = {}; // Clear favorite status cache
        _flagAssignmentsForChapter = {};
      } else if (_currentView == BibleReaderView.chapters) {
        // From Chapters -> Books
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

  // --- Toggle Favorite Logic for Reader Screen ---
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
            _flagAssignmentsForChapter[verseID] = currentFlagIds;
          });
          // DON'T show dialog automatically per user request
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

  // --- Flag Selection Dialog (includes delete/hide logic) ---
 // NOTE: Duplicated logic from HomeScreen. Consider refactoring later.
 Future<void> _showFlagSelectionDialog(Verse verse) async {
   if (verse.verseID == null) return;
   String verseID = verse.verseID!;

    // Get current flag assignments for THIS specific verse
    List<int> currentFlagIds = _flagAssignmentsForChapter[verseID] ?? [];

    // Prepare flags for the dialog using the latest _allAvailableFlags
    List<Flag> dialogFlags = _allAvailableFlags.map((f) {
      bool isSelected = currentFlagIds.contains(f.id);
      return Flag(id: f.id, name: f.name, isSelected: isSelected); // isPrebuilt check comes from f.id < 0
    }).toList();

    if(!mounted) return;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Function to handle hiding/deleting flag
            Future<void> handleDeleteOrHideFlag(Flag flagToDelete) async {
               bool? confirm = await showDialog<bool>( context: context, builder: (BuildContext confirmContext) { /* ... Confirmation Dialog ... */ return AlertDialog( title: Text(flagToDelete.isPrebuilt ? "Confirm Hide" : "Confirm Delete"), content: Text(flagToDelete.isPrebuilt ? "Hide the default flag '${flagToDelete.name}'?" : "Delete the flag '${flagToDelete.name}'?\nThis removes it permanently."), actions: <Widget>[ TextButton(onPressed: () => Navigator.of(confirmContext).pop(false), child: const Text("Cancel")), TextButton( onPressed: () => Navigator.of(confirmContext).pop(true), child: Text(flagToDelete.isPrebuilt ? "Hide" : "Delete", style: TextStyle(color: flagToDelete.isPrebuilt ? Colors.orange.shade800 : Colors.red)), ), ], ); });
               if (confirm == true) {
                  try {
                      if (flagToDelete.isPrebuilt) {
                          await PrefsHelper.hideFlagId(flagToDelete.id);
                      } else {
                          await _dbHelper.deleteUserFlag(flagToDelete.id);
                      }
                      await _loadAvailableFlags(); // Refresh combined list
                      setDialogState(() { dialogFlags.removeWhere((f) => f.id == flagToDelete.id); });
                      if (mounted) { // Update reader screen state
                           setState(() { _flagAssignmentsForChapter[verseID]?.remove(flagToDelete.id); });
                      }
                  } catch (e) { print("Error hiding/deleting flag: $e"); if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating flags: $e"))); }
              }
            }

            // Build actual dialog
            return AlertDialog(
              title: Text('Manage Flags for ${verse.bookAbbr} ${verse.chapter}:${verse.verseNumber}'),
              content: SizedBox( /* ... Dialog Content Structure ... */
                  width: double.maxFinite, child: Column( mainAxisSize: MainAxisSize.min, children: [ Expanded( child: ListView( shrinkWrap: true, children: <Widget>[ if (dialogFlags.isEmpty) const Padding( padding: EdgeInsets.all(8.0), child: Text("No flags. Add one below."),), ...dialogFlags.map((flag) { return CheckboxListTile( title: Text(flag.name), value: flag.isSelected, controlAffinity: ListTileControlAffinity.leading, secondary: IconButton( // Hide/Delete Button
                                       icon: Icon( flag.isPrebuilt ? Icons.visibility_off_outlined : Icons.delete_outline, color: flag.isPrebuilt ? Colors.grey : Colors.red.shade300), tooltip: flag.isPrebuilt ? "Hide default flag" : "Delete custom flag", onPressed: () => handleDeleteOrHideFlag(flag), ), onChanged: (bool? value) { setDialogState(() { flag.isSelected = value ?? false; }); }, ); }).toList(), ], ), ), TextButton.icon( /* ... Add new flag button ... */ icon: const Icon(Icons.add), label: const Text("Add New Flag"), onPressed: () async { final newFlagName = await _showAddNewFlagDialog(); if (newFlagName != null && newFlagName.trim().isNotEmpty) { try { int newId = await _dbHelper.addUserFlag(newFlagName.trim()); await _loadAvailableFlags(); final currentSelectedIds = dialogFlags.where((df) => df.isSelected).map((df) => df.id).toSet(); dialogFlags = _allAvailableFlags.map((f) { bool shouldBeSelected = currentSelectedIds.contains(f.id) || (newId > 0 && f.id == newId); return Flag(id: f.id, name: f.name, isSelected: shouldBeSelected); }).toList(); setDialogState((){}); } catch (e) { print("Error adding new flag: $e"); if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error adding flag: $e"))); } } }, ), ], ),
              ),
              actions: <Widget>[ /* ... Cancel and Save Buttons ... */
                  TextButton( child: const Text('Cancel'), onPressed: () { Navigator.of(context).pop(); }, ), TextButton( child: const Text('Save Flags'), onPressed: () async { try { List<int> newlySelectedIds = []; List<int> previouslySelectedIds = List.from(_flagAssignmentsForChapter[verseID] ?? []); for (var flag in dialogFlags) { bool wasSelected = previouslySelectedIds.contains(flag.id); if (flag.isSelected) { newlySelectedIds.add(flag.id); if (!wasSelected) { await _dbHelper.assignFlagToFavorite(verseID, flag.id); } } else { if (wasSelected) { await _dbHelper.removeFlagFromFavorite(verseID, flag.id); } } } if (mounted) { setState(() { _flagAssignmentsForChapter[verseID] = newlySelectedIds; }); } Navigator.of(context).pop(); } catch (e) { print("Error saving flags: $e"); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving flags: $e"))); } }, ),
              ],
            );
          }
        );
      },
    );
  }

  // Add New Flag Dialog (same as HomeScreen)
  Future<String?> _showAddNewFlagDialog() async {
     TextEditingController flagController = TextEditingController();
     return showDialog<String>( context: context, builder: (context) { return AlertDialog( title: const Text("Add New Flag"), content: TextField(controller: flagController, autofocus: true, decoration: const InputDecoration(hintText: "Flag name"), textCapitalization: TextCapitalization.sentences,), actions: [ TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), TextButton(onPressed: () { if (flagController.text.trim().isNotEmpty) { Navigator.pop(context, flagController.text.trim()); } }, child: const Text("Add")), ],); });
   }

  // Helper to get flag names for display (uses combined list)
  List<String> _getFlagNamesForVerse(String verseID) {
      List<int> flagIds = _flagAssignmentsForChapter[verseID] ?? [];
      List<String> names = [];
      for (int id in flagIds) {
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
        // --- Book List (Unchanged) ---
        if (_books.isEmpty) return const Center(child: Text("No books found."));
        return ListView.builder(itemCount: _books.length, itemBuilder: (context, index) { final book = _books[index]; return ListTile(title: Text(book.fullName), onTap: () => _loadChapters(book),); },);

      case BibleReaderView.chapters:
        // --- Chapter Grid (Unchanged) ---
        if (_chapters.isEmpty) return Center(child: Text("No chapters found for ${_selectedBook?.fullName ?? 'this book'}."));
        return GridView.builder(padding: const EdgeInsets.all(8.0), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 8.0, mainAxisSpacing: 8.0,), itemCount: _chapters.length, itemBuilder: (context, index) { final chapterNum = _chapters[index]; return InkWell(onTap: () => _loadVerses(chapterNum), child: Card(child: Center(child: Text(chapterNum, style: Theme.of(context).textTheme.titleMedium),),),); },);

      case BibleReaderView.verses:
        // --- Verse List Builder with Favorites/Flags ---
        if (_verses.isEmpty) return const Center(child: Text("No verses found for this chapter."));
        return ListView.builder(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 80.0), // Add bottom padding
          itemCount: _verses.length,
          itemBuilder: (context, index) {
            final verse = _verses[index];
            final bool isFavorite = _favoritedVerseIdsInChapter.contains(verse.verseID);
            final List<String> flagNames = _getFlagNamesForVerse(verse.verseID ?? "");

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0), // Increased spacing between verses
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row( // Main row for verse number, text, favorite button
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Verse Number
                      SizedBox(
                        width: 35, // Space for verse number
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2.0), // Align number better
                          child: Text(
                            '${verse.verseNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 14, height: 1.5),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5), // Space between number and text
                      // Verse Text (selectable)
                      Expanded(
                        child: SelectableText(
                          verse.text,
                          style: const TextStyle(fontSize: 17, height: 1.5, color: Colors.black87), // Slightly larger text
                        ),
                      ),
                      // Favorite Button
                      if (verse.verseID != null)
                        Padding( // Add padding around button
                          padding: const EdgeInsets.only(left: 8.0, top: 0),
                          child: IconButton(
                            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.redAccent : Colors.grey.shade400,), // Slightly lighter grey
                            iconSize: 22,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(), // Use minimum constraints
                            tooltip: isFavorite ? "Remove from Favorites" : "Add to Favorites",
                            onPressed: () => _toggleFavorite(verse),
                          ),
                        ),
                    ],
                  ),
                  // Display Flags and Add/Manage Button if favorited
                  if (isFavorite && verse.verseID != null)
                     Padding(
                       padding: const EdgeInsets.only(left: 40.0, top: 6.0), // Indent under verse text
                       child: Row(
                         crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                            Expanded(
                              child: flagNames.isEmpty
                                ? const SizedBox(height: 10) // Ensure space even if no flags, before button
                                : Wrap( // Display chips if flags exist
                                  spacing: 6.0, runSpacing: 4.0,
                                  children: flagNames.map((name) => Chip(
                                    label: Text(name, style: const TextStyle(fontSize: 11)), // Slightly larger chip text
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0), // More padding
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
                                  )).toList(),
                                ),
                            ),
                           // Add/Manage Flags Button
                           TextButton.icon(
                             icon: Icon(flagNames.isNotEmpty ? Icons.edit_note_outlined : Icons.label_outline, size: 18),
                             label: Text(flagNames.isNotEmpty ? "Manage Flags" : "Add Flags", style: const TextStyle(fontSize: 12)),
                             onPressed: () => _showFlagSelectionDialog(verse),
                             style: TextButton.styleFrom(padding: const EdgeInsets.only(left: 8.0), minimumSize: const Size(50, 20), visualDensity: VisualDensity.compact ),
                           ),
                         ],
                       ),
                    ),
                    // Add a subtle divider between verses
                    if (index < _verses.length - 1)
                       Padding(
                         padding: const EdgeInsets.only(left: 40.0, top: 8.0),
                         child: Divider(height: 1, thickness: 0.5, color: Colors.grey.shade300),
                       ),
                ],
              ),
            );
          },
        );
        // --- END MODIFIED Verse List Builder ---
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Scaffold and AppBar structure remains the same ---
     return Scaffold(
       appBar: AppBar(
         title: Text(_appBarTitle),
         leading: _currentView != BibleReaderView.books || Navigator.canPop(context)
           ? IconButton( icon: const Icon(Icons.arrow_back), onPressed: () { if (_currentView != BibleReaderView.books) { _goBack(); } else if (Navigator.canPop(context)){ Navigator.of(context).pop(); } }, )
           : null,
       ),
       body: _buildBody(),
     );
  }
}