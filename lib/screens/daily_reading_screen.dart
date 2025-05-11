// lib/screens/daily_reading_screen.dart
// Path: lib/screens/daily_reading_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../helpers/database_helper.dart';
import '../helpers/book_names.dart';
import '../models/reader_settings_enums.dart';
import '../helpers/prefs_helper.dart';
import '../widgets/reader_settings_bottom_sheet.dart';
// --- NEW IMPORTS ---
import '../widgets/verse_list_item.dart';
import '../widgets/verse_actions_bottom_sheet.dart';
import '../dialogs/flag_selection_dialog.dart';
// --- END NEW IMPORTS ---

class DailyReadingScreen extends StatefulWidget {
  final String planId;
  final ReadingPlanDay dayReading;
  final String planTitle;

  final ReaderThemeMode readerThemeMode;
  final double fontSizeDelta;
  final ReaderFontFamily readerFontFamily;

  const DailyReadingScreen({
    super.key,
    required this.planId,
    required this.dayReading,
    required this.planTitle,
    required this.readerThemeMode,
    required this.fontSizeDelta,
    required this.readerFontFamily,
  });

  @override
  State<DailyReadingScreen> createState() => _DailyReadingScreenState();
}

class _DailyReadingScreenState extends State<DailyReadingScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoadingVerses = true;
  Map<BiblePassagePointer, List<Verse>> _passageVerses = {};
  String _errorMessage = '';
  bool _isCompletedToday = false;

  late double _currentFontSizeDelta;
  late ReaderFontFamily _currentReaderFontFamily;
  late ReaderThemeMode _currentReaderThemeMode;
  late ReaderViewMode _currentReaderViewMode;

  // --- NEW STATE for favorites and flags ---
  List<Flag> _allAvailableFlags = [];
  Map<String, bool> _isVerseFavoriteMap = {};
  Map<String, List<int>> _assignedFlagIdsMap = {};
  // --- END NEW STATE ---

  static const double _baseVerseFontSize = 18.0;
  static const double _baseDailyReaderVerseNumberFontSize = 12.0;
  static const double _basePassageTitleFontSize = 20.0;

  @override
  void initState() {
    super.initState();
    _currentFontSizeDelta = widget.fontSizeDelta;
    _currentReaderFontFamily = widget.readerFontFamily;
    _currentReaderThemeMode = widget.readerThemeMode;
    _currentReaderViewMode = PrefsHelper.getReaderViewMode();

    _initializeScreenData();
  }

  Future<void> _initializeScreenData() async {
    await _loadAvailableFlags(); // Load flags first
    _checkIfAlreadyCompleted();
    _loadAllPassageVerses(); // Now loads fav/flag info too
  }

  Future<void> _loadAvailableFlags() async {
    if (!mounted) return;
    try {
      final Set<int> hiddenIds = PrefsHelper.getHiddenFlagIds();
      final List<Flag> visiblePrebuiltFlags = prebuiltFlags.where((flag) => !hiddenIds.contains(flag.id)).toList();
      final userFlagMaps = await _dbHelper.getUserFlags();
      final userFlags = userFlagMaps.map((map) => Flag.fromUserDbMap(map)).toList();
      if (mounted) {
        setState(() {
          _allAvailableFlags = [...visiblePrebuiltFlags, ...userFlags];
          _allAvailableFlags.sort((a, b) => a.name.compareTo(b.name));
        });
      }
    } catch (e) {
      print("Error loading available flags in DailyReadingScreen: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error loading flag data: ${e.toString()}")));
      }
    }
  }

  Future<void> _checkIfAlreadyCompleted() async {
    UserReadingProgress? progress = await _dbHelper.getReadingPlanProgress(widget.planId);
    if (progress != null && progress.completedDays.containsKey(widget.dayReading.dayNumber)) {
      if (mounted) {
        setState(() { _isCompletedToday = true; });
      }
    }
  }

  Future<void> _loadAllPassageVerses() async {
    if (!mounted) return;
    setState(() { _isLoadingVerses = true; _errorMessage = ''; });
    Map<BiblePassagePointer, List<Verse>> tempPassageVerses = {};
    Map<String, bool> tempIsFavoriteMap = {};
    Map<String, List<int>> tempAssignedFlagIdsMap = {};

    try {
      for (var passagePtr in widget.dayReading.passages) {
        List<Verse> verses = await _dbHelper.getVersesForPassage(passagePtr);
        tempPassageVerses[passagePtr] = verses;
        for (var verse in verses) {
          if (verse.verseID != null) {
            bool isFav = await _dbHelper.isFavorite(verse.verseID!);
            tempIsFavoriteMap[verse.verseID!] = isFav;
            if (isFav) {
              tempAssignedFlagIdsMap[verse.verseID!] = await _dbHelper.getFlagIdsForFavorite(verse.verseID!);
            }
          }
        }
      }
      if (mounted) {
        setState(() {
          _passageVerses = tempPassageVerses;
          _isVerseFavoriteMap = tempIsFavoriteMap;
          _assignedFlagIdsMap = tempAssignedFlagIdsMap;
          _isLoadingVerses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _errorMessage = "Could not load scripture text. Please try again."; _isLoadingVerses = false; });
      }
    }
  }

  Future<void> _markDayAsComplete() async {
    try {
      await _dbHelper.markReadingDayAsComplete(widget.planId, widget.dayReading.dayNumber);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text("Day ${widget.dayReading.dayNumber} marked complete!"), backgroundColor: Colors.green,));
        setState(() { _isCompletedToday = true; });
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Error updating progress: ${e.toString()}")));
      }
    }
  }

  // --- Favorite and Flagging Logic (similar to FullBibleReaderScreen) ---
  Future<void> _toggleFavoriteForVerse(Verse verse) async {
    if (verse.verseID == null || !mounted) return;
    final verseID = verse.verseID!;
    bool newFavoriteState = !(_isVerseFavoriteMap[verseID] ?? false);

    try {
      if (newFavoriteState) {
        Map<String, dynamic> favData = {
          DatabaseHelper.bibleColVerseID: verse.verseID,
          DatabaseHelper.bibleColBook: verse.bookAbbr,
          DatabaseHelper.bibleColChapter: verse.chapter,
          DatabaseHelper.bibleColStartVerse: verse.verseNumber,
          DatabaseHelper.bibleColVerseText: verse.text,
        };
        await _dbHelper.addFavorite(favData);
        List<int> currentFlagIds = await _dbHelper.getFlagIdsForFavorite(verseID); // Fetch flags if newly favorited
        if (mounted) {
          setState(() {
            _isVerseFavoriteMap[verseID] = true;
            _assignedFlagIdsMap[verseID] = currentFlagIds;
          });
        }
      } else {
        await _dbHelper.removeFavorite(verseID);
        if (mounted) {
          setState(() {
            _isVerseFavoriteMap[verseID] = false;
            _assignedFlagIdsMap.remove(verseID); // Clear flags when unfavorited
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating favorite: ${e.toString()}")));
      }
    }
  }

  void _manageFlagsForVerse(Verse verse) {
    if (verse.verseID == null || !mounted || !(_isVerseFavoriteMap[verse.verseID!] ?? false)) return;
    final String verseID = verse.verseID!;
    final String verseRef = "${getFullBookName(verse.bookAbbr ?? '?')} ${verse.chapter ?? '?'}:${verse.verseNumber}";
    final List<int> currentSelection = _assignedFlagIdsMap[verseID] ?? [];

    showDialog(
      context: context,
      builder: (_) => FlagSelectionDialog(
        verseRef: verseRef,
        initialSelectedFlagIds: currentSelection,
        allAvailableFlags: _allAvailableFlags, // Pass the loaded list
        onHideFlag: (flagIdToHide) async {
          await PrefsHelper.hideFlagId(flagIdToHide);
          await _loadAvailableFlags(); // Refresh available flags
          if (mounted) { // Update local assignment for this verse
            setState(() {
              _assignedFlagIdsMap[verseID]?.remove(flagIdToHide);
            });
          }
        },
        onDeleteFlag: (flagIdToDelete) async {
          await _dbHelper.deleteUserFlag(flagIdToDelete);
          await _loadAvailableFlags(); // Refresh available flags
           if (mounted) { // Update local assignment for this verse
            setState(() {
              _assignedFlagIdsMap[verseID]?.remove(flagIdToDelete);
            });
          }
        },
        onAddNewFlag: (newName) async {
          int newId = await _dbHelper.addUserFlag(newName);
          await _loadAvailableFlags(); // Refresh available flags
          try {
            return _allAvailableFlags.firstWhere((f) => f.id == newId);
          } catch (e) { return null; }
        },
        onSave: (finalSelectedIds) async {
          Set<int> initialSet = currentSelection.toSet();
          Set<int> finalSet = finalSelectedIds.toSet();
          for (int id in finalSet.difference(initialSet)) {
            await _dbHelper.assignFlagToFavorite(verseID, id);
          }
          for (int id in initialSet.difference(finalSet)) {
            await _dbHelper.removeFlagFromFavorite(verseID, id);
          }
          if (mounted) {
            setState(() {
              _assignedFlagIdsMap[verseID] = finalSelectedIds;
            });
          }
        },
      ),
    );
  }

  List<String> _getFlagNamesForVerseId(String? verseID) {
    if (verseID == null) return [];
    List<int> flagIds = _assignedFlagIdsMap[verseID] ?? [];
    if (flagIds.isEmpty) return [];
    List<String> names = [];
    for (int id in flagIds) {
      try {
        final flag = _allAvailableFlags.firstWhere((f) => f.id == id);
        names.add(flag.name);
      } catch (e) { /* Flag not found, skip */ }
    }
    names.sort();
    return names;
  }
  
  void _showActionsForVerse(Verse verse) {
    if (verse.verseID == null || !mounted) return;
    final String bookName = getFullBookName(verse.bookAbbr ?? "Unknown Book");
    final bool isCurrentlyFavorite = _isVerseFavoriteMap[verse.verseID!] ?? false;
    final List<String> currentFlagNames = _getFlagNamesForVerseId(verse.verseID);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Important for custom sheet design
      builder: (BuildContext bContext) {
        return VerseActionsBottomSheet(
          verse: verse,
          isFavorite: isCurrentlyFavorite,
          assignedFlagNames: currentFlagNames,
          onToggleFavorite: () {
            _toggleFavoriteForVerse(verse);
            // Optionally close sheet, or let parent handle rebuild if necessary
            // Navigator.pop(bContext); 
          },
          onManageFlags: () {
            // Navigator.pop(bContext); // Close this sheet before opening dialog
            _manageFlagsForVerse(verse);
          },
          fullBookName: bookName,
        );
      },
    );
  }
  // --- End Favorite and Flagging Logic ---

  // ... (styling methods _getTextStyle, _getBackgroundColor, etc. remain the same) ...
  TextStyle _getTextStyle(
    ReaderFontFamily family,
    double baseSize,
    FontWeight fontWeight,
    Color color, {
    double height = 1.5,
    FontStyle? fontStyle,
  }) {
    double currentSize = baseSize + _currentFontSizeDelta;
    TextStyle defaultStyle = TextStyle(
        fontSize: currentSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        fontStyle: fontStyle,
      );
    switch (family) {
      case ReaderFontFamily.serif:
        return GoogleFonts.notoSerif(textStyle: defaultStyle);
      case ReaderFontFamily.sansSerif:
        return GoogleFonts.roboto(textStyle: defaultStyle);
      case ReaderFontFamily.systemDefault:
      default:
        return defaultStyle;
    }
  }

  Color _getBackgroundColor() {
    switch (_currentReaderThemeMode) {
      case ReaderThemeMode.dark:
        return Colors.black87;
      case ReaderThemeMode.sepia:
        return const Color(0xFFFBF0D9);
      case ReaderThemeMode.light:
      default:
        return Colors.white;
    }
  }

  Color _getTextColor() {
    switch (_currentReaderThemeMode) {
      case ReaderThemeMode.dark:
        return Colors.grey.shade300;
      case ReaderThemeMode.sepia:
        return Colors.brown.shade800;
      case ReaderThemeMode.light:
      default:
        return Colors.black87;
    }
  }

  Color _getAccentColor() {
    switch (_currentReaderThemeMode) {
      case ReaderThemeMode.dark:
        return Colors.tealAccent.shade100;
      case ReaderThemeMode.sepia:
        return Colors.brown.shade700;
      case ReaderThemeMode.light:
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

   Color _getSecondaryAccentColor() {
    switch (_currentReaderThemeMode) {
      case ReaderThemeMode.dark:
        return Colors.cyanAccent.shade200.withOpacity(0.9);
      case ReaderThemeMode.sepia:
        return Colors.brown.shade600;
      case ReaderThemeMode.light:
      default:
        return Theme.of(context).colorScheme.primary.withOpacity(0.85);
    }
  }

  Color _getReflectionBoxColor() {
    switch (_currentReaderThemeMode) {
      case ReaderThemeMode.dark:
        return Colors.grey.shade800;
      case ReaderThemeMode.sepia:
        return const Color(0xFFEFEBE2);
      case ReaderThemeMode.light:
      default:
        return Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5);
    }
  }

  Color _getReflectionBoxBorderColor() {
     switch (_currentReaderThemeMode) {
      case ReaderThemeMode.dark:
        return Colors.grey.shade700;
      case ReaderThemeMode.sepia:
        return Colors.brown.withOpacity(0.3);
      case ReaderThemeMode.light:
      default:
        return Theme.of(context).colorScheme.outlineVariant;
    }
  }


  void _openReaderSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bContext) {
        return ReaderSettingsBottomSheet(
          initialFontSizeDelta: _currentFontSizeDelta,
          initialFontFamily: _currentReaderFontFamily,
          initialThemeMode: _currentReaderThemeMode,
          initialReaderViewMode: _currentReaderViewMode,
          onSettingsChanged: (newDelta, newFamily, newMode, newViewMode) async {
            setState(() {
              _currentFontSizeDelta = newDelta;
              _currentReaderFontFamily = newFamily;
              _currentReaderThemeMode = newMode;
              _currentReaderViewMode = newViewMode;
            });
            await PrefsHelper.setReaderFontSizeDelta(newDelta);
            await PrefsHelper.setReaderFontFamily(newFamily);
            await PrefsHelper.setReaderThemeMode(newMode);
            await PrefsHelper.setReaderViewMode(newViewMode);
          },
        );
      },
    );
  }

  Widget _buildProseStylePassage(
      BiblePassagePointer passagePtr,
      List<Verse> verses,
      TextStyle passageTitleStyle,
      TextStyle verseNumberStyle,
      TextStyle verseTextStyle,
      Color textColor) {
    if (verses.isEmpty && !_isLoadingVerses) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text("No text found for ${passagePtr.displayText}.",
            style: verseTextStyle.copyWith(
                fontStyle: FontStyle.italic,
                color: textColor.withOpacity(0.7))),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            "${getFullBookName(passagePtr.bookAbbr)} ${passagePtr.displayText.replaceFirst(RegExp(r'^[A-Za-z\s]+'), '')}",
            style: passageTitleStyle,
          ),
        ),
        SelectableText.rich(
          TextSpan(
            children: verses.map((verse) {
              return TextSpan(
                children: [
                  TextSpan(
                    text: "${verse.verseNumber} ",
                    style: verseNumberStyle,
                  ),
                  TextSpan(
                    text: "${verse.text} ",
                    style: verseTextStyle,
                  ),
                ],
              );
            }).toList(),
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  // --- MODIFIED to use VerseListItem ---
  Widget _buildVerseByVerseStylePassage(
      BiblePassagePointer passagePtr,
      List<Verse> verses,
      TextStyle passageTitleStyle,
      // Styles for VerseListItem will be computed based on current theme state
      Color currentTextColor, // Pass for fallback text
      Color currentSecondaryAccentColor // Pass for verse numbers if needed for fallback text
  ) {
     List<Widget> passageWidgets = [];
      passageWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
          child: Text(
            "${getFullBookName(passagePtr.bookAbbr)} ${passagePtr.displayText.replaceFirst(RegExp(r'^[A-Za-z\s]+'), '')}",
            style: passageTitleStyle,
          ),
        ),
      );

      if (verses.isEmpty && !_isLoadingVerses) {
        passageWidgets.add(
           Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
              child: Text("No text found for ${passagePtr.displayText}.", style: _getTextStyle(_currentReaderFontFamily, _baseVerseFontSize, FontWeight.normal, currentTextColor, fontStyle: FontStyle.italic).copyWith(color: currentTextColor.withOpacity(0.7))),
           )
        );
      } else {
        for (var verse in verses) {
          bool isFavorite = _isVerseFavoriteMap[verse.verseID] ?? false;
          List<String> flagNames = _getFlagNamesForVerseId(verse.verseID);

          // Compute styles for VerseListItem based on current theme
          TextStyle vTextStyle = _getTextStyle(_currentReaderFontFamily, _baseVerseFontSize, FontWeight.normal, _getTextColor(), height: 1.6);
          TextStyle vNumStyle = _getTextStyle(_currentReaderFontFamily, _baseDailyReaderVerseNumberFontSize, FontWeight.bold, _getSecondaryAccentColor(), height: 1.6);
          TextStyle fChipStyle = _getTextStyle(_currentReaderFontFamily, 10.0, FontWeight.normal, (_currentReaderThemeMode == ReaderThemeMode.dark) ? Colors.grey.shade300 : Theme.of(context).colorScheme.onSecondaryContainer);
          Color favIconColor = (_currentReaderThemeMode == ReaderThemeMode.dark) ? Colors.grey.shade400 : Theme.of(context).colorScheme.outline;
          Color flagManageBtnColor = (_currentReaderThemeMode == ReaderThemeMode.dark) ? Colors.cyanAccent.shade200 : Theme.of(context).colorScheme.primary;
          Color flagChipBg = (_currentReaderThemeMode == ReaderThemeMode.dark) ? Colors.grey.shade700.withOpacity(0.6) : Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.6);
          Color flagChipBorder = (_currentReaderThemeMode == ReaderThemeMode.dark) ? Colors.grey.shade600 : Theme.of(context).colorScheme.secondaryContainer;
          Color divColor = (_currentReaderThemeMode == ReaderThemeMode.dark) ? Colors.grey.shade700 : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5);


          passageWidgets.add(
            VerseListItem(
              verse: verse,
              isFavorite: isFavorite,
              assignedFlagNames: flagNames,
              onToggleFavorite: () => _toggleFavoriteForVerse(verse),
              onManageFlags: () => _manageFlagsForVerse(verse),
              onVerseTap: () => _showActionsForVerse(verse),
              // Pass computed styles
              verseTextStyle: vTextStyle,
              verseNumberStyle: vNumStyle,
              flagChipStyle: fChipStyle,
              favoriteIconColor: favIconColor,
              flagManageButtonColor: flagManageBtnColor,
              flagChipBackgroundColor: flagChipBg,
              flagChipBorderColor: flagChipBorder,
              dividerColor: divColor,
              // isHighlighted and verseHighlightColor are not used in DailyReadingScreen for now
            ),
          );
        }
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: passageWidgets);
  }
  // --- END MODIFICATION ---


  @override
  Widget build(BuildContext context) {
    final Color currentBackgroundColor = _getBackgroundColor();
    final Color currentTextColor = _getTextColor();
    final Color currentAccentColor = _getAccentColor();
    final Color currentSecondaryAccentColor = _getSecondaryAccentColor();

    final TextTheme appTextTheme = Theme.of(context).textTheme;

    final TextStyle passageTitleStyle = _getTextStyle(_currentReaderFontFamily, _basePassageTitleFontSize, FontWeight.bold, currentAccentColor);
    final TextStyle verseTextStyle = _getTextStyle(_currentReaderFontFamily, _baseVerseFontSize, FontWeight.normal, currentTextColor, height: 1.6);
    final TextStyle verseNumberStyle = _getTextStyle(_currentReaderFontFamily, _baseDailyReaderVerseNumberFontSize, FontWeight.bold, currentSecondaryAccentColor, height: 1.6);
    final TextStyle reflectionPromptTitleStyle = _getTextStyle(_currentReaderFontFamily, 16.0, FontWeight.bold, currentTextColor);
    final TextStyle reflectionPromptTextStyle = _getTextStyle(
        _currentReaderFontFamily,
        16.0,
        FontWeight.normal,
        currentTextColor,
        height: 1.5,
        fontStyle: FontStyle.italic
    );

    return Scaffold(
      backgroundColor: currentBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.planTitle, style: appTextTheme.titleMedium?.copyWith(color: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.8))),
            Text("Day ${widget.dayReading.dayNumber}${widget.dayReading.title.isNotEmpty ? ': ${widget.dayReading.title}' : ''}", style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: "Reader Settings",
            onPressed: _openReaderSettings,
          ),
        ],
      ),
      body: _isLoadingVerses
          ? Center(child: CircularProgressIndicator(color: currentAccentColor))
          : _errorMessage.isNotEmpty
              ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage, style: TextStyle(color: Colors.red.shade400))))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...widget.dayReading.passages.expand((passagePtr) {
                        final versesForPassage = _passageVerses[passagePtr] ?? [];
                        List<Widget> widgetsForPassageContent = [];

                        if (_currentReaderViewMode == ReaderViewMode.prose) {
                          widgetsForPassageContent.add(_buildProseStylePassage(
                              passagePtr, versesForPassage, passageTitleStyle, verseNumberStyle, verseTextStyle, currentTextColor));
                        } else { 
                          widgetsForPassageContent.add(_buildVerseByVerseStylePassage(
                              passagePtr, versesForPassage, passageTitleStyle, currentTextColor, currentSecondaryAccentColor));
                        }
                        
                        // If not using VerseListItem's internal divider, or if an explicit passage divider is still desired
                        if (_currentReaderViewMode == ReaderViewMode.prose) {
                           widgetsForPassageContent.add(const SizedBox(height: 12));
                           widgetsForPassageContent.add(Divider(color: currentTextColor.withOpacity(0.2)));
                           widgetsForPassageContent.add(const SizedBox(height: 10));
                        }


                        return widgetsForPassageContent;
                      }).toList(),

                      if (widget.dayReading.reflectionPrompt != null && widget.dayReading.reflectionPrompt!.isNotEmpty) ...[
                        if(_currentReaderViewMode == ReaderViewMode.verseByVerse) const SizedBox(height:10), // Add space if coming from VLV items
                        Text("Reflection Prompt:", style: reflectionPromptTitleStyle),
                        const SizedBox(height: 8.0),
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: _getReflectionBoxColor(),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: _getReflectionBoxBorderColor())
                          ),
                          child: Text(widget.dayReading.reflectionPrompt!, style: reflectionPromptTextStyle),
                        ),
                      ],
                      const SizedBox(height: 30.0),
                      ElevatedButton.icon(
                        icon: Icon(_isCompletedToday ? Icons.check_circle : Icons.check_circle_outline,
                                   color: _isCompletedToday
                                        ? (_getBackgroundColor().computeLuminance() > 0.5 ? Colors.black87 : Colors.white)
                                        : (_getAccentColor().computeLuminance() > 0.5 ? Colors.black87 : Colors.white)
                        ),
                        label: Text(
                            _isCompletedToday ? "Day Completed" : "Mark as Complete",
                            style: _getTextStyle(ReaderFontFamily.systemDefault, 16, FontWeight.bold,
                                    _isCompletedToday
                                        ? (_getBackgroundColor().computeLuminance() > 0.5 ? Colors.black87 : Colors.white)
                                        : (_getAccentColor().computeLuminance() > 0.5 ? Colors.black87 : Colors.white)
                            )
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCompletedToday ? Colors.green.shade600 : currentAccentColor,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          foregroundColor: _isCompletedToday
                                        ? (_getBackgroundColor().computeLuminance() > 0.5 ? Colors.black87 : Colors.white)
                                        : (_getAccentColor().computeLuminance() > 0.5 ? Colors.black87 : Colors.white),
                        ),
                        onPressed: _isCompletedToday ? null : _markDayAsComplete,
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
    );
  }
}