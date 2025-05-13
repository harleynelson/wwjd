# App Setup & Deployment Checklist

This guide outlines the key steps for setting up the Flutter app with Firebase, securing API keys, and preparing for release.

## Phase 1: Core Firebase Project Setup

* [X] **Create Firebase Project:** Project `wwjd-459421` created in the Firebase Console.
* [X] **Add Android App to Firebase:** Android app (`com.alpentor.wwjd`) added to the Firebase project.
* [X] **Download `google-services.json`:** Configuration file downloaded.
* [ ] **Add iOS App to Firebase:** (PENDING) Add your iOS app to the Firebase project when ready.
* [ ] **Download `GoogleService-Info.plist`:** (PENDING) Configuration file for iOS.
* [X] **Add Firebase Dependencies:** `firebase_core` (and others like `firebase_auth`) added to `pubspec.yaml`.
* [X] **Initialize Firebase in `main.dart`:** `await Firebase.initializeApp(...)` is present.
* [X] **Anonymous User Sign-In:** Implemented `signInAnonymouslyIfNeeded()` in `AuthService`.

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
    * Instance obtained, settings configured, defaults set (optional).
    * `await remoteConfig.fetchAndActivate()` called.
* [X] **Update `TextToSpeechService`:**
    * Now retrieves API key using `FirebaseRemoteConfig.instance.getString(...)`.
    * Removed direct dependency on `flutter_dotenv` for this key.
* **App Check Provider Configuration in Firebase Console:**
    * [ ] **Android (Play Integrity):**
        * Registered app in App Check.
        * Enabled Play Integrity.
        * Added **SHA-256 fingerprints** (debug & release) in Firebase Project Settings for your Android app.
    * [ ] **iOS (App Attest / DeviceCheck):** (PENDING)
        * Register app in App Check.
        * Enable chosen provider(s).
        * Complete necessary Apple Developer portal configurations (e.g., App Attest capability for App ID).
* [ ] **Enforce App Check for Remote Config:**
    * In Firebase Console > App Check > APIs > Remote Config:
        * Currently in "Monitor" mode (recommended for initial testing).
        * **Switch to "Enforce"** once thoroughly tested on real devices.
* [ ] **Restrict API Key in Google Cloud Console:**
    * Go to Google Cloud Console > APIs & Services > Credentials.
    * Select your API key.
    * Under "Application restrictions":
        * Add your Android app (package name & **SHA-1** fingerprint for *API key restrictions*, though App Check uses SHA-256).
        * (PENDING iOS) Add your iOS app (bundle ID).
    * Under "API restrictions":
        * Select "Restrict key".
        * Choose **only** "Cloud Text-to-Speech API" (and any other specific APIs this key absolutely needs).

## Phase 5: Building for Release

* [ ] **Android:**
    * Create an upload keystore (if not already done).
    * Configure `android/app/build.gradle` for release signing with your keystore details.
    * Run `flutter build appbundle` or `flutter build apk --release`.
* [ ] **iOS:** (PENDING)
    * Configure signing & capabilities in Xcode.
    * Archive and distribute via TestFlight/App Store.

---

# Application TODO List & Future Enhancements

## 🚧 Core Monetization & Content Strategy

* [ ] **Implement In-App Purchases (IAP):**
    * [ ] Choose an IAP package (e.g., `in_app_purchase`).
    * [ ] Define premium features/content (e.g., exclusive reading plans, advanced TTS voices, ad-free experience, additional devotionals).
    * [ ] Design and implement paywall/unlock UI elements.
    * [ ] **Server-Side Receipt Validation:** Crucial for security.
        * Consider using Firebase Functions to validate receipts with Apple/Google servers.
    * [ ] **Manage User Premium Status:**
        * Use Firebase Auth custom claims (set via Firebase Functions after successful purchase/validation).
        * Alternatively, use Firestore to store user entitlements (link to `AppUser.uid`).
    * [ ] Handle "Restore Purchases" functionality.
    * [ ] Consider one-off purchases for specific content packs if it fits your model.
