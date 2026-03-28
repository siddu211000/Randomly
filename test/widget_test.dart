import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:randomly/bootstrap/app_bootstrap.dart';
import 'package:randomly/core/services/connectivity_service.dart';
import 'package:randomly/main.dart';
import 'package:randomly/router/app_routes.dart';

void main() {
  setUp(() async {
    Get.reset();
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await initializeApp(
      registerPlatformConnectivity: false,
      enableFirebase: false,
    );
  });

  tearDown(() async {
    if (Get.isRegistered<ConnectivityService>()) {
      Get.find<ConnectivityService>().dispose();
    }
    Get.reset();
  });

  testWidgets('User home counter increments', (WidgetTester tester) async {
    await tester.pumpWidget(
      const RandomlyApp(initialRouteOverride: AppRoutes.userHome),
    );
    await tester.pump();

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
