// File: lib/models/app_user.dart

class AppUser {
  final String uid;
  final bool isAnonymous;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isPremium;

  AppUser({
    required this.uid,
    this.isAnonymous = false,
    this.email,
    this.displayName,
    this.photoURL,
    this.isPremium = false,
  });

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
