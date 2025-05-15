// File: lib/services/prayer_service.dart
// Purpose: Handles all Firebase interactions related to the Prayer Wall feature.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode and BuildContext
import 'package:flutter/material.dart';    // For BuildContext
import 'package:provider/provider.dart'; // For accessing AppUser from context
import 'package:uuid/uuid.dart'; // For generating unique IDs (UUIDs)

// Import models used by this service
import '../models/prayer_request_model.dart';
import '../models/prayer_interaction_model.dart';
import '../models/user_prayer_profile_model.dart';
import '../models/app_user.dart'; // Your custom AppUser model

class PrayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid(); // For generating unique anonymous IDs

  // Firestore collection references for cleaner code
  CollectionReference<Map<String, dynamic>> get _prayerRequestsRef =>
      _firestore.collection('prayerRequests');
  CollectionReference<Map<String, dynamic>> get _prayerInteractionsRef =>
      _firestore.collection('prayerInteractions');
  CollectionReference<Map<String, dynamic>> get _userPrayerProfilesRef =>
      _firestore.collection('userPrayerProfiles');

  // Getter for the current Firebase authenticated user
  User? get _currentUser => _auth.currentUser;

  // --- User Profile and Anonymous ID Management ---

  /// Gets or creates a prayer profile for the current user from Firestore.
  /// This profile stores the user's anonymous prayer ID and premium status for prayer limits.
  /// Requires [BuildContext] to access [AppUser] via Provider for the most up-to-date premium status.
  Future<UserPrayerProfile> _getOrCreateUserPrayerProfile(BuildContext context) async {
    if (_currentUser == null) {
      throw Exception("User not authenticated. Cannot manage prayer profile.");
    }
    final String userId = _currentUser!.uid;
    final docRef = _userPrayerProfilesRef.doc(userId);
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await docRef.get();

    // Attempt to get the AppUser from Provider to check the latest premium status.
    // This assumes AppUser? is available via StreamProvider higher up the widget tree.
    final AppUser? appUser = Provider.of<AppUser?>(context, listen: false);

    if (appUser == null && kDebugMode) {
      // This indicates a potential issue in app state management or call timing.
      // AppUser should ideally be loaded before actions requiring its data are performed.
      print("Warning: AppUser is null in _getOrCreateUserPrayerProfile. Premium status might be based on stale data or default to false.");
    }
    
    // Determine the user's premium status. Default to false if AppUser or its premium flag is null.
    bool isUserPremium = appUser?.isPremium ?? false;

    if (snapshot.exists) {
      // UserPrayerProfile document exists, parse it.
      UserPrayerProfile profile = UserPrayerProfile.fromFirestore(snapshot);
      // Update the profile's premium status if it differs from the AppUser's current status.
      if (profile.isPremium != isUserPremium) {
        profile.isPremium = isUserPremium;
        await docRef.set(profile.toFirestore(), SetOptions(merge: true));
      }
      return profile;
    } else {
      // No UserPrayerProfile document exists, create a new one.
      final newAnonymousId = _uuid.v4(); // Generate a new unique anonymous ID.
      final newProfile = UserPrayerProfile(
        userId: userId,
        submitterAnonymousId: newAnonymousId,
        isPremium: isUserPremium, // Set premium status based on current AppUser data.
        freePrayersSubmittedThisPeriod: 0,
        lastFreePrayerDate: null,
      );
      await docRef.set(newProfile.toFirestore());
      return newProfile;
    }
  }

  /// Retrieves the current user's submitterAnonymousId.
  /// Requires [BuildContext] to pass to [_getOrCreateUserPrayerProfile].
  Future<String?> getCurrentUserSubmitterAnonymousId(BuildContext context) async {
    if (_currentUser == null) return null; // No user logged in.
    try {
      final profile = await _getOrCreateUserPrayerProfile(context);
      return profile.submitterAnonymousId;
    } catch (e) {
      print("Error getting current user's submitterAnonymousId: $e");
      return null;
    }
  }

  // --- Prayer Submission ---

  /// Submits a new prayer request.
  /// Requires [BuildContext] to access user's premium status for limit checks.
  /// Returns a map with 'prayerId' and 'submitterAnonymousId' on success, or 'error' on failure.
  /// **Note:** For robust security and limit enforcement, this logic (especially limit checks)
  /// should ideally be handled by a Firebase Cloud Function.
  Future<Map<String, String>?> submitPrayer({
    required BuildContext context, // Needed for _getOrCreateUserPrayerProfile
    required String prayerText,
    required bool isAdultConfirmed,
    String? locationApproximation,
  }) async {
    if (_currentUser == null) {
      print("User not logged in. Prayer submission denied.");
      return {'error': 'User not logged in. Please sign in to submit a prayer.'};
    }

    if (!isAdultConfirmed) {
      print("User has not confirmed they are an adult. Submission denied.");
      return {'error': 'Age confirmation is required to submit a prayer.'};
    }

    try {
      // Get or create the user's prayer profile, which includes their premium status.
      final userPrayerProfile = await _getOrCreateUserPrayerProfile(context);

      // --- Client-side Limit Check (Less Secure - Prefer Cloud Functions) ---
      if (!userPrayerProfile.isPremium) {
        const int freePrayerLimitPerPeriod = 1; // Example: 1 free prayer per defined period
        // A more robust implementation would track 'freePrayersSubmittedThisPeriod'
        // and reset it based on a defined period (e.g., monthly) via a Cloud Function or scheduled task.
        if (userPrayerProfile.lastFreePrayerDate != null) {
          // Simple example: allow one free prayer every 30 days.
          final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
          if (userPrayerProfile.lastFreePrayerDate!.isAfter(thirtyDaysAgo)) {
            print("Free prayer limit reached for non-premium user.");
            return {'error': 'You have reached your free prayer limit for this period. Upgrade to premium for unlimited prayers.'};
          }
        }
      }
      // --- End of Client-side Limit Check ---

      final prayerId = _prayerRequestsRef.doc().id; // Pre-generate ID for local use.
      // The submitterAnonymousId should always exist after _getOrCreateUserPrayerProfile.
      final submitterId = userPrayerProfile.submitterAnonymousId ?? _uuid.v4(); 

      final newPrayer = PrayerRequest(
        prayerId: prayerId, // Firestore will use this ID.
        submitterAnonymousId: submitterId,
        prayerText: prayerText,
        timestamp: Timestamp.now(), // Current server timestamp is preferred if set by Cloud Function.
        status: PrayerStatus.pending, // All new prayers require admin approval.
        locationApproximation: locationApproximation,
        prayerCount: 0,
        reportCount: 0,
      );

      await _prayerRequestsRef.doc(prayerId).set(newPrayer.toFirestore());

      // Update user's prayer limits (client-side, less secure - move to Cloud Function)
      if (!userPrayerProfile.isPremium) {
        userPrayerProfile.lastFreePrayerDate = DateTime.now();
        // userPrayerProfile.freePrayersSubmittedThisPeriod++; // Increment if using period counter
        await _userPrayerProfilesRef
            .doc(userPrayerProfile.userId)
            .set(userPrayerProfile.toFirestore(), SetOptions(merge: true));
      }
      
      print("Prayer submitted successfully. ID: $prayerId, Submitter Anonymous ID: $submitterId");
      return {
        'prayerId': prayerId,
        'submitterAnonymousId': submitterId,
      };

    } catch (e) {
      print("Error submitting prayer: $e");
      // Provide a more user-friendly error message.
      if (e is FirebaseException) {
        return {'error': 'Failed to submit prayer: ${e.message ?? "Firebase error"}'};
      }
      if (e.toString().contains("User not authenticated")) {
         return {'error': 'Authentication error. Please log in again.'};
      }
      return {'error': 'An unexpected error occurred while submitting your prayer. Please try again.'};
    }
  }

  // --- Fetching Prayers ---

  /// Gets a stream of approved prayer requests, ordered by timestamp.
  /// [limit] specifies the maximum number of prayers to fetch initially.
  Stream<List<PrayerRequest>> getApprovedPrayers({int limit = 25}) {
    return _prayerRequestsRef
        .where('status', isEqualTo: PrayerStatus.approved.name) // Filter by approved status.
        .orderBy('timestamp', descending: true) // Show newest prayers first.
        .limit(limit) // Limit the number of results for pagination/performance.
        .snapshots() // Listen to real-time updates.
        .map((snapshot) {
          // Convert Firestore documents to PrayerRequest objects.
          return snapshot.docs
              .map((doc) => PrayerRequest.fromFirestore(doc))
              .toList();
        }).handleError((error) {
          // Gracefully handle errors in the stream.
          print("Error fetching approved prayers: $error");
          return <PrayerRequest>[]; // Return an empty list on error.
        });
  }

  /// Gets prayers submitted by a specific anonymous ID (for "My Prayers" screen).
  /// Shows all statuses for that user's prayers.
  Stream<List<PrayerRequest>> getMySubmittedPrayers(String submitterAnonymousId, {int limit = 25}) {
     if (kDebugMode) {
      print("Fetching prayers for anonymous ID: $submitterAnonymousId");
    }
    return _prayerRequestsRef
        .where('submitterAnonymousId', isEqualTo: submitterAnonymousId) // Filter by anonymous ID.
        .orderBy('timestamp', descending: true) // Show newest first.
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          if (kDebugMode) {
            print("Found ${snapshot.docs.length} prayers for submitter ID $submitterAnonymousId");
          }
          return snapshot.docs
              .map((doc) => PrayerRequest.fromFirestore(doc))
              .toList();
        }).handleError((error) {
          print("Error fetching submitted prayers for $submitterAnonymousId: $error");
          return <PrayerRequest>[];
        });
  }

  // --- Prayer Interactions (Praying and Reporting) ---

  /// Increments the prayer count for a given prayerId.
  /// Ensures a user can only "pray" for a specific prayer once.
  Future<bool> incrementPrayerCount(String prayerId) async {
    if (_currentUser == null) {
      print("User not logged in. Cannot increment prayer count.");
      return false; // Or throw an exception / return an error code.
    }
    final String userId = _currentUser!.uid;

    // Check if the user has already prayed for this specific prayer.
    final QuerySnapshot<Map<String, dynamic>> interactionQuery = await _prayerInteractionsRef
        .where('prayerId', isEqualTo: prayerId)
        .where('userId', isEqualTo: userId)
        .where('interactionType', isEqualTo: InteractionType.prayed.name)
        .limit(1)
        .get();

    if (interactionQuery.docs.isNotEmpty) {
      print("User $userId has already prayed for prayer $prayerId.");
      return false; // User has already prayed.
    }

    // Use a Firestore transaction to ensure atomicity of operations.
    return _firestore.runTransaction<bool>((transaction) async {
      final DocumentReference<Map<String, dynamic>> prayerDocRef = _prayerRequestsRef.doc(prayerId);
      final DocumentSnapshot<Map<String, dynamic>> prayerSnapshot = await transaction.get(prayerDocRef);

      if (!prayerSnapshot.exists) {
        throw Exception("Prayer with ID $prayerId does not exist!");
      }
      
      final Map<String, dynamic>? currentData = prayerSnapshot.data();
      if (currentData == null) throw Exception("Prayer data is null for ID $prayerId!");

      // Increment the prayer count.
      final int newPrayerCount = (currentData['prayerCount'] as int? ?? 0) + 1;
      transaction.update(prayerDocRef, {'prayerCount': newPrayerCount});

      // Record this interaction in the 'prayerInteractions' collection.
      final DocumentReference<Map<String, dynamic>> interactionDocRef = _prayerInteractionsRef.doc(); // Auto-generate ID.
      final newInteraction = PrayerInteraction(
        interactionId: interactionDocRef.id,
        prayerId: prayerId,
        userId: userId,
        interactionType: InteractionType.prayed,
        timestamp: Timestamp.now(),
      );
      transaction.set(interactionDocRef, newInteraction.toFirestore());
      return true; // Success
    }).then((success) {
      print("Prayer count incremented successfully for $prayerId by user $userId.");
      return success;
    }).catchError((error) {
      print("Error incrementing prayer count for $prayerId: $error");
      return false; // Failure
    });
  }

  /// Reports a prayer for review.
  /// Ensures a user can only report a specific prayer once.
  Future<bool> reportPrayer(String prayerId, String reason) async {
    if (_currentUser == null) {
      print("User not logged in. Cannot report prayer.");
      return false;
    }
    final String userId = _currentUser!.uid;

    // Check if the user has already reported this prayer.
    final QuerySnapshot<Map<String, dynamic>> interactionQuery = await _prayerInteractionsRef
        .where('prayerId', isEqualTo: prayerId)
        .where('userId', isEqualTo: userId)
        .where('interactionType', isEqualTo: InteractionType.reported.name)
        .limit(1)
        .get();

    if (interactionQuery.docs.isNotEmpty) {
      print("User $userId has already reported prayer $prayerId.");
      return false; // User has already reported.
    }
    
    // Use a Firestore transaction.
    return _firestore.runTransaction<bool>((transaction) async {
      final DocumentReference<Map<String, dynamic>> prayerDocRef = _prayerRequestsRef.doc(prayerId);
      final DocumentSnapshot<Map<String, dynamic>> prayerSnapshot = await transaction.get(prayerDocRef);

      if (!prayerSnapshot.exists) {
        throw Exception("Prayer with ID $prayerId does not exist!");
      }
      
      final Map<String, dynamic>? currentData = prayerSnapshot.data();
      if (currentData == null) throw Exception("Prayer data is null for ID $prayerId!");

      // Increment the report count on the prayer request.
      final int newReportCount = (currentData['reportCount'] as int? ?? 0) + 1;
      transaction.update(prayerDocRef, {'reportCount': newReportCount});

      // Optional: If report count hits a threshold (e.g., 3), automatically change status.
      // const int reportThreshold = 3;
      // if (newReportCount >= reportThreshold && currentData['status'] == PrayerStatus.approved.name) {
      //   transaction.update(prayerDocRef, {'status': PrayerStatus.pendingReview.name});
      //   // Consider sending a notification to admins via a Cloud Function triggered by this update.
      // }

      // Record this report interaction.
      final DocumentReference<Map<String, dynamic>> interactionDocRef = _prayerInteractionsRef.doc();
      final newInteraction = PrayerInteraction(
        interactionId: interactionDocRef.id,
        prayerId: prayerId,
        userId: userId,
        interactionType: InteractionType.reported,
        timestamp: Timestamp.now(),
        reportReason: reason.isNotEmpty ? reason : null, // Store reason if provided.
      );
      transaction.set(interactionDocRef, newInteraction.toFirestore());
      return true; // Success
    }).then((success) {
      print("Prayer $prayerId reported successfully by user $userId.");
      return success;
    }).catchError((error) {
      print("Error reporting prayer $prayerId: $error");
      return false; // Failure
    });
  }

  // --- Admin Functions (Illustrative - Secure these via Cloud Functions or Admin SDK) ---
  // These methods should ideally be callable only by authorized admin users.

  /// Admin action to approve a pending prayer.
  Future<void> adminApprovePrayer(String prayerId, String adminUserId) async {
    // TODO: Implement proper admin authorization checks.
    await _prayerRequestsRef.doc(prayerId).update({
      'status': PrayerStatus.approved.name,
      'approvedBy': adminUserId,
      'approvedAt': Timestamp.now(),
      'reportCount': 0, // Optionally reset report count on re-approval
    });
    print("Prayer $prayerId approved by admin $adminUserId.");
  }

  /// Admin action to reject a pending or reported prayer.
  Future<void> adminRejectPrayer(String prayerId, String adminUserId) async {
    // TODO: Implement proper admin authorization checks.
    await _prayerRequestsRef.doc(prayerId).update({
      'status': PrayerStatus.rejected.name,
      // Optionally store 'rejectedBy': adminUserId and 'rejectedAt': Timestamp.now()
    });
     print("Prayer $prayerId rejected by admin $adminUserId.");
  }
}
