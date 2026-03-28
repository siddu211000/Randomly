import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/utils/app_log.dart';

/// Logs requests/responses in debug only.
final class DioLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      AppLog.d('→ ${options.method} ${options.uri}', name: 'dio');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      AppLog.d(
        '← ${response.statusCode} ${response.requestOptions.uri}',
        name: 'dio',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      AppLog.d('✗ ${err.type} ${err.requestOptions.uri}', name: 'dio');
    }
    handler.next(err);
  }
}
