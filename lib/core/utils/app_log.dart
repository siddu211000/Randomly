import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Single place for debug logging. No-op in release for [d].
abstract final class AppLog {
  static void d(String message, {String name = 'randomly'}) {
    if (kDebugMode) {
      developer.log(message, name: name);
    }
  }

  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'randomly',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
