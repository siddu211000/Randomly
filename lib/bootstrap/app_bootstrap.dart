import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app/app_config.dart';
import '../core/bloc/app_bloc_observer.dart';
import '../core/persistence/prefs_service.dart';
import '../core/persistence/prefs_service_impl.dart';
import '../core/services/connectivity_service.dart';
import '../core/utils/app_log.dart';
import '../data/auth/firebase_auth_repository.dart';
import '../data/firebase/firebase_bootstrap.dart';
import '../data/repositories/traveler_profile_repository.dart';
import '../network/api_networks/api_client/api_client.dart';

/// Registers core services once. Safe to call again after [Get.reset] in tests.
///
/// Set [registerPlatformConnectivity] to false in widget tests (no platform plugin).
/// Set [enableFirebase] to false in widget tests or when Firebase is not configured.
Future<void> initializeApp({
  bool registerPlatformConnectivity = true,
  bool enableFirebase = true,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    Bloc.observer = AppBlocObserver();
  }

  if (!Get.isRegistered<PrefsService>()) {
    final prefs = await SharedPreferences.getInstance();
    Get.put<PrefsService>(PrefsServiceImpl(prefs), permanent: true);
  }

  if (!Get.isRegistered<ApiClient>()) {
    Get.put<ApiClient>(ApiClient(), permanent: true);
  }

  if (!Get.isRegistered<ConnectivityService>()) {
    final connectivity = ConnectivityService(
      usePlatformPlugin: registerPlatformConnectivity,
    );
    await connectivity.init();
    Get.put<ConnectivityService>(connectivity, permanent: true);
  }

  var firebaseReady = false;
  if (enableFirebase) {
    try {
      await ensureFirebaseInitialized();
      firebaseReady = true;
    } catch (e, st) {
      AppLog.e(
        'Firebase init failed — run flutterfire configure and add real config files.',
        error: e,
        stackTrace: st,
      );
    }
  }

  if (!Get.isRegistered<AppConfig>()) {
    Get.put<AppConfig>(
      AppConfig(firebaseEnabled: firebaseReady),
      permanent: true,
    );
  }

  if (firebaseReady) {
    if (!Get.isRegistered<FirebaseAuthRepository>()) {
      Get.put<FirebaseAuthRepository>(FirebaseAuthRepository(), permanent: true);
    }
    if (!Get.isRegistered<TravelerProfileRepository>()) {
      Get.put<TravelerProfileRepository>(
        TravelerProfileRepository(),
        permanent: true,
      );
    }
  }
}
