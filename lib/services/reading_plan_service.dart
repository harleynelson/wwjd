// lib/services/reading_plan_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class ReadingPlanService {
  List<ReadingPlan> _bundledPlans = [];
  bool _areBundledPlansLoaded = false;
  List<ReadingPlan> _firebasePlans = [];
  bool _areFirebasePlansFetched = false;
  DateTime? _lastFirebaseFetchTime;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ReadingPlanService() {
    // _loadBundledPlans(); // Optional
  }

  Future<void> _loadBundledPlans() async {
    if (_areBundledPlansLoaded) return;
    try {
      final List<String> bundledPlanFiles = [
        'rp_genesis_intro.json',
        'rp_john_gospel_7day.json',
        'rp_biblical_silences_5day.json',
        'rp_evolving_understandings_5day.json',
        'rp_love_your_neighbor_7day.json',
        'rp_creation_care_7day.json',
      ];
      List<ReadingPlan> loadedPlans = [];
      for (String fileName in bundledPlanFiles) {
        try {
          final String jsonString = await rootBundle.loadString('assets/reading_plans/$fileName');
          final Map<String, dynamic> jsonMap = json.decode(jsonString);
          loadedPlans.add(ReadingPlan.fromJson(jsonMap));
        } catch (e) {
          print("Error loading or parsing bundled plan '$fileName': $e");
        }
      }
      _bundledPlans = loadedPlans;
      _areBundledPlansLoaded = true;
      print("ReadingPlanService: Loaded ${_bundledPlans.length} bundled reading plans.");
    } catch (e) {
      print("ReadingPlanService: Error loading bundled reading plans: $e");
      _bundledPlans = [];
      _areBundledPlansLoaded = false;
    }
  }

  Future<void> _fetchPlansFromFirebase({bool forceRefresh = false}) async {
    if (_areFirebasePlansFetched && !forceRefresh) {
      if (_lastFirebaseFetchTime != null && DateTime.now().difference(_lastFirebaseFetchTime!).inMinutes < 60) {
        return;
      }
    }
    print("ReadingPlanService: Fetching plans from Firebase (forceRefresh: $forceRefresh)...");
    try {
      QuerySnapshot snapshot = await _firestore.collection('reading_plans').get();
      _firebasePlans = snapshot.docs
          .map((doc) {
            try {
              return ReadingPlan.fromJson(doc.data() as Map<String, dynamic>);
            } catch (e) {
              print("ReadingPlanService: Error parsing Firebase plan ${doc.id}: $e");
              return null;
            }
          })
          .whereType<ReadingPlan>()
          .toList();
      _areFirebasePlansFetched = true;
      _lastFirebaseFetchTime = DateTime.now();
      print("ReadingPlanService: Fetched ${_firebasePlans.length} plans from Firebase.");
    } catch (e) {
      print("ReadingPlanService: Error fetching plans from Firebase: $e");
      _areFirebasePlansFetched = false;
    }
  }

  // MODIFIED: Added {bool forceRefreshFirebase = false}
  Future<List<ReadingPlan>> getAllPlans({bool forceRefreshFirebase = false}) async {
    if (!_areBundledPlansLoaded) {
      await _loadBundledPlans();
    }

    // Pass the forceRefreshFirebase flag to _fetchPlansFromFirebase
    await _fetchPlansFromFirebase(forceRefresh: forceRefreshFirebase);

    Map<String, ReadingPlan> planMap = {};
    for (var plan in _bundledPlans) {
      planMap[plan.id] = plan;
    }

    for (var firebasePlan in _firebasePlans) {
      if (planMap.containsKey(firebasePlan.id)) {
        ReadingPlan bundledPlan = planMap[firebasePlan.id]!;
        if ((firebasePlan.version) > (bundledPlan.version)) {
          planMap[firebasePlan.id] = firebasePlan;
          print("ReadingPlanService: Using newer Firebase version for plan '${firebasePlan.id}' (v${firebasePlan.version} > bundled v${bundledPlan.version})");
        }
      } else {
        planMap[firebasePlan.id] = firebasePlan;
      }
    }

    List<ReadingPlan> allAvailablePlans = planMap.values.toList();
    allAvailablePlans.sort((a, b) {
      if (a.isPremium && !b.isPremium) return -1;
      if (!a.isPremium && b.isPremium) return 1;
      return a.title.compareTo(b.title);
    });

    print("ReadingPlanService: Total available unique plans after merge: ${allAvailablePlans.length}");
    return allAvailablePlans;
  }

  // MODIFIED: Added {bool forceRefreshFirebase = false} to match getAllPlans
  Future<ReadingPlan?> getPlanById(String planId, {bool forceRefreshFirebase = false}) async {
    if (!_areBundledPlansLoaded) {
      await _loadBundledPlans();
    }
    // Use the same forceRefresh flag for fetching if a direct ID lookup also needs fresh data
    await _fetchPlansFromFirebase(forceRefresh: forceRefreshFirebase);

    ReadingPlan? bundledVersion;
    try {
      bundledVersion = _bundledPlans.firstWhere((plan) => plan.id == planId);
    } catch (e) { /* Not found */ }

    ReadingPlan? firebaseVersion;
    try {
      firebaseVersion = _firebasePlans.firstWhere((plan) => plan.id == planId);
    } catch (e) { /* Not found */ }

    if (firebaseVersion != null) {
      if (bundledVersion != null) {
        return (firebaseVersion.version) > (bundledVersion.version) ? firebaseVersion : bundledVersion;
      }
      return firebaseVersion;
    }
    return bundledVersion;
  }
}