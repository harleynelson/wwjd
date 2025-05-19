// File: lib/services/prayer_service.dart
// Path: lib/services/prayer_service.dart
// Approximate line: 300 (new method: deleteUserPrayerData)

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../models/prayer_request_model.dart'; //
import '../models/prayer_interaction_model.dart'; //
import '../models/user_prayer_profile_model.dart'; //
import '../models/app_user.dart'; //

class PrayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _prayerRequestsRef =>
      _firestore.collection('prayerRequests');
  CollectionReference<Map<String, dynamic>> get _prayerInteractionsRef =>
      _firestore.collection('prayerInteractions');
  CollectionReference<Map<String, dynamic>> get _userPrayerProfilesRef =>
      _firestore.collection('userPrayerProfiles');

  User? get _currentUser => _auth.currentUser;

  Future<UserPrayerProfile> _getOrCreateUserPrayerProfile(BuildContext context) async {
    if (_currentUser == null) {
      throw Exception("User not authenticated (currentUser is null). Cannot manage prayer profile.");
    }
    final String userId = _currentUser!.uid;
    final docRef = _userPrayerProfilesRef.doc(userId);
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await docRef.get();

    final AppUser? appUser = Provider.of<AppUser?>(context, listen: false);
    
    bool isUserPremium = appUser?.isPremium ?? false;
    if (_currentUser!.isAnonymous) {
        isUserPremium = false; 
    }


    if (snapshot.exists) {
      UserPrayerProfile profile = UserPrayerProfile.fromFirestore(snapshot); //
      bool profileNeedsUpdate = false;

      if (!_currentUser!.isAnonymous && profile.isPremium != isUserPremium) {
        profile.isPremium = isUserPremium;
        profileNeedsUpdate = true;
      }
      if (_currentUser!.isAnonymous && profile.isPremium) {
          profile.isPremium = false;
          profileNeedsUpdate = true;
      }


      final data = snapshot.data();
      if (data != null) {
          if (!data.containsKey('currentPrayerStreak')) {
              profile.currentPrayerStreak = 0; profileNeedsUpdate = true;
          }
          if (!data.containsKey('lastPrayerStreakTimestamp')) {
              profileNeedsUpdate = true; 
          }
          if (!data.containsKey('prayersSentOnStreakDay')) {
              profile.prayersSentOnStreakDay = 0; profileNeedsUpdate = true;
          }
          if (!data.containsKey('totalPrayersSent')) {
              profile.totalPrayersSent = 0; profileNeedsUpdate = true;
          }
          if (!data.containsKey('lastWeeklySubmissionTimestamp')) { //
              profileNeedsUpdate = true; 
          }
      } else { 
          profileNeedsUpdate = true; 
      }


      if (profileNeedsUpdate) {
        await docRef.set(profile.toFirestore(), SetOptions(merge: true));
      }
      return profile;
    } else {
      final newAnonymousId = _currentUser!.isAnonymous ? (_currentUser!.uid) : _uuid.v4();
      final newProfile = UserPrayerProfile(
        userId: userId,
        submitterAnonymousId: newAnonymousId, 
        isPremium: isUserPremium, 
        lastWeeklySubmissionTimestamp: null, 
        currentPrayerStreak: 0,
        lastPrayerStreakTimestamp: null,
        prayersSentOnStreakDay: 0,
        totalPrayersSent: 0,
      );
      await docRef.set(newProfile.toFirestore());
      return newProfile;
    }
  }

  Future<String?> getCurrentUserSubmitterAnonymousId(BuildContext context) async {
    if (_currentUser == null) return null;
    try {
      final profile = await _getOrCreateUserPrayerProfile(context);
      return profile.submitterAnonymousId;
    } catch (e) {
      print("Error getting current user's submitterAnonymousId: $e");
      return null;
    }
  }

  Future<UserPrayerProfile?> getUserPrayerProfile(String userId) async {
    if (userId.isEmpty) return null;
    try {
      final docRef = _userPrayerProfilesRef.doc(userId);
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        return UserPrayerProfile.fromFirestore(snapshot); //
      } else {
        return UserPrayerProfile(userId: userId);
      }
    } catch (e) {
      print("Error fetching UserPrayerProfile for $userId: $e");
      return null;
    }
  }

  Future<Map<String, String>?> submitPrayer({
    required BuildContext context,
    required String prayerText,
    required bool isAdultConfirmed,
    String? locationApproximation,
  }) async {
    if (_currentUser == null) {
      print("User not available (currentUser is null). Prayer submission denied.");
      return {'error': 'User session not available. Please restart the app or try again.'};
    }

    if (!isAdultConfirmed) {
      print("User has not confirmed they are an adult. Submission denied.");
      return {'error': 'Age confirmation is required to submit a prayer.'};
    }

    try {
      final userPrayerProfile = await _getOrCreateUserPrayerProfile(context);

      if (!userPrayerProfile.isPremium) { 
        if (userPrayerProfile.lastWeeklySubmissionTimestamp != null) { //
          final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
          if (userPrayerProfile.lastWeeklySubmissionTimestamp!.toDate().isAfter(sevenDaysAgo)) {
            print("Weekly free prayer submission limit reached for user ${userPrayerProfile.userId}.");
            final nextAvailableDate = userPrayerProfile.lastWeeklySubmissionTimestamp!.toDate().add(const Duration(days: 7));
            final formattedDate = DateFormat.yMMMd().add_jm().format(nextAvailableDate);
            return {'error': 'You have reached your free prayer submission limit for this week. Next submission available after $formattedDate.'};
          }
        }
      }
      
      final prayerId = _prayerRequestsRef.doc().id;
      final submitterId = userPrayerProfile.submitterAnonymousId ?? _currentUser!.uid;


      final newPrayer = PrayerRequest( //
        prayerId: prayerId,
        submitterAnonymousId: submitterId,
        prayerText: prayerText,
        timestamp: Timestamp.now(),
        status: PrayerStatus.pending, //
        locationApproximation: locationApproximation,
        prayerCount: 0,
        reportCount: 0,
      );

      await _prayerRequestsRef.doc(prayerId).set(newPrayer.toFirestore());

      if (!userPrayerProfile.isPremium) {
        userPrayerProfile.lastWeeklySubmissionTimestamp = Timestamp.now(); //
        await _userPrayerProfilesRef
            .doc(userPrayerProfile.userId)
            .set(userPrayerProfile.toFirestore(), SetOptions(merge: true));
      }
      
      print("Prayer submitted successfully. ID: $prayerId, Submitter Anonymous ID: $submitterId (User UID: ${userPrayerProfile.userId})");
      return {
        'prayerId': prayerId,
        'submitterAnonymousId': submitterId,
      };

    } catch (e) {
      print("Error submitting prayer: $e");
      if (e is FirebaseException) {
        return {'error': 'Failed to submit prayer: ${e.message ?? "Firebase error"}'};
      }
      return {'error': 'An unexpected error occurred. Please try again.'};
    }
  }

  Stream<List<PrayerRequest>> getApprovedPrayers({int limit = 25}) {
    return _prayerRequestsRef
        .where('status', isEqualTo: PrayerStatus.approved.name) //
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PrayerRequest.fromFirestore(doc)) //
              .toList();
        }).handleError((error) {
          print("Error fetching approved prayers: $error");
          return <PrayerRequest>[];
        });
  }

  Stream<List<PrayerRequest>> getMySubmittedPrayers(String submitterAnonymousId, {int limit = 25}) {
     if (kDebugMode) {
      print("Fetching prayers for anonymous ID: $submitterAnonymousId");
    }
    return _prayerRequestsRef
        .where('submitterAnonymousId', isEqualTo: submitterAnonymousId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          if (kDebugMode) {
            print("Found ${snapshot.docs.length} prayers for submitter ID $submitterAnonymousId");
          }
          return snapshot.docs
              .map((doc) => PrayerRequest.fromFirestore(doc)) //
              .toList();
        }).handleError((error) {
          print("Error fetching submitted prayers for $submitterAnonymousId: $error");
          return <PrayerRequest>[];
        });
  }

  Future<void> _updateUserPrayerActivityStreak(String userId) async {
    if (userId.isEmpty) {
        print("Error: Attempted to update prayer streak for an empty userId.");
        return;
    }
    final userProfileRef = _userPrayerProfilesRef.doc(userId);
    
    try {
      DocumentSnapshot<Map<String, dynamic>> profileSnap = await userProfileRef.get();
      UserPrayerProfile profile;

      if (profileSnap.exists) {
        profile = UserPrayerProfile.fromFirestore(profileSnap); //
      } else {
        print("PrayerService: UserPrayerProfile not found for $userId during streak update. Creating default.");
        profile = UserPrayerProfile(userId: userId);
      }

      DateTime now = DateTime.now();
      DateTime todayDateNormalized = DateTime(now.year, now.month, now.day);

      profile.totalPrayersSent = (profile.totalPrayersSent) + 1;

      if (profile.lastPrayerStreakTimestamp != null) {
        DateTime lastStreakDateNormalized = DateTime(
          profile.lastPrayerStreakTimestamp!.toDate().year,
          profile.lastPrayerStreakTimestamp!.toDate().month,
          profile.lastPrayerStreakTimestamp!.toDate().day,
        );
        int differenceInDays = todayDateNormalized.difference(lastStreakDateNormalized).inDays;

        if (differenceInDays == 0) {
          profile.prayersSentOnStreakDay = (profile.prayersSentOnStreakDay) + 1;
        } else if (differenceInDays == 1) {
          profile.currentPrayerStreak = (profile.currentPrayerStreak) + 1;
          profile.prayersSentOnStreakDay = 1;
        } else {
          profile.currentPrayerStreak = 1;
          profile.prayersSentOnStreakDay = 1;
        }
      } else {
        profile.currentPrayerStreak = 1;
        profile.prayersSentOnStreakDay = 1;
      }
      profile.lastPrayerStreakTimestamp = Timestamp.fromDate(todayDateNormalized);

      await userProfileRef.set(profile.toFirestore(), SetOptions(merge: true));
      print("User $userId prayer activity streak updated: ${profile.currentPrayerStreak} days, ${profile.prayersSentOnStreakDay} sent on this streak day. Total sent: ${profile.totalPrayersSent}.");

    } catch (e) {
      print("Error updating user prayer activity streak for $userId: $e");
    }
  }

  Future<bool> incrementPrayerCount(String prayerId) async {
    if (_currentUser == null) {
      print("User not available (currentUser is null). Cannot increment prayer count for streak.");
      return false;
    }
    final String userId = _currentUser!.uid;

    final QuerySnapshot<Map<String, dynamic>> interactionQuery = await _prayerInteractionsRef
        .where('prayerId', isEqualTo: prayerId)
        .where('userId', isEqualTo: userId) 
        .where('interactionType', isEqualTo: InteractionType.prayed.name) //
        .limit(1)
        .get();

    if (interactionQuery.docs.isNotEmpty) {
      print("User $userId has already prayed for prayer $prayerId. Streak not incremented again for this specific prayer.");
    }


    return _firestore.runTransaction<bool>((transaction) async {
      final DocumentReference<Map<String, dynamic>> prayerDocRef = _prayerRequestsRef.doc(prayerId);
      final DocumentSnapshot<Map<String, dynamic>> prayerSnapshot = await transaction.get(prayerDocRef);

      if (!prayerSnapshot.exists) {
        throw Exception("Prayer with ID $prayerId does not exist!");
      }
      
      final Map<String, dynamic>? currentData = prayerSnapshot.data();
      if (currentData == null) throw Exception("Prayer data is null for ID $prayerId!");

      final int newPrayerCount = (currentData['prayerCount'] as int? ?? 0) + 1;
      transaction.update(prayerDocRef, {'prayerCount': newPrayerCount});

      if (interactionQuery.docs.isEmpty) {
          final DocumentReference<Map<String, dynamic>> interactionDocRef = _prayerInteractionsRef.doc();
          final newInteraction = PrayerInteraction( //
            interactionId: interactionDocRef.id,
            prayerId: prayerId,
            userId: userId, 
            interactionType: InteractionType.prayed, //
            timestamp: Timestamp.now(),
          );
          transaction.set(interactionDocRef, newInteraction.toFirestore());
      }
      return true;
    }).then((success) async {
      if (success) {
        print("Prayer count incremented successfully for $prayerId by user $userId.");
        await _updateUserPrayerActivityStreak(userId);
      }
      return success;
    }).catchError((error) {
      print("Error incrementing prayer count for $prayerId: $error");
      return false;
    });
  }

  Future<bool> reportPrayer(String prayerId, String reason) async {
    if (_currentUser == null) {
      print("User not logged in. Cannot report prayer.");
      return false;
    }
    final String userId = _currentUser!.uid;

    final QuerySnapshot<Map<String, dynamic>> interactionQuery = await _prayerInteractionsRef
        .where('prayerId', isEqualTo: prayerId)
        .where('userId', isEqualTo: userId)
        .where('interactionType', isEqualTo: InteractionType.reported.name) //
        .limit(1)
        .get();

    if (interactionQuery.docs.isNotEmpty) {
      print("User $userId has already reported prayer $prayerId.");
      return false;
    }
    
    return _firestore.runTransaction<bool>((transaction) async {
      final DocumentReference<Map<String, dynamic>> prayerDocRef = _prayerRequestsRef.doc(prayerId);
      final DocumentSnapshot<Map<String, dynamic>> prayerSnapshot = await transaction.get(prayerDocRef);

      if (!prayerSnapshot.exists) {
        throw Exception("Prayer with ID $prayerId does not exist!");
      }
      
      final Map<String, dynamic>? currentData = prayerSnapshot.data();
      if (currentData == null) throw Exception("Prayer data is null for ID $prayerId!");

      final int newReportCount = (currentData['reportCount'] as int? ?? 0) + 1;
      transaction.update(prayerDocRef, {'reportCount': newReportCount});

      final DocumentReference<Map<String, dynamic>> interactionDocRef = _prayerInteractionsRef.doc();
      final newInteraction = PrayerInteraction( //
        interactionId: interactionDocRef.id,
        prayerId: prayerId,
        userId: userId,
        interactionType: InteractionType.reported, //
        timestamp: Timestamp.now(),
        reportReason: reason.isNotEmpty ? reason : null,
      );
      transaction.set(interactionDocRef, newInteraction.toFirestore());
      return true;
    }).then((success) {
      print("Prayer $prayerId reported successfully by user $userId.");
      return success;
    }).catchError((error) {
      print("Error reporting prayer $prayerId: $error");
      return false;
    });
  }

  Future<void> adminApprovePrayer(String prayerId, String adminUserId) async {
    await _prayerRequestsRef.doc(prayerId).update({
      'status': PrayerStatus.approved.name, //
      'approvedBy': adminUserId,
      'approvedAt': Timestamp.now(),
      'reportCount': 0,
    });
    print("Prayer $prayerId approved by admin $adminUserId.");
  }

  Future<void> adminRejectPrayer(String prayerId, String adminUserId) async {
    await _prayerRequestsRef.doc(prayerId).update({
      'status': PrayerStatus.rejected.name, //
    });
     print("Prayer $prayerId rejected by admin $adminUserId.");
  }

  Future<void> deleteUserPrayerData(String userId) async {
    if (userId.isEmpty) {
      print("PrayerService: Cannot delete data for empty userId.");
      return;
    }
    print("PrayerService: Deleting prayer data for userId: $userId");

    try {
      // Delete UserPrayerProfile
      await _userPrayerProfilesRef.doc(userId).delete();
      print("PrayerService: Deleted UserPrayerProfile for $userId.");

      // Delete PrayerInteractions
      WriteBatch batch = _firestore.batch();
      QuerySnapshot interactionsSnapshot = await _prayerInteractionsRef
          .where('userId', isEqualTo: userId)
          .get();

      if (interactionsSnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot doc in interactionsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        print("PrayerService: Deleted ${interactionsSnapshot.docs.length} PrayerInteractions for $userId.");
      } else {
        print("PrayerService: No PrayerInteractions found for $userId to delete.");
      }
    } catch (e) {
      print("PrayerService: Error deleting prayer data for userId $userId: $e");
      // Optionally rethrow or handle more gracefully
      throw Exception("Failed to delete user's prayer data from Firestore: $e");
    }
  }
}