// lib/favorites_screen.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models.dart'; // Includes FavoriteVerse, Flag, Book
import 'book_names.dart'; // For getFullBookName
import 'prefs_helper.dart'; // Needed for filtering hidden flags
import 'dialogs/flag_selection_dialog.dart'; // Import the refactored dialog

// Enum for Sort Options
enum SortOption { recentDesc, recentAsc, bookOrder }

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // State Variables
  bool _isLoading = true;
  List<FavoriteVerse> _allFetchedFavorites = []; // Holds data from DB (potentially filtered)
  List<FavoriteVerse> _displayFavorites = []; // Holds data after sorting
  List<Flag> _allAvailableFlags = []; // Pre-built (filtered) + User flags
  Map<String, String> _bookOrderMap = {}; // Book Abbr -> Canon Order

  // Sorting and Filtering State
  SortOption _currentSortOption = SortOption.recentDesc;
  int _selectedFilterFlagId = 0; // Use 0 for "All Flags"

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Load flags and book order map first, as they are needed for processing favorites
    await _loadAvailableFlagsAndBookOrder();
    // Then load favorites based on the initial filter state (0 = all)
    await _loadFavoritesAndApplyState();
  }

  // Load available flags (filtering hidden) and book order map
  Future<void> _loadAvailableFlagsAndBookOrder() async {
    if (!mounted) return;
    bool flagsChanged = false; // Track if flag list changed for setState
    try {
      final Set<int> hiddenIds = PrefsHelper.getHiddenFlagIds();
      final List<Flag> visiblePrebuiltFlags = prebuiltFlags
          .where((flag) => !hiddenIds.contains(flag.id))
          .toList();
      final userFlagMaps = await _dbHelper.getUserFlags();
      final userFlags = userFlagMaps.map((map) => Flag.fromUserDbMap(map)).toList();

      final newAvailableFlags = [...visiblePrebuiltFlags, ...userFlags];
      newAvailableFlags.sort((a, b) => a.name.compareTo(b.name));

      // Check if the list actually changed before calling setState
      if (_allAvailableFlags.length != newAvailableFlags.length ||
          !listContentEquals(_allAvailableFlags, newAvailableFlags)) {
           _allAvailableFlags = newAvailableFlags;
           flagsChanged = true;
      }

      final newBookOrderMap = await _dbHelper.getBookAbbrToOrderMap();
      // Check if map changed before potentially causing rebuild
      if (!mapEquals(_bookOrderMap, newBookOrderMap)) {
            _bookOrderMap = newBookOrderMap;
            // This map change doesn't directly require setState unless UI depends on it immediately
      }

    } catch (e) {
      print("Error loading available flags/book order: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error loading filter data: ${e.toString()}")));
      }
    } finally {
       // Only call setState if the flag list actually changed to avoid unnecessary rebuilds
       if (mounted && flagsChanged) setState(() {});
    }
  }

  // Load favorites (potentially filtered) and apply sort
  Future<void> _loadFavoritesAndApplyState() async {
    if (!mounted) return;
    setState(() { _isLoading = true; });

    try {
      List<Map<String, dynamic>> favMaps;
      // Fetch based on filter (checking for 0 sentinel value)
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
        // Map flag IDs to actual Flag objects from our available list
        List<Flag> assignedFlags = flagIds.map((id) {
          return _allAvailableFlags.firstWhere(
            (flag) => flag.id == id,
            orElse: () => Flag(id: id, name: "Unknown Flag", isSelected: false) // Fallback
          );
        }).where((flag) => flag.name != "Unknown Flag").toList();
         assignedFlags.sort((a,b) => a.name.compareTo(b.name));

        // Get canon order for sorting
        String canonOrder = _bookOrderMap[bookAbbr] ?? 'zzz'; // Fallback for sorting puts unknown books last

        loadedFavorites.add(FavoriteVerse.fromMapAndFlags(
            favMap: favMap, flags: assignedFlags, canonOrder: canonOrder));
      }

      _allFetchedFavorites = loadedFavorites; // Store fetched (filtered) data
      _applySort(); // Apply current sort order to populate _displayFavorites

    } catch (e) {
      print("Error loading favorites list: $e");
      _allFetchedFavorites = []; // Clear lists on error
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

  // Apply sorting to the _allFetchedFavorites list
  void _applySort() {
    // Create a mutable copy to sort
    List<FavoriteVerse> sortedList = List.from(_allFetchedFavorites);

    switch (_currentSortOption) {
      case SortOption.recentAsc:
        sortedList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.bookOrder:
        sortedList.sort((a, b) {
          // Compare based on canon_order string first
          int bookCompare = a.bookCanonOrder.compareTo(b.bookCanonOrder);
          if (bookCompare != 0) return bookCompare;
          // Then by chapter number (parsing to int)
          int chapterCompare = int.tryParse(a.chapter)?.compareTo(int.tryParse(b.chapter) ?? 0) ?? 0;
          if (chapterCompare != 0) return chapterCompare;
          // Then by verse number (parsing to int)
          return int.tryParse(a.verseNumber)?.compareTo(int.tryParse(b.verseNumber) ?? 0) ?? 0;
        });
        break;
      case SortOption.recentDesc:
      default: // Default is recentDesc
        sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    // Update the list that the ListView builder uses
    _displayFavorites = sortedList;
  }

  // --- Remove Favorite Logic ---
  Future<void> _removeFavorite(String verseID) async {
     bool? confirm = await showDialog<bool>( context: context, builder: (context) => AlertDialog( title: const Text("Confirm Remove"), content: const Text("Remove from favorites?"), actions: [ TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Remove", style: TextStyle(color: Colors.red))), ], ) );

     if (confirm == true && mounted) {
         try {
             await _dbHelper.removeFavorite(verseID);
             // Refresh the list visually by removing from both lists
             setState(() {
                 _allFetchedFavorites.removeWhere((fav) => fav.verseID == verseID);
                 _displayFavorites.removeWhere((fav) => fav.verseID == verseID); // Update displayed list too
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


  // --- Method to call the refactored flag dialog ---
  void _openFlagManagerForFavorite(FavoriteVerse favorite) {
     if (!mounted) return;
     final String verseID = favorite.verseID;
     final String verseRef = favorite.getReference(getFullBookName);
     // Pass the current assigned flags for this favorite
     final List<int> currentSelection = favorite.assignedFlags.map((f) => f.id).toList();

     showDialog(
         context: context,
         builder: (_) => FlagSelectionDialog(
             verseRef: verseRef,
             initialSelectedFlagIds: currentSelection,
             allAvailableFlags: List<Flag>.from(_allAvailableFlags), // Pass available flags
             // Implement callbacks:
             onHideFlag: (flagId) async {
                 await PrefsHelper.hideFlagId(flagId);
                 await _loadAvailableFlagsAndBookOrder(); // Refresh available flags list
                 // Update local state for this favorite
                 if (mounted) setState(() { favorite.assignedFlags.removeWhere((f) => f.id == flagId); });
                 // Reload main list to remove flag from other favorites shown
                 _loadFavoritesAndApplyState(); // Reload ensures consistency
             },
             onDeleteFlag: (flagId) async {
                 await _dbHelper.deleteUserFlag(flagId);
                 await _loadAvailableFlagsAndBookOrder(); // Refresh available flags list
                  // Update local state for this favorite
                 if (mounted) setState(() { favorite.assignedFlags.removeWhere((f) => f.id == flagId); });
                 // Reload main list to remove flag from other favorites shown
                 _loadFavoritesAndApplyState(); // Reload ensures consistency
             },
            // --- CORRECTED onAddNewFlag Callback ---
             onAddNewFlag: (newName) async {
                 int newId = await _dbHelper.addUserFlag(newName);
                 await _loadAvailableFlagsAndBookOrder(); // Refresh main list
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
                 if (mounted) { setState(() { favorite.assignedFlags = _allAvailableFlags.where((f) => finalSet.contains(f.id)).toList(); favorite.assignedFlags.sort((a,b)=>a.name.compareTo(b.name)); }); }
             },
         ),
     );
  }

  // Add New Flag Dialog (needed by the flag selection dialog callback)
   Future<String?> _showAddNewFlagDialog() async {
     TextEditingController flagController = TextEditingController();
     return showDialog<String>(
         context: context,
         builder: (context) {
           return AlertDialog(
             title: const Text("Add New Flag"),
             content: TextField(
               controller: flagController,
               autofocus: true,
               decoration: const InputDecoration(hintText: "Flag name"),
               textCapitalization: TextCapitalization.sentences,
             ),
             actions: [
               TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
               TextButton(
                   onPressed: () {
                     if (flagController.text.trim().isNotEmpty) {
                       Navigator.pop(context, flagController.text.trim());
                     }
                   },
                   child: const Text("Add")),
             ],
           );
         });
   }


  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    // Determine current filter name and icon for display
    String filterName = "All Flags";
    IconData filterIcon = Icons.filter_list;
    // Check against 0 now
    if (_selectedFilterFlagId != 0) {
      final flag = _allAvailableFlags.firstWhere(
          (f) => f.id == _selectedFilterFlagId,
          orElse: () {
              // Reset if flag not found (e.g., hidden/deleted while selected)
              if (_selectedFilterFlagId != 0) { // Check if a filter was actually active
                 WidgetsBinding.instance.addPostFrameCallback((_) {
                   if (mounted && _selectedFilterFlagId != 0) {
                      print("Resetting filter because flag ID $_selectedFilterFlagId not found.");
                      setState(() { _selectedFilterFlagId = 0; });
                      _loadFavoritesAndApplyState(); // Reload data
                   }
                 });
              }
              return Flag(id:0, name:"All Flags");
          }
      );
       filterName = flag.name;
       // Check if flag was actually found (ID is not 0)
       if (flag.id != 0) {
            filterIcon = Icons.filter_list_alt; // Use filled icon when filtered
       } else {
           // Reset name if orElse was triggered
            filterName = "All Flags";
       }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
        actions: [
          // --- Filter Button ---
          Tooltip(
            message: "Filter by: $filterName",
            child: PopupMenuButton<int>( // Use non-nullable int
              icon: Icon(filterIcon),
              initialValue: _selectedFilterFlagId,
              onSelected: (int selectedId) { // Receive non-nullable int
                print("[Filter Popup] Selected ID: $selectedId (Current State: $_selectedFilterFlagId)");
                if (_selectedFilterFlagId != selectedId) {
                  setState(() { _selectedFilterFlagId = selectedId; });
                  _loadFavoritesAndApplyState(); // Reload data with new filter
                }
              },
              itemBuilder: (BuildContext context) {
                List<PopupMenuEntry<int>> items = []; // Use non-nullable int

                // Add "All Flags" option
                items.add(
                  PopupMenuItem<int>(
                    value: 0, // Value is 0
                    child: Text(
                      "All Flags",
                      style: TextStyle(fontWeight: _selectedFilterFlagId == 0 ? FontWeight.bold : FontWeight.normal)
                    ),
                  )
                );
                items.add(const PopupMenuDivider());

                // Add available flags
                if (_allAvailableFlags.isEmpty) {
                   items.add(const PopupMenuItem<int>(enabled: false, child: Text("No flags available")));
                }
                for (final flag in _allAvailableFlags) {
                  items.add(
                    PopupMenuItem<int>(
                      value: flag.id,
                      child: Text(
                        flag.name,
                        style: TextStyle(fontWeight: _selectedFilterFlagId == flag.id ? FontWeight.bold : FontWeight.normal)
                      ),
                    )
                  );
                }
                return items;
              },
            ),
          ), // End Filter Button

          // --- Sort Button ---
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: "Sort Favorites",
            initialValue: _currentSortOption,
            onSelected: (SortOption selectedOption) {
              if (_currentSortOption != selectedOption) {
                setState(() {
                  _currentSortOption = selectedOption;
                  _applySort(); // Re-sort the currently displayed data
                });
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              PopupMenuItem<SortOption>( value: SortOption.recentDesc, child: Text('Sort by Recent (Newest First)', style: TextStyle(fontWeight: _currentSortOption == SortOption.recentDesc ? FontWeight.bold : FontWeight.normal)),),
              PopupMenuItem<SortOption>( value: SortOption.recentAsc, child: Text('Sort by Recent (Oldest First)', style: TextStyle(fontWeight: _currentSortOption == SortOption.recentAsc ? FontWeight.bold : FontWeight.normal)),),
              PopupMenuItem<SortOption>( value: SortOption.bookOrder, child: Text('Sort by Book Order', style: TextStyle(fontWeight: _currentSortOption == SortOption.bookOrder ? FontWeight.bold : FontWeight.normal)),),
            ],
          ), // End Sort Button
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          // Check original fetched list for the initial empty message when NO filter is applied
          : _allFetchedFavorites.isEmpty && _selectedFilterFlagId == 0
              ? const Center( child: Padding( padding: EdgeInsets.all(20.0), child: Text( "You haven't favorited any verses yet.\nTap the heart icon next to a verse!", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey), ), ), )
              // Use _displayFavorites for the list, check if it's empty *after* potential filtering
              : _displayFavorites.isEmpty
                  ? Center( child: Padding( padding: EdgeInsets.all(20.0), child: Text( "No favorites found with the flag '$filterName'.", textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey), ), ), )
                  // Display the list
                  : RefreshIndicator(
                      onRefresh: _loadInitialData, // Allow pull-to-refresh
                      child: ListView.builder(
                        itemCount: _displayFavorites.length, // Use the sorted/filtered list
                        itemBuilder: (context, index) {
                          final favorite = _displayFavorites[index];
                          final reference = favorite.getReference(getFullBookName);

                          // Build the Card for each favorite verse
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row( // Reference and Remove Button
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text( reference, style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 16,), ),
                                      ),
                                      IconButton( icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 22), padding: EdgeInsets.zero, constraints: const BoxConstraints(), tooltip: "Remove from Favorites", onPressed: () => _removeFavorite(favorite.verseID), ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SelectableText( favorite.verseText, style: const TextStyle(fontSize: 15, height: 1.4), ), // Verse Text
                                  const SizedBox(height: 10),
                                  Row( // Flags and Manage Button
                                    children: [
                                      Expanded(
                                        child: favorite.assignedFlags.isEmpty
                                          ? const SizedBox(height: 30) // Placeholder height
                                          : Wrap( spacing: 6.0, runSpacing: 4.0, children: favorite.assignedFlags.map((flag) => Chip( label: Text(flag.name, style: const TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7), )).toList(), ),
                                      ),
                                      TextButton.icon(
                                        icon: Icon(favorite.assignedFlags.isNotEmpty ? Icons.edit_note_outlined : Icons.label_outline, size: 18),
                                        label: Text(favorite.assignedFlags.isNotEmpty ? "Manage Flags" : "Add Flags", style: const TextStyle(fontSize: 12)),
                                        onPressed: () => _openFlagManagerForFavorite(favorite), // Use the refactored dialog caller
                                        style: TextButton.styleFrom(padding: const EdgeInsets.only(left: 8.0), minimumSize: const Size(50, 20), visualDensity: VisualDensity.compact ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ); // End Card
                        }, // End itemBuilder
                      ), // End ListView.builder
                    ), // End RefreshIndicator
    ); // End Scaffold
  } // End build method


  // Helper functions for comparing lists/maps (optional, can remove if not used elsewhere)
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

} // End _FavoritesScreenState