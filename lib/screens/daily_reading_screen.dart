// lib/screens/daily_reading_screen.dart
// Path: lib/screens/daily_reading_screen.dart
// Updated to use ReaderThemeHelper for styling.
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // No longer needed directly
import 'package:wwjd_app/models/models.dart';
import 'package:wwjd_app/helpers/database_helper.dart';
import 'package:wwjd_app/helpers/book_names.dart';
import 'package:wwjd_app/models/reader_settings_enums.dart';
import 'package:wwjd_app/helpers/prefs_helper.dart';
import 'package:wwjd_app/widgets/reading_plans/reader_settings_bottom_sheet.dart';
import 'package:wwjd_app/widgets/verse_actions_bottom_sheet.dart';
import 'package:wwjd_app/dialogs/flag_selection_dialog.dart';
import 'package:wwjd_app/widgets/tts_play_button.dart';
import 'package:wwjd_app/services/text_to_speech_service.dart';
import 'package:wwjd_app/widgets/reading_plans/interspersed_insight_widget.dart';
import 'package:wwjd_app/widgets/reading_plans/daily_reading_passage_display.dart';
import 'package:wwjd_app/helpers/reader_theme_helper.dart'; // NEW IMPORT

class DailyReadingScreen extends StatefulWidget {
  final String planId;
  final ReadingPlanDay dayReading;
  final String planTitle;
  final ReaderThemeMode readerThemeMode; // Initial value
  final double fontSizeDelta; // Initial value
  final ReaderFontFamily readerFontFamily; // Initial value

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
  final TextToSpeechService _ttsService = TextToSpeechService();

  bool _isLoadingVerses = true;
  Map<BiblePassagePointer, List<Verse>> _passageVerses = {};
  String _errorMessage = '';
  bool _isCompletedToday = false;
  late bool _userHasPremiumAccess;

  // These will now hold the current state, initialized from widget params
  late double _currentFontSizeDelta;
  late ReaderFontFamily _currentReaderFontFamily;
  late ReaderThemeMode _currentReaderThemeMode;
  late ReaderViewMode _currentReaderViewMode;

  List<Flag> _allAvailableFlags = [];
  Map<String, bool> _isVerseFavoriteMap = {};
  Map<String, List<int>> _assignedFlagIdsMap = {};

  static const double _baseVerseFontSize = 18.0;
  static const double _baseDailyReaderVerseNumberFontSize = 12.0;
  static const double _basePassageTitleFontSize = 20.0;

  @override
  void initState() {
    super.initState();
    _currentFontSizeDelta = widget.fontSizeDelta;
    _currentReaderFontFamily = widget.readerFontFamily;
    _currentReaderThemeMode = widget.readerThemeMode;
    _currentReaderViewMode = PrefsHelper.getReaderViewMode(); // Keep loading this from Prefs
    _userHasPremiumAccess = PrefsHelper.getDevPremiumEnabled();
    _initializeScreenData();
  }

  Future<void> _initializeScreenData() async {
    await _loadAvailableFlags();
    _checkIfAlreadyCompleted();
    _loadAllPassageVerses();
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
        List<int> currentFlagIds = await _dbHelper.getFlagIdsForFavorite(verseID);
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
            _assignedFlagIdsMap.remove(verseID);
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
        allAvailableFlags: _allAvailableFlags,
        onHideFlag: (flagIdToHide) async {
          await PrefsHelper.hideFlagId(flagIdToHide);
          await _loadAvailableFlags();
          if (mounted) {
            setState(() {
              _assignedFlagIdsMap[verseID]?.remove(flagIdToHide);
            });
          }
        },
        onDeleteFlag: (flagIdToDelete) async {
          await _dbHelper.deleteUserFlag(flagIdToDelete);
          await _loadAvailableFlags();
           if (mounted) {
            setState(() {
              _assignedFlagIdsMap[verseID]?.remove(flagIdToDelete);
            });
          }
        },
        onAddNewFlag: (newName) async {
          int newId = await _dbHelper.addUserFlag(newName);
          await _loadAvailableFlags();
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
      backgroundColor: Colors.transparent,
      builder: (BuildContext bContext) {
        return VerseActionsBottomSheet(
          verse: verse,
          isFavorite: isCurrentlyFavorite,
          assignedFlagNames: currentFlagNames,
          onToggleFavorite: () {
            _toggleFavoriteForVerse(verse);
          },
          onManageFlags: () {
            _manageFlagsForVerse(verse);
          },
          fullBookName: bookName,
        );
      },
    );
  }

