// ignore_for_file: lines_longer_than_80_chars
//
// Replace this file by running:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Placeholder values let the project compile; real Firebase features need your
// project's keys from the Firebase Console.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'randomly-dev-placeholder',
    authDomain: 'randomly-dev-placeholder.firebaseapp.com',
    storageBucket: 'randomly-dev-placeholder.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholderReplaceFromFirebaseConsole',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'randomly-dev-placeholder',
    storageBucket: 'randomly-dev-placeholder.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholderReplaceFromFirebaseConsole',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'randomly-dev-placeholder',
    storageBucket: 'randomly-dev-placeholder.appspot.com',
    iosBundleId: 'com.example.randomly',
  );
}
