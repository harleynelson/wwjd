// File: lib/models/prayer_submission_details_model.dart
// Purpose: Locally store details about a user's prayer submission for tracking,
//          potentially for SharedPreferences or a local database.

import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

class PrayerSubmissionDetails {
  final String prayerId; // The ID of the prayer the user submitted.
  final String submitterAnonymousId; // The anonymous ID assigned to the user for this submission.
  final Timestamp submissionTime; // Timestamp of when the prayer was submitted.

  PrayerSubmissionDetails({
    required this.prayerId,
    required this.submitterAnonymousId,
    required this.submissionTime,
  });

  // Method to convert to a JSON map, useful for storing in SharedPreferences (as a JSON string).
  Map<String, dynamic> toJson() => {
        'prayerId': prayerId,
        'submitterAnonymousId': submitterAnonymousId,
        // Convert Timestamp to ISO 8601 string for JSON compatibility.
        'submissionTime': submissionTime.toDate().toIso8601String(),
      };

  // Factory constructor to create a PrayerSubmissionDetails instance from a JSON map.
  factory PrayerSubmissionDetails.fromJson(Map<String, dynamic> json) =>
      PrayerSubmissionDetails(
        prayerId: json['prayerId'] as String? ?? '',
        submitterAnonymousId: json['submitterAnonymousId'] as String? ?? '',
        // Parse ISO 8601 string back to DateTime, then to Timestamp.
        submissionTime: Timestamp.fromDate(DateTime.parse(json['submissionTime'] as String? ?? DateTime.now().toIso8601String())),
      );
}