  // REMOVED: _getTextStyle, _getBackgroundColor, _getTextColor, _getAccentColor,
  // _getSecondaryAccentColor, _getReflectionBoxColor, _getReflectionBoxBorderColor
  // These will now be called from ReaderThemeHelper.

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

  Future<String?> _getCombinedTextForTts() async {
    if (_isLoadingVerses || _passageVerses.isEmpty) {
      return null;
    }
    StringBuffer sb = StringBuffer();

    if (widget.dayReading.title.isNotEmpty) {
        sb.writeln("Today's focus, ${widget.dayReading.title}.");
    } else {
        sb.writeln("Today's reading: Day ${widget.dayReading.dayNumber}.");
    }
    sb.writeln();

    for (var passagePtr in widget.dayReading.passages) {
      final versesForPassage = _passageVerses[passagePtr] ?? [];
      if (versesForPassage.isNotEmpty) {
        String bookName = getFullBookName(passagePtr.bookAbbr);
        String ttsPassageAnnouncement;

        if (passagePtr.startChapter == passagePtr.endChapter) {
          ttsPassageAnnouncement = "Reading from $bookName, chapter ${passagePtr.startChapter}";
          if (passagePtr.startVerse == 0 && passagePtr.endVerse == 0) {
            // Entire chapter
          } else if (passagePtr.startVerse == passagePtr.endVerse) {
            ttsPassageAnnouncement += ", verse ${passagePtr.startVerse}";
          } else {
            ttsPassageAnnouncement += ", verses ${passagePtr.startVerse} through ${passagePtr.endVerse}";
          }
        } else {
          ttsPassageAnnouncement = "Reading from $bookName, beginning at chapter ${passagePtr.startChapter}, verse ${passagePtr.startVerse}, through chapter ${passagePtr.endChapter}, verse ${passagePtr.endVerse}";
        }
        sb.writeln("$ttsPassageAnnouncement.");
        sb.writeln();

        for (var verse in versesForPassage) {
          sb.writeln("${verse.text}");
        }
        sb.writeln();
      }
    }

    if (widget.dayReading.reflectionPrompt != null && widget.dayReading.reflectionPrompt!.isNotEmpty) {
      sb.writeln();
      sb.writeln();
      sb.writeln(widget.dayReading.reflectionPrompt!);
    }
    return sb.toString().trim();
  }


