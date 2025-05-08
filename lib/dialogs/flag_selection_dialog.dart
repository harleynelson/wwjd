// lib/dialogs/flag_selection_dialog.dart
import 'package:flutter/material.dart';
import '../models.dart'; // Access to Flag class and prebuiltFlags list is needed if not passed in
// Note: We avoid direct DB/Prefs helper imports here by using callbacks

class FlagSelectionDialog extends StatefulWidget {
  final String verseRef; // e.g., "Genesis 1:1" (for display)
  final List<int> initialSelectedFlagIds; // IDs currently assigned
  final List<Flag> allAvailableFlags; // Combined, filtered list to display
  // Callbacks for actions
  final Future<void> Function(int flagIdToHide) onHideFlag; // Handles hiding pre-built
  final Future<void> Function(int flagIdToDelete) onDeleteFlag; // Handles deleting user flag
  final Future<Flag?> Function(String newName) onAddNewFlag; // Handles adding new user flag
  final Future<void> Function(List<int> finalSelectedIds) onSave; // Handles saving assignments

  const FlagSelectionDialog({
    super.key,
    required this.verseRef,
    required this.initialSelectedFlagIds,
    required this.allAvailableFlags,
    required this.onHideFlag,
    required this.onDeleteFlag,
    required this.onAddNewFlag,
    required this.onSave,
  });

  @override
  State<FlagSelectionDialog> createState() => _FlagSelectionDialogState();
}

class _FlagSelectionDialogState extends State<FlagSelectionDialog> {
  late List<Flag> _dialogFlags; // Local state for checkboxes
  late Set<int> _selectedIds; // Local state for selected IDs

  @override
  void initState() {
    super.initState();
    // Initialize local state based on input parameters
    _selectedIds = Set<int>.from(widget.initialSelectedFlagIds);
    _updateDialogFlags();
  }

  // Update the local _dialogFlags list based on widget.allAvailableFlags and _selectedIds
  void _updateDialogFlags() {
     _dialogFlags = widget.allAvailableFlags.map((f) {
      bool isSelected = _selectedIds.contains(f.id);
      // Create copies to manage isSelected state locally
      return Flag(id: f.id, name: f.name, isSelected: isSelected);
    }).toList();
     // Keep the sort order from the parent
     // _dialogFlags.sort((a, b) => a.name.compareTo(b.name));
  }


  // --- Handler for Hiding/Deleting Flags ---
  Future<void> _handleDeleteOrHideFlag(Flag flagToDelete) async {
    // Show Confirmation Dialog
    bool? confirm = await showDialog<bool>(
      context: context, // Use context available in State
      builder: (BuildContext confirmContext) {
        return AlertDialog(
          title: Text(flagToDelete.isPrebuilt ? "Confirm Hide" : "Confirm Delete"),
          content: Text(flagToDelete.isPrebuilt
              ? "Hide the default flag '${flagToDelete.name}'?"
              : "Delete the flag '${flagToDelete.name}'?\nThis removes it permanently."),
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

    if (confirm == true && mounted) {
        try {
            if (flagToDelete.isPrebuilt) {
                // Call the callback provided by the parent screen
                await widget.onHideFlag(flagToDelete.id);
            } else {
                // Call the callback provided by the parent screen
                await widget.onDeleteFlag(flagToDelete.id);
            }
            // Parent screen is responsible for refreshing _allAvailableFlags and passing it down again if needed.
            // For immediate UI update in the dialog, remove the flag from local state.
            setState(() {
                _selectedIds.remove(flagToDelete.id);
                _dialogFlags.removeWhere((f) => f.id == flagToDelete.id);
            });
        } catch (e) {
            print("Error in dialog hide/delete callback: $e");
            if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating flags: $e")));
        }
    }
  } // End _handleDeleteOrHideFlag

  // --- Handler for Adding New Flags ---
  Future<void> _handleAddNewFlag() async {
      final newFlagName = await _showAddNewFlagDialog(); // Uses local context
      if (newFlagName != null && newFlagName.trim().isNotEmpty && mounted) {
         try {
             // Call the callback provided by the parent to add the flag
             final newFlag = await widget.onAddNewFlag(newFlagName.trim());
             if (newFlag != null) {
                 // Parent screen should refresh _allAvailableFlags and pass it again?
                 // Or we just add locally and select it? Let's add locally for now.
                  setState(() {
                     // Add to local dialog state and mark selected
                     newFlag.isSelected = true;
                     _dialogFlags.add(newFlag);
                     _selectedIds.add(newFlag.id);
                     _dialogFlags.sort((a, b) => a.name.compareTo(b.name)); // Keep sorted
                  });
             }
         } catch (e) {
            print("Error in dialog add flag callback: $e");
            if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error adding flag: $e")));
         }
      }
  } // End _handleAddNewFlag

  // --- Dialog to get new flag name ---
  Future<String?> _showAddNewFlagDialog() async {
     TextEditingController flagController = TextEditingController();
     // Use root navigator context if nesting dialogs, otherwise local context is fine
     return showDialog<String>( context: context, builder: (context) { return AlertDialog( title: const Text("Add New Flag"), content: TextField(controller: flagController, autofocus: true, decoration: const InputDecoration(hintText: "Flag name"), textCapitalization: TextCapitalization.sentences,), actions: [ TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), TextButton(onPressed: () { if (flagController.text.trim().isNotEmpty) { Navigator.pop(context, flagController.text.trim()); } }, child: const Text("Add")), ],); });
   }


  @override
  Widget build(BuildContext context) {
     // Rebuild dialogFlags based on latest _allAvailableFlags potentially passed down
     // (Although StatefulWidget rebuilds usually handle this if key changes,
     // it's safer to rebuild local state if parent might change the list)
     // _updateDialogFlags(); // Might cause issues if called directly in build, handled in initState

    return AlertDialog(
      title: Text('Manage Flags for ${widget.verseRef}'),
      contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6, // Consider making dynamic
          child: Column(
            children: [
              Expanded(
                child: _dialogFlags.isEmpty
                  ? const Center(child: Padding( padding: EdgeInsets.all(16.0), child: Text("No flags. Add one below."),))
                  : ListView.builder(
                      // Use local _dialogFlags list
                      itemCount: _dialogFlags.length,
                      itemBuilder: (context, index) {
                        final flag = _dialogFlags[index];
                        return CheckboxListTile(
                          title: Text(flag.name),
                          value: flag.isSelected, // Use local state
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          secondary: IconButton(
                            icon: Icon( flag.isPrebuilt ? Icons.visibility_off_outlined : Icons.delete_outline, color: flag.isPrebuilt ? Colors.grey : Colors.red.shade300),
                            iconSize: 22,
                            tooltip: flag.isPrebuilt ? "Hide default flag" : "Delete custom flag",
                            onPressed: () => _handleDeleteOrHideFlag(flag),
                          ),
                          onChanged: (bool? value) {
                            // Update local state only
                            setState(() {
                              flag.isSelected = value ?? false;
                              if (flag.isSelected) {
                                _selectedIds.add(flag.id);
                              } else {
                                _selectedIds.remove(flag.id);
                              }
                            });
                          },
                        );
                      },
                    ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add New Flag"),
                    onPressed: _handleAddNewFlag,
                ),
              ),
            ],
          ),
        ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: <Widget>[
        TextButton( child: const Text('Cancel'), onPressed: () { Navigator.of(context).pop(); }, ),
        TextButton(
          child: const Text('Save Flags'),
          onPressed: () async {
            // Call the onSave callback with the final set of selected IDs
            await widget.onSave(List<int>.from(_selectedIds)); // Pass back list
            if (mounted) Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}