// File: lib/models/prayer_request_model.dart
// Purpose: Represents a prayer request in the application.

import 'package:cloud_firestore/cloud_firestore.dart';

// Enum to represent the status of a prayer request.
enum PrayerStatus {
  pending,       // awaiting admin approval.
  approved,      // approved and visible on the wall.
  rejected,      // rejected by an admin.
  pendingReview, // approved but later flagged and needs re-review.
}

class PrayerRequest {
  final String prayerId; // Unique ID for the prayer (document ID from Firestore).
  final String submitterAnonymousId; // Anonymous ID of the user who submitted the prayer.
  final String prayerText; // content.
  final Timestamp timestamp; // submitted.
  PrayerStatus status; // status (pending, approved, etc.).
  final String? locationApproximation; // Optional, coarse location (e.g., "USA", "Europe").
  int prayerCount; // Number "Prayed for this".
  int reportCount; // Number reported by other users.
  final String? approvedBy; // Optional: Admin user ID who approved the prayer.
  final Timestamp? approvedAt; // Optional: approved.

  PrayerRequest({
    required this.prayerId,
    required this.submitterAnonymousId,
    required this.prayerText,
    required this.timestamp,
    this.status = PrayerStatus.pending,
    this.locationApproximation,
    this.prayerCount = 0,
    this.reportCount = 0,
    this.approvedBy,
    this.approvedAt,
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
    };
  }

  // parse prayer status string from Firestore to the PrayerStatus enum.
  static PrayerStatus _parsePrayerStatus(String statusStr) {
    switch (statusStr.toLowerCase()) {
      case 'approved':
        return PrayerStatus.approved;
      case 'rejected':
        return PrayerStatus.rejected;
      case 'pending_review':
        return PrayerStatus.pendingReview;
      case 'pending':
      default:
        return PrayerStatus.pending; // Default to pending if status is unknown or missing.
    }
  }
}
