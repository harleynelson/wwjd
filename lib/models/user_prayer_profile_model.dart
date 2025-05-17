// File: lib/models/user_prayer_profile_model.dart
// Path: lib/models/user_prayer_profile_model.dart
// Added lastWeeklySubmissionTimestamp for prayer submission limits.

import 'package:cloud_firestore/cloud_firestore.dart';

class UserPrayerProfile {
  final String userId; // Firebase Authentication UID (this will be the document ID).
  String? submitterAnonymousId; // The unique anonymous ID assigned to this user for their prayer submissions.
  
  // Fields for prayer SUBMISSION limits
  DateTime? lastFreePrayerDate; // Timestamp of the user's last free prayer submission (DEPRECATED by weekly below, but kept for now if old logic exists)
  Timestamp? lastWeeklySubmissionTimestamp; // New: Tracks the last prayer submission for weekly limit
  int freePrayersSubmittedThisPeriod; // Counter for free prayers in the current period (e.g., month).
  
  bool isPremium; // Flag indicating if the user has a premium subscription.

  // Fields for prayer ACTIVITY streak (praying FOR others)
  int currentPrayerStreak;
  Timestamp? lastPrayerStreakTimestamp; // Firestore Timestamp for the date part of the last prayer sent FOR OTHERS
  int prayersSentOnStreakDay; // How many prayers the user sent for others on the lastPrayerStreakTimestamp day
  int totalPrayersSent; // All-time count of prayers sent for others

  UserPrayerProfile({
    required this.userId,
    this.submitterAnonymousId,
    this.lastFreePrayerDate,
    this.lastWeeklySubmissionTimestamp, // Added
    this.freePrayersSubmittedThisPeriod = 0,
    this.isPremium = false,
    this.currentPrayerStreak = 0,
    this.lastPrayerStreakTimestamp,
    this.prayersSentOnStreakDay = 0,
    this.totalPrayersSent = 0,
  });

  factory UserPrayerProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return UserPrayerProfile(
      userId: doc.id,
      submitterAnonymousId: data['submitterAnonymousId'] as String?,
      lastFreePrayerDate: (data['lastFreePrayerDate'] as Timestamp?)?.toDate(),
      lastWeeklySubmissionTimestamp: data['lastWeeklySubmissionTimestamp'] as Timestamp?, // Added
      freePrayersSubmittedThisPeriod: data['freePrayersSubmittedThisPeriod'] as int? ?? 0,
      isPremium: data['isPremium'] as bool? ?? false,
      currentPrayerStreak: data['currentPrayerStreak'] as int? ?? 0,
      lastPrayerStreakTimestamp: data['lastPrayerStreakTimestamp'] as Timestamp?,
      prayersSentOnStreakDay: data['prayersSentOnStreakDay'] as int? ?? 0,
      totalPrayersSent: data['totalPrayersSent'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (submitterAnonymousId != null) 'submitterAnonymousId': submitterAnonymousId,
      if (lastFreePrayerDate != null) 'lastFreePrayerDate': Timestamp.fromDate(lastFreePrayerDate!),
      if (lastWeeklySubmissionTimestamp != null) 'lastWeeklySubmissionTimestamp': lastWeeklySubmissionTimestamp, // Added
      'freePrayersSubmittedThisPeriod': freePrayersSubmittedThisPeriod,
      'isPremium': isPremium,
      'currentPrayerStreak': currentPrayerStreak,
      if (lastPrayerStreakTimestamp != null) 'lastPrayerStreakTimestamp': lastPrayerStreakTimestamp,
      'prayersSentOnStreakDay': prayersSentOnStreakDay,
      'totalPrayersSent': totalPrayersSent,
    };
  }
}