// lib/models/app_user.dart (NEW FILE)
class AppUser {
  final String uid;
  final bool isAnonymous;
  final String? email; // Null if anonymous or not email/password user

  AppUser({required this.uid, required this.isAnonymous, this.email});
}