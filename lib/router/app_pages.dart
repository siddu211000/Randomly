import 'package:get/get.dart';

import '../features/admin_home/presentation/screens/admin_home_screen.dart';
import '../features/authentication/presentation/screens/authentication_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/user_home/presentation/screens/user_home_screen.dart';
import '../features/vendor_home/presentation/screens/vendor_home_screen.dart';
import 'app_routes.dart';

/// Central list of [GetPage] definitions.
abstract final class AppPages {
  static List<GetPage<dynamic>> get pages => <GetPage<dynamic>>[
        GetPage<dynamic>(
          name: AppRoutes.splash,
          page: SplashScreen.new,
        ),
        GetPage<dynamic>(
          name: AppRoutes.onboarding,
          page: OnboardingFlowScreen.new,
        ),
        GetPage<dynamic>(
          name: AppRoutes.userHome,
          page: UserHomeScreen.new,
        ),
        GetPage<dynamic>(
          name: AppRoutes.vendorHome,
          page: VendorHomeScreen.new,
        ),
        GetPage<dynamic>(
          name: AppRoutes.adminHome,
          page: AdminHomeScreen.new,
        ),
        GetPage<dynamic>(
          name: AppRoutes.authentication,
          page: AuthenticationScreen.new,
        ),
        GetPage<dynamic>(
          name: AppRoutes.profile,
          page: ProfileScreen.new,
        ),
      ];
}
