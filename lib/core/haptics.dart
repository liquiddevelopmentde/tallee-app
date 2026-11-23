import 'dart:async';

import 'package:flutter/services.dart';

/// Wrapper for [HapticFeedback].
///
/// Provides unawaited calls of the HapticFeedback methods.
abstract final class Haptics {
  static void selectionClick() => unawaited(HapticFeedback.selectionClick());

  static void lightImpact() => unawaited(HapticFeedback.lightImpact());

  static void heavyImpact() => unawaited(HapticFeedback.heavyImpact());

  static void successNotification() =>
      unawaited(HapticFeedback.successNotification());

  static void errorNotification() =>
      unawaited(HapticFeedback.errorNotification());
}