* [ ] **Migrate Content to Firebase:**
    * [ ] **Reading Plans:**
        * Design Firestore schema for reading plans, days, and scripture passages.
        * Move content from `lib/helpers/reading_plans_data.dart` to Firestore.
        * Update app to fetch plans dynamically.
        * Implement admin interface/scripts for managing plans in Firestore.
    * [ ] **Daily Devotionals:**
        * Design Firestore schema for devotionals.
        * Move content from `lib/helpers/daily_devotions.dart` to Firestore.
        * Update app to fetch daily devotional (consider caching strategies for offline/efficiency).
        * Implement admin interface/scripts for managing devotionals.
    * [ ] **Assets (Images):**
        * Move plan header images (e.g., `assets/images/reading_plan_headers/`) to Firebase Storage.
        * Update app to load these images from Firebase Storage URLs.

## ✨ User Experience & Feature Enhancements

* [ ] **User Notes & Journaling:**
    * Allow users to add personal notes to specific verses or devotional entries.
    * Store notes in Firestore, associated with the user's UID and the content ID (verse/devotional).
* [ ] **Enhanced Offline Support:**
    * Cache Bible text (SQLite is good for this, as it's already there).
    * Cache fetched devotionals and reading plans (e.g., using Firestore offline persistence or caching fetched data locally).
    * Ensure progress in reading plans can be made offline and synced when back online.
* [ ] **Advanced Search:**
    * Filter search results by book ranges.
    * Consider adding topical tags to verses/devotionals for thematic searching (would require data enhancement).
* [ ] **Push Notifications (Firebase Cloud Messaging - FCM):**
    * Daily devotional reminders.
    * Reading plan progress reminders/encouragement.
    * Notifications for new content or features.
* [ ] **User Settings Expansion:**
    * More TTS voice customization options (if API supports more fine-grained control easily).
    * Notification preferences.
    * Data management (e.g., clear cache, export notes).
* [ ] **UI/UX Polish:**
    * Review and refine animations for a more modern feel.
    * Ensure consistent styling and theming.
    * Improve visual hierarchy and information density on cards/screens.
* [ ] **Accessibility (a11y):**
    * Ensure good color contrast.
    * Proper semantic labels for screen readers.
    * Adequate tap target sizes.
* [ ] **Analytics (Firebase Analytics):**
    * Track key user actions (e.g., plan started/completed, feature usage, TTS usage).
    * Monitor user engagement and retention.
    * Use insights to guide future development.

## 📱 iOS Specific Development

* [ ] Complete all steps in "Phase 3: iOS Specific Setup" from the checklist.
* [ ] Thoroughly test all features on various iOS devices and OS versions.
* [ ] Implement iOS-specific UI conventions where appropriate.
* [ ] Prepare for App Store submission (screenshots, app description, privacy policy, keywords).

## 🔒 Security, Maintenance & Admin

* [ ] **Firebase Security Rules:**
    * Write and test robust security rules for Firestore (e.g., users can only write to their own progress/notes).
    * Configure security rules for Firebase Storage if used.
* [ ] **Dependency Management:** Regularly update Flutter and package dependencies to patch vulnerabilities.
* [ ] **Error Reporting (Firebase Crashlytics):** Ensure Crashlytics is integrated and monitor for issues.
* [ ] **Data Backup:** Implement a strategy for backing up critical Firestore data.
* [ ] **Admin Panel/Tools (Consider):**
    * For managing devotionals, reading plans, and potentially users if needed, directly in Firebase or via a simple web interface.

## 👤 User Account Enhancements

* [ ] **Password Reset:** Implement for email/password accounts.
* [ ] **Account Deletion:** Provide an option for users to delete their account and associated data.
* [ ] **Additional Sign-In Providers:** Consider "Sign in with Apple" for iOS users.

