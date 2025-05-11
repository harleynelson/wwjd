// lib/screens/daily_reading_screen.dart
// Path: lib/screens/daily_reading_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../models/models.dart';
import '../helpers/database_helper.dart';
import '../helpers/book_names.dart'; 
import '../models/reader_settings_enums.dart'; 
import '../helpers/prefs_helper.dart'; 
// --- NEW: Import the new widget ---
import '../widgets/reader_settings_bottom_sheet.dart'; 
// --- END NEW ---

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
  
  static const double _baseVerseFontSize = 18.0;
  static const double _baseDailyReaderVerseNumberFontSize = 12.0;
  static const double _basePassageTitleFontSize = 20.0; 

  @override
  void initState() {
    super.initState();
    _currentFontSizeDelta = widget.fontSizeDelta;
    _currentReaderFontFamily = widget.readerFontFamily;
    _currentReaderThemeMode = widget.readerThemeMode;

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
    try {
      for (var passagePtr in widget.dayReading.passages) {
        List<Verse> verses = await _dbHelper.getVersesForPassage(passagePtr);
        tempPassageVerses[passagePtr] = verses;
      }
      if (mounted) {
        setState(() { _passageVerses = tempPassageVerses; _isLoadingVerses = false; });
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

  // --- MODIFIED: Use the new ReaderSettingsBottomSheet ---
  void _openReaderSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for larger content
      builder: (BuildContext bContext) {
        return ReaderSettingsBottomSheet(
          initialFontSizeDelta: _currentFontSizeDelta,
          initialFontFamily: _currentReaderFontFamily,
          initialThemeMode: _currentReaderThemeMode,
          onSettingsChanged: (newDelta, newFamily, newMode) async {
            // This callback is triggered by the sheet when a setting changes
            setState(() {
              _currentFontSizeDelta = newDelta;
              _currentReaderFontFamily = newFamily;
              _currentReaderThemeMode = newMode;
            });
            // Save preferences asynchronously
            await PrefsHelper.setReaderFontSizeDelta(newDelta);
            await PrefsHelper.setReaderFontFamily(newFamily);
            await PrefsHelper.setReaderThemeMode(newMode);
          },
        );
      },
    );
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
            // --- MODIFIED: Call the new method ---
            onPressed: _openReaderSettings,
            // --- END MODIFICATION ---
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
                        final verses = _passageVerses[passagePtr] ?? [];
                        return [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(
                              "${getFullBookName(passagePtr.bookAbbr)} ${passagePtr.displayText.replaceFirst(RegExp(r'^[A-Za-z\s]+'), '')}",
                              style: passageTitleStyle,
                            ),
                          ),
                          if (verses.isEmpty && !_isLoadingVerses)
                             Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text("No text found for ${passagePtr.displayText}.", style: verseTextStyle.copyWith(fontStyle: FontStyle.italic, color: currentTextColor.withOpacity(0.7))),
                             )
                          else
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
                          const SizedBox(height: 12),
                          Divider(color: currentTextColor.withOpacity(0.2)),
                          const SizedBox(height: 10),
                        ];
                      }).toList(),

                      if (widget.dayReading.reflectionPrompt != null && widget.dayReading.reflectionPrompt!.isNotEmpty) ...[
                        const SizedBox(height: 20.0),
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