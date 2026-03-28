import 'package:flutter/material.dart';

/// App bar refresh control: shows a small progress ring while [isRefreshing].
class RefreshIconButton extends StatelessWidget {
  const RefreshIconButton({
    super.key,
    required this.onPressed,
    this.isRefreshing = false,
  });

  final VoidCallback onPressed;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: 'Refresh',
      onPressed: isRefreshing ? null : onPressed,
      icon: isRefreshing
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.onSurface,
              ),
            )
          : Icon(Icons.refresh_rounded, color: scheme.onSurface),
    );
  }
}
