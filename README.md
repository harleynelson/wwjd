# WWJD App - Feature Rich Religious Application

This application provides users with daily devotionals, a verse of the day, full Bible access, reading plans, and a community prayer wall, all designed to support their spiritual journey.

## ✨ Key Features

* **Core Bible & Devotional Content:**
    * Verse of the Day (VotD) with favoriting and custom flagging.
    * Daily Devotionals.
    * Full Bible Reader with customizable appearance (font size, type, background).
    * Favorites system for verses.
    * Reading Plans with streak tracking and progress management.
    * Search functionality for Bible content.
    * Text-to-Speech (TTS) Narration for Bible chapters and devotionals.
* **NEW: Community Prayer Wall:**
    * **Anonymous Prayer Submission:** Users can submit prayer requests without revealing their identity. These are reviewed by an admin before appearing.
    * **View Prayer Wall:** A public display of approved, anonymous prayer requests from the community.
    * **Pray for Others:** Users can tap a button to indicate they have prayed for a specific request, which increments a public prayer count for that request.
    * **Track Own Submissions (Optional):** Upon submission, users receive a unique, anonymous ID. They can use this ID on the "My Submitted Prayers" screen to see the prayer count and status of prayers they've submitted.
    * **Moderation & Safety:**
        * All prayers are submitted for admin approval before becoming visible.
        * Users can report prayers they find inappropriate.
        * (Backend TODO) Automated checks for profanity/spam are planned.
    * **Premium Features (Planned):**
        * (Backend TODO) Limits on free prayer submissions per period, with unlimited submissions for premium users.
* **User Customization & Experience:**
    * Light/Dark Mode for the overall app theme.
    * User accounts (anonymous, email/password, Google Sign-In) with linking capabilities.
    * Developer options for testing and debugging.

---

# App Setup & Deployment Checklist

This guide outlines the key steps for setting up the Flutter app with Firebase, securing API keys, and preparing for release.

## Phase 1: Core Firebase Project Setup

* [X] **Create Firebase Project:** Project `wwjd-459421` created in the Firebase Console.
* [X] **Add Android App to Firebase:** Android app (`com.alpentor.wwjd`) added to the Firebase project.
* [X] **Download `google-services.json`:** Configuration file downloaded.
* [ ] **Add iOS App to Firebase:** (PENDING) Add your iOS app to the Firebase project when ready.
* [ ] **Download `GoogleService-Info.plist`:** (PENDING) Configuration file for iOS.
* [X] **Add Firebase Dependencies:** `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_remote_config`, `firebase_app_check` (and others) added to `pubspec.yaml`.
* [X] **Initialize Firebase in `main.dart`:** `await Firebase.initializeApp(...)` is present.
* [X] **Anonymous User Sign-In:** Implemented `signInAnonymouslyIfNeeded()` in `AuthService`.
* [X] **Firestore Database Setup:**
    * [X] Enabled Firestore (Native Mode).
    * [X] **NEW:** Created collections for Prayer Wall: `prayerRequests`, `prayerInteractions`, `userPrayerProfiles`.
    * [ ] (TODO) Define and test comprehensive security rules for all collections, including new Prayer Wall collections.
* [X] **Firebase Authentication:** Setup for Email/Password, Google Sign-In, and Anonymous.
* [ ] **Firebase Cloud Functions (Planned for Prayer Wall & IAP):**
    * (TODO) Set up Firebase Functions environment.
    * (TODO) Deploy functions for Prayer Wall moderation, submission limits, and potentially for IAP receipt validation.

## Phase 2: Android Specific Setup

* [X] **Place `google-services.json`:** File is correctly placed in `android/app/`.
* [X] **Check `build.gradle` files:** Firebase dependencies (BoM, relevant SDKs) are present.
* [ ] **Get Debug SHA-1 & SHA-256 Fingerprints:**
    * Run `cd android && ./gradlew signingReport` (or `gradlew signingReport` on Windows).
    * Add these to the Firebase Console under Project Settings > Your Android App > SHA certificate fingerprints. (SHA-1 for Google Sign-In, SHA-256 for App Check Play Integrity & API Key restrictions).
