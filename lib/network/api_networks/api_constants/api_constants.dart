/// Base URLs, timeouts, and shared API configuration.
abstract final class ApiConstants {
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Override via `--dart-define=API_BASE_URL=https://api.example.com`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );
}
