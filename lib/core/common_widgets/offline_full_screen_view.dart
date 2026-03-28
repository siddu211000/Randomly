import 'package:flutter/material.dart';

import '../ui_constants/app_spacing.dart';

/// Calm full-screen state when the device likely has no usable connection.
class OfflineFullScreenView extends StatelessWidget {
  const OfflineFullScreenView({
    super.key,
    required this.onRetry,
    this.title = "You're offline",
    this.message = 'Check your connection and try again.',
    this.onOpenSettings,
    this.illustration,
  });

  final VoidCallback onRetry;
  final String title;
  final String message;
  final VoidCallback? onOpenSettings;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            const Spacer(flex: 2),
            illustration ??
                Icon(
                  Icons.wifi_off_rounded,
                  size: 72,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 3),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ),
            if (onOpenSettings != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: onOpenSettings,
                child: const Text('Connection settings'),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
