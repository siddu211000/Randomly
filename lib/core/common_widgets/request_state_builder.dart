import 'package:flutter/material.dart';

import '../../network/bloc/request_states.dart';
import '../utils/network_error_classifier.dart';
import 'app_error_retry_view.dart';
import 'offline_full_screen_view.dart';

/// Maps [RequestState] to widgets: offline vs generic error vs loading vs data.
class RequestStateBuilder<T> extends StatelessWidget {
  const RequestStateBuilder({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onSuccess,
    this.onInitial,
    this.onLoading,
  });

  final RequestState<T> state;
  final VoidCallback onRetry;
  final Widget Function(T data) onSuccess;
  final Widget? onInitial;
  final Widget? onLoading;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      RequestInitial<T>() => onInitial ?? const SizedBox.shrink(),
      RequestLoading<T>(:final attempt, :final maxAttempts) =>
        onLoading ??
            _DefaultRequestLoading(
              attempt: attempt,
              maxAttempts: maxAttempts,
            ),
      RequestSuccess<T>(:final data) => onSuccess(data),
      RequestFailure<T>(:final error, :final message) => _failure(
          context,
          error,
          message,
        ),
    };
  }

  Widget _failure(BuildContext context, Object error, String? message) {
    if (isLikelyOfflineError(error)) {
      return OfflineFullScreenView(
        onRetry: onRetry,
        message: message ?? 'Check your connection and try again.',
      );
    }
    return AppErrorRetryView(
      message: message ?? error.toString(),
      onRetry: onRetry,
    );
  }
}

class _DefaultRequestLoading extends StatelessWidget {
  const _DefaultRequestLoading({
    required this.attempt,
    required this.maxAttempts,
  });

  final int attempt;
  final int maxAttempts;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: scheme.primary),
          if (attempt > 1) ...[
            const SizedBox(height: 16),
            Text(
              'Reconnecting… ($attempt/$maxAttempts)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
