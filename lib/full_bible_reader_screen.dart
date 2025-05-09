// lib/full_bible_reader_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'database_helper.dart';
import 'models.dart';
import 'book_names.dart';
import 'prefs_helper.dart';
import 'dialogs/flag_selection_dialog.dart';
import 'widgets/verse_list_item.dart';
import 'widgets/verse_actions_bottom_sheet.dart';
// Assuming reader_settings_enums.dart is in lib/models/
import 'models/reader_settings_enums.dart';

enum BibleReaderView { books, chapters, verses }

class FullBibleReaderScreen extends StatefulWidget {
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
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  BibleReaderView _currentView = BibleReaderView.books;
  bool _isLoading = true;
  String _appBarTitle = "Select a Book";

  List<Book> _books = [];
  List<String> _chapters = []; // List of chapter numbers for the selected book
  List<Verse> _verses = [];
  Book? _selectedBook;
  String? _selectedChapter; // The current chapter string (e.g., "1", "12")
  int _currentChapterIndex = -1; // Index of _selectedChapter within _chapters list

  List<Flag> _allAvailableFlags = [];
  Set<String> _favoritedVerseIdsInChapter = {};
  Map<String, List<int>> _flagAssignmentsForChapter = {};

  bool _initialScrollDone = false;
  String? _verseToHighlight;
  Timer? _highlightTimer;

  // --- NEW Reader Settings State ---
  double _fontSizeDelta = 0.0;
  ReaderFontFamily _selectedFontFamily = ReaderFontFamily.systemDefault;
  ReaderThemeMode _selectedReaderTheme = ReaderThemeMode.light;

  // Base font sizes (can be adjusted)
  static const double _baseVerseFontSize = 18.0;
  static const double _baseVerseNumberFontSize = 12.0;

  @override
  void initState() {
    super.initState();
    _loadReaderPreferencesAndInitialData();
  }

  Future<void> _loadReaderPreferencesAndInitialData() async {
    await _loadReaderPreferences(); // Load settings first
    await _loadInitialData();     // Then load Bible data
  }

  Future<void> _loadReaderPreferences() async {
    if (!mounted) return;
    setState(() {
      _fontSizeDelta = PrefsHelper.getReaderFontSizeDelta();
      _selectedFontFamily = PrefsHelper.getReaderFontFamily();
      _selectedReaderTheme = PrefsHelper.getReaderThemeMode();
    });
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadAvailableFlags();
    if (widget.targetBookAbbr != null && widget.targetChapter != null && widget.targetVerseNumber != null) {
      Book? targetBook = await _findBookByAbbr(widget.targetBookAbbr!);
      if (targetBook != null) {
        // Temporarily set to fetch chapters to correctly set _currentChapterIndex
        await _loadData(book: targetBook, chapter: null, initialChapterTarget: widget.targetChapter!);

        // Now properly load verses for the target
        setState(() {
          _selectedBook = targetBook;
          _selectedChapter = widget.targetChapter!;
          _currentView = BibleReaderView.verses;
          _appBarTitle = "${_selectedBook!.fullName} ${_selectedChapter!}";
          _isLoading = true;
        });
        await _loadData(book: _selectedBook, chapter: _selectedChapter); // This will trigger scroll and highlight
      } else {
        _loadBooks();
      }
    } else {
      _loadBooks();
    }
  }
  
