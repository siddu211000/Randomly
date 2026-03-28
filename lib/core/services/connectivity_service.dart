import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../ui_constants/app_durations.dart';

/// Coarse online / offline for UI (banner, messaging). Not a guarantee of internet.
enum ConnectivityUiStatus { unknown, online, offline }

class ConnectivityService {
  /// When [usePlatformPlugin] is false (e.g. widget tests), stays [online] without plugins.
  ConnectivityService({
    Connectivity? connectivity,
    this.usePlatformPlugin = true,
  }) : _connectivity = connectivity;

  final Connectivity? _connectivity;
  final bool usePlatformPlugin;

  final ValueNotifier<ConnectivityUiStatus> notifier =
      ValueNotifier(ConnectivityUiStatus.unknown);

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _debounce;

  Future<void> init() async {
    if (!usePlatformPlugin) {
      notifier.value = ConnectivityUiStatus.online;
      return;
    }
    final c = _connectivity ?? Connectivity();
    final initial = await c.checkConnectivity();
    _apply(initial);
    _subscription = c.onConnectivityChanged.listen(_onChanged);
  }

  void _onChanged(List<ConnectivityResult> results) {
    _debounce?.cancel();
    _debounce = Timer(AppDurations.connectivityDebounce, () => _apply(results));
  }

  void _apply(List<ConnectivityResult> results) {
    final offline = results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none);
    notifier.value =
        offline ? ConnectivityUiStatus.offline : ConnectivityUiStatus.online;
  }

  void dispose() {
    _debounce?.cancel();
    _subscription?.cancel();
    notifier.dispose();
  }
}
