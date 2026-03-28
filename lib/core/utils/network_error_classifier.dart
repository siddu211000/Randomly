import 'package:dio/dio.dart';

import '../../network/api_networks/api_exception/api_exception.dart';

/// True when failure is likely due to no route / timeout (show offline UX).
bool isLikelyOfflineError(Object error) {
  if (error is ApiException) {
    final code = error.statusCode;
    if (code != null) return false;
    final cause = error.cause;
    if (cause is DioException) {
      return _dioOfflineLike(cause);
    }
    return true;
  }
  if (error is DioException) {
    return _dioOfflineLike(error);
  }
  return false;
}

bool _dioOfflineLike(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return true;
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      return false;
    // ignore: unreachable_switch_default — future Dio enum values
    default:
      return false;
  }
}
