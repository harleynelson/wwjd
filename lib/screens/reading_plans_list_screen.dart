// lib/screens/reading_plans_list_screen.dart
import 'package:flutter/material.dart';
import '../models.dart';
import '../reading_plans_data.dart'; // Your hardcoded plans
import '../database_helper.dart';
import '../widgets/reading_plan_list_item.dart';
import 'reading_plan_detail_screen.dart'; // We'll create this next

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

  @override
  void initState() {
    super.initState();
    _loadPlansAndProgress();
  }

  Future<void> _loadPlansAndProgress() async {
    setState(() {
      _isLoading = true;
    });

    // Load static plan definitions
    _plans = List<ReadingPlan>.from(allReadingPlans); // Make a mutable copy if needed for sorting/filtering later
    
    Map<String, UserReadingProgress> tempProgressMap = {};
    try {
      for (var plan in _plans) {
        UserReadingProgress? progress = await _dbHelper.getReadingPlanProgress(plan.id);
        if (progress != null) {
          tempProgressMap[plan.id] = progress;
        }
      }
    } catch (e) {
        print("Error loading reading plan progresses: $e");
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

  void _navigateToPlanDetail(ReadingPlan plan) async {
    // Navigate and await result in case detail screen modifies progress
    // and we want to refresh this list screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingPlanDetailScreen(
          plan: plan,
          initialProgress: _progressMap[plan.id], // Pass initial progress
        ),
      ),
    );

    // If the detail screen indicates a change (e.g., plan started/progressed), refresh.
    if (result == true && mounted) { // Use a boolean flag or specific result type
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
              ? const Center(
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
                      return ReadingPlanListItem(
                        plan: plan,
                        progress: _progressMap[plan.id],
                        onTap: () => _navigateToPlanDetail(plan),
                      );
                    },
                  ),
                ),
    );
  }
}