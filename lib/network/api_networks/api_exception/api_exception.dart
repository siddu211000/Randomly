/// Thrown when an API call fails after normalization (e.g. from [DioException]).
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() =>
      'ApiException($statusCode): $message${cause != null ? ' ($cause)' : ''}';
}