  Future<Book?> _findBookByAbbr(String abbr) async {
    if (_books.isEmpty) {
      final List<Map<String, dynamic>> bookMaps = await _dbHelper.getBookAbbreviations();
       _books = bookMaps.map((map) {
            String bAbbr = map[DatabaseHelper.bibleColBook] as String;
            String order = map['c_order'] as String? ?? 'zzz';
            return Book(abbreviation: bAbbr, fullName: getFullBookName(bAbbr), canonOrder: order);
          }).toList();
    }
    try {
      return _books.firstWhere((b) => b.abbreviation == abbr);
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadAvailableFlags() async {
     if (!mounted) return;
     try {
        final Set<int> hiddenIds = PrefsHelper.getHiddenFlagIds();
        final List<Flag> visiblePrebuiltFlags = prebuiltFlags.where((flag) => !hiddenIds.contains(flag.id)).toList();
        final userFlagMaps = await _dbHelper.getUserFlags();
        final userFlags = userFlagMaps.map((map) => Flag.fromUserDbMap(map)).toList();
        _allAvailableFlags = [...visiblePrebuiltFlags, ...userFlags];
        _allAvailableFlags.sort((a, b) => a.name.compareTo(b.name));
     } catch (e) {
        print("Error loading available flags in reader: $e");
     }
  }

  Future<void> _loadData({Book? book, String? chapter, String? initialChapterTarget}) async {
    if (!mounted) return;
    bool enteringVerseView = (chapter != null && _currentView != BibleReaderView.verses);
    setState(() {
       _isLoading = true;
       if(enteringVerseView) {
         _initialScrollDone = false;
         _verseToHighlight = null;
         _highlightTimer?.cancel();
       }
    });

    try {
      if (book == null) {
        final List<Map<String, dynamic>> bookMaps = await _dbHelper.getBookAbbreviations();
        _books = bookMaps.map((map) {
            String abbr = map[DatabaseHelper.bibleColBook] as String;
            String order = map['c_order'] as String? ?? 'zzz';
            return Book(abbreviation: abbr, fullName: getFullBookName(abbr), canonOrder: order);
          }).toList();
        _currentView = BibleReaderView.books; _appBarTitle = "Select a Book"; _selectedBook = null; _selectedChapter = null; _chapters = []; _verses = []; _favoritedVerseIdsInChapter = {}; _flagAssignmentsForChapter = {}; _currentChapterIndex = -1;
      } else if (chapter == null) {
        _chapters = await _dbHelper.getChaptersForBook(book.abbreviation);
        _selectedBook = book; 
        _currentView = BibleReaderView.chapters; 
        _appBarTitle = book.fullName; 
        _selectedChapter = null; 
        _verses = []; 
        _favoritedVerseIdsInChapter = {}; 
        _flagAssignmentsForChapter = {};
        _currentChapterIndex = (initialChapterTarget != null) ? _chapters.indexOf(initialChapterTarget) : -1;

      } else {
        final List<Map<String, dynamic>> verseMaps = await _dbHelper.getVersesForChapter(book.abbreviation, chapter);
        _verses = verseMaps.map((map) => Verse( verseID: map[DatabaseHelper.bibleColVerseID] as String?, bookAbbr: map[DatabaseHelper.bibleColBook] as String?, chapter: map[DatabaseHelper.bibleColChapter]?.toString(), verseNumber: map[DatabaseHelper.bibleColStartVerse].toString(), text: map[DatabaseHelper.bibleColVerseText] as String,)).toList();
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
        _selectedBook = book;
        _selectedChapter = chapter;
        _currentView = BibleReaderView.verses;
        _appBarTitle = "${book.fullName} $chapter";
        // Ensure _chapters is populated if we landed here directly
        if (_chapters.isEmpty || _chapters.first.split(' ').first != book.abbreviation) { // Crude check, assumes chapters are loaded for selectedBook
            _chapters = await _dbHelper.getChaptersForBook(book.abbreviation);
        }
        _currentChapterIndex = _chapters.indexOf(chapter);


        bool shouldScrollAndHighlight = widget.targetBookAbbr == book.abbreviation &&
                            widget.targetChapter == chapter &&
                            widget.targetVerseNumber != null &&
                            !_initialScrollDone;

        if (shouldScrollAndHighlight) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
             if (mounted) {
               _scrollToTargetVerse(widget.targetVerseNumber);
             }
           });
        }
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

  void _scrollToTargetVerse(String? targetVerseNumToScroll) {
    if (targetVerseNumToScroll == null || _verses.isEmpty || !_itemScrollController.isAttached) {
      if (targetVerseNumToScroll != null) {
          setState(() { _initialScrollDone = true; });
      }
      return;
    }
    final index = _verses.indexWhere((v) => v.verseNumber == targetVerseNumToScroll);
    if (index != -1) {
      setState(() {
        _initialScrollDone = true;
        _verseToHighlight = targetVerseNumToScroll;
        _highlightTimer?.cancel();
        _highlightTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() { _verseToHighlight = null; });
          }
        });
      });
      _itemScrollController.scrollTo(index: index, duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic, alignment: 0.1);
    } else {
         setState(() { _initialScrollDone = true; });
    }
  }

  void _loadBooks() { _loadData(); }
  void _loadChapters(Book book) { _loadData(book: book); }
  void _loadVerses(String chapter) { if (_selectedBook != null) { _loadData(book: _selectedBook!, chapter: chapter); } }

  void _goBack() {
    if (!mounted) return;
    if (_currentView == BibleReaderView.verses) {
      if (_selectedBook != null) {
         _loadChapters(_selectedBook!);
      } else {
         _goBackToBooks();
      }
    } else if (_currentView == BibleReaderView.chapters) {
      _goBackToBooks();
    }
  }
  void _goBackToBooks() { if (!mounted) return; _loadBooks(); }

  Future<void> _toggleFavorite(Verse verse) async {
    if (verse.verseID == null || verse.bookAbbr == null || verse.chapter == null) return;
    String verseID = verse.verseID!;
    bool isCurrentlyFavorite = _favoritedVerseIdsInChapter.contains(verseID);
    bool newFavoriteState = !isCurrentlyFavorite;
    try {
      if (newFavoriteState) {
        Map<String, dynamic> favData = { DatabaseHelper.bibleColVerseID: verseID, DatabaseHelper.bibleColBook: verse.bookAbbr, DatabaseHelper.bibleColChapter: verse.chapter, DatabaseHelper.bibleColStartVerse: verse.verseNumber, DatabaseHelper.bibleColVerseText: verse.text, };
        await _dbHelper.addFavorite(favData);
        List<int> currentFlagIds = await _dbHelper.getFlagIdsForFavorite(verseID);
        if (mounted) setState(() { _favoritedVerseIdsInChapter.add(verseID); _flagAssignmentsForChapter[verseID] = currentFlagIds; });
      } else {
        await _dbHelper.removeFavorite(verseID);
        if (mounted) setState(() { _favoritedVerseIdsInChapter.remove(verseID); _flagAssignmentsForChapter.remove(verseID); });
      }
    } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating favorite: ${e.toString()}")));
    }
  }

  void _openFlagManagerForVerse(Verse verse) {
     if (verse.verseID == null || !mounted) return;
     final String verseID = verse.verseID!;
     final String verseRef = "${getFullBookName(verse.bookAbbr ?? '?')} ${verse.chapter ?? '?'}:${verse.verseNumber}";
     final List<int> currentSelection = _flagAssignmentsForChapter[verseID] ?? [];
     showDialog( context: context, builder: (_) => FlagSelectionDialog( verseRef: verseRef, initialSelectedFlagIds: currentSelection, allAvailableFlags: List<Flag>.from(_allAvailableFlags),
             onHideFlag: (flagId) async { await PrefsHelper.hideFlagId(flagId); await _loadAvailableFlags(); if(mounted) setState(() { _flagAssignmentsForChapter[verseID]?.remove(flagId); }); },
             onDeleteFlag: (flagId) async { await _dbHelper.deleteUserFlag(flagId); await _loadAvailableFlags(); if(mounted) setState(() { _flagAssignmentsForChapter[verseID]?.remove(flagId); }); },
             onAddNewFlag: (newName) async { int newId = await _dbHelper.addUserFlag(newName); await _loadAvailableFlags(); try { return _allAvailableFlags.firstWhere((f) => f.id == newId); } catch (e) { return null; } },
             onSave: (finalSelectedIds) async { List<int> initialIds = List<int>.from(currentSelection); Set<int> initialSet = initialIds.toSet(); Set<int> finalSet = finalSelectedIds.toSet();
                 for (int id in finalSet) { if (!initialSet.contains(id)) { await _dbHelper.assignFlagToFavorite(verseID, id); } }
                 for (int id in initialSet) { if (!finalSet.contains(id)) { await _dbHelper.removeFlagFromFavorite(verseID, id); } }
                 if (mounted) { setState(() { _flagAssignmentsForChapter[verseID] = finalSelectedIds; }); }
             },),);
  }
  List<String> _getFlagNamesForVerse(String verseID) {
      List<int> flagIds = _flagAssignmentsForChapter[verseID] ?? [];
      List<String> names = [];
      for (int id in flagIds) {
          final flag = _allAvailableFlags.firstWhere((f) => f.id == id, orElse: () => Flag(id: 0, name: "Unknown"));
          if (flag.id != 0) { names.add(flag.name); }
      }
      names.sort(); return names;
  }

  // --- Reader Settings and Theme Logic ---
  TextStyle _getTextStyleForFontFamily(ReaderFontFamily family, double baseSize, FontWeight fontWeight) {
    double currentSize = baseSize + _fontSizeDelta;
    switch (family) {
      case ReaderFontFamily.serif:
        return GoogleFonts.notoSerif(fontSize: currentSize, fontWeight: fontWeight); // Example Serif
      case ReaderFontFamily.sansSerif:
        return GoogleFonts.roboto(fontSize: currentSize, fontWeight: fontWeight); // Example Sans-Serif
      case ReaderFontFamily.systemDefault:
      default:
        return TextStyle(fontSize: currentSize, fontWeight: fontWeight); // System default
    }
  }

  Color _getReaderBackgroundColor() {
    switch (_selectedReaderTheme) {
      case ReaderThemeMode.dark:
        return Colors.black87;
      case ReaderThemeMode.sepia:
        return const Color(0xFFFBF0D9);
      case ReaderThemeMode.light:
      default:
        return Colors.white;
    }
  }

  Color _getReaderTextColor() {
    switch (_selectedReaderTheme) {
      case ReaderThemeMode.dark:
        return Colors.grey.shade300;
      case ReaderThemeMode.sepia:
        return Colors.brown.shade800;
      case ReaderThemeMode.light:
      default:
        return Colors.black87;
    }
  }
  
  Color _getReaderVerseNumberColor() {
     switch (_selectedReaderTheme) {
      case ReaderThemeMode.dark:
        return Colors.tealAccent.shade100.withOpacity(0.8);
      case ReaderThemeMode.sepia:
        return Colors.brown.withOpacity(0.8);
      case ReaderThemeMode.light:
      default:
        return Theme.of(context).colorScheme.primary.withOpacity(0.8);
    }
  }
  Color _getReaderBottomAppBarColor(BuildContext context) {
    final bool isMaterial3 = Theme.of(context).useMaterial3;
    switch (_selectedReaderTheme) {
      case ReaderThemeMode.dark:
        return const Color(0xFF2D2D2D);
      case ReaderThemeMode.sepia:
        // A darker, muted color that complements sepia
        return isMaterial3 ? Color.lerp(const Color(0xFFFBF0D9), Colors.black, 0.3)! : Colors.brown.shade800; // Darker sepia tone
      case ReaderThemeMode.light:
      default:
        return isMaterial3 ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.9) : Colors.grey.shade200;
    }
  }

  Color _getReaderBottomAppBarIconColor(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);
    switch (_selectedReaderTheme) {
      case ReaderThemeMode.dark:
        return Colors.grey.shade400; // Light icons on dark bar
      case ReaderThemeMode.sepia:
        return const Color(0xFFFBF0D9).withOpacity(0.8); // Light icons on brownish bar
      case ReaderThemeMode.light:
      default:
        // Use a color that contrasts well with the light grey BottomAppBar
        return currentTheme.colorScheme.onSurfaceVariant;
    }
  }

  void _showReaderSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bContext) {
        // Use a StatefulWidget here to manage the local state of the bottom sheet controls
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter sheetSetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                child: Wrap( // Use Wrap for better layout with multiple sections
                  children: <Widget>[
                    Text("Reader Settings", style: Theme.of(context).textTheme.titleLarge),
                    const Divider(height: 20),

                    // Font Size
                    Text("Font Size", style: Theme.of(context).textTheme.titleMedium),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _fontSizeDelta > -4.0 ? () async { // Min delta
                            // Update sheet UI first
                            sheetSetState(() {
                              _fontSizeDelta -= 1.0;
                            });
                            // Then update main screen state
                            setState(() {
                              // _fontSizeDelta is already changed, this triggers reader rebuild
                            });
                            // Then save asynchronously
                            await PrefsHelper.setReaderFontSizeDelta(_fontSizeDelta);
                          } : null
                        ),
                        Text((_baseVerseFontSize + _fontSizeDelta).toStringAsFixed(0), style: Theme.of(context).textTheme.bodyLarge),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _fontSizeDelta < 6.0 ? () async { // Max delta
                            // Update sheet UI first
                            sheetSetState(() {
                              _fontSizeDelta += 1.0;
                            });
                            // Then update main screen state
                            setState(() {
                              // _fontSizeDelta is already changed, this triggers reader rebuild
                            });
                            // Then save asynchronously
                            await PrefsHelper.setReaderFontSizeDelta(_fontSizeDelta);
                          } : null
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Font Family
                    Text("Font Family", style: Theme.of(context).textTheme.titleMedium),
                    DropdownButtonFormField<ReaderFontFamily>(
                      value: _selectedFontFamily,
                      items: ReaderFontFamily.values.map((ReaderFontFamily family) {
                        return DropdownMenuItem<ReaderFontFamily>(
                          value: family,
                          child: Text(family.displayName, style: _getTextStyleForFontFamily(family, 16, FontWeight.normal)),
                        );
                      }).toList(),
                      onChanged: (ReaderFontFamily? newValue) async { // Make callback async
                        if (newValue != null) {
                          // Update sheet UI first
                          sheetSetState(() {
                            _selectedFontFamily = newValue;
                          });
                          // Then update main screen state
                          setState(() {
                            // _selectedFontFamily is already changed
                          });
                          // Then save asynchronously
                          await PrefsHelper.setReaderFontFamily(newValue);
                        }
                      },
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),

                    // Reader Theme
                    Text("Theme", style: Theme.of(context).textTheme.titleMedium),
                    DropdownButtonFormField<ReaderThemeMode>(
                      value: _selectedReaderTheme,
                      items: ReaderThemeMode.values.map((ReaderThemeMode themeMode) {
                        return DropdownMenuItem<ReaderThemeMode>(
                          value: themeMode,
                          child: Text(themeMode.displayName),
                        );
                      }).toList(),
                      onChanged: (ReaderThemeMode? newValue) async { // Make callback async
                        if (newValue != null) {
                          // Update sheet UI first
                          sheetSetState(() {
                            _selectedReaderTheme = newValue;
                          });
                          // Then update main screen state
                          setState(() {
                            // _selectedReaderTheme is already changed
                          });
                          // Then save asynchronously
                          await PrefsHelper.setReaderThemeMode(newValue);
                        }
                      },
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        child: const Text("Done"),
                        onPressed: () => Navigator.pop(bContext),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  // --- Chapter Navigation Methods ---
  void _goToPreviousChapter() {
    if (_selectedBook == null || _selectedChapter == null || _currentChapterIndex <= 0) {
      // At the first chapter of the book or book/chapter not selected
      if (_currentChapterIndex == 0 && _selectedBook != null) {
          int currentBookIndex = _books.indexWhere((b) => b.abbreviation == _selectedBook!.abbreviation);
          if (currentBookIndex > 0) {
            Book previousBook = _books[currentBookIndex - 1];
            // Load last chapter of previous book
            _dbHelper.getChaptersForBook(previousBook.abbreviation).then((prevBookChapters) {
                if (prevBookChapters.isNotEmpty) {
                    _loadData(book: previousBook, chapter: prevBookChapters.last);
                } else {
                    _loadChapters(previousBook); // If no chapters, just load the book view.
                }
            });
            return;
          }
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You are at the beginning."), duration: Duration(seconds: 1)));
      return;
    }
    String previousChapter = _chapters[_currentChapterIndex - 1];
    _loadVerses(previousChapter);
  }

  void _goToNextChapter() {
    if (_selectedBook == null || _selectedChapter == null || _currentChapterIndex < 0 || _currentChapterIndex >= _chapters.length - 1) {
      // At the last chapter of the book or book/chapter not selected
      if (_currentChapterIndex == _chapters.length - 1 && _selectedBook != null) {
          int currentBookIndex = _books.indexWhere((b) => b.abbreviation == _selectedBook!.abbreviation);
          if (currentBookIndex < _books.length - 1 && currentBookIndex != -1) {
              Book nextBook = _books[currentBookIndex + 1];
              // Load first chapter of next book
              _dbHelper.getChaptersForBook(nextBook.abbreviation).then((nextBookChapters) {
                  if (nextBookChapters.isNotEmpty) {
                      _loadData(book: nextBook, chapter: nextBookChapters.first);
                  } else {
                      _loadChapters(nextBook);
                  }
              });
              return;
          }
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You are at the end."), duration: Duration(seconds: 1)));
      return;
    }
    String nextChapter = _chapters[_currentChapterIndex + 1];
    _loadVerses(nextChapter);
  }


  Widget _buildBody() {
    if (_isLoading) { return const Center(child: CircularProgressIndicator()); }

    // Apply reader theme background to the main content area for verses
    Color readerBackgroundColor = _getReaderBackgroundColor();
    Color readerTextColor = _getReaderTextColor();
    Color readerVerseNumberColor = _getReaderVerseNumberColor();

    Color readerFavoriteIconColor = (_selectedReaderTheme == ReaderThemeMode.dark) ? Colors.grey.shade400 : Theme.of(context).colorScheme.outline;
    Color readerFlagManageButtonColor = (_selectedReaderTheme == ReaderThemeMode.dark) ? Colors.cyanAccent.shade200 : Theme.of(context).colorScheme.primary;
    Color readerFlagChipBgColor = (_selectedReaderTheme == ReaderThemeMode.dark) ? Colors.grey.shade700.withOpacity(0.6) : Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.6);
    Color readerFlagChipBorderColor = (_selectedReaderTheme == ReaderThemeMode.dark) ? Colors.grey.shade600 : Theme.of(context).colorScheme.secondaryContainer;
    Color readerDividerColor = (_selectedReaderTheme == ReaderThemeMode.dark) ? Colors.grey.shade700 : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5);
    Color? readerHighlightColor = (_selectedReaderTheme == ReaderThemeMode.dark) ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4);


    TextStyle currentVerseTextStyle = _getTextStyleForFontFamily(_selectedFontFamily, _baseVerseFontSize, FontWeight.normal).copyWith(color: readerTextColor, height: 1.6);
    TextStyle currentVerseNumberStyle = _getTextStyleForFontFamily(_selectedFontFamily, _baseVerseNumberFontSize, FontWeight.bold).copyWith(color: readerVerseNumberColor);
    TextStyle currentFlagChipStyle = _getTextStyleForFontFamily(_selectedFontFamily, 10.0, FontWeight.normal).copyWith(color: (_selectedReaderTheme == ReaderThemeMode.dark) ? Colors.grey.shade300 : Theme.of(context).colorScheme.onSecondaryContainer);


    switch (_currentView) {
      case BibleReaderView.books:
        // Book list remains themed by the main app theme
        if (_books.isEmpty) return const Center(child: Text("No books found."));
        return ListView.builder(
          itemCount: _books.length,
          itemBuilder: (context, index) {
            final book = _books[index];
            return ListTile(title: Text(book.fullName), onTap: () => _loadChapters(book));
          },
        );
      case BibleReaderView.chapters:
        // Chapter grid remains themed by the main app theme
        if (_chapters.isEmpty) return Center(child: Text("No chapters found for ${_selectedBook?.fullName ?? 'this book'}."));
        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 8.0, mainAxisSpacing: 8.0, childAspectRatio: 1.5),
          itemCount: _chapters.length,
          itemBuilder: (context, index) {
            final chapterNum = _chapters[index];
            return InkWell( onTap: () => _loadVerses(chapterNum), child: Card( elevation: 1.5, child: Center(child: Text(chapterNum, style: Theme.of(context).textTheme.titleMedium),),),);
          },
        );
      case BibleReaderView.verses:
        if (_verses.isEmpty) return const Center(child: Text("No verses found for this chapter."));
        // Apply reader theme background here
        return GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity == null) return;
            if (details.primaryVelocity! < -500) { // Swipe Left
              _goToNextChapter();
            } else if (details.primaryVelocity! > 500) { // Swipe Right
              _goToPreviousChapter();
            }
          },
          child: Container( // Container to apply background color for the reader
            color: readerBackgroundColor,
            child: ScrollablePositionedList.builder(
              itemScrollController: _itemScrollController,
              itemPositionsListener: _itemPositionsListener,
              itemCount: _verses.length,
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 80.0), // Keep padding for FAB/BottomBar
              itemBuilder: (context, index) {
                final verse = _verses[index];
                final bool isFavorite = _favoritedVerseIdsInChapter.contains(verse.verseID);
                final List<String> flagNames = _getFlagNamesForVerse(verse.verseID ?? "");
                final bool shouldHighlight = verse.verseNumber == _verseToHighlight;

                return VerseListItem(
                  verse: verse,
                  isFavorite: isFavorite,
                  assignedFlagNames: flagNames,
                  isHighlighted: shouldHighlight,
                  onToggleFavorite: () => _toggleFavorite(verse),
                  onManageFlags: () => _openFlagManagerForVerse(verse),
                  onVerseTap: () { /* ... verse actions bottom sheet ... */
                    final String bookName = getFullBookName(verse.bookAbbr ?? "Unknown Book");
                    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                      builder: (BuildContext bContext) {
                        return VerseActionsBottomSheet(verse: verse, isFavorite: isFavorite, assignedFlagNames: flagNames,
                          onToggleFavorite: () { _toggleFavorite(verse); },
                          onManageFlags: () { _openFlagManagerForVerse(verse); },
                          fullBookName: bookName,
                        );
                      },);
                  },
                  // Pass computed styles and colors
                  verseTextStyle: currentVerseTextStyle,
                  verseNumberStyle: currentVerseNumberStyle,
                  flagChipStyle: currentFlagChipStyle,
                  favoriteIconColor: readerFavoriteIconColor,
                  flagManageButtonColor: readerFlagManageButtonColor,
                  flagChipBackgroundColor: readerFlagChipBgColor,
                  flagChipBorderColor: readerFlagChipBorderColor,
                  dividerColor: readerDividerColor,
                  verseHighlightColor: readerHighlightColor,
                );
              },
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
     bool canGoPrev = _currentView == BibleReaderView.verses && _selectedBook != null && _currentChapterIndex > 0;
     bool canGoNext = _currentView == BibleReaderView.verses && _selectedBook != null && _chapters.isNotEmpty && _currentChapterIndex < _chapters.length - 1;

     int currentBookIdx = _selectedBook != null ? _books.indexWhere((b) => b.abbreviation == _selectedBook!.abbreviation) : -1;
     if (_currentView == BibleReaderView.verses) {
        if (_currentChapterIndex == 0 && currentBookIdx > 0) {
            canGoPrev = true;
        }
        if (_currentChapterIndex == _chapters.length -1 && currentBookIdx != -1 && currentBookIdx < _books.length -1) {
            canGoNext = true;
        }
     }

     Color bottomAppBarColor = _getReaderBottomAppBarColor(context);
     Color bottomAppBarIconColor = _getReaderBottomAppBarIconColor(context);
     TextStyle bottomAppBarTextStyle = Theme.of(context).textTheme.bodySmall!.copyWith(color: bottomAppBarIconColor.withOpacity(0.7));

     // Get the reader background color
     Color currentReaderBackgroundColor = _getReaderBackgroundColor();

     return Scaffold(
       // --- NEW: Apply dynamic background color to Scaffold ---
       backgroundColor: (_currentView == BibleReaderView.verses || (_isLoading && _currentView == BibleReaderView.chapters && _selectedChapter != null) )
                        ? currentReaderBackgroundColor // Apply reader theme if in verses view or loading into verses view
                        : Theme.of(context).scaffoldBackgroundColor, // Use default scaffold bg for book/chapter lists
       appBar: AppBar(
         title: Text(_appBarTitle),
         // Adapt AppBar color if needed based on reader theme, or keep it consistent with app theme
         // For simplicity, we'll let the main app theme control the AppBar for now.
         // If you want the AppBar to also change with the reader theme, you'd apply similar logic here.
         leading: _currentView != BibleReaderView.books || Navigator.canPop(context) || (widget.targetBookAbbr != null)
           ? IconButton( icon: const Icon(Icons.arrow_back), onPressed: () { if (_currentView != BibleReaderView.books) { _goBack(); } else if (Navigator.canPop(context)){ Navigator.of(context).pop(); } },)
           : null,
         actions: [
           if (_currentView == BibleReaderView.verses)
             IconButton(
               icon: const Icon(Icons.tune_rounded),
               tooltip: "Reader Settings",
               onPressed: _showReaderSettingsBottomSheet,
             ),
         ],
       ),
       body: _buildBody(), // _buildBody will also respect the theme for its direct background when showing verses
       bottomNavigationBar: _currentView == BibleReaderView.verses
        ? Container(
            decoration: BoxDecoration(
              color: bottomAppBarColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3.0,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SizedBox(
              height: 48.0,
              child: BottomAppBar(
                color: Colors.transparent,
                elevation: 0,
                padding: EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: bottomAppBarIconColor),
                      iconSize: 20.0,
                      tooltip: "Previous Chapter",
                      onPressed: canGoPrev ? _goToPreviousChapter : null,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    Flexible(
                      child: Text(
                        _selectedBook != null && _selectedChapter != null ? "${_selectedBook!.fullName} $_selectedChapter" : "",
                        style: bottomAppBarTextStyle,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios_rounded, color: bottomAppBarIconColor),
                      iconSize: 20.0,
                      tooltip: "Next Chapter",
                      onPressed: canGoNext ? _goToNextChapter : null,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ],
                ),
              ),
            ),
          )
        : null,
     );
  }
}