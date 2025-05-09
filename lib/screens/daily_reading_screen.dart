// lib/screens/daily_reading_screen.dart
import 'package:flutter/material.dart';
import '../models.dart';
import '../database_helper.dart';
import '../book_names.dart'; // For getFullBookName

class DailyReadingScreen extends StatefulWidget {
  final String planId;
  final ReadingPlanDay dayReading;
  final String planTitle; // For AppBar context

  const DailyReadingScreen({
    super.key,
    required this.planId,
    required this.dayReading,
    required this.planTitle,
  });

  @override
  State<DailyReadingScreen> createState() => _DailyReadingScreenState();
}

class _DailyReadingScreenState extends State<DailyReadingScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoadingVerses = true;
  // Store verses per passage to display them grouped
  Map<BiblePassagePointer, List<Verse>> _passageVerses = {};
  String _errorMessage = '';
  bool _isCompletedToday = false; // To manage button state after completion

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
        setState(() {
          _isCompletedToday = true;
        });
      }
    }
  }


  Future<void> _loadAllPassageVerses() async {
    if (!mounted) return;
    setState(() {
      _isLoadingVerses = true;
      _errorMessage = '';
    });

    Map<BiblePassagePointer, List<Verse>> tempPassageVerses = {};
    try {
      for (var passagePtr in widget.dayReading.passages) {
        List<Verse> verses = await _dbHelper.getVersesForPassage(passagePtr);
        tempPassageVerses[passagePtr] = verses;
      }
      if (mounted) {
        setState(() {
          _passageVerses = tempPassageVerses;
          _isLoadingVerses = false;
        });
      }
    } catch (e) {
      print("Error loading verses for DailyReadingScreen: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Could not load scripture text. Please try again.";
          _isLoadingVerses = false;
        });
      }
    }
  }

  Future<void> _markDayAsComplete() async {
    try {
      await _dbHelper.markReadingDayAsComplete(widget.planId, widget.dayReading.dayNumber);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Day ${widget.dayReading.dayNumber} marked complete!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isCompletedToday = true; // Update button state
        });
        // Optionally, pop with a result to refresh the previous screen
        Navigator.pop(context, true); // Signal that progress was made
      }
    } catch (e) {
      print("Error marking day as complete: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating progress: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.planTitle, style: textTheme.titleMedium?.copyWith(color: Colors.white70)),
            Text("Day ${widget.dayReading.dayNumber}${widget.dayReading.title.isNotEmpty ? ': ${widget.dayReading.title}' : ''}"),
          ],
        ),
      ),
      body: _isLoadingVerses
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage, style: TextStyle(color: colorScheme.error))))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...widget.dayReading.passages.expand((passagePtr) {
                        final verses = _passageVerses[passagePtr] ?? [];
                        return [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "${getFullBookName(passagePtr.bookAbbr)} ${passagePtr.displayText.replaceFirst(RegExp(r'^[A-Za-z]+\s*'), '')}", // Display like "Genesis 1:1-31"
                              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                            ),
                          ),
                          if (verses.isEmpty && !_isLoadingVerses)
                             Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text("No text found for ${passagePtr.displayText}.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade600)),
                             )
                          else
                            SelectableText.rich(
                              TextSpan(
                                children: verses.map((verse) {
                                  return TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "${verse.verseNumber} ",
                                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.secondary),
                                      ),
                                      TextSpan(
                                        text: "${verse.text} ",
                                        style: textTheme.bodyLarge?.copyWith(height: 1.5),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          const SizedBox(height: 10),
                          const Divider(),
                        ];
                      }).toList(),

                      if (widget.dayReading.reflectionPrompt != null && widget.dayReading.reflectionPrompt!.isNotEmpty) ...[
                        const SizedBox(height: 20.0),
                        Text("Reflection Prompt:", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8.0),
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: colorScheme.outlineVariant)
                          ),
                          child: Text(widget.dayReading.reflectionPrompt!, style: textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
                        ),
                      ],
                      const SizedBox(height: 30.0),
                      ElevatedButton.icon(
                        icon: Icon(_isCompletedToday ? Icons.check_circle : Icons.check_circle_outline),
                        label: Text(_isCompletedToday ? "Day Completed" : "Mark as Complete"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCompletedToday ? Colors.green.shade600 : colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          textStyle: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                        onPressed: _isCompletedToday ? null : _markDayAsComplete, // Disable if already completed
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
    );
  }
}