// File: lib/models/user_prayer_profile_model.dart
// Purpose: Represents user-specific prayer data, like their anonymous ID for submissions
//          and information about their prayer submission limits.
//          This document is typically stored in Firestore with the user's Firebase UID as the document ID.

import 'package:cloud_firestore/cloud_firestore.dart';

class UserPrayerProfile {
  final String userId; // Firebase Authentication UID (this will be the document ID).
  String? submitterAnonymousId; // The unique anonymous ID assigned to this user for their prayer submissions.
  DateTime? lastFreePrayerDate; // Timestamp of the user's last free prayer submission.
  int freePrayersSubmittedThisPeriod; // Counter for free prayers in the current period (e.g., month).
  bool isPremium; // Flag indicating if the user has a premium subscription.

  UserPrayerProfile({
    required this.userId,
    this.submitterAnonymousId,
    this.lastFreePrayerDate,
    this.freePrayersSubmittedThisPeriod = 0, // Default to 0.
    this.isPremium = false, // Default to false.
  });

  // Factory constructor to create a UserPrayerProfile instance from a Firestore document.
  factory UserPrayerProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!; // Assume data is never null.
    return UserPrayerProfile(
      userId: doc.id, // The document ID is the userId.
      submitterAnonymousId: data['submitterAnonymousId'] as String?,
      lastFreePrayerDate: (data['lastFreePrayerDate'] as Timestamp?)?.toDate(), // Convert Firestore Timestamp to DateTime.
      freePrayersSubmittedThisPeriod: data['freePrayersSubmittedThisPeriod'] as int? ?? 0,
      isPremium: data['isPremium'] as bool? ?? false,
    );
  }

  // Method to convert a UserPrayerProfile instance to a map for storing in Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      // userId is the document ID, so it's not included in the map data.
      if (submitterAnonymousId != null) 'submitterAnonymousId': submitterAnonymousId,
      if (lastFreePrayerDate != null) 'lastFreePrayerDate': Timestamp.fromDate(lastFreePrayerDate!), // Convert DateTime to Firestore Timestamp.
      'freePrayersSubmittedThisPeriod': freePrayersSubmittedThisPeriod,
      'isPremium': isPremium,
    };
  }
}
