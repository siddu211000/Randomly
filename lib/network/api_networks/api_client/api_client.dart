import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api_constants/api_constants.dart';
import '../api_exception/api_exception.dart';
import 'dio_logging_interceptor.dart';

/// Shared [Dio] instance for the app. Inject or subclass per test/mocks.
class ApiClient {
  ApiClient({Dio? dio, List<Interceptor>? extraInterceptors})
      : _dio = dio ?? _createDefaultDio(extraInterceptors: extraInterceptors);

  final Dio _dio;

  static Dio _createDefaultDio({List<Interceptor>? extraInterceptors}) {
    final options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: <String, dynamic>{
        Headers.acceptHeader: Headers.jsonContentType,
        Headers.contentTypeHeader: Headers.jsonContentType,
      },
    );
    final dio = Dio(options);
    if (kDebugMode) {
      dio.interceptors.add(DioLoggingInterceptor());
    }
    if (extraInterceptors != null) {
      dio.interceptors.addAll(extraInterceptors);
    }
    return dio;
  }

  Dio get dio => _dio;

  /// GET helper; maps [DioException] to [ApiException].
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e, st) {
      Error.throwWithStackTrace(_mapDio(e), st);
    }
  }

  /// POST helper; maps [DioException] to [ApiException].
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e, st) {
      Error.throwWithStackTrace(_mapDio(e), st);
    }
  }

  static ApiException _mapDio(DioException e) {
    final response = e.response;
    final status = response?.statusCode;
    final data = response?.data;
    String message = e.message ?? 'Network error';
    if (data is Map && data['message'] is String) {
      message = data['message'] as String;
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }
    return ApiException(
      message,
      statusCode: status,
      cause: e,
    );
  }
}
