// lib/screens/daily_reading_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import '../models.dart';
import '../database_helper.dart';
import '../book_names.dart'; // For getFullBookName
// Assuming reader_settings_enums.dart is in lib/models/
import '../models/reader_settings_enums.dart'; // Import reader enums
import '../prefs_helper.dart'; // To load defaults if not passed (though passing is better)

class DailyReadingScreen extends StatefulWidget {
  final String planId;
  final ReadingPlanDay dayReading;
  final String planTitle;

  // --- NEW: Theme parameters ---
  final ReaderThemeMode readerThemeMode;
  final double fontSizeDelta;
  final ReaderFontFamily readerFontFamily;

  const DailyReadingScreen({
    super.key,
    required this.planId,
    required this.dayReading,
    required this.planTitle,
    // --- NEW: Theme parameters in constructor ---
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

  // Base font sizes (can be adjusted or made consistent with FullBibleReaderScreen)
  static const double _baseVerseFontSize = 18.0;
  static const double _baseVerseNumberFontSize = 12.0;
  static const double _basePassageTitleFontSize = 20.0; // For "Genesis 1:1-10"

  @override
  void initState() {
    super.initState();
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

  // --- Theme Helper Methods (similar to FullBibleReaderScreen) ---
  TextStyle _getTextStyle(
    ReaderFontFamily family,
    double baseSize,
    FontWeight fontWeight,
    Color color, {
    double height = 1.5,
    FontStyle? fontStyle, // NEW: Add optional fontStyle parameter
  }) {
    double currentSize = baseSize + widget.fontSizeDelta;
    TextStyle defaultStyle = TextStyle(
        fontSize: currentSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        fontStyle: fontStyle, // Apply fontStyle here
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
    switch (widget.readerThemeMode) {
      case ReaderThemeMode.dark:
        return Colors.black87;
      case ReaderThemeMode.sepia:
        return const Color(0xFFFBF0D9);
      case ReaderThemeMode.light:
      default:
        return Colors.white; // Or Theme.of(context).colorScheme.background
    }
  }

  Color _getTextColor() {
    switch (widget.readerThemeMode) {
      case ReaderThemeMode.dark:
        return Colors.grey.shade300;
      case ReaderThemeMode.sepia:
        return Colors.brown.shade800;
      case ReaderThemeMode.light:
      default:
        return Colors.black87;
    }
  }

  Color _getAccentColor() { // For verse numbers, passage titles etc.
    switch (widget.readerThemeMode) {
      case ReaderThemeMode.dark:
        return Colors.tealAccent.shade100;
      case ReaderThemeMode.sepia:
        return Colors.brown.shade700;
      case ReaderThemeMode.light:
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

   Color _getSecondaryAccentColor() { // For verse numbers within text spans
    switch (widget.readerThemeMode) {
      case ReaderThemeMode.dark:
        return Colors.cyanAccent.shade200.withOpacity(0.9);
      case ReaderThemeMode.sepia:
        return Colors.brown.shade600;
      case ReaderThemeMode.light:
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  Color _getReflectionBoxColor() {
    switch (widget.readerThemeMode) {
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
     switch (widget.readerThemeMode) {
      case ReaderThemeMode.dark:
        return Colors.grey.shade700;
      case ReaderThemeMode.sepia:
        return Colors.brown.withOpacity(0.3);
      case ReaderThemeMode.light:
      default:
        return Theme.of(context).colorScheme.outlineVariant;
    }
  }


  @override
  Widget build(BuildContext context) {
    final Color currentBackgroundColor = _getBackgroundColor();
    final Color currentTextColor = _getTextColor();
    final Color currentAccentColor = _getAccentColor();
    final Color currentSecondaryAccentColor = _getSecondaryAccentColor();

    final TextTheme appTextTheme = Theme.of(context).textTheme; // For AppBar

    final TextStyle passageTitleStyle = _getTextStyle(widget.readerFontFamily, _basePassageTitleFontSize, FontWeight.bold, currentAccentColor);
    final TextStyle verseTextStyle = _getTextStyle(widget.readerFontFamily, _baseVerseFontSize, FontWeight.normal, currentTextColor, height: 1.6);
    final TextStyle verseNumberStyle = _getTextStyle(widget.readerFontFamily, _baseVerseFontSize, FontWeight.bold, currentSecondaryAccentColor, height: 1.6);
    final TextStyle reflectionPromptTitleStyle = _getTextStyle(widget.readerFontFamily, 16.0, FontWeight.bold, currentTextColor);
    
    // --- MODIFIED LINE ---
    final TextStyle reflectionPromptTextStyle = _getTextStyle(
        widget.readerFontFamily, 
        16.0, // baseSize
        FontWeight.normal, // fontWeight (assuming normal weight for italic text)
        currentTextColor, 
        height: 1.5, 
        fontStyle: FontStyle.italic // Pass fontStyle correctly
    );

    return Scaffold(
      backgroundColor: currentBackgroundColor, // Apply themed background
      appBar: AppBar(
        // AppBar uses main app theme, not reader theme for consistency with rest of app
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.planTitle, style: appTextTheme.titleMedium?.copyWith(color: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.8))),
            Text("Day ${widget.dayReading.dayNumber}${widget.dayReading.title.isNotEmpty ? ': ${widget.dayReading.title}' : ''}", style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor)),
          ],
        ),
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
                              "${getFullBookName(passagePtr.bookAbbr)} ${passagePtr.displayText.replaceFirst(RegExp(r'^[A-Za-z]+\s*'), '')}",
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
                                        style: verseNumberStyle, // Apply themed style
                                      ),
                                      TextSpan(
                                        text: "${verse.text} ",
                                        style: verseTextStyle, // Apply themed style
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
                                   color: _isCompletedToday ? (_getBackgroundColor() == Colors.white ? Colors.white : _getBackgroundColor()) : _getBackgroundColor() // Icon color contrasts with button bg
                        ),
                        label: Text(
                            _isCompletedToday ? "Day Completed" : "Mark as Complete",
                            style: _getTextStyle(ReaderFontFamily.systemDefault, 16, FontWeight.bold, _isCompletedToday ? (_getBackgroundColor() == Colors.white ? Colors.white : _getBackgroundColor()) : _getBackgroundColor())
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCompletedToday ? Colors.green.shade600 : currentAccentColor,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
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