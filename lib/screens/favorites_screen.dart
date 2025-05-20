// File: lib/screens/favorites_screen.dart
// Path: lib/screens/favorites_screen.dart
// Updated: Implemented onTap and onShareAsImage for FavoriteListItemCard.

import 'package:flutter/material.dart';
import 'package:wwjd_app/widgets/favorite_list_item_card.dart';
import '../helpers/database_helper.dart';
import '../models/models.dart'; 
import '../helpers/book_names.dart'; 
import '../helpers/prefs_helper.dart'; 
import '../dialogs/flag_selection_dialog.dart';
import 'full_bible_reader_screen.dart'; // <<< NEW IMPORT
import 'verse_image_generator_screen.dart'; // <<< NEW IMPORT

enum SortOption { recentDesc, recentAsc, bookOrder }

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isLoading = true;
  List<FavoriteVerse> _allFetchedFavorites = []; 
  List<FavoriteVerse> _displayFavorites = []; 
  List<Flag> _allAvailableFlags = []; 
  Map<String, String> _bookOrderMap = {}; 

  SortOption _currentSortOption = SortOption.recentDesc;
  int _selectedFilterFlagId = 0; 

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadAvailableFlagsAndBookOrder();
    await _loadFavoritesAndApplyState();
  }

  Future<void> _loadAvailableFlagsAndBookOrder() async {
    if (!mounted) return;
    bool flagsChanged = false; 
    try {
      final Set<int> hiddenIds = PrefsHelper.getHiddenFlagIds();
      final List<Flag> visiblePrebuiltFlags = prebuiltFlags
          .where((flag) => !hiddenIds.contains(flag.id))
          .toList();
      final userFlagMaps = await _dbHelper.getUserFlags();
      final userFlags = userFlagMaps.map((map) => Flag.fromUserDbMap(map)).toList();

      final newAvailableFlags = [...visiblePrebuiltFlags, ...userFlags];
      newAvailableFlags.sort((a, b) => a.name.compareTo(b.name));

      if (_allAvailableFlags.length != newAvailableFlags.length ||
          !listContentEquals(_allAvailableFlags, newAvailableFlags)) {
           _allAvailableFlags = newAvailableFlags;
           flagsChanged = true;
      }

      final newBookOrderMap = await _dbHelper.getBookAbbrToOrderMap();
      if (!mapEquals(_bookOrderMap, newBookOrderMap)) {
            _bookOrderMap = newBookOrderMap;
      }

    } catch (e) {
      print("Error loading available flags/book order: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error loading filter data: ${e.toString()}")));
      }
    } finally {
       if (mounted && flagsChanged) setState(() {});
    }
  }

  Future<void> _loadFavoritesAndApplyState() async {
    if (!mounted) return;
    setState(() { _isLoading = true; });

    try {
      List<Map<String, dynamic>> favMaps;
      if (_selectedFilterFlagId == 0) {
        favMaps = await _dbHelper.getFavoritedVerses();
      } else {
        favMaps = await _dbHelper.getFavoritedVersesFilteredByFlag(_selectedFilterFlagId);
      }

      List<FavoriteVerse> loadedFavorites = [];
      for (var favMap in favMaps) {
        String verseID = favMap[DatabaseHelper.favColVerseID];
        String bookAbbr = favMap[DatabaseHelper.favColBookAbbr];
        List<int> flagIds = await _dbHelper.getFlagIdsForFavorite(verseID);
        List<Flag> assignedFlags = flagIds.map((id) {
          return _allAvailableFlags.firstWhere(
            (flag) => flag.id == id,
            orElse: () => Flag(id: id, name: "Unknown Flag", isSelected: false) 
          );
        }).where((flag) => flag.name != "Unknown Flag").toList();
         assignedFlags.sort((a,b) => a.name.compareTo(b.name));
        String canonOrder = _bookOrderMap[bookAbbr] ?? 'zzz'; 

        loadedFavorites.add(FavoriteVerse.fromMapAndFlags(
            favMap: favMap, flags: assignedFlags, canonOrder: canonOrder));
      }

      _allFetchedFavorites = loadedFavorites; 
      _applySort(); 

    } catch (e) {
      print("Error loading favorites list: $e");
      _allFetchedFavorites = []; 
      _displayFavorites = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error loading favorites: ${e.toString()}")));
      }
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  void _applySort() {
    List<FavoriteVerse> sortedList = List.from(_allFetchedFavorites);
    switch (_currentSortOption) {
      case SortOption.recentAsc:
        sortedList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.bookOrder:
        sortedList.sort((a, b) {
          int bookCompare = a.bookCanonOrder.compareTo(b.bookCanonOrder);
          if (bookCompare != 0) return bookCompare;
          int chapterCompare = int.tryParse(a.chapter)?.compareTo(int.tryParse(b.chapter) ?? 0) ?? 0;
          if (chapterCompare != 0) return chapterCompare;
          return int.tryParse(a.verseNumber)?.compareTo(int.tryParse(b.verseNumber) ?? 0) ?? 0;
        });
        break;
      case SortOption.recentDesc:
      default: 
        sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    _displayFavorites = sortedList;
  }

  Future<void> _removeFavorite(String verseID) async {
     bool? confirm = await showDialog<bool>( context: context, builder: (context) => AlertDialog( title: const Text("Confirm Remove"), content: const Text("Remove from favorites?"), actions: [ TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Remove", style: TextStyle(color: Colors.red))), ], ) );
     if (confirm == true && mounted) {
         try {
             await _dbHelper.removeFavorite(verseID);
             setState(() {
                 _allFetchedFavorites.removeWhere((fav) => fav.verseID == verseID);
                 _displayFavorites.removeWhere((fav) => fav.verseID == verseID); 
             });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed from favorites."), duration: Duration(seconds: 2),));
         } catch (e) {
             print("Error removing favorite: $e");
             if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error removing favorite: $e")));
             }
         }
     }
  }

  void _openFlagManagerForFavorite(FavoriteVerse favorite) {
     if (!mounted) return;
     final String verseID = favorite.verseID;
     final String verseRef = favorite.getReference(getFullBookName);
     final List<int> currentSelection = favorite.assignedFlags.map((f) => f.id).toList();

     showDialog(
         context: context,
         builder: (_) => FlagSelectionDialog(
             verseRef: verseRef,
             initialSelectedFlagIds: currentSelection,
             allAvailableFlags: List<Flag>.from(_allAvailableFlags), 
             onHideFlag: (flagId) async {
                 await PrefsHelper.hideFlagId(flagId);
                 await _loadAvailableFlagsAndBookOrder(); 
                 if (mounted) setState(() { favorite.assignedFlags.removeWhere((f) => f.id == flagId); });
                 _loadFavoritesAndApplyState(); 
             },
             onDeleteFlag: (flagId) async {
                 await _dbHelper.deleteUserFlag(flagId);
                 await _loadAvailableFlagsAndBookOrder(); 
                 if (mounted) setState(() { favorite.assignedFlags.removeWhere((f) => f.id == flagId); });
                 _loadFavoritesAndApplyState(); 
             },
             onAddNewFlag: (newName) async {
                 int newId = await _dbHelper.addUserFlag(newName);
                 await _loadAvailableFlagsAndBookOrder(); 
                 try {
                    final newFlag = _allAvailableFlags.firstWhere((f) => f.id == newId);
                    return newFlag;
                 } catch (e) {
                    print("Error finding newly added flag $newId after loading: $e");
                    return null;
                 }
             },
             onSave: (finalSelectedIds) async {
                 List<int> initialIds = List<int>.from(currentSelection); Set<int> initialSet = initialIds.toSet(); Set<int> finalSet = finalSelectedIds.toSet();
                 for (int id in finalSet) { if (!initialSet.contains(id)) { await _dbHelper.assignFlagToFavorite(verseID, id); } }
                 for (int id in initialSet) { if (!finalSet.contains(id)) { await _dbHelper.removeFlagFromFavorite(verseID, id); } }
                 if (mounted) { setState(() { favorite.assignedFlags = _allAvailableFlags.where((f) => finalSet.contains(f.id)).toList(); favorite.assignedFlags.sort((a,b)=>a.name.compareTo(b.name)); }); }
             },
         ),
     );
  }

  // --- NEW: Navigate to FullBibleReaderScreen ---
  void _navigateToVerseInBible(FavoriteVerse favorite) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullBibleReaderScreen(
          targetBookAbbr: favorite.bookAbbr,
          targetChapter: favorite.chapter,
          targetVerseNumber: favorite.verseNumber,
        ),
      ),
    );
  }

  // --- NEW: Navigate to VerseImageGeneratorScreen ---
  void _shareFavoriteAsImage(FavoriteVerse favorite) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerseImageGeneratorScreen(
          initialVerseText: favorite.verseText,
          initialVerseReference: favorite.getReference(getFullBookName),
          initialBookAbbr: favorite.bookAbbr,
          initialChapter: favorite.chapter,
          initialVerseNum: favorite.verseNumber,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    String filterName = "All Flags";
    IconData filterIcon = Icons.filter_list; 
    if (_selectedFilterFlagId != 0) {
      final flag = _allAvailableFlags.firstWhere(
          (f) => f.id == _selectedFilterFlagId,
          orElse: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                 if (mounted && _selectedFilterFlagId != 0) { 
                    print("Resetting filter because flag ID $_selectedFilterFlagId not found.");
                    setState(() { _selectedFilterFlagId = 0; });
                    _loadFavoritesAndApplyState(); 
                 }
              });
              return Flag(id:0, name:"All Flags"); 
          }
      );
       filterName = flag.name;
       if (flag.id != 0) {
            filterIcon = Icons.filter_list_alt; 
       } else {
            filterName = "All Flags";
       }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
        actions: [ 
          Tooltip(
            message: "Filter by: $filterName",
            child: PopupMenuButton<int>( 
              icon: Icon(filterIcon), 
              initialValue: _selectedFilterFlagId, 
              onSelected: (int selectedId) { 
                if (_selectedFilterFlagId != selectedId) {
                  setState(() { 
                    _selectedFilterFlagId = selectedId;
                  });
                  _loadFavoritesAndApplyState();
                }
              },
              itemBuilder: (BuildContext context) {
                List<PopupMenuEntry<int>> items = [];
                items.add(
                  PopupMenuItem<int>(
                    value: 0, 
                    child: Text(
                      "All Flags",
                      style: TextStyle(
                        fontWeight: _selectedFilterFlagId == 0 ? FontWeight.bold : FontWeight.normal
                      )
                    ),
                  )
                );
                items.add(const PopupMenuDivider()); 
                if (_allAvailableFlags.isEmpty) {
                   items.add(const PopupMenuItem<int>(enabled: false, child: Text("No flags available")));
                } else {
                  for (final flag in _allAvailableFlags) {
                    items.add(
                      PopupMenuItem<int>(
                        value: flag.id, 
                        child: Text(
                          flag.name,
                          style: TextStyle(
                            fontWeight: _selectedFilterFlagId == flag.id ? FontWeight.bold : FontWeight.normal
                          )
                        ),
                      )
                    );
                  }
                }
                return items; 
              }, 
            ), 
          ), 
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: "Sort Favorites",
            initialValue: _currentSortOption,
            onSelected: (SortOption selectedOption) {
              if (_currentSortOption != selectedOption) {
                setState(() {
                  _currentSortOption = selectedOption;
                  _applySort(); 
                });
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              PopupMenuItem<SortOption>( value: SortOption.recentDesc, child: Text('Sort by Recent (Newest First)', style: TextStyle(fontWeight: _currentSortOption == SortOption.recentDesc ? FontWeight.bold : FontWeight.normal)),),
              PopupMenuItem<SortOption>( value: SortOption.recentAsc, child: Text('Sort by Recent (Oldest First)', style: TextStyle(fontWeight: _currentSortOption == SortOption.recentAsc ? FontWeight.bold : FontWeight.normal)),),
              PopupMenuItem<SortOption>( value: SortOption.bookOrder, child: Text('Sort by Book Order', style: TextStyle(fontWeight: _currentSortOption == SortOption.bookOrder ? FontWeight.bold : FontWeight.normal)),),
            ],
          ), 
        ], 
      ), 
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allFetchedFavorites.isEmpty && _selectedFilterFlagId == 0
              ? const Center( child: Padding( padding: EdgeInsets.all(20.0), child: Text( "You haven't favorited any verses yet.\nTap the heart icon next to a verse!", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey), ), ), )
              : _displayFavorites.isEmpty
                  ? Center( child: Padding( padding: EdgeInsets.all(20.0), child: Text( "No favorites found with the flag '$filterName'.", textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey), ), ), )
                  : RefreshIndicator(
                      onRefresh: _loadInitialData, 
                      child: ListView.builder(
                        itemCount: _displayFavorites.length, 
                        itemBuilder: (context, index) {
                          final favorite = _displayFavorites[index];
                          return FavoriteListItemCard(
                            favoriteVerse: favorite,
                            getFullBookName: getFullBookName,
                            onRemove: () => _removeFavorite(favorite.verseID),
                            onManageFlags: () => _openFlagManagerForFavorite(favorite),
                            onTap: () => _navigateToVerseInBible(favorite), // <<< NEW
                            onShareAsImage: () => _shareFavoriteAsImage(favorite), // <<< NEW
                          );
                        }, 
                      ), 
                    ), 
    ); 
  } 

  bool listContentEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) { if (a[i] != b[i]) return false; }
    return true;
  }
  bool mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final K key in a.keys) { if (!b.containsKey(key) || a[key] != b[key]) { return false; } }
    return true;
  }

} 
