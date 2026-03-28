# Firebase setup (Randomly)

1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Anonymous** sign-in: Authentication → Sign-in method → Anonymous.
3. Create a **Cloud Firestore** database (start in test mode only for local dev, then deploy rules from `docs/firestore.rules`).
4. Install CLI and link the app:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This regenerates `lib/firebase_options.dart` and updates native config.
5. Replace placeholder files:
   - `android/app/google-services.json` — download from Firebase (Android app).
   - `ios/Runner/GoogleService-Info.plist` — download from Firebase (iOS app).
6. Deploy rules (when ready):
   ```bash
   firebase deploy --only firestore:rules
   ```

**Tests** call `initializeApp(enableFirebase: false)` so CI does not need Firebase.

**Roles:** `users/{uid}` includes a `role` field (`user` | `vendor` | `admin`) for future portals on the same codebase.
