// lib/screens/reading_plan_detail_screen.dart
import 'package:flutter/material.dart';
import '../models.dart';
import '../database_helper.dart';
import '../helpers/ui_helpers.dart';
import 'daily_reading_screen.dart'; // Import the new screen

class ReadingPlanDetailScreen extends StatefulWidget {
  final ReadingPlan plan;
  final UserReadingProgress? initialProgress;

  const ReadingPlanDetailScreen({
    super.key,
    required this.plan,
    this.initialProgress,
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
    // If progress was passed, we use it. If not (e.g. deep link scenario), load it.
    // Also, if the plan was already active, the initialProgress might be stale if user
    // completed a day and came back. So a refresh on resume might be good eventually.
    // For now, we load if null.
    if (_progress == null && widget.initialProgress == null) { // Only load if initialProgress was also null
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
      print("Error loading progress for plan ${widget.plan.id}: $e");
      if (mounted) {
        setState(() => _isLoadingProgress = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not load plan progress: ${e.toString()}")));
      }
    }
  }

  Future<void> _startPlan() async {
    if (widget.plan.isPremium /* && !userIsPremium() */) { // Placeholder for premium check
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
      // Inform the list screen that a change was made by popping with 'true'
      // This ensures the list screen can refresh if it's listening for this result.
      // However, ReadingPlanListScreen's _navigateToPlanDetail already expects this.
      // For clarity, this pop should happen after specific actions, not just start.
      // The list screen will reload on pop if we pass true from here.
    }
  }

  Future<void> _handleDayTap(ReadingPlanDay day) async {
    if (_progress == null || !_progress!.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please start the plan to access daily readings.")),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyReadingScreen(
          planId: widget.plan.id,
          dayReading: day,
          planTitle: widget.plan.title,
        ),
      ),
    );

    if (result == true && mounted) {
      // A day was marked complete, refresh progress on this screen
      _loadProgress(); 
      // We also want to signal the ReadingPlansListScreen to refresh,
      // so when this screen (ReadingPlanDetailScreen) is popped,
      // it should also return true. We'll handle this on the back button.
      // Or, the list screen can just always refresh when it resumes.
    }
  }

  Widget _buildActionButton() {
    // ... (existing _buildActionButton logic - no changes needed here for Phase 3 navigation)
    // just ensure that the "Continue: Day X" button correctly calls _handleDayTap for the current day.
    if (_isLoadingProgress) return const Center(child: CircularProgressIndicator());

    bool isFullyCompleted = _progress != null && _progress!.completedDays.length >= widget.plan.durationDays;

    if (_progress == null || (!_progress!.isActive && !isFullyCompleted)) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.play_arrow),
        label: const Text("Start Plan"),
        onPressed: _startPlan,
        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
      );
    } else if (isFullyCompleted) {
       return Column(
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
    } else { // In progress and active
      // Ensure currentDayNumber is within bounds before trying to access dailyReadings
      final currentDayExists = _progress!.currentDayNumber > 0 && _progress!.currentDayNumber <= widget.plan.dailyReadings.length;
      ReadingPlanDay? currentDayReading;
      if(currentDayExists){
          currentDayReading = widget.plan.dailyReadings.firstWhere((day) => day.dayNumber == _progress!.currentDayNumber);
      }

      return ElevatedButton.icon(
        icon: const Icon(Icons.play_circle_outline),
        label: Text(currentDayExists ? "Continue: Day ${_progress!.currentDayNumber}" : "Review Plan"),
        onPressed: currentDayExists && currentDayReading != null ? () {
          _handleDayTap(currentDayReading!);
        } : null, // Disable if currentDayNumber is out of bounds (plan finished but not marked inactive)
         style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary, foregroundColor: Theme.of(context).colorScheme.onSecondary),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // This WillPopScope helps signal back to the ReadingPlansListScreen if progress might have changed.
    return WillPopScope(
      onWillPop: () async {
        // If progress might have changed (e.g., a day was completed, or plan started/restarted),
        // pop with true to signal ReadingPlansListScreen to refresh.
        // We assume any navigation to DailyReadingScreen and back means potential change.
        bool progressPotentiallyChanged = true; // Simple assumption for now
        Navigator.pop(context, progressPotentiallyChanged);
        return false; // We've handled the pop.
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              // Ensure back button pops with a result if changes were made
              leading: BackButton(onPressed: () {
                 // Assume any detail view interaction could mean progress needs refresh on list
                 Navigator.pop(context, true);
              }),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.plan.title, style: const TextStyle(shadows: [Shadow(blurRadius: 1.0, color: Colors.black54, offset: Offset(1,1))])),
                background: Container(
                  decoration: BoxDecoration(gradient: UiHelper.generateGradient(widget.plan.id)),
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.plan.category, style: textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                        Text("${widget.plan.durationDays} Days", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(widget.plan.description, style: textTheme.bodyLarge),
                    const SizedBox(height: 16.0),
                    if(_progress != null && _progress!.isActive && !(_progress!.completedDays.length >= widget.plan.durationDays)) ...[
                      LinearProgressIndicator(
                        value: widget.plan.durationDays > 0 ? _progress!.completedDays.length / widget.plan.durationDays : 0,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
                         valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                      const SizedBox(height: 4),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text("${_progress!.completedDays.length} / ${widget.plan.durationDays} complete", style: textTheme.labelSmall)
                      ),
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
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final day = widget.plan.dailyReadings[index];
                  bool isDayCompleted = _progress?.completedDays.containsKey(day.dayNumber) ?? false;
                  bool isCurrentActiveDay = _progress != null && _progress!.isActive && !isDayCompleted && _progress!.currentDayNumber == day.dayNumber;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isDayCompleted
                          ? Colors.green.shade100
                          : (isCurrentActiveDay ? colorScheme.primaryContainer : colorScheme.surfaceVariant),
                      child: isDayCompleted
                          ? Icon(Icons.check_circle, color: Colors.green.shade700)
                          : Text(
                              day.dayNumber.toString(),
                              style: TextStyle(
                                  fontWeight: isCurrentActiveDay ? FontWeight.bold : FontWeight.normal,
                                  color: isCurrentActiveDay ? colorScheme.onPrimaryContainer : null),
                            ),
                    ),
                    title: Text(day.title.isNotEmpty ? day.title : "Day ${day.dayNumber}", style: TextStyle(fontWeight: isCurrentActiveDay ? FontWeight.bold : FontWeight.normal)),
                    subtitle: Text(day.passages.map((p) => p.displayText).join('; ')),
                    trailing: isCurrentActiveDay && !isDayCompleted ? const Icon(Icons.arrow_forward_ios, size: 16) : (isDayCompleted ? null : Icon(Icons.circle_outlined, size:16, color: Colors.grey.shade400)),
                    onTap: () => _handleDayTap(day), // Allow tapping any day to view its content
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