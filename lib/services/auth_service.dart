// lib/services/auth_service.dart (NEW FILE)
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Use alias to avoid name collision
import '../models/app_user.dart'; // Your AppUser model

class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;

  // Create a stream that emits your AppUser model or null
  Stream<AppUser?> get user {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  // Get current user synchronously (can be null)
  AppUser? get currentUser {
    return _userFromFirebase(_firebaseAuth.currentUser);
  }

  AppUser? _userFromFirebase(fb_auth.User? firebaseUser) {
    if (firebaseUser == null) {
      return null;
    }
    return AppUser(
      uid: firebaseUser.uid,
      isAnonymous: firebaseUser.isAnonymous,
      email: firebaseUser.email,
    );
  }

  Future<AppUser?> signInAnonymouslyIfNeeded() async {
    if (_firebaseAuth.currentUser == null) {
      try {
        final userCredential = await _firebaseAuth.signInAnonymously();
        print("AuthService: Signed in anonymously: ${userCredential.user?.uid}");
        return _userFromFirebase(userCredential.user);
      } catch (e) {
        print("AuthService: Error signing in anonymously: $e");
        return null;
      }
    }
    print("AuthService: User already signed in: ${_firebaseAuth.currentUser?.uid}, Anonymous: ${_firebaseAuth.currentUser?.isAnonymous}");
    return _userFromFirebase(_firebaseAuth.currentUser);
  }

  // --- Placeholder for Sign-In with Google ---
  Future<AppUser?> signInWithGoogle() async {
    // TODO: Implement Google Sign-In using google_sign_in package
    // 1. Get GoogleSignInAccount
    // 2. Get GoogleSignInAuthentication
    // 3. Create AuthCredential
    // 4. If current user is anonymous, link with credential:
    //    await _firebaseAuth.currentUser?.linkWithCredential(credential);
    // 5. Else, sign in with credential:
    //    await _firebaseAuth.signInWithCredential(credential);
    print("signInWithGoogle: Not yet implemented.");
    return _userFromFirebase(_firebaseAuth.currentUser); // Placeholder
  }

  // --- Placeholder for Sign-In with Apple ---
  Future<AppUser?> signInWithApple() async {
    // TODO: Implement Sign in with Apple using sign_in_with_apple package
    print("signInWithApple: Not yet implemented.");
    return _userFromFirebase(_firebaseAuth.currentUser); // Placeholder
  }

  // --- Placeholder for Sign-Up with Email/Password ---
  Future<AppUser?> signUpWithEmailPassword(String email, String password) async {
    // TODO: Implement email/password sign up
    // If current user is anonymous, create credential and link.
    // Else, create user directly.
    print("signUpWithEmailPassword: Not yet implemented.");
    return _userFromFirebase(_firebaseAuth.currentUser); // Placeholder
  }

  // --- Placeholder for Sign-In with Email/Password ---
  Future<AppUser?> signInWithEmailPassword(String email, String password) async {
    // TODO: Implement email/password sign in
    print("signInWithEmailPassword: Not yet implemented.");
    return _userFromFirebase(_firebaseAuth.currentUser); // Placeholder
  }


  Future<void> signOut() async {
    try {
      // Optional: Sign out from specific providers like Google
      // if (await GoogleSignIn().isSignedIn()) {
      //   await GoogleSignIn().signOut();
      // }
      await _firebaseAuth.signOut();
      print("AuthService: User signed out.");
      // After sign out, immediately sign in anonymously again
      // so the app always has a user session.
      await signInAnonymouslyIfNeeded();
    } catch (e) {
      print("AuthService: Error signing out: $e");
    }
  }

  // Method to link an anonymous account with a credential (e.g., Google, Apple, Email)
  Future<AppUser?> linkAnonymousAccount(fb_auth.AuthCredential credential) async {
    try {
      if (_firebaseAuth.currentUser != null && _firebaseAuth.currentUser!.isAnonymous) {
        final userCredential = await _firebaseAuth.currentUser!.linkWithCredential(credential);
        print("AuthService: Anonymous account linked. UID: ${userCredential.user?.uid}");
        return _userFromFirebase(userCredential.user);
      } else {
        // If not anonymous, or no user, this method shouldn't ideally be called.
        // Or, you might want to handle it as a regular sign-in if no user exists.
        print("AuthService: No anonymous user to link, or user is not anonymous. Attempting sign-in instead.");
        final userCredential = await _firebaseAuth.signInWithCredential(credential);
         return _userFromFirebase(userCredential.user);
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      // Handle specific errors like 'credential-already-in-use'
      // This means the credential (e.g., Google account) is already linked to another Firebase user.
      // You'll need a strategy for this:
      // 1. Inform the user.
      // 2. Option to sign in with that existing account (they might lose current anonymous data if not migrated).
      // 3. Advanced: Data migration logic (complex).
      print("AuthService: Error linking credential: ${e.code} - ${e.message}");
      if (e.code == 'credential-already-in-use') {
        // Handle this specific case, e.g., by trying to sign in with the conflicting credential
        // and then deciding how to merge data or inform the user.
        // For now, just rethrow or return null.
      }
      return null;
    } catch (e) {
      print("AuthService: Generic error linking credential: $e");
      return null;
    }
  }
}