// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models.dart'; // Brings in Flag class and prebuiltFlags list
import 'book_names.dart'; // For getFullBookName
import 'full_bible_reader_screen.dart'; // To navigate to the Bible reader
import 'prefs_helper.dart'; // Import PrefsHelper for hidden flags

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
  List<int> _votdSelectedFlagIds = []; // Only IDs

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadAvailableFlags(); // Load flags considering hidden ones
    await _loadVerseOfTheDay(); // Then load VotD and its flags
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

        // 4. Combine and sort
        setState(() { // Update state so dialog uses the latest list
          _allAvailableFlags = [...visiblePrebuiltFlags, ...userFlags];
          _allAvailableFlags.sort((a, b) => a.name.compareTo(b.name)); // Sort alphabetically
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

  // Toggle favorite status ONLY
 Future<void> _toggleVotDFavorite() async {
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
        // Refresh assigned flags (might be empty initially)
        _votdSelectedFlagIds = await _dbHelper.getFlagIdsForFavorite(verseID);
      } else {
        await _dbHelper.removeFavorite(verseID);
        _votdSelectedFlagIds = []; // Clear flags when unfavorited
      }
      if (mounted) {
        setState(() {
          _isVotDFavorite = newFavoriteState;
          // _votdSelectedFlagIds is updated implicitly above or cleared
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

  // Show dialog to manage flags for the VotD
 Future<void> _showFlagSelectionDialog(String verseID) async {
    // Prepare flags for the dialog, marking current selections
    List<Flag> dialogFlags = _allAvailableFlags.map((f) {
      bool isSelected = _votdSelectedFlagIds.contains(f.id);
      // Create new instances for the dialog state
      return Flag(id: f.id, name: f.name, isSelected: isSelected); // isPrebuilt determined by f.id < 0
    }).toList();

    if (!mounted) return;

    return showDialog<void>(
      context: context,
      // barrierDismissible: false, // Optional: prevent closing by tapping outside
      builder: (BuildContext context) {
        return StatefulBuilder( // Use StatefulBuilder for dialog's own state
          builder: (context, setDialogState) {
            // Function to handle hiding pre-built or deleting user flags
            Future<void> handleDeleteOrHideFlag(Flag flagToDelete) async {
              bool? confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext confirmContext) {
                  return AlertDialog(
                    title: Text(flagToDelete.isPrebuilt ? "Confirm Hide" : "Confirm Delete"),
                    content: Text(flagToDelete.isPrebuilt
                        ? "Hide the default flag '${flagToDelete.name}'?\n\n(You can restore defaults later in settings)." // Mention settings possibility
                        : "Delete the flag '${flagToDelete.name}'?\n\nThis removes it permanently and from all favorites."),
                    actions: <Widget>[
                      TextButton(onPressed: () => Navigator.of(confirmContext).pop(false), child: const Text("Cancel")),
                      TextButton(
                        onPressed: () => Navigator.of(confirmContext).pop(true),
                        child: Text(flagToDelete.isPrebuilt ? "Hide" : "Delete", style: TextStyle(color: flagToDelete.isPrebuilt ? Colors.orange.shade800 : Colors.red)),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                  try {
                      if (flagToDelete.isPrebuilt) {
                          // Hide pre-built flag using PrefsHelper
                          await PrefsHelper.hideFlagId(flagToDelete.id);
                      } else {
                          // Delete user flag using DatabaseHelper
                          await _dbHelper.deleteUserFlag(flagToDelete.id);
                      }
                      // Refresh the combined list used by the main screen and dialog
                      await _loadAvailableFlags();
                      // Update the dialog's view immediately by filtering the local list
                      setDialogState(() {
                          dialogFlags.removeWhere((f) => f.id == flagToDelete.id);
                      });
                      // Also update the main screen's selected flags if the hidden/deleted one was selected
                      if (mounted) {
                        setState(() { _votdSelectedFlagIds.remove(flagToDelete.id); });
                      }
                  } catch (e) {
                      print("Error hiding/deleting flag: $e");
                      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating flags: $e")));
                  }
              }
            } // End handleDeleteOrHideFlag

            // Build the actual dialog content
            return AlertDialog(
              title: const Text('Manage Flags'),
              content: SizedBox(
                width: double.maxFinite, // Use available width
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Take minimum height
                  children: [
                    // Scrollable list of flags
                    Expanded( // Make list scrollable if content overflows
                      child: ListView(
                        shrinkWrap: true, // Make list fit content height initially
                        children: <Widget>[
                          if (dialogFlags.isEmpty) const Text("No flags available. Add one below!"),
                          ...dialogFlags.map((flag) {
                            return CheckboxListTile(
                              title: Text(flag.name),
                              value: flag.isSelected,
                              controlAffinity: ListTileControlAffinity.leading,
                              // Show delete/hide icon using secondary
                              secondary: IconButton(
                                      icon: Icon( flag.isPrebuilt ? Icons.visibility_off_outlined : Icons.delete_outline, color: flag.isPrebuilt ? Colors.grey : Colors.red.shade300),
                                      iconSize: 22,
                                      tooltip: flag.isPrebuilt ? "Hide default flag" : "Delete custom flag",
                                      onPressed: () => handleDeleteOrHideFlag(flag),
                                    ),
                              onChanged: (bool? value) {
                                setDialogState(() {
                                  flag.isSelected = value ?? false;
                                });
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    // Add New Flag Button
                    TextButton.icon(
                       icon: const Icon(Icons.add),
                       label: const Text("Add New Flag"),
                       onPressed: () async {
                         final newFlagName = await _showAddNewFlagDialog();
                         if (newFlagName != null && newFlagName.trim().isNotEmpty) {
                           try {
                             int newId = await _dbHelper.addUserFlag(newFlagName.trim());
                             await _loadAvailableFlags(); // Refresh main screen's list
                             // Rebuild dialog list state to include the new flag, marking it selected
                             final currentSelectedIds = dialogFlags.where((df) => df.isSelected).map((df) => df.id).toSet();
                             dialogFlags = _allAvailableFlags.map((f) {
                                 bool shouldBeSelected = currentSelectedIds.contains(f.id) || (newId > 0 && f.id == newId);
                                 return Flag(id: f.id, name: f.name, isSelected: shouldBeSelected);
                             }).toList();
                             setDialogState((){}); // Update dialog UI
                           } catch (e) {
                              print("Error adding new flag: $e");
                              if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error adding flag: $e")));
                           }
                         }
                       },
                     ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () { Navigator.of(context).pop(); },
                ),
                TextButton(
                  child: const Text('Save Flags'),
                  onPressed: () async {
                    // Save logic
                    try {
                      List<int> newlySelectedIds = [];
                      List<int> previouslySelectedIds = List.from(_votdSelectedFlagIds);

                      for (var flag in dialogFlags) {
                        bool wasSelected = previouslySelectedIds.contains(flag.id);
                        if (flag.isSelected) {
                          newlySelectedIds.add(flag.id);
                          if (!wasSelected) { // Only assign if newly selected
                             await _dbHelper.assignFlagToFavorite(verseID, flag.id);
                          }
                        } else {
                           if (wasSelected) { // Only remove if previously selected and now isn't
                              await _dbHelper.removeFlagFromFavorite(verseID, flag.id);
                           }
                        }
                      }

                      if (mounted) {
                        setState(() { _votdSelectedFlagIds = newlySelectedIds; }); // Update main screen state
                      }
                      Navigator.of(context).pop(); // Close dialog
                    } catch (e) {
                        print("Error saving flags: $e");
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving flags: $e")));
                    }
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  // Dialog to add a new custom flag
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

  // Helper to get flag names for display for the VotD
  List<String> _getVotDFlagNames() {
      List<int> flagIds = _votdSelectedFlagIds;
      List<String> names = [];
      for (int id in flagIds) {
          // Find in the combined list (_allAvailableFlags)
          final flag = _allAvailableFlags.firstWhere((f) => f.id == id, orElse: () => Flag(id: 0, name: "Unknown"));
          if (flag.id != 0) { names.add(flag.name); }
      }
      names.sort(); // Sort names alphabetically for display
      return names;
  }

  @override
  Widget build(BuildContext context) {
    // Extract VotD data safely
    String votdText = "Loading verse...";
    String votdRef = "";
    String currentVerseIdForVotD = "";
    if (!_isLoadingVotD && _verseOfTheDayData != null) {
      votdText = _verseOfTheDayData![DatabaseHelper.bibleColVerseText] ?? "Error: Text missing.";
      String bookAbbr = _verseOfTheDayData![DatabaseHelper.bibleColBook] ?? "??";
      String chapter = _verseOfTheDayData![DatabaseHelper.bibleColChapter]?.toString() ?? "?";
      String verseNum = _verseOfTheDayData![DatabaseHelper.bibleColStartVerse]?.toString() ?? "?";
      votdRef = "${getFullBookName(bookAbbr)} $chapter:$verseNum";
      currentVerseIdForVotD = _verseOfTheDayData![DatabaseHelper.bibleColVerseID] ?? "";
    } else if (!_isLoadingVotD) {
      votdText = "Could not load Verse of the Day.";
      votdRef = "Pull down to refresh.";
    }

    List<String> flagNamesForVotD = _getVotDFlagNames();

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
        child: RefreshIndicator( // Pull to refresh VotD
          onRefresh: _loadInitialData,
          child: ListView( // Main content scrolling
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              // --- Verse of the Day Card ---
              Card(
                 elevation: 4.0,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                 child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row( // Title and Favorite Icon
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Expanded( // Allow title to take space
                             child: Text(
                               "Verse of the Day",
                               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                     fontWeight: FontWeight.bold,
                                     color: Theme.of(context).colorScheme.primary,
                                   ),
                             ),
                           ),
                           // Show icon only if VotD is loaded
                           if (!_isLoadingVotD && _verseOfTheDayData != null)
                             IconButton(
                               icon: Icon(
                                 _isVotDFavorite ? Icons.favorite : Icons.favorite_border,
                                 color: _isVotDFavorite ? Colors.redAccent : Colors.grey,
                                 size: 28,
                               ),
                               tooltip: _isVotDFavorite ? "Remove from Favorites" : "Add to Favorites",
                               onPressed: _toggleVotDFavorite, // Toggle favorite ONLY
                             )
                         ],
                      ),
                       const SizedBox(height: 12.0),
                       // Verse Text Area
                       _isLoadingVotD
                          ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: CircularProgressIndicator(),))
                          : SelectableText( // Verse text
                              '"$votdText"',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic, height: 1.5,),
                            ),
                       const SizedBox(height: 8.0),
                       // Verse Reference
                       if (!_isLoadingVotD && votdRef.isNotEmpty)
                         Align(
                           alignment: Alignment.centerRight,
                           child: Text(votdRef, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold,),),
                         ),
                       // --- Flag Display / Add/Manage Button ---
                       if (_isVotDFavorite) ...[
                         const SizedBox(height: 10),
                         // Display chips if flags exist
                         if (flagNamesForVotD.isNotEmpty)
                           Wrap(
                             spacing: 6.0, runSpacing: 4.0,
                             children: flagNamesForVotD.map((name) => Chip(
                               label: Text(name, style: const TextStyle(fontSize: 10)),
                               visualDensity: VisualDensity.compact,
                               padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                               backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.6),
                             )).toList(),
                           ),
                         // Show "Manage Flags" or "Add Flags" button
                         TextButton.icon(
                            icon: Icon(flagNamesForVotD.isNotEmpty ? Icons.edit_note_outlined : Icons.label_outline, size: 18),
                            label: Text(flagNamesForVotD.isNotEmpty ? "Manage Flags" : "Add Flags", style: const TextStyle(fontSize: 12)),
                            onPressed: () {
                              // Open dialog only if we have a valid verse ID
                              if (currentVerseIdForVotD.isNotEmpty) {
                                _showFlagSelectionDialog(currentVerseIdForVotD);
                              }
                            },
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                          )
                       ]
                       // --- END Flag Display/Button ---
                    ],
                  ),
                ),
              ), // End VotD Card

              const SizedBox(height: 24.0),

              // --- Navigation Buttons ---
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
                label: "My Favorites (Coming Soon)",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text("Favorites screen coming soon!")));
                  // Later: Navigator.push( context, MaterialPageRoute(builder: (context) => FavoritesScreen()),);
                },
              ),
              const SizedBox(height: 16.0),
              _buildNavigationButton(
                context,
                icon: Icons.search,
                label: "Search (Coming Soon)",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text("Search functionality coming soon!")));
                },
              ),
              // Add more navigation options here later

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
}