import 'package:equatable/equatable.dart';

import 'request_retry_config.dart';

/// Events for [RequestBloc]. The loader is intentionally omitted from [props].
sealed class RequestEvent<T> extends Equatable {
  const RequestEvent();

  @override
  List<Object?> get props => [];
}

/// Execute a one-shot async operation and emit loading → success/failure.
class RequestLoad<T> extends RequestEvent<T> {
  const RequestLoad(
    this.loader, {
    this.retry = RequestRetryConfig.none,
  });

  final Future<T> Function() loader;

  /// Automatic retries with optional backoff (see [RequestRetryConfig]).
  final RequestRetryConfig retry;

  @override
  List<Object?> get props => [retry];
}

/// Re-run the last successful loader (must call after at least one [RequestLoad]).
class RequestReload<T> extends RequestEvent<T> {
  const RequestReload();
}
