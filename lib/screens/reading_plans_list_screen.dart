// lib/screens/reading_plans_list_screen.dart
// Path: lib/screens/reading_plans_list_screen.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../helpers/reading_plans_data.dart';
import '../helpers/database_helper.dart';
import '../widgets/reading_plan_list_item.dart';
import 'reading_plan_detail_screen.dart';
import '../theme/app_colors.dart';
// --- NEW IMPORT ---
import '../helpers/prefs_helper.dart';

class ReadingPlansListScreen extends StatefulWidget {
  const ReadingPlansListScreen({super.key});

  @override
  State<ReadingPlansListScreen> createState() => _ReadingPlansListScreenState();
}

class _ReadingPlansListScreenState extends State<ReadingPlansListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<ReadingPlan> _plans = [];
  Map<String, UserReadingProgress> _progressMap = {};
  bool _isLoading = true;
  // --- NEW STATE for dev premium status ---
  bool _devPremiumEnabled = false;

  final List<Alignment> _gradientAlignmentsBegin = [
    Alignment.topLeft, Alignment.topCenter, Alignment.topRight, Alignment.centerLeft,
    Alignment.bottomLeft,
    Alignment.center,
  ];
  final List<Alignment> _gradientAlignmentsEnd = [
    Alignment.bottomRight, Alignment.bottomCenter, Alignment.bottomLeft, Alignment.centerRight,
    Alignment.topRight,
    Alignment.center,
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() { _isLoading = true; });
    // Load dev premium status first
    await PrefsHelper.init(); // Ensure prefs are initialized
    _devPremiumEnabled = PrefsHelper.getDevPremiumEnabled();
    await _loadPlansAndProgress();
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _loadPlansAndProgress() async {
    // No need to set _isLoading here if _loadInitialData handles it
    _plans = List<ReadingPlan>.from(allReadingPlans);
    Map<String, UserReadingProgress> tempProgressMap = {};
    try {
      for (var plan in _plans) {
        UserReadingProgress? progress = await _dbHelper.getReadingPlanProgress(plan.id);
        if (progress != null) {
          tempProgressMap[plan.id] = progress;
        }
      }
    } catch (e) {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error loading plan progress: ${e.toString()}"))
            );
        }
    }
    if (mounted) {
      // This setState will be called by _loadInitialData or onRefresh
      _progressMap = tempProgressMap;
    }
  }

  void _navigateToPlanDetail(
    ReadingPlan plan,
    List<Color> gradientColors,
    Alignment beginAlignment,
    Alignment endAlignment
  ) async {
    // When navigating, ReadingPlanDetailScreen will also load _devPremiumEnabled in its own initState
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingPlanDetailScreen(
          plan: plan,
          initialProgress: _progressMap[plan.id],
          headerGradientColors: gradientColors,
          headerBeginAlignment: beginAlignment,
          headerEndAlignment: endAlignment,
        ),
      ),
    );
    if (result == true && mounted) {
      // Refresh data which includes reloading dev premium status
      _loadInitialData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reading Plans"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plans.isEmpty
              ? const Center(
                  child: Text(
                    "No reading plans available at the moment.\nCheck back soon!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadInitialData, // Use _loadInitialData to also refresh dev setting
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: _plans.length,
                    itemBuilder: (context, index) {
                      final plan = _plans[index];
                      final List<Color> gradient = AppColors.getReadingPlanGradient(index);
                      final Alignment beginAlignment = _gradientAlignmentsBegin[index % _gradientAlignmentsBegin.length];
                      final Alignment endAlignment = _gradientAlignmentsEnd[index % _gradientAlignmentsEnd.length];

                      // --- Determine if plan should be treated as locked ---
                      final bool isPlanEffectivelyLocked = plan.isPremium && !_devPremiumEnabled;
                      // --- END ---

                      return ReadingPlanListItem(
                        plan: plan,
                        progress: _progressMap[plan.id],
                        onTap: () => _navigateToPlanDetail(plan, gradient, beginAlignment, endAlignment),
                        backgroundGradientColors: gradient,
                        beginGradientAlignment: beginAlignment,
                        endGradientAlignment: endAlignment,
                        // --- PASS new parameter ---
                        isPlanEffectivelyLocked: isPlanEffectivelyLocked,
                      );
                    },
                  ),
                ),
    );
  }
}