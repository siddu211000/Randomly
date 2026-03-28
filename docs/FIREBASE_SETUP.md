# Firebase setup (Randomly)

**Project:** `randomly-3b0c6` — Android is wired via `android/app/google-services.json` and `lib/firebase_options.dart`.

## Required in Firebase Console

1. **Authentication** → Sign-in method → enable **Anonymous**.
2. **Firestore** → create database (use test rules only for your own device, then deploy `docs/firestore.rules` before wider testing).

## Android (ready)

- `google-services.json` is in `android/app/` for package `com.example.randomly`.
- Run on a device/emulator: `flutter run` — Firebase should initialize if the steps above are done.

## iOS & Web (if you use those targets)

Each platform needs its **own** app registration in Firebase (Project settings → Your apps). The **App ID** is **not** the same as Android’s.

1. Add **iOS** (bundle `com.example.randomly`), download **`GoogleService-Info.plist`**, replace `ios/Runner/GoogleService-Info.plist`.
2. Copy **`GOOGLE_APP_ID`** from that plist into `lib/firebase_options.dart` → `DefaultFirebaseOptions.ios.appId`.
3. Add a **Web** app if you build for web; paste its `appId` into `DefaultFirebaseOptions.web.appId` in `firebase_options.dart`.

Or run **`flutterfire configure`** after adding each app — it regenerates `firebase_options.dart` for you.

## Optional CLI

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

## Rules deploy

```bash
firebase deploy --only firestore:rules
```

**Tests** call `initializeApp(enableFirebase: false)` so CI does not need Firebase.

**Roles:** `users/{uid}` includes a `role` field (`user` | `vendor` | `admin`) for future portals.

## API key note

The client API key in `google-services.json` is normal to ship inside the app. In [Google Cloud Console](https://console.cloud.google.com/) you can restrict the key (e.g. Android app + package name) for extra safety.
