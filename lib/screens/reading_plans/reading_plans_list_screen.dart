// lib/screens/reading_plans_list_screen.dart
// Path: lib/screens/reading_plans_list_screen.dart
// Approximate line: Entire File (Significant Changes)

import 'package:flutter/material.dart';
import 'dart:math'; // For randomizing 'Other Plans'
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Firebase
import '../../models/models.dart';
import '../../services/reading_plan_service.dart';
import '../../helpers/database_helper.dart';
import '../../widgets/reading_plans/reading_plan_list_item.dart';
import 'reading_plan_detail_screen.dart';
import '../../theme/app_colors.dart';
import '../../helpers/prefs_helper.dart';

class ReadingPlansListScreen extends StatefulWidget {
  const ReadingPlansListScreen({super.key});

  @override
  State<ReadingPlansListScreen> createState() => _ReadingPlansListScreenState();
}

class _ReadingPlansListScreenState extends State<ReadingPlansListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ReadingPlanService _planService = ReadingPlanService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Added Firebase instance

  List<ReadingPlan> _featuredPlans = [];
  Map<String, int> _featuredPlansOrder = {};
  List<ReadingPlan> _activePlans = [];
  List<ReadingPlan> _otherPlans = [];

  Map<String, UserReadingProgress> _progressMap = {};
  bool _isLoading = true;
  bool _devPremiumEnabled = false;

  final List<Alignment> _gradientAlignmentsBegin = [
    Alignment.topLeft, Alignment.topCenter, Alignment.topRight, Alignment.centerLeft,
    Alignment.bottomLeft, Alignment.center,
  ];
  final List<Alignment> _gradientAlignmentsEnd = [
    Alignment.bottomRight, Alignment.bottomCenter, Alignment.bottomLeft, Alignment.centerRight,
    Alignment.topRight, Alignment.center,
  ];
  final Random _random = Random(); // For shuffling 'Other Plans'

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() { _isLoading = true; });
    print("[ReadingPlansListScreen] Starting _loadInitialData (forceRefresh: $forceRefresh)");

    await PrefsHelper.init();
    _devPremiumEnabled = PrefsHelper.getDevPremiumEnabled();
    print("[ReadingPlansListScreen] Dev Premium Enabled: $_devPremiumEnabled");

    try {
      // 1. Fetch Featured Plan IDs and Order from Firestore
      List<String> featuredPlanIdsFromFirestore = [];
      Map<String, int> tempFeaturedPlansOrder = {}; // Use a temporary map for clarity

      try {
        print("[ReadingPlansListScreen] Fetching Featured_content from Firestore...");
        DocumentSnapshot featuredContentDoc = await _firestore
            .collection('app_settings')
            .doc('featured_content')
            .get(const GetOptions(source: Source.serverAndCache)); // Try server first, then cache

        if (featuredContentDoc.exists) {
          print("[ReadingPlansListScreen] Featured_content document found.");
          final data = featuredContentDoc.data() as Map<String, dynamic>?;
          if (data != null) {
            print("[ReadingPlansListScreen] Featured_content data: $data");
            featuredPlanIdsFromFirestore = List<String>.from(data['featuredPlanIds'] ?? []);
            print("[ReadingPlansListScreen] Raw featuredPlanIds from Firestore: $featuredPlanIdsFromFirestore");

            final dynamicOrderMap = data['featuredPlansOrder'];
            if (dynamicOrderMap is Map) {
              tempFeaturedPlansOrder = dynamicOrderMap.map((key, value) {
                int orderValue = 999; // Default if parsing fails or type is unexpected
                if (value is int) {
                  orderValue = value;
                } else if (value is String) {
                  orderValue = int.tryParse(value) ?? 999;
                } else if (value is double) {
                  orderValue = value.toInt();
                }
                return MapEntry(key.toString(), orderValue);
              });
              print("[ReadingPlansListScreen] Parsed featuredPlansOrder: $tempFeaturedPlansOrder");
            } else {
              print("[ReadingPlansListScreen] featuredPlansOrder field is not a Map or is null.");
            }
            _featuredPlansOrder = tempFeaturedPlansOrder; // Assign to state variable
          } else {
            print("[ReadingPlansListScreen] Featured_content data is null.");
          }
        } else {
          print("[ReadingPlansListScreen] Featured_content document does NOT exist.");
        }
      } catch (e) {
        print("[ReadingPlansListScreen] Error fetching featured content from Firestore: $e");
        // Continue without featured plans if Firestore fetch fails, lists will be empty
      }

      // 2. Fetch All Plans (Bundled + Firebase if applicable by service)
      print("[ReadingPlansListScreen] Fetching all plans from ReadingPlanService...");
      List<ReadingPlan> allFetchedPlans = await _planService.getAllPlans(forceRefreshFirebase: forceRefresh);
      print("[ReadingPlansListScreen] Fetched ${allFetchedPlans.length} total plans from service.");

      // 3. Fetch All Progress
      print("[ReadingPlansListScreen] Fetching all reading plan progresses from DB...");
      List<UserReadingProgress> allProgressList = await _dbHelper.getAllReadingPlanProgresses();
      _progressMap = {for (var p in allProgressList) p.planId: p};
      print("[ReadingPlansListScreen] Fetched progress for ${_progressMap.length} plans.");

      // 4. Categorize Plans
      List<ReadingPlan> tempFeaturedPlans = [];
      List<ReadingPlan> tempActivePlans = [];
      List<ReadingPlan> tempOtherPlans = [];
      Set<String> processedPlanIds = {};

      // Populate Featured Plans
      if (featuredPlanIdsFromFirestore.isNotEmpty) {
        print("[ReadingPlansListScreen] Processing ${featuredPlanIdsFromFirestore.length} featured plan IDs...");
        for (String id in featuredPlanIdsFromFirestore) {
          try {
            ReadingPlan plan = allFetchedPlans.firstWhere((p) => p.id == id);
            tempFeaturedPlans.add(plan);
            processedPlanIds.add(id);
            print("[ReadingPlansListScreen] Found and added featured plan: ${plan.title} (ID: $id)");
          } catch (e) {
            print("[ReadingPlansListScreen] Featured plan with ID '$id' NOT FOUND in allFetchedPlans. It may have failed to load or ID is incorrect.");
          }
        }
        tempFeaturedPlans.sort((a, b) {
          int orderA = _featuredPlansOrder[a.id] ?? 999;
          int orderB = _featuredPlansOrder[b.id] ?? 999;
          return orderA.compareTo(orderB);
        });
      } else {
        print("[ReadingPlansListScreen] No featured plan IDs found in Firestore or list was empty.");
      }
      _featuredPlans = tempFeaturedPlans;
      print("[ReadingPlansListScreen] Populated ${_featuredPlans.length} featured plans.");

      // Populate Active Plans
      print("[ReadingPlansListScreen] Processing active plans...");
      for (var progress in allProgressList) {
        // Find the plan details from allFetchedPlans
        ReadingPlan? planDetails;
        try {
          planDetails = allFetchedPlans.firstWhere((p) => p.id == progress.planId);
        } catch (e) {
           print("[ReadingPlansListScreen] Plan details for active progress (ID: ${progress.planId}) not found in allFetchedPlans. Skipping.");
           continue;
        }

        if (progress.isActive && (progress.completedDays.length < planDetails.durationDays)) {
          if (!processedPlanIds.contains(progress.planId)) {
            tempActivePlans.add(planDetails);
            processedPlanIds.add(progress.planId);
            print("[ReadingPlansListScreen] Added active plan: ${planDetails.title} (ID: ${progress.planId})");
          } else {
             print("[ReadingPlansListScreen] Plan ID ${progress.planId} is active but already processed (likely featured). Skipping for active list.");
          }
        }
      }
      tempActivePlans.sort((a, b) {
          DateTime? startDateA = _progressMap[a.id]?.startDate;
          DateTime? startDateB = _progressMap[b.id]?.startDate;
          if(startDateA != null && startDateB != null) {
              return startDateB.compareTo(startDateA); // Most recent first
          }
          return a.title.compareTo(b.title);
      });
      _activePlans = tempActivePlans;
      print("[ReadingPlansListScreen] Populated ${_activePlans.length} active plans.");

      // Populate Other Plans
      print("[ReadingPlansListScreen] Processing other plans...");
      for (var plan in allFetchedPlans) {
        if (!processedPlanIds.contains(plan.id)) {
          tempOtherPlans.add(plan);
        }
      }
      tempOtherPlans.shuffle(_random);
      _otherPlans = tempOtherPlans;
      print("[ReadingPlansListScreen] Populated ${_otherPlans.length} other plans.");

    } catch (e, s) { // Added stack trace
      print("[ReadingPlansListScreen] CRITICAL Error in _loadInitialData: $e");
      print("[ReadingPlansListScreen] Stack Trace: $s"); // Log stack trace
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Critical error loading reading plans: ${e.toString()}")));
      }
       _featuredPlans = [];
       _activePlans = [];
       _otherPlans = [];
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
        print("[ReadingPlansListScreen] _loadInitialData finished. isLoading: $_isLoading");
      }
    }
  }

  void _navigateToPlanDetail(
    ReadingPlan plan,
    List<Color> gradientColors,
    Alignment beginAlignment,
    Alignment endAlignment
  ) async {
    if (!mounted) return;

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
      _loadInitialData(forceRefresh: true);
    }
  }

  Widget _buildHorizontalPlanList(List<ReadingPlan> plans, String sectionTitle) {
    if (plans.isEmpty) {
      return const SizedBox.shrink(); // Don't show section if no plans
    }

    // Determine a fixed height for items in horizontal lists
    // This ensures the horizontal list has a consistent child extent.
    // This value might need adjustment based on your ReadingPlanListItem's content.
    const double itemHeight = 240.0; // Approximate height of ReadingPlanListItem
    const double itemWidth = 280.0; // Width for items in horizontal scroll

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
          child: Text(
            sectionTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: itemHeight, // Constrain the height of the horizontal ListView
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0), // Padding for the list itself
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              final List<Color> gradient = AppColors.getReadingPlanGradient(index + (sectionTitle == "Featured Plans" ? 0 : _featuredPlans.length)); // Offset gradient index
              final Alignment beginAlignment = _gradientAlignmentsBegin[(index + _featuredPlans.length) % _gradientAlignmentsBegin.length];
              final Alignment endAlignment = _gradientAlignmentsEnd[(index + _featuredPlans.length) % _gradientAlignmentsEnd.length];
              final bool isPlanEffectivelyLocked = plan.isPremium && !_devPremiumEnabled;

              return Container(
                width: itemWidth, // Fixed width for horizontal items
                margin: const EdgeInsets.only(right: 12.0), // Space between items
                child: ReadingPlanListItem(
                  plan: plan,
                  progress: _progressMap[plan.id],
                  onTap: () => _navigateToPlanDetail(plan, gradient, beginAlignment, endAlignment),
                  backgroundGradientColors: gradient,
                  beginGradientAlignment: beginAlignment,
                  endGradientAlignment: endAlignment,
                  isPlanEffectivelyLocked: isPlanEffectivelyLocked,
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reading Plans"),
         actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Plans",
            onPressed: () => _loadInitialData(forceRefresh: true),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_featuredPlans.isEmpty && _activePlans.isEmpty && _otherPlans.isEmpty)
              ? Center(
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
                  child: ListView( // Changed to ListView to accommodate multiple sections
                    children: [
                      _buildHorizontalPlanList(_featuredPlans, "Featured Plans"),
                      _buildHorizontalPlanList(_activePlans, "Active Plans"),

                      // Section for "Other Plans" (vertically scrolling list)
                      if (_otherPlans.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
                          child: Text(
                            "Explore More Plans",
                             style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ListView.builder(
                        shrinkWrap: true, // Important for nested ListViews
                        physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this inner list
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        itemCount: _otherPlans.length,
                        itemBuilder: (context, index) {
                          final plan = _otherPlans[index];
                          final List<Color> gradient = AppColors.getReadingPlanGradient(index + _featuredPlans.length + _activePlans.length);
                          final Alignment beginAlignment = _gradientAlignmentsBegin[(index + _featuredPlans.length + _activePlans.length) % _gradientAlignmentsBegin.length];
                          final Alignment endAlignment = _gradientAlignmentsEnd[(index + _featuredPlans.length + _activePlans.length) % _gradientAlignmentsEnd.length];
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
                      const SizedBox(height: 20), // Padding at the bottom
                    ],
                  ),
                ),
    );
  }
}