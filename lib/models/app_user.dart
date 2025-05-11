// lib/models/app_user.dart
// Path: lib/models/app_user.dart
// Approximate line: 1

class AppUser {
  final String uid;
  final bool isAnonymous;
  final String? email;
  final String? displayName; // Added for Google Sign-In, etc.
  final String? photoURL;    // Added for Google Sign-In, etc.

  AppUser({
    required this.uid,
    required this.isAnonymous,
    this.email,
    this.displayName, // Initialize
    this.photoURL,    // Initialize
  });
}