* [ ] **Create Release Keystore & Get Release SHA-1/SHA-256 Fingerprints:**
    * Follow Flutter documentation to create an upload keystore (`.jks` file).
    * Securely store your keystore and its passwords.
    * Use `keytool -list -v -keystore path-to-your-keystore.jks -alias your-alias-name` to get the release SHA fingerprints.
    * Add these release SHA fingerprints to the Firebase Console.
    * Add these release SHA fingerprints to your Google Cloud API Key restrictions.

## Phase 3: iOS Specific Setup (Future)

* [ ] **Place `GoogleService-Info.plist`:** (PENDING) Place in `ios/Runner/`.
* [ ] **CocoaPods Setup:** Run `pod install` in the `ios` directory after adding Firebase iOS SDKs via `pubspec.yaml`.
* [ ] **Xcode Configuration:**
    * Ensure Bundle ID in Xcode matches the one registered in Firebase and Apple Developer portal.
    * Set up your Apple Developer Team.
    * Enable necessary capabilities (e.g., Push Notifications, App Attest if used).

## Phase 4: API Key Security (Remote Config & App Check)

* [X] **Add API Key to Remote Config:**
    * Parameter created in Firebase Console (e.g., `google_cloud_tts_api_key`).
    * API key set as its value and published.
* [X] **Add Dependencies:** `firebase_remote_config` and `firebase_app_check` added to `pubspec.yaml`.
* [X] **Initialize App Check in `main.dart`:**
    * `await FirebaseAppCheck.instance.activate(...)` called.
    * Using `AndroidProvider.playIntegrity` (or `.debug` for emulator testing).
    * (PENDING iOS) `AppleProvider.appAttest` (or `.debug` for simulator testing).
* [X] **Initialize & Fetch Remote Config in `main.dart`:**
    * Instance obtained, settings configured, defaults set.
    * `await remoteConfig.fetchAndActivate()` called. (Note: Log shows occasional fetch errors, monitor this).
* [X] **Update `TextToSpeechService`:**
    * Now retrieves API key using `FirebaseRemoteConfig.instance.getString(...)`.
* **App Check Provider Configuration in Firebase Console:**
    * [ ] **Android (Play Integrity):**
        * Registered app in App Check.
        * Enabled Play Integrity.
        * Added **SHA-256 fingerprints** (debug & release) in Firebase Project Settings for your Android app.
    * [ ] **iOS (App Attest / DeviceCheck):** (PENDING)
        * Register app in App Check.
        * Enable chosen provider(s).
        * Complete necessary Apple Developer portal configurations.
* [ ] **Enforce App Check for Remote Config & Firestore (if applicable):**
    * In Firebase Console > App Check > APIs:
        * Currently in "Monitor" mode for Remote Config (recommended for initial testing).
        * **Switch to "Enforce"** once thoroughly tested on real devices.
        * (TODO) Review and enforce for Cloud Firestore if sensitive data access needs App Check protection beyond security rules.
* [ ] **Restrict API Key in Google Cloud Console:**
    * Go to Google Cloud Console > APIs & Services > Credentials.
    * Select your API key.
    * Under "Application restrictions":
        * Add your Android app (package name & **SHA-1** fingerprint).
        * (PENDING iOS) Add your iOS app (bundle ID).
    * Under "API restrictions":
        * Select "Restrict key".
        * Choose **only** "Cloud Text-to-Speech API" (and any other specific APIs this key absolutely needs).

## Phase 5: Building for Release

* [ ] **Android:**
    * Create an upload keystore (if not already done).
    * Configure `android/app/build.gradle` for release signing.
    * Run `flutter build appbundle` or `flutter build apk --release`.
* [ ] **iOS:** (PENDING)
    * Configure signing & capabilities in Xcode.
    * Archive and distribute via TestFlight/App Store.

---

# Application TODO List & Future Enhancements

## 圦 Core Monetization & Content Strategy

* [ ] **Implement In-App Purchases (IAP):**
    * [ ] Choose an IAP package (e.g., `in_app_purchase`).
    * [ ] Define premium features/content (e.g., exclusive reading plans, advanced TTS voices, ad-free experience, additional devotionals, **unlimited Prayer Wall submissions**).
    * [ ] Design and implement paywall/unlock UI elements.
    * [ ] **Server-Side Receipt Validation:** Crucial for security (Firebase Functions).
    * [ ] **Manage User Premium Status:**
        * Use Firebase Auth custom claims or Firestore to store user entitlements (link to `AppUser.uid` and `AppUser.isPremium`).
    * [ ] Handle "Restore Purchases" functionality.
