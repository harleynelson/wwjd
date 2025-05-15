// File: lib/models/prayer_interaction_model.dart
// Purpose: Represents user interactions with a prayer (e.g., praying for it, reporting it).

import 'package:cloud_firestore/cloud_firestore.dart';

// Enum to represent the type of interaction a user has with a prayer.
enum InteractionType {
  prayed,   // User marked "Prayed for this".
  reported, // User reported the prayer.
}

class PrayerInteraction {
  final String interactionId; // Unique ID for the interaction (document ID from Firestore).
  final String prayerId; // Foreign key referencing the ID of the prayer in the 'prayerRequests' collection.
  final String userId; // Firebase Authentication UID of the user who performed the action.
  final InteractionType interactionType; // Type of interaction (prayed or reported).
  final Timestamp timestamp; // Timestamp of when the interaction occurred.
  final String? reportReason; // Optional: Reason provided if the interactionType is "reported".

  PrayerInteraction({
    required this.interactionId,
    required this.prayerId,
    required this.userId,
    required this.interactionType,
    required this.timestamp,
    this.reportReason,
  });

  // Factory constructor to create a PrayerInteraction instance from a Firestore document.
  factory PrayerInteraction.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!; // Assume data is never null.
    return PrayerInteraction(
      interactionId: doc.id, // Use the document's ID.
      prayerId: data['prayerId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      interactionType: _parseInteractionType(data['interactionType'] as String? ?? 'prayed'),
      timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(),
      reportReason: data['reportReason'] as String?,
    );
  }

  // Method to convert a PrayerInteraction instance to a map for storing in Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      // interactionId is the document ID, not part of the data map.
      'prayerId': prayerId,
      'userId': userId,
      'interactionType': interactionType.name, // Store enum's name as a string.
      'timestamp': timestamp,
      if (reportReason != null) 'reportReason': reportReason,
    };
  }

  // Helper method to parse the interaction type string from Firestore to the InteractionType enum.
  static InteractionType _parseInteractionType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'reported':
        return InteractionType.reported;
      case 'prayed':
      default:
        return InteractionType.prayed; // Default to prayed if type is unknown or missing.
    }
  }
}
