// File: lib/models/app_user.dart
// Path: lib/models/app_user.dart
// Approximate line: 7 (add isPremium), 15 (add to constructor)

// Ensure you have this class defined in your project.
// If it's part of a larger models.dart, update it there.

class AppUser {
  final String uid;
  final bool isAnonymous;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isPremium; // Added for premium status

  AppUser({
    required this.uid,
    this.isAnonymous = false,
    this.email,
    this.displayName,
    this.photoURL,
    this.isPremium = false, // Default to false
  });

  // Optional: Add a copyWith method if you find it useful
  AppUser copyWith({
    String? uid,
    bool? isAnonymous,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isPremium,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
