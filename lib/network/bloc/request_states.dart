import 'package:equatable/equatable.dart';

/// Generic API / async request state for reuse across features.
sealed class RequestState<T> extends Equatable {
  const RequestState();

  @override
  List<Object?> get props => [];
}

class RequestInitial<T> extends RequestState<T> {
  const RequestInitial();
}

class RequestLoading<T> extends RequestState<T> {
  const RequestLoading({
    this.attempt = 1,
    this.maxAttempts = 1,
  });

  /// Current attempt (1-based). Shown for subtle “retrying” UX when > 1.
  final int attempt;

  final int maxAttempts;

  @override
  List<Object?> get props => [attempt, maxAttempts];
}

class RequestSuccess<T> extends RequestState<T> {
  const RequestSuccess(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

class RequestFailure<T> extends RequestState<T> {
  const RequestFailure(this.error, {this.message});

  final Object error;
  final String? message;

  @override
  List<Object?> get props => [error, message];
}
