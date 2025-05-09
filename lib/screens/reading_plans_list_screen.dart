// lib/screens/reading_plans_list_screen.dart
import 'package:flutter/material.dart';
import '../models.dart';
import '../reading_plans_data.dart'; 
import '../database_helper.dart';
import '../widgets/reading_plan_list_item.dart';
import 'reading_plan_detail_screen.dart'; 
import '../theme/app_colors.dart'; 

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

  final List<Alignment> _gradientAlignmentsBegin = [
    Alignment.topLeft, Alignment.topCenter, Alignment.topRight, Alignment.centerLeft,
    Alignment.bottomLeft, // Added more variety
    Alignment.center,
  ];
  final List<Alignment> _gradientAlignmentsEnd = [
    Alignment.bottomRight, Alignment.bottomCenter, Alignment.bottomLeft, Alignment.centerRight,
    Alignment.topRight, // Added more variety
    Alignment.center,
  ];

  @override
  void initState() {
    super.initState();
    _loadPlansAndProgress();
  }

  Future<void> _loadPlansAndProgress() async {
    // ... (no changes to this method from last version)
    setState(() { _isLoading = true; });
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
      setState(() {
        _progressMap = tempProgressMap;
        _isLoading = false;
      });
    }
  }

  void _navigateToPlanDetail(
    ReadingPlan plan, 
    List<Color> gradientColors, 
    Alignment beginAlignment, 
    Alignment endAlignment
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingPlanDetailScreen(
          plan: plan,
          initialProgress: _progressMap[plan.id], 
          headerGradientColors: gradientColors, // Pass gradient colors
          headerBeginAlignment: beginAlignment, // Pass begin alignment
          headerEndAlignment: endAlignment,     // Pass end alignment
        ),
      ),
    );
    if (result == true && mounted) { 
      _loadPlansAndProgress();
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
              ? const Center( /* ... empty state text ... */ 
                  child: Text(
                    "No reading plans available at the moment.\nCheck back soon!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPlansAndProgress,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: _plans.length,
                    itemBuilder: (context, index) {
                      final plan = _plans[index];
                      final List<Color> gradient = AppColors.getReadingPlanGradient(index);
                      final Alignment beginAlignment = _gradientAlignmentsBegin[index % _gradientAlignmentsBegin.length];
                      final Alignment endAlignment = _gradientAlignmentsEnd[index % _gradientAlignmentsEnd.length];

                      return ReadingPlanListItem(
                        plan: plan,
                        progress: _progressMap[plan.id],
                        onTap: () => _navigateToPlanDetail(plan, gradient, beginAlignment, endAlignment), // Pass them here
                        backgroundGradientColors: gradient, 
                        beginGradientAlignment: beginAlignment, 
                        endGradientAlignment: endAlignment,   
                      );
                    },
                  ),
                ),
    );
  }
}
