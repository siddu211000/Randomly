import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// On Android, prefer native config from `google-services.json` (merged by
/// Gradle) so Auth sees the same `oauth_client` as the console download.
/// Dart-only [FirebaseOptions] can still trigger `CONFIGURATION_NOT_FOUND` for
/// some `firebase_auth` versions even when [FirebaseOptions.androidClientId]
/// is set.
Future<void> ensureFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) return;
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return;
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    await Firebase.initializeApp();
    return;
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
