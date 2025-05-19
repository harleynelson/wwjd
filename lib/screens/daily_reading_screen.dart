// lib/screens/daily_reading_screen.dart
// Path: lib/screens/daily_reading_screen.dart
// Confirmed: Uses InterspersedInsightWidget.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wwjd_app/models/models.dart';
import 'package:wwjd_app/helpers/database_helper.dart';
import 'package:wwjd_app/helpers/book_names.dart';
import 'package:wwjd_app/models/reader_settings_enums.dart';
import 'package:wwjd_app/helpers/prefs_helper.dart';
import 'package:wwjd_app/widgets/reading_plans/reader_settings_bottom_sheet.dart';
import 'package:wwjd_app/widgets/verse_list_item.dart';
import 'package:wwjd_app/widgets/verse_actions_bottom_sheet.dart';
import 'package:wwjd_app/dialogs/flag_selection_dialog.dart';
import 'package:wwjd_app/widgets/tts_play_button.dart';
import 'package:wwjd_app/services/text_to_speech_service.dart';
import 'package:wwjd_app/widgets/reading_plans/interspersed_insight_widget.dart'; // Ensure this is imported

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
  final TextToSpeechService _ttsService = TextToSpeechService();

  bool _isLoadingVerses = true;
  Map<BiblePassagePointer, List<Verse>> _passageVerses = {};
  String _errorMessage = '';
  bool _isCompletedToday = false;
  late bool _userHasPremiumAccess;
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
    _currentReaderViewMode = PrefsHelper.getReaderViewMode();
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
        return Colors.brown.shade800;
      case ReaderThemeMode.light:
      default:
        final appPrimaryColor = Theme.of(context).colorScheme.primary;
        return Color.lerp(appPrimaryColor, Colors.black, 0.6) ?? Colors.black.withOpacity(0.8);
    }
  }

  Color _getSecondaryAccentColor() {
    switch (_currentReaderThemeMode) {
      case ReaderThemeMode.dark:
        return Colors.cyanAccent.shade200.withOpacity(0.9);
      case ReaderThemeMode.sepia:
        return Colors.brown.shade700;
      case ReaderThemeMode.light:
      default:
        return Colors.black.withOpacity(0.65);
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

  Widget _buildProseStylePassage(
      BiblePassagePointer passagePtr,
      List<Verse> verses,
      TextStyle passageTitleStyle,
      TextStyle verseNumberStyle,
      TextStyle verseTextStyle,
      Color textColor
      ) {
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
            "${getFullBookName(passagePtr.bookAbbr)} ${passagePtr.displayText.replaceFirst(RegExp(r'^[A-Za-z\s]+'), '').trim()}",
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

  Widget _buildVerseByVerseStylePassage(
      BiblePassagePointer passagePtr,
      List<Verse> verses,
      TextStyle passageTitleStyle,
      Color currentTextColor,
      Color currentSecondaryAccentColor
  ) {
     List<Widget> passageWidgets = [];
      passageWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
          child: Text(
            "${getFullBookName(passagePtr.bookAbbr)} ${passagePtr.displayText.replaceFirst(RegExp(r'^[A-Za-z\s]+'), '').trim()}",
            style: passageTitleStyle,
          ),
        ),
      );

      if (verses.isEmpty && !_isLoadingVerses) {
        passageWidgets.add(
           Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
              child: Text("No text found for ${passagePtr.displayText}.",
                          style: _getTextStyle(_currentReaderFontFamily, _baseVerseFontSize, FontWeight.normal, currentTextColor, fontStyle: FontStyle.italic).copyWith(color: currentTextColor.withOpacity(0.7))),
           )
        );
      } else {
        for (var verse in verses) {
          bool isFavorite = _isVerseFavoriteMap[verse.verseID] ?? false;
          List<String> flagNames = _getFlagNamesForVerseId(verse.verseID);

          TextStyle vTextStyle = _getTextStyle(_currentReaderFontFamily, _baseVerseFontSize, FontWeight.normal, _getTextColor(), height: 1.6);
          TextStyle vNumStyle = _getTextStyle(_currentReaderFontFamily, _baseDailyReaderVerseNumberFontSize, FontWeight.bold, currentSecondaryAccentColor, height: 1.6);
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
              verseTextStyle: vTextStyle,
              verseNumberStyle: vNumStyle,
              flagChipStyle: fChipStyle,
              favoriteIconColor: favIconColor,
              flagManageButtonColor: flagManageBtnColor,
              flagChipBackgroundColor: flagChipBg,
              flagChipBorderColor: flagChipBorder,
              dividerColor: divColor,
            ),
          );
        }
      }
      passageWidgets.add(const SizedBox(height: 8.0));
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: passageWidgets);
  }

  @override
  Widget build(BuildContext context) {
    final Color currentBackgroundColor = _getBackgroundColor();
    final Color currentTextColor = _getTextColor();
    final Color currentAccentColor = _getAccentColor();
    final Color currentSecondaryAccentColor = _getSecondaryAccentColor();
    
    final Color pronouncedReflectionBoxColor = _getReflectionBoxColor();
    final Color pronouncedReflectionBoxBorderColor = _getReflectionBoxBorderColor();

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

    final TextStyle passageTitleStyle = _getTextStyle(_currentReaderFontFamily, _basePassageTitleFontSize, FontWeight.bold, currentAccentColor);
    final TextStyle reflectionPromptTitleStyle = _getTextStyle(_currentReaderFontFamily, 16.0, FontWeight.bold, currentTextColor);
    final TextStyle reflectionPromptTextStyle = _getTextStyle(
        _currentReaderFontFamily,
        16.0,
        FontWeight.normal,
        currentTextColor,
        height: 1.5,
        fontStyle: FontStyle.italic
    );
    
    final appBarIconColor = Theme.of(context).appBarTheme.foregroundColor ?? 
                            (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black54);

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

        if (_currentReaderViewMode == ReaderViewMode.prose) {
          contentWidgets.add(_buildProseStylePassage(
              passagePtr, versesForPassage, passageTitleStyle,
              _getTextStyle(_currentReaderFontFamily, _baseDailyReaderVerseNumberFontSize, FontWeight.bold, currentSecondaryAccentColor, height: 1.6),
              _getTextStyle(_currentReaderFontFamily, _baseVerseFontSize, FontWeight.normal, currentTextColor, height: 1.6),
              currentTextColor
            ));
          if (widget.dayReading.interspersedInsights.where((insight) => insight.afterPassageIndex == i).isEmpty && i < widget.dayReading.passages.length -1) {
             contentWidgets.add(Padding(
               padding: const EdgeInsets.symmetric(vertical: 10.0),
               child: Divider(color: currentTextColor.withOpacity(0.15), height: 1, thickness: 0.5),
             ));
          }
        } else {
          contentWidgets.add(_buildVerseByVerseStylePassage(
              passagePtr, versesForPassage, passageTitleStyle, currentTextColor, currentSecondaryAccentColor));
        }

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
                            style: _getTextStyle(ReaderFontFamily.systemDefault, 16, FontWeight.bold,
                                    _isCompletedToday
                                        ? (currentBackgroundColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white)
                                        : (currentAccentColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white)
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