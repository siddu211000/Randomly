import '../api_networks/api_exception/api_exception.dart';

/// Controls automatic retries for [RequestLoad] / [RequestReload] in [RequestBloc].
///
/// Use [none] (default) for mutations unless you have idempotency keys.
/// Use [standardRead] or a custom config for safe, idempotent GET-style loads.
class RequestRetryConfig {
  const RequestRetryConfig({
    this.maxAttempts = 1,
    this.baseDelay = Duration.zero,
    this.exponentialBackoff = true,
    this.shouldRetry,
  });

  /// A single attempt — no automatic retry.
  static const RequestRetryConfig none = RequestRetryConfig();

  /// Example policy for read-only API calls (tune delays and count for your app).
  static const RequestRetryConfig standardRead = RequestRetryConfig(
    maxAttempts: 3,
    baseDelay: Duration(milliseconds: 400),
    exponentialBackoff: true,
  );

  /// Total tries including the first. Must be >= 1.
  final int maxAttempts;

  /// Base delay before the second try; grows when [exponentialBackoff] is true.
  final Duration baseDelay;

  /// If true, delay multiplier roughly doubles after each failed attempt.
  final bool exponentialBackoff;

  /// Override [defaultShouldRetry]; return false for errors that must not repeat (e.g. 400).
  final bool Function(Object error)? shouldRetry;

  bool allowsRetryForError(Object error, int completedAttempts) {
    if (completedAttempts >= maxAttempts) return false;
    final fn = shouldRetry;
    if (fn != null) return fn(error);
    return defaultShouldRetry(error);
  }

  /// Wait time after failure `failedAttemptNumber` (1 = first failure, before 2nd try).
  Duration delayAfterFailure(int failedAttemptNumber) {
    if (baseDelay <= Duration.zero) return Duration.zero;
    if (!exponentialBackoff) return baseDelay;
    final exp = (failedAttemptNumber - 1).clamp(0, 10);
    return baseDelay * (1 << exp);
  }
}

/// Conservative default: transient network / server errors, not most 4xx client errors.
bool defaultShouldRetry(Object error) {
  if (error is ApiException) {
    final code = error.statusCode;
    if (code == null) return true;
    if (code == 408 || code == 429) return true;
    if (code >= 500) return true;
    return false;
  }
  return true;
}
