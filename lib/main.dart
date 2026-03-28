import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bootstrap/app_bootstrap.dart';
import 'core/common_widgets/connectivity_banner.dart';
import 'core/services/connectivity_service.dart';
import 'core/ui_constants/app_theme.dart';
import 'router/app_pages.dart';
import 'router/app_routes.dart';

Future<void> main() async {
  await initializeApp();
  runApp(const RandomlyApp());
}

class RandomlyApp extends StatelessWidget {
  const RandomlyApp({
    super.key,
    this.initialRouteOverride,
  });

  /// Tests can skip [AppRoutes.splash] (Firebase / routing side-effects).
  final String? initialRouteOverride;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Randomly',
      initialRoute: initialRouteOverride ?? AppRoutes.splash,
      getPages: AppPages.pages,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        if (!Get.isRegistered<ConnectivityService>()) {
          return content;
        }
        return ConnectivityBanner(
          connectivity: Get.find<ConnectivityService>(),
          child: content,
        );
      },
    );
  }
}
