// lib/screens/reading_plans/reading_plan_detail_screen.dart
// Path: lib/screens/reading_plans/reading_plan_detail_screen.dart
// Updated to use ReadingDayListItem.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wwjd_app/models/models.dart';
import 'package:wwjd_app/helpers/database_helper.dart';
import 'package:wwjd_app/models/reader_settings_enums.dart';
import 'package:wwjd_app/helpers/prefs_helper.dart';
import 'package:wwjd_app/screens/daily_reading_screen.dart';
import 'package:wwjd_app/widgets/reading_plans/reading_plan_action_button.dart';
import 'package:wwjd_app/widgets/reading_plans/reading_day_list_item.dart'; // NEW IMPORT

class ReadingPlanDetailScreen extends StatefulWidget {
  final ReadingPlan plan;
  final UserReadingProgress? initialProgress;
  final List<Color> headerGradientColors;
  final Alignment headerBeginAlignment;
  final Alignment headerEndAlignment;

  const ReadingPlanDetailScreen({
    super.key,
    required this.plan,
    this.initialProgress,
    required this.headerGradientColors,
    required this.headerBeginAlignment,
    required this.headerEndAlignment,
  });

  @override
  State<ReadingPlanDetailScreen> createState() => _ReadingPlanDetailScreenState();
}

class _ReadingPlanDetailScreenState extends State<ReadingPlanDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  UserReadingProgress? _progress;
  bool _isLoadingProgress = false;
  bool _devPremiumEnabled = false;

  @override
  void initState() {
    super.initState();
    _progress = widget.initialProgress;
    _devPremiumEnabled = PrefsHelper.getDevPremiumEnabled();

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
    bool effectivelyHasPremiumAccess = _devPremiumEnabled || !widget.plan.isPremium;

    if (widget.plan.isPremium && !effectivelyHasPremiumAccess) {
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
       Navigator.pop(context, true);
    }
  }
   Future<void> _restartPlan() async {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Restart Plan?"),
          content: const Text("This will delete your current progress for this plan and restart it from Day 1. Are you sure?"),
          actions: [
            TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop(false)),
            TextButton(child: Text("Restart", style: TextStyle(color: Theme.of(context).colorScheme.error)), onPressed: () => Navigator.of(ctx).pop(true)),
          ],
        )
      );
      if (confirm == true) {
        if (mounted) setState(() => _isLoadingProgress = true);
        await _dbHelper.deleteReadingPlanProgress(widget.plan.id);
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
          Navigator.pop(context, true);
        }
      }
  }


  Future<void> _handleDayTap(ReadingPlanDay day) async {
    if (_progress == null || !_progress!.isActive) {
      bool effectivelyHasPremiumAccess = _devPremiumEnabled || !widget.plan.isPremium;
      bool planRequiresPremiumAndNotOwned = widget.plan.isPremium && !effectivelyHasPremiumAccess;

      bool? confirmStart = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(planRequiresPremiumAndNotOwned ? "Unlock Premium Plan?" : "Start Reading Plan?"),
          content: Text(planRequiresPremiumAndNotOwned
              ? "To access '${widget.plan.title}', please unlock our premium features."
              : "Would you like to start the reading plan '${widget.plan.title}' to view Day ${day.dayNumber}?"),
          actions: [
            TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop(false)),
            TextButton(
              child: Text(planRequiresPremiumAndNotOwned ? "Unlock (Coming Soon)" : "Start Plan"),
              onPressed: planRequiresPremiumAndNotOwned ? null : () => Navigator.of(ctx).pop(true)
            ),
          ],
        )
      );
      if (confirmStart == true && !planRequiresPremiumAndNotOwned) {
        await _startPlan();
        if (_progress != null && _progress!.isActive) {
           _navigateToDailyReading(day);
        }
      }
      return;
    }
     _navigateToDailyReading(day);
  }

  Future<void> _navigateToDailyReading(ReadingPlanDay day) async {
    final ReaderThemeMode themeMode = PrefsHelper.getReaderThemeMode();
    final double fontSizeDelta = PrefsHelper.getReaderFontSizeDelta();
    final ReaderFontFamily fontFamily = PrefsHelper.getReaderFontFamily();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyReadingScreen(
          planId: widget.plan.id,
          dayReading: day,
          planTitle: widget.plan.title,
          readerThemeMode: themeMode,
          fontSizeDelta: fontSizeDelta,
          readerFontFamily: fontFamily,
        ),
      ),
    );

    if (result == true && mounted) {
      _loadProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Widget headerContent;
    if (widget.plan.headerImageAssetPath != null && widget.plan.headerImageAssetPath!.isNotEmpty) {
      headerContent = Image.asset(
        widget.plan.headerImageAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.headerGradientColors,
                begin: widget.headerBeginAlignment,
                end: widget.headerEndAlignment,
              ),
            ),
          );
        },
      );
    } else {
      headerContent = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.headerGradientColors,
            begin: widget.headerBeginAlignment,
            end: widget.headerEndAlignment,
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              iconTheme: const IconThemeData(color: Colors.white),
              actionsIconTheme: const IconThemeData(color: Colors.white),
              systemOverlayStyle: SystemUiOverlayStyle.light,
              leading: BackButton(
                onPressed: () {
                   Navigator.pop(context, true);
                }
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.plan.title,
                  style: const TextStyle(
                    color: Colors.white,
                    shadows: [
                      Shadow(blurRadius: 2.0, color: Colors.black87, offset: Offset(1,1))
                    ]
                  )
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    headerContent,
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.60),
                            Colors.black.withOpacity(0.30),
                            Colors.black.withOpacity(0.70),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    if (widget.plan.isPremium)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8.0,
                        right: 16.0,
                        child: Chip(
                          label: Text("Premium", style: TextStyle(color: colorScheme.onSecondaryContainer, fontSize: 10, fontWeight: FontWeight.bold)),
                          backgroundColor: colorScheme.secondaryContainer.withOpacity(0.8),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                        ),
                      ),
                  ],
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
                    Center(
                      child: ReadingPlanActionButton( // Using the extracted widget
                        isLoadingProgress: _isLoadingProgress,
                        progress: _progress,
                        plan: widget.plan,
                        devPremiumEnabled: _devPremiumEnabled,
                        onStartPlan: _startPlan,
                        onContinuePlan: (ReadingPlanDay day) => _navigateToDailyReading(day),
                        onRestartPlan: _restartPlan,
                      ),
                    ),
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
                  
                  // Using the new ReadingDayListItem widget
                  return ReadingDayListItem(
                    day: day,
                    isCompleted: isDayCompleted,
                    isCurrentActiveDay: isCurrentActiveDay,
                    onTap: () => _handleDayTap(day),
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