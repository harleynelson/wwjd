// File: lib/services/auth_service.dart
// Path: lib/services/auth_service.dart
// Entire file updated to handle AppUser stream refresh for dev premium toggle.

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Use alias
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:flutter/services.dart'; // For PlatformException
import '../models/app_user.dart'; // Your AppUser model
import '../helpers/prefs_helper.dart'; // For Dev Premium Toggle

class AuthService with ChangeNotifier { // Made it a ChangeNotifier
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '854479366367-3b1c8qqmlrjahm2ic17jqqupe2k8u0ik.apps.googleusercontent.com', // YOUR WEB OAUTH CLIENT ID
  );

  // StreamController to manage the AppUser stream more directly
  final StreamController<AppUser?> _appUserStreamController = StreamController<AppUser?>.broadcast();
  StreamSubscription? _firebaseAuthSubscription;
  AppUser? _currentAppUser; // Internal cache of the current AppUser

  AuthService() {
    // Listen to Firebase auth state changes to update our AppUser stream
    _firebaseAuthSubscription = _firebaseAuth.authStateChanges().listen(_onFirebaseUserChanged);
    // Initialize with current user state
    _onFirebaseUserChanged(_firebaseAuth.currentUser);
  }

  // The public stream for AppUser
  Stream<AppUser?> get user => _appUserStreamController.stream;

  // Getter for the synchronously available current AppUser
  AppUser? get currentUser => _currentAppUser;

  // Internal method to map Firebase user to AppUser and update stream
  Future<void> _onFirebaseUserChanged(fb_auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentAppUser = null;
    } else {
      // Determine premium status
      // 1. Check Dev Premium Toggle
      bool isDevPremium = PrefsHelper.getDevPremiumEnabled();
      bool finalPremiumStatus = isDevPremium;

      // 2. If Dev Premium is NOT enabled, you would check actual premium status
      //    (e.g., from Firestore user document or custom claims).
      //    This part needs to be implemented based on your app's premium logic.
      if (!isDevPremium) {
        // Placeholder: Replace with your actual premium status check logic
        // For example, fetch from Firestore:
        // final userDoc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
        // finalPremiumStatus = userDoc.exists && (userDoc.data()?['isPremium'] == true);
        // Or from custom claims:
        // final idTokenResult = await firebaseUser.getIdTokenResult(true); // Force refresh
        // finalPremiumStatus = idTokenResult.claims?['premium'] == true;

        // For now, if not dev premium, it defaults to false as per AppUser model
        // (unless your AppUser model's default changes or you set it here).
        // This part is crucial for real premium functionality.
        // For this exercise, we'll rely on AppUser's default if dev toggle is off.
      }
      
      _currentAppUser = AppUser(
        uid: firebaseUser.uid,
        isAnonymous: firebaseUser.isAnonymous,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        isPremium: finalPremiumStatus, // Apply determined premium status
      );
    }
    _appUserStreamController.add(_currentAppUser);
    notifyListeners(); // Notify if any part of UI listens to AuthService directly
    print("AuthService: AppUser updated. UID: ${_currentAppUser?.uid}, IsAnonymous: ${_currentAppUser?.isAnonymous}, IsPremium (effective): ${_currentAppUser?.isPremium}");
  }

  /// Called by SettingsScreen when the dev premium toggle changes.
  Future<void> triggerAppUserReFetch() async {
    print("AuthService: triggerAppUserReFetch called due to dev premium toggle.");
    // Re-evaluate the current Firebase user with potentially new PrefsHelper state
    await _onFirebaseUserChanged(_firebaseAuth.currentUser);
  }

  Future<AppUser?> signInAnonymouslyIfNeeded() async {
    if (_firebaseAuth.currentUser == null) {
      try {
        print("AuthService: No current user. Attempting to sign in anonymously.");
        await _firebaseAuth.signInAnonymously();
        // _onFirebaseUserChanged will be called by the authStateChanges listener
        // and will update _currentAppUser and the stream.
        // We return the _currentAppUser which should be updated by the listener.
        return _currentAppUser;
      } catch (e) {
        print("AuthService: Error signing in anonymously: $e");
        _currentAppUser = null;
        _appUserStreamController.add(null);
        notifyListeners();
        return null;
      }
    }
    // If user already exists, ensure _currentAppUser is up-to-date.
    // This might be redundant if _onFirebaseUserChanged already ran at startup,
    // but good for safety or if called before listener fires.
    if (_currentAppUser == null && _firebaseAuth.currentUser != null) {
        await _onFirebaseUserChanged(_firebaseAuth.currentUser);
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
      } else {
        print("AuthService: Attempting to create new Email/Password account.");
        userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      // _onFirebaseUserChanged will handle mapping and stream update via listener.
      return _currentAppUser; // Should be updated by the listener
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
      // _onFirebaseUserChanged will handle mapping and stream update.
      return _currentAppUser;
    } on fb_auth.FirebaseAuthException catch (e) {
      print("AuthService: FirebaseAuthException during Email/Password sign-in: ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      print("AuthService: Generic error during Email/Password sign-in: $e");
      throw Exception("An unexpected error occurred during sign-in.");
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
              code: 'link-google-to-email-erforderlich',
              message: linkError.message ?? 'This Google account\'s email is already used.',
              email: googleUserAccount.email,
            );
          } else {
            throw linkError;
          }
        }
      } else {
        print("AuthService: No anonymous user or user is permanent. Signing in with Google.");
        finalUserCredential = await _firebaseAuth.signInWithCredential(credential);
      }
      
      fb_auth.User? firebaseUserToUpdate = finalUserCredential?.user;
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
                  firebaseUserToUpdate = _firebaseAuth.currentUser; // Get the reloaded user
              } catch (e) {
                  print("AuthService: Error updating profile or reloading: $e");
                  firebaseUserToUpdate = _firebaseAuth.currentUser ?? finalUserCredential?.user;
              }
          }
      }
      // _onFirebaseUserChanged will be triggered by authStateChanges if linking/signing in was successful.
      // So, _currentAppUser should reflect the latest state.
      return _currentAppUser;

    } on fb_auth.FirebaseAuthException catch (e) {
      print("AuthService: FirebaseAuthException during Google sign-in: (Code: ${e.code}) - ${e.message}");
      if (e.code == 'link-google-to-email-erforderlich') throw e;
      String uiMessage = e.message ?? "An error occurred during Google Sign-In.";
      if (e.code == 'network-request-failed') uiMessage = 'Network error.';
      else if (e.code == 'credential-already-in-use' || e.code == 'account-exists-with-different-credential') {
        uiMessage = 'This Google account is already associated with another profile.';
      }
      throw fb_auth.FirebaseAuthException(code: e.code, message: uiMessage);
    } on PlatformException catch (e) {
        print("AuthService: PlatformException Google: (Code: ${e.code}) - ${e.message}");
        String uiMessage = "Google Sign-In failed.";
        if (e.code == "sign_in_failed" || e.code == "google_sign_in_failed") {
            if (e.message?.contains(" ApiException: 10") ?? false) uiMessage = "Google Sign-In config error (10).";
            else if (e.message?.contains(" ApiException: 12500") ?? false) uiMessage = "Google Sign-In issue (12500).";
            else if (e.message?.contains(" ApiException: 12501") ?? false) { print("AuthService: Google Sign-In cancelled (12501)."); return null; }
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
      // _onFirebaseUserChanged will handle mapping and stream update.
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
      // _onFirebaseUserChanged will be called by the listener, setting _currentAppUser to null.
    } catch (e) {
      print("AuthService: Error signing out: $e");
      // Even on error, try to ensure local state reflects signed out.
      // _currentAppUser = null; // This will be handled by _onFirebaseUserChanged if signOut succeeds
      // _appUserStreamController.add(null);
      // notifyListeners();
    }
  }

  @override
  void dispose() {
    _firebaseAuthSubscription?.cancel(); // Cancel the Firebase auth listener
    _appUserStreamController.close();    // Close the stream controller
    super.dispose();
  }
}
