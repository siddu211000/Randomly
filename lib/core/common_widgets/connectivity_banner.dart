import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';
import 'value_notifier_builder.dart';

/// Offline strip at the top over [child]. Safe for [GetMaterialApp.builder] (uses [Stack]).
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({
    super.key,
    required this.connectivity,
    required this.child,
    this.message = 'No connection · Showing saved data where available',
  });

  final ConnectivityService connectivity;
  final Widget child;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ValueNotifierBuilder<ConnectivityUiStatus>(
      notifier: connectivity.notifier,
      builder: (context, status, _) {
        final offline = status == ConnectivityUiStatus.offline;
        final scheme = Theme.of(context).colorScheme;

        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (offline)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Material(
                    color: scheme.errorContainer,
                    elevation: 2,
                    shadowColor: scheme.shadow.withValues(alpha: 0.2),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onErrorContainer,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
