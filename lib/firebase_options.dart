// ignore_for_file: lines_longer_than_80_chars
//
// Synced with `android/app/google-services.json` for project randomly-3b0c6.
// For iOS / Web, add those apps in Firebase Console and run:
//   flutterfire configure
// or paste the values from each platform’s config file.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform — run flutterfire configure.',
        );
    }
  }

  /// Add a Web app in Firebase Console → Project settings → Your apps, then
  /// replace [appId] with the `appId` from the web config snippet.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyArTxWsYynvykfVZH7L69gsapnydkltG8E',
    appId: '1:357044840267:web:577d7d4ac2ba3bba4eaace',
    messagingSenderId: '357044840267',
    projectId: 'randomly-3b0c6',
    authDomain: 'randomly-3b0c6.firebaseapp.com',
    storageBucket: 'randomly-3b0c6.firebasestorage.app',
  );

  /// If Android Auth shows `CONFIGURATION_NOT_FOUND`, paste your **Android**
  /// OAuth 2.0 client ID here (not the Web client).
  ///
  /// Google Cloud Console → project **randomly-3b0c6** → **APIs & Services** →
  /// **Credentials** → **Create credentials** → **OAuth client ID** →
  /// application type **Android** → package `com.example.randomly` → your
  /// debug **SHA-1** → Create → copy **Client ID** (`….apps.googleusercontent.com`).
  ///
  /// Or run `flutterfire configure` after adding SHA-1 in Firebase and use the
  /// generated file (it may fill this for you).
  static const String _androidOAuthClientId =
      '357044840267-eqorstfigdu11flniiq4pe0lmni0efgp.apps.googleusercontent.com';

  static FirebaseOptions get android {
    const id = _androidOAuthClientId;
    return FirebaseOptions(
      apiKey: 'AIzaSyArTxWsYynvykfVZH7L69gsapnydkltG8E',
      appId: '1:357044840267:android:577d7d4ac2ba3bba4eaace',
      messagingSenderId: '357044840267',
      projectId: 'randomly-3b0c6',
      authDomain: 'randomly-3b0c6.firebaseapp.com',
      storageBucket: 'randomly-3b0c6.firebasestorage.app',
      androidClientId: id.isEmpty ? null : id,
    );
  }

  /// Add an iOS app in Firebase, download `GoogleService-Info.plist`, and set
  /// [appId] to `GOOGLE_APP_ID` from that file (differs from Android).
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyArTxWsYynvykfVZH7L69gsapnydkltG8E',
    appId: '1:357044840267:ios:577d7d4ac2ba3bba4eaace',
    messagingSenderId: '357044840267',
    projectId: 'randomly-3b0c6',
    storageBucket: 'randomly-3b0c6.firebasestorage.app',
    iosBundleId: 'com.example.randomly',
  );
}