  @override
  Widget build(BuildContext context) {
    // Use ReaderThemeHelper for theme-dependent values
    final Color currentBackgroundColor = ReaderThemeHelper.getBackgroundColor(_currentReaderThemeMode);
    final Color currentTextColor = ReaderThemeHelper.getTextColor(_currentReaderThemeMode);
    final Color currentAccentColor = ReaderThemeHelper.getAccentColor(_currentReaderThemeMode, context);
    final Color currentSecondaryAccentColor = ReaderThemeHelper.getSecondaryAccentColor(_currentReaderThemeMode, context);
    final Color pronouncedReflectionBoxColor = ReaderThemeHelper.getReflectionBoxColor(_currentReaderThemeMode, context);
    final Color pronouncedReflectionBoxBorderColor = ReaderThemeHelper.getReflectionBoxBorderColor(_currentReaderThemeMode, context);
    
    Color subtleInsightBackgroundColor;
    switch (_currentReaderThemeMode) {
      case ReaderThemeMode.dark:
        subtleInsightBackgroundColor = Colors.white.withOpacity(0.05);
        break;
      case ReaderThemeMode.sepia:
        subtleInsightBackgroundColor = const Color(0xFFFDF5E6).withOpacity(0.7);
        break;
      case ReaderThemeMode.light:
      default:
        subtleInsightBackgroundColor = Colors.black.withOpacity(0.03);
        break;
    }

    final TextTheme appTextTheme = Theme.of(context).textTheme;

    final TextStyle passageTitleStyle = ReaderThemeHelper.getTextStyle(
        fontFamily: _currentReaderFontFamily,
        baseSize: _basePassageTitleFontSize,
        fontWeight: FontWeight.bold,
        color: currentAccentColor,
        fontSizeDelta: _currentFontSizeDelta);
    final TextStyle reflectionPromptTitleStyle = ReaderThemeHelper.getTextStyle(
        fontFamily: _currentReaderFontFamily,
        baseSize: 16.0,
        fontWeight: FontWeight.bold,
        color: currentTextColor,
        fontSizeDelta: _currentFontSizeDelta);
    final TextStyle reflectionPromptTextStyle = ReaderThemeHelper.getTextStyle(
        fontFamily: _currentReaderFontFamily,
        baseSize: 16.0,
        fontWeight: FontWeight.normal,
        color: currentTextColor,
        fontSizeDelta: _currentFontSizeDelta,
        height: 1.5,
        fontStyle: FontStyle.italic);
    
    final appBarIconColor = Theme.of(context).appBarTheme.foregroundColor ?? 
                            (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black54);

    // Styles for VerseListItem to be passed to DailyReadingPassageDisplay
    final TextStyle vTextStyle = ReaderThemeHelper.getTextStyle(fontFamily:_currentReaderFontFamily, baseSize: _baseVerseFontSize, fontWeight: FontWeight.normal, color: currentTextColor, fontSizeDelta: _currentFontSizeDelta, height: 1.6);
    final TextStyle vNumStyle = ReaderThemeHelper.getTextStyle(fontFamily: _currentReaderFontFamily, baseSize: _baseDailyReaderVerseNumberFontSize, fontWeight: FontWeight.bold, color: currentSecondaryAccentColor, fontSizeDelta: _currentFontSizeDelta, height: 1.6);
    final TextStyle fChipStyle = ReaderThemeHelper.getTextStyle(fontFamily: _currentReaderFontFamily, baseSize: 10.0, fontWeight: FontWeight.normal, color: (_currentReaderThemeMode == ReaderThemeMode.dark) ? Colors.grey.shade300 : Theme.of(context).colorScheme.onSecondaryContainer, fontSizeDelta: _currentFontSizeDelta);
    
    final Color favIconColor = ReaderThemeHelper.getVerseListItemFavoriteIconColor(_currentReaderThemeMode, context);
    final Color flagManageBtnColor = ReaderThemeHelper.getVerseListItemFlagManageButtonColor(_currentReaderThemeMode, context);
    final Color flagChipBg = ReaderThemeHelper.getVerseListItemFlagChipBackgroundColor(_currentReaderThemeMode, context);
    final Color flagChipBorder = ReaderThemeHelper.getVerseListItemFlagChipBorderColor(_currentReaderThemeMode, context);
    final Color divColor = ReaderThemeHelper.getVerseListItemDividerColor(_currentReaderThemeMode, context);


    List<Widget> contentWidgets = [];
    if (!_isLoadingVerses && _passageVerses.isNotEmpty) {
      widget.dayReading.interspersedInsights
          .where((insight) => insight.afterPassageIndex == -1)
          .forEach((insight) {
        contentWidgets.add(
          InterspersedInsightWidget(
            insight: insight,
            textColor: currentTextColor,
            subtleBackgroundColor: subtleInsightBackgroundColor,
            baseFontSize: _baseVerseFontSize,
            fontSizeDelta: _currentFontSizeDelta,
            fontFamily: _currentReaderFontFamily,
          )
        );
      });

      for (int i = 0; i < widget.dayReading.passages.length; i++) {
        final passagePtr = widget.dayReading.passages[i];
        final versesForPassage = _passageVerses[passagePtr] ?? [];

        contentWidgets.add(
          DailyReadingPassageDisplay(
            passagePointer: passagePtr,
            verses: versesForPassage,
            viewMode: _currentReaderViewMode,
            isLoading: _isLoadingVerses,
            passageTitleStyle: passageTitleStyle,
            verseTextStyle: vTextStyle, 
            verseNumberStyle: vNumStyle,
            textColor: currentTextColor,
            isVerseFavoriteMap: _isVerseFavoriteMap,
            assignedFlagIdsMap: _assignedFlagIdsMap,
            allAvailableFlags: _allAvailableFlags,
            onToggleFavorite: _toggleFavoriteForVerse,
            onManageFlags: _manageFlagsForVerse,
            onVerseTap: _showActionsForVerse,
            readerThemeMode: _currentReaderThemeMode,
            flagChipBackgroundColor: flagChipBg,
            flagChipBorderColor: flagChipBorder,
            dividerColor: divColor,
            favoriteIconColor: favIconColor,
            flagManageButtonColor: flagManageBtnColor,
            flagChipStyle: fChipStyle,
          )
        );

        widget.dayReading.interspersedInsights
            .where((insight) => insight.afterPassageIndex == i)
            .forEach((insight) {
          contentWidgets.add(
            InterspersedInsightWidget(
              insight: insight,
              textColor: currentTextColor,
              subtleBackgroundColor: subtleInsightBackgroundColor,
              baseFontSize: _baseVerseFontSize,
              fontSizeDelta: _currentFontSizeDelta,
              fontFamily: _currentReaderFontFamily,
            )
          );
        });
      }
    }
    
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
          TtsPlayButton<String>(
            textProvider: _getCombinedTextForTts,
            isPremiumFeature: true,
            hasPremiumAccess: _userHasPremiumAccess,
            iconColor: appBarIconColor,
            iconSize: 26.0,
            onPremiumLockTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Unlock Premium to use audio playback for guided readings!")),
              );
            },
          ),
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
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...contentWidgets,

                      if (widget.dayReading.reflectionPrompt != null && widget.dayReading.reflectionPrompt!.isNotEmpty) ...[
                        const SizedBox(height:24),
                        Text("Reflection Prompt:", style: reflectionPromptTitleStyle),
                        const SizedBox(height: 8.0),
                        Container(
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: pronouncedReflectionBoxColor,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: pronouncedReflectionBoxBorderColor.withOpacity(0.8), width: 1.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0,3),
                              )
                            ]
                          ),
                          child: Text(widget.dayReading.reflectionPrompt!, style: reflectionPromptTextStyle),
                        ),
                      ],
                      const SizedBox(height: 30.0),
                      ElevatedButton.icon(
                         icon: Icon(_isCompletedToday ? Icons.check_circle : Icons.check_circle_outline,
                                   color: _isCompletedToday
                                        ? (currentBackgroundColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white)
                                        : (currentAccentColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white)
                        ),
                        label: Text(
                            _isCompletedToday ? "Day Completed" : "Mark as Complete",
                            style: ReaderThemeHelper.getTextStyle( // Using helper
                                fontFamily: ReaderFontFamily.systemDefault, 
                                baseSize: 16, 
                                fontWeight: FontWeight.bold, 
                                color: _isCompletedToday
                                        ? (currentBackgroundColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white)
                                        : (currentAccentColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white),
                                fontSizeDelta: _currentFontSizeDelta 
                            )
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCompletedToday ? Colors.green.shade600 : currentAccentColor,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          foregroundColor: _isCompletedToday
                                        ? (currentBackgroundColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white)
                                        : (currentAccentColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white),
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