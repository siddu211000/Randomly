import 'package:flutter/widgets.dart';

/// Rebuilds when [notifier] changes, without [setState].
///
/// Prefer this for local UI state driven by [ValueNotifier].
class ValueNotifierBuilder<T> extends StatelessWidget {
  const ValueNotifierBuilder({
    super.key,
    required this.notifier,
    required this.builder,
    this.child,
  });

  final ValueNotifier<T> notifier;
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, child) => builder(context, notifier.value, child),
      child: child,
    );
  }
}
