import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app/app_config.dart';
import '../../../../core/persistence/prefs_keys.dart';
import '../../../../core/persistence/prefs_service.dart';
import '../../../../data/auth/firebase_auth_repository.dart';
import '../../../../data/repositories/traveler_profile_repository.dart';
import '../../../../router/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  Future<void> _route() async {
    final config = Get.find<AppConfig>();
    final prefs = Get.find<PrefsService>();

    if (!config.firebaseEnabled) {
      final localDone = await prefs.getBool(PrefsKeys.onboardingCompleteLocal);
      Get.offAllNamed(
        localDone ? AppRoutes.userHome : AppRoutes.onboarding,
      );
      return;
    }

    try {
      final auth = Get.find<FirebaseAuthRepository>();
      await auth.ensureSignedIn();
      final uid = auth.currentUser!.uid;
      final profile = await Get.find<TravelerProfileRepository>().fetchProfile(uid);
      if (!mounted) return;
      Get.offAllNamed(
        profile?.onboardingComplete == true
            ? AppRoutes.userHome
            : AppRoutes.onboarding,
      );
    } catch (_) {
      if (!mounted) return;
      final localDone = await prefs.getBool(PrefsKeys.onboardingCompleteLocal);
      Get.offAllNamed(
        localDone ? AppRoutes.userHome : AppRoutes.onboarding,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_rounded, size: 72, color: scheme.primary),
            const SizedBox(height: 24),
            Text(
              'Randomly',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
