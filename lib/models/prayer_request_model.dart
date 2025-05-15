// File: lib/models/prayer_request_model.dart
// Purpose: Represents a prayer request in the application.

import 'package:cloud_firestore/cloud_firestore.dart';

// Enum to represent the status of a prayer request.
enum PrayerStatus {
  pending,       // Prayer is awaiting admin approval.
  approved,      // Prayer is approved and visible on the wall.
  rejected,      // Prayer was rejected by an admin.
  pendingReview, // Prayer was approved but later flagged and needs re-review.
}

class PrayerRequest {
  final String prayerId; // Unique ID for the prayer (document ID from Firestore).
  final String submitterAnonymousId; // Anonymous ID of the user who submitted the prayer.
  final String prayerText; // The content of the prayer.
  final Timestamp timestamp; // Timestamp of when the prayer was submitted.
  PrayerStatus status; // Current status of the prayer (pending, approved, etc.).
  final String? locationApproximation; // Optional, coarse-grained location (e.g., "USA", "Europe").
  int prayerCount; // Number of times users have marked "Prayed for this".
  int reportCount; // Number of times this prayer has been reported by other users.
  final String? approvedBy; // Optional: Admin user ID who approved the prayer.
  final Timestamp? approvedAt; // Optional: Timestamp of when the prayer was approved.
  // final String? actualUserId; // Consider if needed vs. submitterAnonymousId.
                               // For true anonymity, avoid storing if possible,
                               // or ensure strict rules if stored for backend logic.

  PrayerRequest({
    required this.prayerId,
    required this.submitterAnonymousId,
    required this.prayerText,
    required this.timestamp,
    this.status = PrayerStatus.pending, // Default status is pending.
    this.locationApproximation,
    this.prayerCount = 0, // Default prayer count is 0.
    this.reportCount = 0, // Default report count is 0.
    this.approvedBy,
    this.approvedAt,
    // this.actualUserId,
  });

  // Factory constructor to create a PrayerRequest instance from a Firestore document.
  factory PrayerRequest.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!; // Assume data is never null for an existing doc.
    return PrayerRequest(
      prayerId: doc.id, // Use the document's ID as prayerId.
      submitterAnonymousId: data['submitterAnonymousId'] as String? ?? '',
      prayerText: data['prayerText'] as String? ?? '',
      timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(),
      status: _parsePrayerStatus(data['status'] as String? ?? 'pending'),
      locationApproximation: data['locationApproximation'] as String?,
      prayerCount: data['prayerCount'] as int? ?? 0,
      reportCount: data['reportCount'] as int? ?? 0,
      approvedBy: data['approvedBy'] as String?,
      approvedAt: data['approvedAt'] as Timestamp?,
      // actualUserId: data['actualUserId'] as String?,
    );
  }

  // Method to convert a PrayerRequest instance to a map for storing in Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      // prayerId is the document ID, so it's not included in the map data itself.
      'submitterAnonymousId': submitterAnonymousId,
      'prayerText': prayerText,
      'timestamp': timestamp,
      'status': status.name, // Store the enum's name (e.g., "pending") as a string.
      if (locationApproximation != null) 'locationApproximation': locationApproximation,
      'prayerCount': prayerCount,
      'reportCount': reportCount,
      if (approvedBy != null) 'approvedBy': approvedBy,
      if (approvedAt != null) 'approvedAt': approvedAt,
      // if (actualUserId != null) 'actualUserId': actualUserId,
    };
  }

  // Helper method to parse the prayer status string from Firestore to the PrayerStatus enum.
  static PrayerStatus _parsePrayerStatus(String statusStr) {
    switch (statusStr.toLowerCase()) {
      case 'approved':
        return PrayerStatus.approved;
      case 'rejected':
        return PrayerStatus.rejected;
      case 'pending_review': // Ensure Firestore uses this string if "pendingReview" is a status.
        return PrayerStatus.pendingReview;
      case 'pending':
      default:
        return PrayerStatus.pending; // Default to pending if status is unknown or missing.
    }
  }
}
