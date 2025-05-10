// lib/screens/reading_plan_detail_screen.dart
import 'package:flutter/material.dart';
import '../models.dart';
import '../database_helper.dart';
// import '../helpers/ui_helpers.dart'; // No longer needed if we pass the gradient
import '../models/reader_settings_enums.dart';
import '../prefs_helper.dart';
import '../theme/app_colors.dart'; // For fallback or default if needed
import 'daily_reading_screen.dart'; 

class ReadingPlanDetailScreen extends StatefulWidget {
  final ReadingPlan plan;
  final UserReadingProgress? initialProgress;
  final List<Color> headerGradientColors; // New property
  final Alignment headerBeginAlignment;   // New property
  final Alignment headerEndAlignment;     // New property

  const ReadingPlanDetailScreen({
    super.key,
    required this.plan,
    this.initialProgress,
    required this.headerGradientColors, // Make it required
    required this.headerBeginAlignment, // Make it required
    required this.headerEndAlignment,   // Make it required
  });

  @override
  State<ReadingPlanDetailScreen> createState() => _ReadingPlanDetailScreenState();
}

class _ReadingPlanDetailScreenState extends State<ReadingPlanDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  UserReadingProgress? _progress;
  bool _isLoadingProgress = false; 

  @override
  void initState() {
    super.initState();
    _progress = widget.initialProgress;
    if (_progress == null && widget.initialProgress == null) { 
      _loadProgress();
    }
  }

  Future<void> _loadProgress() async {
    if (mounted) setState(() => _isLoadingProgress = true);
    try {
        final progressData = await _dbHelper.getReadingPlanProgress(widget.plan.id);
        if (mounted) {
            setState(() {
                _progress = progressData;
                _isLoadingProgress = false;
            });
        }
    } catch (e) {
        if (mounted) {
            setState(() => _isLoadingProgress = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not load plan progress: ${e.toString()}")));
        }
    }
  }

  Future<void> _startPlan() async {
    if (widget.plan.isPremium /* && !currentUser.hasPremiumAccess */) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This is a premium plan. Unlock premium to start!")),
      );
      return;
    }

    if (mounted) setState(() => _isLoadingProgress = true);
    UserReadingProgress newProgress = UserReadingProgress(
      planId: widget.plan.id,
      startDate: DateTime.now(),
      currentDayNumber: 1, 
      isActive: true,
    );
    await _dbHelper.saveReadingPlanProgress(newProgress);
    if (mounted) {
      setState(() {
        _progress = newProgress;
        _isLoadingProgress = false;
      });
      // No need to pop with true here, _loadProgress will be called on resume if needed
      // or the list screen can refresh based on other signals if necessary.
      // However, if an immediate refresh of the list is desired after starting:
      // Navigator.pop(context, true); 
    }
  }

  Future<void> _handleDayTap(ReadingPlanDay day) async {
    if (_progress == null || !_progress!.isActive) {
      // If plan not started, offer to start it, or show a message
      bool? confirmStart = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(widget.plan.isPremium ? "Unlock Premium Plan?" : "Start Reading Plan?"),
          content: Text(widget.plan.isPremium 
              ? "To access '${widget.plan.title}', please unlock our premium features." 
              : "Would you like to start the reading plan '${widget.plan.title}' to view Day ${day.dayNumber}?"),
          actions: [
            TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop(false)),
            TextButton(
              child: Text(widget.plan.isPremium ? "Unlock (Coming Soon)" : "Start Plan"), 
              onPressed: widget.plan.isPremium ? null : () => Navigator.of(ctx).pop(true)
            ),
          ],
        )
      );
      if (confirmStart == true && !widget.plan.isPremium) {
        await _startPlan(); // Start the plan
        if (_progress != null && _progress!.isActive) { // If successfully started
           _navigateToDailyReading(day); // Then navigate
        }
      }
      return;
    }
     _navigateToDailyReading(day);
  }

  Future<void> _navigateToDailyReading(ReadingPlanDay day) async {
    // --- NEW: Load reader preferences ---
    final ReaderThemeMode themeMode = PrefsHelper.getReaderThemeMode();
    final double fontSizeDelta = PrefsHelper.getReaderFontSizeDelta();
    final ReaderFontFamily fontFamily = PrefsHelper.getReaderFontFamily();
    // --- END NEW ---

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyReadingScreen(
          planId: widget.plan.id,
          dayReading: day,
          planTitle: widget.plan.title,
          // --- NEW: Pass loaded preferences ---
          readerThemeMode: themeMode,
          fontSizeDelta: fontSizeDelta,
          readerFontFamily: fontFamily,
          // --- END NEW ---
        ),
      ),
    );

    if (result == true && mounted) {
      _loadProgress();
    }
  }


  Widget _buildActionButton() {
    if (_isLoadingProgress) return const Center(child: CircularProgressIndicator());

    bool isFullyCompleted = _progress != null && _progress!.completedDays.length >= widget.plan.durationDays;

    if (_progress == null || (!_progress!.isActive && !isFullyCompleted)) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.play_arrow),
        label: Text(widget.plan.isPremium ? "Unlock Premium" : "Start Plan"),
        onPressed: _startPlan, // _startPlan handles premium check
        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
      );
    } else if (isFullyCompleted) {
       return Column( /* ... Restart plan button ... */ // Unchanged
         children: [
           Text("Plan Completed!", style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 18)),
           const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Restart Plan (Deletes Progress)"),
              onPressed: () async {
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Restart Plan?"),
                    content: const Text("This will delete your current progress for this plan. Are you sure?"),
                    actions: [
                      TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop(false)),
                      TextButton(child: Text("Restart", style: TextStyle(color: Theme.of(context).colorScheme.error)), onPressed: () => Navigator.of(ctx).pop(true)),
                    ],
                  )
                );
                if (confirm == true) {
                  await _dbHelper.deleteReadingPlanProgress(widget.plan.id);
                  _loadProgress(); 
                }
              },
            ),
         ],
       );
    } else { 
      final currentDayExists = _progress!.currentDayNumber > 0 && _progress!.currentDayNumber <= widget.plan.dailyReadings.length;
      ReadingPlanDay? currentDayReading;
      if(currentDayExists){
          try {
            currentDayReading = widget.plan.dailyReadings.firstWhere((day) => day.dayNumber == _progress!.currentDayNumber);
          } catch (e) {
            // Should not happen if currentDayNumber is within bounds and dailyReadings is well-formed
            print("Error finding current day reading: $e");
          }
      }

      return ElevatedButton.icon(
        icon: const Icon(Icons.play_circle_outline),
        label: Text(currentDayReading != null ? "Continue: Day ${_progress!.currentDayNumber}" : "Review Plan"),
        onPressed: currentDayReading != null ? () {
          _navigateToDailyReading(currentDayReading!);
        } : null, 
         style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary, foregroundColor: Theme.of(context).colorScheme.onSecondary),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true); // Always signal potential refresh to list screen
        return false; 
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              leading: BackButton(onPressed: () {
                 Navigator.pop(context, true); // Signal refresh
              }),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.plan.title, style: const TextStyle(shadows: [Shadow(blurRadius: 1.0, color: Colors.black54, offset: Offset(1,1))])),
                background: Container( // Use the passed-in gradient properties
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.headerGradientColors,
                      begin: widget.headerBeginAlignment,
                      end: widget.headerEndAlignment,
                    )
                  ),
                  child: widget.plan.isPremium ? Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Chip(label: Text("Premium", style: TextStyle(color: colorScheme.onSecondaryContainer)), backgroundColor: colorScheme.secondaryContainer, visualDensity: VisualDensity.compact),
                      )
                  ) : null,
                ),
              ),
            ),
            SliverToBoxAdapter( /* ... content ... */ // Unchanged
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text(widget.plan.category, style: textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)), Text("${widget.plan.durationDays} Days", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), ],),
                    const SizedBox(height: 8.0),
                    Text(widget.plan.description, style: textTheme.bodyLarge),
                    const SizedBox(height: 16.0),
                    if(_progress != null && _progress!.isActive && !(_progress!.completedDays.length >= widget.plan.durationDays)) ...[
                      LinearProgressIndicator( value: widget.plan.durationDays > 0 ? _progress!.completedDays.length / widget.plan.durationDays : 0, minHeight: 8, borderRadius: BorderRadius.circular(4), backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5), valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),),
                      const SizedBox(height: 4),
                      Align( alignment: Alignment.centerRight, child: Text("${_progress!.completedDays.length} / ${widget.plan.durationDays} complete", style: textTheme.labelSmall) ),
                      const SizedBox(height: 16.0),
                    ],
                    Center(child: _buildActionButton()),
                    const SizedBox(height: 20.0),
                    Text("Daily Readings:", style: textTheme.headlineSmall),
                    const Divider(),
                  ],
                ),
              ),
            ),
            SliverList( /* ... list of days ... */ // Unchanged
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final day = widget.plan.dailyReadings[index];
                  bool isDayCompleted = _progress?.completedDays.containsKey(day.dayNumber) ?? false;
                  bool isCurrentActiveDay = _progress != null && _progress!.isActive && !isDayCompleted && _progress!.currentDayNumber == day.dayNumber;
                  return ListTile(
                    leading: CircleAvatar( backgroundColor: isDayCompleted ? Colors.green.shade100 : (isCurrentActiveDay ? colorScheme.primaryContainer : colorScheme.surfaceVariant), child: isDayCompleted ? Icon(Icons.check_circle, color: Colors.green.shade700) : Text( day.dayNumber.toString(), style: TextStyle( fontWeight: isCurrentActiveDay ? FontWeight.bold : FontWeight.normal, color: isCurrentActiveDay ? colorScheme.onPrimaryContainer : null), ),),
                    title: Text(day.title.isNotEmpty ? day.title : "Day ${day.dayNumber}", style: TextStyle(fontWeight: isCurrentActiveDay ? FontWeight.bold : FontWeight.normal)),
                    subtitle: Text(day.passages.map((p) => p.displayText).join('; ')),
                    trailing: isCurrentActiveDay && !isDayCompleted ? const Icon(Icons.arrow_forward_ios, size: 16) : (isDayCompleted ? null : Icon(Icons.circle_outlined, size:16, color: Colors.grey.shade400)),
                    onTap: () => _handleDayTap(day), 
                    tileColor: isCurrentActiveDay ? colorScheme.primaryContainer.withOpacity(0.3) : null,
                  );
                },
                childCount: widget.plan.dailyReadings.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 30)), 
          ],
        ),
      ),
    );
  }
}
