// lib/screens/reading_plans_list_screen.dart
// Path: lib/screens/reading_plans_list_screen.dart
// Approximate line: Entire File

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/reading_plan_service.dart'; 
import '../helpers/database_helper.dart';
import '../widgets/reading_plan_list_item.dart';
import 'reading_plan_detail_screen.dart';
import '../theme/app_colors.dart';
import '../helpers/prefs_helper.dart';

class ReadingPlansListScreen extends StatefulWidget {
  const ReadingPlansListScreen({super.key});

  @override
  State<ReadingPlansListScreen> createState() => _ReadingPlansListScreenState();
}

class _ReadingPlansListScreenState extends State<ReadingPlansListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ReadingPlanService _planService = ReadingPlanService();

  List<ReadingPlan> _plans = [];
  Map<String, UserReadingProgress> _progressMap = {};
  bool _isLoading = true;
  bool _devPremiumEnabled = false;

  // For generating varied gradients for list items
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
    _loadInitialData(); // Default forceRefresh is false
  }

  // Fetches all necessary data for the screen
  Future<void> _loadInitialData({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() { _isLoading = true; }); // Set loading true at the beginning
    
    // Load developer premium setting
    await PrefsHelper.init(); // Ensure SharedPreferences is initialized
    _devPremiumEnabled = PrefsHelper.getDevPremiumEnabled();
    
    // Load plans and their progress
    await _loadPlansAndProgress(doForceRefreshFirebase: forceRefresh); 
    
    if (mounted) {
      setState(() { _isLoading = false; }); // Set loading false after all data is fetched
    }
  }

  // Specifically loads plans from the service and then their progress from DB
  Future<void> _loadPlansAndProgress({bool doForceRefreshFirebase = false}) async {
    if (!mounted) return;
    // Note: _isLoading is managed by the calling function (_loadInitialData or onRefresh)

    try {
      // Fetch all plans (bundled + Firebase) using the service
      // Pass the force refresh flag to the service
      _plans = await _planService.getAllPlans(forceRefreshFirebase: doForceRefreshFirebase); 
      
      Map<String, UserReadingProgress> tempProgressMap = {};
      // Only try to load progress if plans were successfully loaded
      if (_plans.isNotEmpty) {
        for (var plan in _plans) {
          UserReadingProgress? progress = await _dbHelper.getReadingPlanProgress(plan.id);
          if (progress != null) {
            tempProgressMap[plan.id] = progress;
          }
        }
      }

      // Update state only if the widget is still mounted
      if (mounted) {
        setState(() { 
          _progressMap = tempProgressMap;
          // _isLoading state is handled by the caller (_loadInitialData / onRefresh)
        });
      }
    } catch (e) {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error loading plans or progress: ${e.toString()}"))
            );
            // Ensure state is updated to reflect error and stop loading
            setState(() { 
              _plans = []; // Clear plans on error to avoid displaying stale or partial data
              _progressMap = {};
            });
        }
        print("Error in _loadPlansAndProgress: $e");
    }
  }

  // Navigates to the detail screen for a selected plan
  void _navigateToPlanDetail(
    ReadingPlan plan,
    List<Color> gradientColors,
    Alignment beginAlignment,
    Alignment endAlignment
  ) async {
    if (!mounted) return; // Ensure widget is still in the tree

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

    // If the detail screen indicated a change (e.g., progress update, plan started/reset)
    if (result == true && mounted) {
      // Force a refresh, potentially fetching fresh data from Firebase
      _loadInitialData(forceRefresh: true); 
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
              ? Center( // Displayed when no plans are loaded (e.g., after an error or if none exist)
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.playlist_remove_rounded, size: 60, color: Colors.grey),
                        const SizedBox(height: 20),
                        const Text(
                          "No reading plans available at the moment.\nPlease check back later or try refreshing.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text("Try Again"),
                          onPressed: () => _loadInitialData(forceRefresh: true),
                        )
                      ],
                    ),
                  )
                )
              : RefreshIndicator(
                  onRefresh: () => _loadInitialData(forceRefresh: true), 
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: _plans.length,
                    itemBuilder: (context, index) {
                      final plan = _plans[index];
                      // Cycle through predefined gradients for visual variety
                      final List<Color> gradient = AppColors.getReadingPlanGradient(index);
                      final Alignment beginAlignment = _gradientAlignmentsBegin[index % _gradientAlignmentsBegin.length];
                      final Alignment endAlignment = _gradientAlignmentsEnd[index % _gradientAlignmentsEnd.length];
                      
                      // Determine if the plan should be displayed as locked
                      final bool isPlanEffectivelyLocked = plan.isPremium && !_devPremiumEnabled;

                      return ReadingPlanListItem(
                        plan: plan,
                        progress: _progressMap[plan.id],
                        onTap: () => _navigateToPlanDetail(plan, gradient, beginAlignment, endAlignment),
                        backgroundGradientColors: gradient,
                        beginGradientAlignment: beginAlignment,
                        endGradientAlignment: endAlignment,
                        isPlanEffectivelyLocked: isPlanEffectivelyLocked,
                      );
                    },
                  ),
                ),
    );
  }
}