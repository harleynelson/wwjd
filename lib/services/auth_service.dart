// File: lib/services/auth_service.dart
// Path: lib/services/auth_service.dart
// Approximate line: 45 (add updateUserPremiumStatus), modified _onFirebaseUserChanged slightly

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart'; 
import '../models/app_user.dart';
import '../helpers/prefs_helper.dart';
import '../services/prayer_service.dart'; // Assuming it's used for data deletion context
import '../helpers/database_helper.dart';
import 'package:provider/provider.dart'; // For context in deleteUserPrayerData

class AuthService with ChangeNotifier {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '854479366367-3b1c8qqmlrjahm2ic17jqqupe2k8u0ik.apps.googleusercontent.com',
  );

  final StreamController<AppUser?> _appUserStreamController = StreamController<AppUser?>.broadcast();
  StreamSubscription? _firebaseAuthSubscription;
  AppUser? _currentAppUser;

  final DatabaseHelper _dbHelper = DatabaseHelper();


  AuthService() {
    _firebaseAuthSubscription = _firebaseAuth.authStateChanges().listen(_onFirebaseUserChangedFromFirebaseAuth);
    _onFirebaseUserChangedFromFirebaseAuth(_firebaseAuth.currentUser);
  }

  Stream<AppUser?> get user => _appUserStreamController.stream;
  AppUser? get currentUser => _currentAppUser;

  // Renamed to avoid confusion with the one that takes AppUser
  Future<void> _onFirebaseUserChangedFromFirebaseAuth(fb_auth.User? firebaseUser) async {
    await _updateAppUserFromFirebaseUser(firebaseUser);
  }

  Future<void> _updateAppUserFromFirebaseUser(fb_auth.User? firebaseUser, {bool? forcePremiumStatus}) async {
    if (firebaseUser == null) {
      _currentAppUser = null;
    } else {
      // Determine effective premium status
      bool isDevPremium = PrefsHelper.getDevPremiumEnabled();
      bool actualPremiumFromSource = forcePremiumStatus ?? _currentAppUser?.isPremium ?? false; // Use forced, then current, then false

      // If not forcing, and not dev premium, check a persistent source (e.g., Firestore profile)
      // This part would be more robust with a dedicated method to fetch premium status from Firestore
      // For now, if forcePremiumStatus is null, we rely on dev settings or existing _currentAppUser state.
      // A more complete solution would fetch from Firestore here if forcePremiumStatus is null.
      
      bool finalPremiumStatus = isDevPremium || actualPremiumFromSource;
      
      _currentAppUser = AppUser(
        uid: firebaseUser.uid,
        isAnonymous: firebaseUser.isAnonymous,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        isPremium: finalPremiumStatus, // Use the determined final status
      );
    }
    _appUserStreamController.add(_currentAppUser);
    notifyListeners();
    print("AuthService: AppUser updated. UID: ${_currentAppUser?.uid}, IsAnonymous: ${_currentAppUser?.isAnonymous}, IsPremium (effective): ${_currentAppUser?.isPremium}");
  }


  Future<void> triggerAppUserReFetch() async {
    print("AuthService: triggerAppUserReFetch called.");
    // This will re-evaluate premium status based on PrefsHelper.getDevPremiumEnabled()
    // and the existing _currentAppUser.isPremium (if any).
    await _updateAppUserFromFirebaseUser(_firebaseAuth.currentUser);
  }

  // --- NEW METHOD to specifically update premium status ---
  Future<void> updateUserPremiumStatus(bool newPremiumStatus) async {
    print("AuthService: Updating premium status to $newPremiumStatus for UID: ${_firebaseAuth.currentUser?.uid}");
    if (_firebaseAuth.currentUser != null) {
      // Here, you would ideally also update this status persistently in your backend (e.g., Firestore user profile)
      // For example:
      // await FirebaseFirestore.instance.collection('userPrayerProfiles').doc(_firebaseAuth.currentUser!.uid).set({'isPremium': newPremiumStatus}, SetOptions(merge: true));
      // Then, re-fetch or update the AppUser model:
      await _updateAppUserFromFirebaseUser(_firebaseAuth.currentUser, forcePremiumStatus: newPremiumStatus);
    }
  }

  Future<AppUser?> signInAnonymouslyIfNeeded() async {
    if (_firebaseAuth.currentUser == null) {
      try {
        print("AuthService: No current user. Attempting to sign in anonymously.");
        await _firebaseAuth.signInAnonymously();
        // _onFirebaseUserChangedFromFirebaseAuth will be called by the authStateChanges listener
        return _currentAppUser; 
      } catch (e) {
        print("AuthService: Error signing in anonymously: $e");
        _currentAppUser = null;
        _appUserStreamController.add(null);
        notifyListeners();
        return null;
      }
    }
    // If firebaseUser exists but _currentAppUser is somehow null, refresh it
    if (_currentAppUser == null && _firebaseAuth.currentUser != null) {
        await _onFirebaseUserChangedFromFirebaseAuth(_firebaseAuth.currentUser);
    }
    return _currentAppUser;
  }

  Future<AppUser?> signUpWithEmailPassword(String email, String password) async {
    fb_auth.UserCredential userCredential;
    try {
      fb_auth.User? currentFbUser = _firebaseAuth.currentUser;
      fb_auth.AuthCredential credential = fb_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      if (currentFbUser != null && currentFbUser.isAnonymous) {
        print("AuthService: Attempting to link anonymous user with Email/Password.");
        userCredential = await currentFbUser.linkWithCredential(credential);
        // _onFirebaseUserChangedFromFirebaseAuth will be called by the authStateChanges listener
      } else {
        print("AuthService: Attempting to create new Email/Password account.");
        userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // _onFirebaseUserChangedFromFirebaseAuth will be called by the authStateChanges listener
      }
      return _currentAppUser; // Return the AppUser shaped by the listener
    } on fb_auth.FirebaseAuthException catch (e) {
      print("AuthService: FirebaseAuthException during Email/Password sign-up: ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      print("AuthService: Generic error during Email/Password sign-up: $e");
      throw Exception("An unexpected error occurred during sign-up.");
    }
  }

  Future<AppUser?> signInWithEmailPassword(String email, String password) async {
    try {
      print("AuthService: Attempting to sign in with Email/Password.");
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // _onFirebaseUserChangedFromFirebaseAuth will be called by the authStateChanges listener
      return _currentAppUser;
    } on fb_auth.FirebaseAuthException catch (e) {
      print("AuthService: FirebaseAuthException during Email/Password sign-in: ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      print("AuthService: Generic error during Email/Password sign-in: $e");
      throw Exception("An unexpected error occurred during sign-in.");
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      print("AuthService: Password reset email sent to $email");
    } on fb_auth.FirebaseAuthException catch (e) {
      print("AuthService: Error sending password reset email: ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      print("AuthService: Generic error sending password reset email: $e");
      throw Exception("An unexpected error occurred.");
    }
  }

  Future<AppUser?> signInWithGoogle() async {
    fb_auth.User? initialCurrentUser = _firebaseAuth.currentUser;
    GoogleSignInAccount? googleUserAccount;
    fb_auth.UserCredential? finalUserCredential;

    try {
      if (_googleSignIn.serverClientId == null ||
          _googleSignIn.serverClientId!.isEmpty ||
          _googleSignIn.serverClientId == 'REPLACE_WITH_YOUR_WEB_APPLICATION_OAUTH_CLIENT_ID.apps.googleusercontent.com') {
          final errorMessage = "AuthService CRITICAL ERROR: serverClientId for GoogleSignIn is not correctly set.";
          print(errorMessage);
          throw Exception(errorMessage);
      }

      googleUserAccount = await _googleSignIn.signIn();
      if (googleUserAccount == null) {
        print("AuthService: Google sign-in cancelled by user.");
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUserAccount.authentication;
      if (googleAuth.idToken == null) {
        print("AuthService: Google Sign-In did not return an idToken.");
        throw fb_auth.FirebaseAuthException(code: 'google-sign-in-no-id-token', message: 'Google Sign-In did not provide an ID token.');
      }

      final fb_auth.AuthCredential credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (initialCurrentUser != null && initialCurrentUser.isAnonymous) {
        print("AuthService: Current user is anonymous. Attempting to link Google credential.");
        try {
          finalUserCredential = await initialCurrentUser.linkWithCredential(credential);
        } on fb_auth.FirebaseAuthException catch (linkError) {
          print("AuthService: Linking anonymous user with Google failed. Code: ${linkError.code}");
          if (linkError.code == 'credential-already-in-use' || 
              linkError.code == 'user-not-found' || 
              linkError.code == 'invalid-user-token') {
            print("AuthService: Linking failed (${linkError.code}). Attempting direct sign-in with Google.");
            finalUserCredential = await _firebaseAuth.signInWithCredential(credential);
          } else if (linkError.code == 'account-exists-with-different-credential') {
            print("AuthService: Linking failed ('account-exists-with-different-credential').");
            throw fb_auth.FirebaseAuthException( 
              code: 'link-google-to-email-erforderlich', // Custom code to identify this specific scenario
              message: linkError.message ?? 'This Google account\'s email is already used by an existing WWJD account. Please sign in with your email and password, then link Google from settings if desired.',
              email: googleUserAccount.email, // Pass the email for potential re-auth flow
            );
          } else {
            throw linkError; // Re-throw other linking errors
          }
        }
      } else {
        print("AuthService: No anonymous user or user is permanent. Signing in with Google.");
        finalUserCredential = await _firebaseAuth.signInWithCredential(credential);
      }
      
      // After linking or signing in, the authStateChanges listener will call _onFirebaseUserChangedFromFirebaseAuth
      // which updates _currentAppUser.
      // We can ensure profile info is up-to-date here if needed.
      fb_auth.User? firebaseUserToUpdate = finalUserCredential?.user ?? _firebaseAuth.currentUser;
      if (firebaseUserToUpdate != null && googleUserAccount != null) {
          bool profileNeedsUpdate = false;
          String? newDisplayName = firebaseUserToUpdate.displayName;
          String? newPhotoURL = firebaseUserToUpdate.photoURL;

          if ((newDisplayName == null || newDisplayName.isEmpty) && (googleUserAccount.displayName != null && googleUserAccount.displayName!.isNotEmpty)) {
              newDisplayName = googleUserAccount.displayName;
              profileNeedsUpdate = true;
          }
          if ((newPhotoURL == null || newPhotoURL.isEmpty) && (googleUserAccount.photoUrl != null && googleUserAccount.photoUrl!.isNotEmpty)) {
              newPhotoURL = googleUserAccount.photoUrl;
              profileNeedsUpdate = true;
          }

          if (profileNeedsUpdate) {
              try {
                  print("AuthService: Updating Firebase profile. Name: $newDisplayName, Photo: $newPhotoURL");
                  if (newDisplayName != firebaseUserToUpdate.displayName) await firebaseUserToUpdate.updateDisplayName(newDisplayName);
                  if (newPhotoURL != firebaseUserToUpdate.photoURL) await firebaseUserToUpdate.updatePhotoURL(newPhotoURL);
                  await firebaseUserToUpdate.reload(); 
                  // Trigger our AppUser update after reload
                  await _onFirebaseUserChangedFromFirebaseAuth(_firebaseAuth.currentUser);
              } catch (e) {
                  print("AuthService: Error updating profile or reloading: $e");
                  await _onFirebaseUserChangedFromFirebaseAuth(_firebaseAuth.currentUser); // Still try to update AppUser
              }
          }
      }
      return _currentAppUser;

    } on fb_auth.FirebaseAuthException catch (e) {
      print("AuthService: FirebaseAuthException during Google sign-in: (Code: ${e.code}) - ${e.message}");
      if (e.code == 'link-google-to-email-erforderlich') throw e; // Propagate this specific error
      String uiMessage = e.message ?? "An error occurred during Google Sign-In.";
      if (e.code == 'network-request-failed') uiMessage = 'Network error. Please check your internet connection.';
      else if (e.code == 'credential-already-in-use' || e.code == 'account-exists-with-different-credential') {
        uiMessage = 'This Google account is already associated with another profile.';
      }
      throw fb_auth.FirebaseAuthException(code: e.code, message: uiMessage);
    } on PlatformException catch (e) {
        print("AuthService: PlatformException Google: (Code: ${e.code}) - ${e.message}");
        String uiMessage = "Google Sign-In failed.";
        if (e.code == "sign_in_failed" || e.code == "google_sign_in_failed") {
            if (e.message?.contains(" ApiException: 10") ?? false) uiMessage = "Google Sign-In config error (10). Check SHA-1 fingerprints and API console setup.";
            else if (e.message?.contains(" ApiException: 12500") ?? false) uiMessage = "Google Sign-In issue (12500). Update Google Play Services or try again.";
            else if (e.message?.contains(" ApiException: 12501") ?? false) { print("AuthService: Google Sign-In cancelled (12501)."); return null; } // User cancelled
            else if (e.message?.contains("NetworkError") ?? false) uiMessage = "Network error with Google Sign-In.";
            else uiMessage = "Error with Google Sign-In. (Code: ${e.code})";
        }
        throw Exception(uiMessage);
    } catch (e) {
      print("AuthService: Generic error Google sign-in: $e");
      throw Exception("Unexpected error during Google Sign-In.");
    }
  }

  Future<AppUser?> reauthenticateAndLinkCredential(String email, String password, fb_auth.AuthCredential newCredentialToLink) async {
    try {
      fb_auth.User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception("No user signed in to re-authenticate.");
      }
      fb_auth.AuthCredential reauthCredential = fb_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await currentUser.reauthenticateWithCredential(reauthCredential);
      print("AuthService: User re-authenticated.");
      await currentUser.linkWithCredential(newCredentialToLink);
      // _onFirebaseUserChangedFromFirebaseAuth will be called by the authStateChanges listener
      return _currentAppUser;
    } on fb_auth.FirebaseAuthException catch (e) {
      print("AuthService: Error re-auth/linking: ${e.code} - ${e.message}");
      if (e.code == 'wrong-password' || e.code == 'invalid-credential' || e.code == 'user-mismatch') {
        throw fb_auth.FirebaseAuthException(code: e.code, message: "Incorrect password. Please try again.");
      }
      throw e;
    } catch (e) {
      print("AuthService: Generic error re-auth/linking: $e");
      throw Exception("Unexpected error linking accounts.");
    }
  }

  Future<bool> reauthenticateUser(String password) async {
    fb_auth.User? user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      print("AuthService: No user or user email for re-authentication.");
      throw Exception("User not found or email not available for re-authentication.");
    }
    try {
      fb_auth.AuthCredential credential = fb_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      print("AuthService: User re-authenticated successfully.");
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      print("AuthService: Re-authentication failed: ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      print("AuthService: Generic error during re-authentication: $e");
      throw Exception("An unexpected error occurred during re-authentication.");
    }
  }

  Future<void> updateUserPassword(String currentPassword, String newPassword) async {
    fb_auth.User? user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      print("AuthService: No user or user email for password update.");
      throw Exception("User not found or email not available for password update.");
    }
    try {
      fb_auth.AuthCredential credential = fb_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      print("AuthService: User re-authenticated successfully for password change.");
      
      await user.updatePassword(newPassword);
      print("AuthService: User password updated successfully.");
    } on fb_auth.FirebaseAuthException catch (e) {
      print("AuthService: Error updating password: ${e.code} - ${e.message}");
      throw e; 
    } catch (e) {
      print("AuthService: Generic error updating password: $e");
      throw Exception("An unexpected error occurred during password update.");
    }
  }

  Future<void> deleteCurrentUserAccount(BuildContext context) async { // Added BuildContext
    fb_auth.User? user = _firebaseAuth.currentUser;
    if (user == null) {
      print("AuthService: No user to delete.");
      throw Exception("No user is currently signed in to delete.");
    }
    
    String uid = user.uid; 
    bool isAnonymousUser = user.isAnonymous;

    try {
      if (!isAnonymousUser) { 
        print("AuthService: Starting data cleanup for user UID: $uid");
        
        // Use Provider.of with listen:false if calling from a service like this,
        // or ensure PrayerService is passed if context isn't available/appropriate.
        // For simplicity here, assuming context might be available from where this is called.
        // If not, PrayerService instance would need to be passed or obtained differently.
        final prayerService = Provider.of<PrayerService>(context, listen: false);
        await prayerService.deleteUserPrayerData(uid);
        print("AuthService: Firestore prayer data deleted for UID: $uid");

        await _dbHelper.deleteAllUserLocalData();
        print("AuthService: Local SQLite data deleted for current user.");

        await PrefsHelper.clearUserSpecificPreferences();
        print("AuthService: User-specific SharedPreferences cleared.");
      } else {
        print("AuthService: Skipping detailed Firestore data cleanup for anonymous user UID: $uid. Local data will be cleared.");
        await PrefsHelper.clearUserSpecificPreferences();
        await _dbHelper.deleteAllUserLocalData(); 
         print("AuthService: Cleared local SharedPreferences and SQLite data for anonymous user.");
      }

      await user.delete();
      print("AuthService: Firebase Auth User account deleted successfully (UID: $uid).");
      // The authStateChanges listener will handle setting _currentAppUser to null.
    } on fb_auth.FirebaseAuthException catch (e) {
      print("AuthService: Error deleting user account: ${e.code} - ${e.message}");
      if (e.code == 'requires-recent-login') {
        print("AuthService: Account deletion requires recent login. Re-authentication needed.");
      }
      throw e;
    } catch (e) {
      print("AuthService: Generic error deleting user account or cleaning up data: $e");
      throw Exception("An unexpected error occurred during account deletion: $e");
    }
  }

  Future<void> signOut() async {
    try {
      final String? oldUid = _firebaseAuth.currentUser?.uid;
      final bool wasAnonymousBeforeSignOut = _firebaseAuth.currentUser?.isAnonymous ?? false;

      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
        print("AuthService: Signed out from Google.");
      }
      await _firebaseAuth.signOut();
      print("AuthService: Signed out from Firebase (Old UID: $oldUid, WasAnonymous: $wasAnonymousBeforeSignOut).");
      // The authStateChanges listener will handle setting _currentAppUser to null.
      // If you need to ensure an anonymous user is signed back in immediately:
      // await signInAnonymouslyIfNeeded(); 
    } catch (e) {
      print("AuthService: Error signing out: $e");
    }
  }

  @override
  void dispose() {
    _firebaseAuthSubscription?.cancel();
    _appUserStreamController.close();
    super.dispose();
  }
}
