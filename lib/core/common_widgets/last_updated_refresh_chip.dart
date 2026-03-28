import 'package:flutter/material.dart';

import '../ui_constants/app_spacing.dart';

/// Tap to refresh + relative "Updated …" label (no extra packages).
class LastUpdatedRefreshChip extends StatelessWidget {
  const LastUpdatedRefreshChip({
    super.key,
    required this.lastUpdated,
    required this.onRefresh,
  });

  final DateTime? lastUpdated;
  final VoidCallback onRefresh;

  static String _relative(DateTime? time) {
    if (time == null) return 'Tap to refresh';
    final d = DateTime.now().difference(time);
    if (d.inSeconds < 10) return 'Updated just now · tap to refresh';
    if (d.inMinutes < 1) return 'Updated ${d.inSeconds}s ago · tap to refresh';
    if (d.inMinutes < 60) return 'Updated ${d.inMinutes}m ago · tap to refresh';
    if (d.inHours < 24) return 'Updated ${d.inHours}h ago · tap to refresh';
    return 'Updated ${d.inDays}d ago · tap to refresh';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ActionChip(
        avatar: Icon(
          Icons.refresh_rounded,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        label: Text(_relative(lastUpdated)),
        onPressed: onRefresh,
      ),
    );
  }
}
