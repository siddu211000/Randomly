/// Central keys for [PrefsService]. Avoid string typos across the app.
abstract final class PrefsKeys {
  static const String onboardingCompleted = 'onboarding_completed';
  static const String lastThemeMode = 'last_theme_mode';

  /// When Firebase is off (e.g. tests), local onboarding flag.
  static const String onboardingCompleteLocal = 'onboarding_complete_local';
}