* [ ] **Migrate Content to Firebase:**
    * [ ] **Reading Plans:** Move from local to Firestore.
    * [ ] **Daily Devotionals:** Move from local to Firestore.
    * [ ] **Assets (Images):** Move to Firebase Storage.

## 🙏 Prayer Wall Enhancements (New Feature Area)

* [ ] **Backend - Cloud Functions for Prayer Wall:**
    * [ ] Implement robust Cloud Function for prayer submission:
        * [ ] Securely check/update prayer submission limits (free vs. premium based on `AppUser.isPremium`).
        * [ ] Perform profanity/spam filtering before setting prayer status to `pending`.
        * [ ] Atomically create prayer document and update user limit counters in `userPrayerProfiles`.
    * [ ] Cloud Function to handle `reportCount` thresholds (e.g., auto-set to `pending_review`, notify admins).
    * [ ] (Optional) Cloud Function for notifications (e.g., when a user's prayer is approved or receives many interactions).
* [ ] **Admin Panel for Prayer Moderation:**
    * [ ] Develop a simple web interface (e.g., using Firebase Hosting + Callable Functions) or a protected in-app section for admins to:
        * [ ] View prayers with `status: "pending"` or `status: "pending_review"`.
        * [ ] Approve or reject prayers.
        * [ ] View/manage reported prayers.
* [ ] **Frontend - Prayer Wall UI/UX:**
    * [ ] Implement "Already Prayed" visual feedback more robustly (persist across sessions, not just current card state).
    * [ ] Add pagination or infinite scrolling for the Prayer Wall if it grows large.
    * [ ] Consider advanced filtering or sorting options (e.g., by region if location is implemented, by most recent, by most prayed for).
    * [ ] User notifications (in-app or push) when their submitted prayer is approved.
    * [ ] UI for users to manage/delete their own anonymous prayer IDs (if this becomes a desired feature).
* [ ] **Prayer Wall - Data & Safety:**
    * [ ] Define and implement data retention policies for prayers in Firestore (e.g., auto-delete old/rejected prayers after a period).
    * [ ] Further enhance GDPR compliance considerations if any (even coarse) location data is used.

## 笨ｨ User Experience & Feature Enhancements (General)

* [ ] **User Notes & Journaling:** For verses or devotionals.
* [ ] **Enhanced Offline Support:** For Bible, devotionals, reading plans.
* [ ] **Advanced Search:** Filter by book ranges, topical tags.
* [ ] **Push Notifications (FCM):** Devotional/plan reminders, new content.
* [ ] **User Settings Expansion:** More TTS options, notification preferences, data management.
* [ ] **UI/UX Polish:** Animations, styling, visual hierarchy.
* [ ] **Accessibility (a11y):** Contrast, labels, tap targets.
* [ ] **Analytics (Firebase Analytics):** Track key user actions and engagement.

## 導 iOS Specific Development

* [ ] Complete all steps in "Phase 3: iOS Specific Setup".
* [ ] Thoroughly test all features on iOS.
* [ ] Prepare for App Store submission.

## 白 Security, Maintenance & Admin (General)

* [ ] **Firebase Security Rules:**
    * [X] Write and test robust security rules for existing Firestore collections.
    * [ ] **NEW/CRITICAL:** Define and thoroughly test security rules for new Prayer Wall collections (`prayerRequests`, `prayerInteractions`, `userPrayerProfiles`).
        * Ensure anonymous submissions are handled correctly while protecting user data.
        * Restrict status updates on prayers to admins (via Cloud Functions or admin SDK).
        * Securely manage prayer counts and report increments (ideally via Cloud Functions).
    * [ ] Configure security rules for Firebase Storage if used.
* [ ] **Dependency Management:** Regularly update Flutter and packages.
* [ ] **Error Reporting (Firebase Crashlytics):** Ensure integration and monitor.
* [ ] **Data Backup:** Strategy for Firestore data.
* [ ] **Admin Panel/Tools (General):** For managing content beyond prayers.

## 側 User Account Enhancements

* [ ] **Password Reset:** Implement for email/password accounts.
* [ ] **Account Deletion:** Provide an option for users to delete their account and associated data (including prayers if linked, or a mechanism for anonymous data removal if feasible).
* [ ] **Additional Sign-In Providers:** Consider "Sign in with Apple" for iOS.

---
This README provides a snapshot of the app's setup, current features, and future direction.
