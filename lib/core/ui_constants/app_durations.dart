import 'package:flutter/animation.dart';

/// Shared animation and delay tokens.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration connectivityDebounce = Duration(milliseconds: 600);
}

abstract final class AppCurves {
  static const Curve standard = Curves.easeOutCubic;
}
