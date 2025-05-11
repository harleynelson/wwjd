// lib/services/auth_service.dart
// Path: lib/services/auth_service.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Use alias
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart'; // For PlatformException
import '../models/app_user.dart'; // Your AppUser model

class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // IMPORTANT: This MUST be your WEB OAuth 2.0 Client ID from GCP Console.
    // Create one of type "Web application" in GCP -> APIs & Services -> Credentials.
    // Using your Android OAuth Client ID (like 8544...u0ik.apps.googleusercontent.com from your google-services.json)
    // here is a very common cause of ApiException 10 or 12500 during the Google Sign-In flow.
    // Please replace the placeholder below with your actual WEB OAuth 2.0 Client ID.
    serverClientId: '854479366367-3b1c8qqmlrjahm2ic17jqqupe2k8u0ik.apps.googleusercontent.com',
  );

  Stream<AppUser?> get user {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUserToAppUser);
  }

  AppUser? _mapFirebaseUserToAppUser(fb_auth.User? firebaseUser) {
    if (firebaseUser == null) {
      return null;
    }
    // print("AuthService Stream: Mapping Firebase user. UID: ${firebaseUser.uid}, IsAnonymous: ${firebaseUser.isAnonymous}, Email: ${firebaseUser.email}");
    return AppUser(
      uid: firebaseUser.uid,
      isAnonymous: firebaseUser.isAnonymous,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
    );
  }

  AppUser? get currentUser {
    return _mapFirebaseUserToAppUser(_firebaseAuth.currentUser);
  }

  Future<AppUser?> signInAnonymouslyIfNeeded() async {
    if (_firebaseAuth.currentUser == null) {
      try {
        final userCredential = await _firebaseAuth.signInAnonymously();
        print("AuthService: Signed in anonymously. UID: ${userCredential.user?.uid}, IsAnonymous: ${userCredential.user?.isAnonymous}");
        return _mapFirebaseUserToAppUser(userCredential.user);
      } catch (e) {
        print("AuthService: Error signing in anonymously: $e");
        return null;
      }
    }
    return _mapFirebaseUserToAppUser(_firebaseAuth.currentUser);
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
        print("AuthService: Anonymous account linked with Email/Password. UID: ${userCredential.user?.uid}, IsAnonymous: ${userCredential.user?.isAnonymous}, Email: ${userCredential.user?.email}");
      } else {
        print("AuthService: Attempting to create new Email/Password account.");
        userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print("AuthService: New Email/Password account created. UID: ${userCredential.user?.uid}, IsAnonymous: ${userCredential.user?.isAnonymous}, Email: ${userCredential.user?.email}");
      }
      // userCredential.user?.providerData.forEach((profile) {print("Provider: ${profile.providerId}, UID: ${profile.uid}, Email: ${profile.email}");});
      return _mapFirebaseUserToAppUser(userCredential.user);

    } on fb_auth.FirebaseAuthException catch (e) {
      print("AuthService: FirebaseAuthException during Email/Password sign-up: ${e.code} - ${e.message}");
      throw e; 
    } catch (e) {
      print("AuthService: Generic error during Email/Password sign-up: $e");
      throw Exception("An unexpected error occurred during sign-up.");
    }
  }

  Future<AppUser?> signInWithEmailPassword(String email, String password) async {
    fb_auth.UserCredential userCredential;
    try {
      print("AuthService: Attempting to sign in with Email/Password.");
      userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("AuthService: Signed in with Email/Password. UID: ${userCredential.user?.uid}, IsAnonymous: ${userCredential.user?.isAnonymous}, Email: ${userCredential.user?.email}");
      // userCredential.user?.providerData.forEach((profile) {print("Provider: ${profile.providerId}, UID: ${profile.uid}, Email: ${profile.email}");});
      return _mapFirebaseUserToAppUser(userCredential.user);
    } on fb_auth.FirebaseAuthException catch (e) {
      print("AuthService: FirebaseAuthException during Email/Password sign-in: ${e.code} - ${e.message}");
      throw e; 
    } catch (e) {
      print("AuthService: Generic error during Email/Password sign-in: $e");
      throw Exception("An unexpected error occurred during sign-in.");
    }
  }

  Future<AppUser?> signInWithGoogle() async {
    fb_auth.User? initialCurrentUser = _firebaseAuth.currentUser; // Capture initial user state
    GoogleSignInAccount? googleUserAccount;
    fb_auth.UserCredential? finalUserCredential; // To store the result of the successful operation

    try {
      // Critical check for serverClientId configuration
      if (_googleSignIn.serverClientId == null || 
          _googleSignIn.serverClientId!.isEmpty || 
          _googleSignIn.serverClientId == 'REPLACE_WITH_YOUR_WEB_APPLICATION_OAUTH_CLIENT_ID.apps.googleusercontent.com') {
          final errorMessage = "AuthService CRITICAL ERROR: serverClientId for GoogleSignIn is not correctly set. Please use your WEB OAuth 2.0 Client ID from GCP.";
          print(errorMessage);
          throw Exception(errorMessage); // Fail early
      }

      googleUserAccount = await _googleSignIn.signIn();
      if (googleUserAccount == null) {
        print("AuthService: Google sign-in cancelled by user.");
        return null; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth = await googleUserAccount.authentication;
      if (googleAuth.idToken == null) {
        print("AuthService: Google Sign-In did not return an idToken. This might be due to incorrect serverClientId or scopes.");
        throw fb_auth.FirebaseAuthException(code: 'google-sign-in-no-id-token', message: 'Google Sign-In did not provide an ID token.');
      }

      final fb_auth.AuthCredential credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (initialCurrentUser != null && initialCurrentUser.isAnonymous) {
        print("AuthService: Current user is anonymous (UID: ${initialCurrentUser.uid}). Attempting to link Google credential.");
        try {
          finalUserCredential = await initialCurrentUser.linkWithCredential(credential);
          print("AuthService: Anonymous account successfully linked with Google. New User State -> UID: ${finalUserCredential.user?.uid}, IsAnonymous: ${finalUserCredential.user?.isAnonymous}, Name: ${finalUserCredential.user?.displayName}");
        } on fb_auth.FirebaseAuthException catch (linkError) {
          if (linkError.code == 'credential-already-in-use') {
            // This Google account is already linked to a *different* Firebase user.
            // Sign in with this Google account, effectively replacing the anonymous user.
            print("AuthService: Linking failed ('credential-already-in-use'). Google account is linked to another Firebase user. Attempting direct sign-in with Google credential.");
            finalUserCredential = await _firebaseAuth.signInWithCredential(credential); // This is the success path
            print("AuthService: Signed in with existing Google-linked Firebase account. New User State -> UID: ${finalUserCredential.user?.uid}, IsAnonymous: ${finalUserCredential.user?.isAnonymous}, Name: ${finalUserCredential.user?.displayName}");
          } else if (linkError.code == 'account-exists-with-different-credential') {
            print("AuthService: Linking failed ('account-exists-with-different-credential'). Email (${googleUserAccount.email}) is used by another sign-in method.");
            throw fb_auth.FirebaseAuthException( // Propagate for UI to handle password prompt
              code: 'link-google-to-email-erforderlich',
              message: 'This Google account\'s email is already used with an Email/Password account. Please sign in with your password to link them.',
              email: googleUserAccount.email,
            );
          } else {
            throw linkError; // Re-throw other linking errors to be caught by outer catch
          }
        }
      } else {
        // No anonymous user, or user is already permanent. Attempt direct sign-in.
        print("AuthService: No anonymous user or user is already permanent. Attempting to sign in with Google credential directly.");
        finalUserCredential = await _firebaseAuth.signInWithCredential(credential);
        print("AuthService: Signed in with Google. New User State -> UID: ${finalUserCredential.user?.uid}, IsAnonymous: ${finalUserCredential.user?.isAnonymous}, Name: ${finalUserCredential.user?.displayName}");
      }
      
      // Log provider data of the final user
      // finalUserCredential?.user?.providerData.forEach((profile) {
      //   print("Final User Provider: ${profile.providerId}, UID: ${profile.uid}, Email: ${profile.email}, Name: ${profile.displayName}");
      // });
      return _mapFirebaseUserToAppUser(finalUserCredential?.user);

    } on fb_auth.FirebaseAuthException catch (e) {
      // This outer catch handles errors from direct signInWithCredential if not anonymous,
      // or errors re-thrown from the linking block, or the custom 'link-google-to-email-erforderlich'.
      print("AuthService: FirebaseAuthException during Google sign-in process: (Code: ${e.code}) - ${e.message}");
      if (e.code == 'link-google-to-email-erforderlich') {
        throw e; // Re-throw for UI to handle specifically
      }
      // Provide more user-friendly messages for other common errors
      String uiMessage = e.message ?? "An error occurred during Google Sign-In.";
      if (e.code == 'network-request-failed') {
         uiMessage = 'Network error. Please check your internet connection.';
      } else if (e.code == 'credential-already-in-use' || e.code == 'account-exists-with-different-credential') {
        // This message is for when direct signInWithCredential fails due to these conflicts
        uiMessage = 'This Google account is already associated with a user profile or uses a different sign-in method. Please try a different Google account or sign in with the original method for that profile.';
      }
      throw fb_auth.FirebaseAuthException(code: e.code, message: uiMessage); // Throw with potentially more user-friendly message

    } on PlatformException catch (e) { // Errors from google_sign_in plugin itself
        print("AuthService: PlatformException during Google sign-in: (Code: ${e.code}) - ${e.message} - Details: ${e.details}");
        String uiMessage = "Google Sign-In failed.";
        if (e.code == "sign_in_failed" || e.code == "google_sign_in_failed") {
            if (e.message?.contains(" ApiException: 10") ?? false) {
                uiMessage = "Google Sign-In configuration error (10). Please ensure app is correctly configured with Google services (SHA-1, google-services.json, Web Client ID for serverClientId).";
            } else if (e.message?.contains(" ApiException: 12500") ?? false) {
                uiMessage = "Google Sign-In was cancelled or there was an issue with Google Play Services (12500). Check network and Play Services.";
            } else if (e.message?.contains(" ApiException: 12501") ?? false) { // SIGN_IN_CANCELLED
                print("AuthService: Google Sign-In cancelled by user (ApiException 12501).");
                return null; // Not an error to show to user, just cancellation.
            } else if (e.message?.contains("NetworkError") ?? false) { // Check for generic network error string
                uiMessage = "Network error during Google Sign-In. Please check your connection.";
            } else {
                uiMessage = "An error occurred with Google Sign-In. Please try again. (Code: ${e.code})";
            }
        }
        throw Exception(uiMessage); // Throw a new Exception with the processed message
    }
    catch (e) {
      print("AuthService: Generic error during Google sign-in: $e");
      throw Exception("An unexpected error occurred during Google Sign-In.");
    }
  }

  Future<AppUser?> reauthenticateAndLinkCredential(String email, String password, fb_auth.AuthCredential newCredentialToLink) async {
    fb_auth.UserCredential userCredential;
    try {
      fb_auth.User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception("No user is currently signed in to re-authenticate.");
      }
      fb_auth.AuthCredential reauthCredential = fb_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await currentUser.reauthenticateWithCredential(reauthCredential);
      print("AuthService: User re-authenticated successfully.");
      userCredential = await currentUser.linkWithCredential(newCredentialToLink);
      print("AuthService: New credential linked successfully after re-authentication. UID: ${userCredential.user?.uid}, IsAnonymous: ${userCredential.user?.isAnonymous}");
      // userCredential.user?.providerData.forEach((profile) {print("Provider: ${profile.providerId}, UID: ${profile.uid}, Email: ${profile.email}");});
      return _mapFirebaseUserToAppUser(userCredential.user);
    } on fb_auth.FirebaseAuthException catch (e) {
      print("AuthService: Error during re-authentication or linking: ${e.code} - ${e.message}");
      if (e.code == 'wrong-password' || e.code == 'invalid-credential' || e.code == 'user-mismatch') {
        throw fb_auth.FirebaseAuthException(code: e.code, message: "Incorrect password. Please try again to link your accounts.");
      }
      throw e;
    } catch (e) {
      print("AuthService: Generic error during re-authentication or linking: $e");
      throw Exception("An unexpected error occurred while linking accounts.");
    }
  }

  Future<void> signOut() async {
    try {
      final String? oldUid = _firebaseAuth.currentUser?.uid;
      final bool wasAnonymousBeforeSignOut = _firebaseAuth.currentUser?.isAnonymous ?? true;

      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
        print("AuthService: Signed out from Google.");
      }
      await _firebaseAuth.signOut();
      print("AuthService: User signed out from Firebase (Old UID: $oldUid, WasAnonymous: $wasAnonymousBeforeSignOut).");
      await signInAnonymouslyIfNeeded();
    } catch (e) {
      print("AuthService: Error signing out: $e");
    }
  }
}
