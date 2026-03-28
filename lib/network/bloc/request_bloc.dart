import 'package:flutter_bloc/flutter_bloc.dart';

import 'request_events.dart';
import 'request_retry_config.dart';
import 'request_states.dart';

/// Reusable BLoC for a single async request (typically an API call).
///
/// Usage:
/// ```dart
/// final bloc = RequestBloc<User>();
/// bloc.add(RequestLoad(() => repository.fetchUser()));
/// ```
///
/// With automatic retries for reads:
/// ```dart
/// bloc.add(RequestLoad(
///   () => repository.fetchUser(),
///   retry: RequestRetryConfig.standardRead,
/// ));
/// ```
class RequestBloc<T> extends Bloc<RequestEvent<T>, RequestState<T>> {
  RequestBloc() : super(const RequestInitial()) {
    on<RequestLoad<T>>(_onLoad);
    on<RequestReload<T>>(_onReload);
  }

  Future<T> Function()? _lastLoader;
  RequestRetryConfig _lastRetry = RequestRetryConfig.none;

  Future<void> _onLoad(
    RequestLoad<T> event,
    Emitter<RequestState<T>> emit,
  ) async {
    _lastLoader = event.loader;
    _lastRetry = event.retry;
    await _runWithRetry(
      emit,
      event.loader,
      event.retry,
    );
  }

  Future<void> _onReload(
    RequestReload<T> event,
    Emitter<RequestState<T>> emit,
  ) async {
    final loader = _lastLoader;
    if (loader == null) {
      emit(RequestFailure<T>(
        StateError('RequestReload before RequestLoad'),
        message: 'No previous request to reload',
      ));
      return;
    }
    await _runWithRetry(emit, loader, _lastRetry);
  }

  Future<void> _runWithRetry(
    Emitter<RequestState<T>> emit,
    Future<T> Function() loader,
    RequestRetryConfig retry,
  ) async {
    final maxAttempts = retry.maxAttempts < 1 ? 1 : retry.maxAttempts;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      emit(RequestLoading<T>(attempt: attempt, maxAttempts: maxAttempts));
      try {
        final data = await loader();
        emit(RequestSuccess<T>(data));
        return;
      } catch (e, st) {
        final shouldRetry = retry.allowsRetryForError(e, attempt);
        if (attempt >= maxAttempts || !shouldRetry) {
          emit(RequestFailure<T>(e, message: e.toString()));
          addError(e, st);
          return;
        }
        final wait = retry.delayAfterFailure(attempt);
        if (wait > Duration.zero) {
          await Future<void>.delayed(wait);
        }
      }
    }
  }
}
