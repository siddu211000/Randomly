import 'dart:async';

import 'package:randomly/core/ui_constants/app_durations.dart';

/// Debounces a callback; only the last call within [duration] runs.
void Function() debounceVoid(
  void Function() callback, {
  Duration duration = AppDurations.connectivityDebounce,
}) {
  Timer? timer;
  return () {
    timer?.cancel();
    timer = Timer(duration, callback);
  };
}
