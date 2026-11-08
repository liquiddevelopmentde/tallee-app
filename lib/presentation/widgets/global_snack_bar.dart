import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:tallee/presentation/widgets/snack_bar_content.dart';

/// Shows a [SnackBarContent] in an overlay above the current route.
///
/// Unlike a [SnackBar] shown through a [ScaffoldMessenger], an overlay is not
/// bound to a [Scaffold] or a [ScaffoldMessenger] and is therefore always
/// visible on the currently active screen.
abstract final class GlobalSnackBar {
  static OverlayEntry? _entry;

  /// Shows [message] on top of the current route.
  ///
  /// An already visible global snackbar is replaced.
  static void show(
    OverlayState overlay, {
    required String message,
    IconData? actionIcon,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) {
    dismiss();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _GlobalSnackBarOverlay(
        message: message,
        actionIcon: actionIcon,
        actionLabel: actionLabel,
        onActionTap: onActionTap,
        onDismissed: () => _remove(entry),
      ),
    );

    _entry = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    final entry = _entry;
    if (entry == null) return;
    _entry = null;
    entry.remove();
  }

  static void _remove(OverlayEntry entry) {
    if (identical(_entry, entry)) _entry = null;
    entry.remove();
  }
}

class _GlobalSnackBarOverlay extends StatefulWidget {
  const _GlobalSnackBarOverlay({
    required this.message,
    required this.onDismissed,
    this.actionIcon,
    this.actionLabel,
    this.onActionTap,
  });

  final String message;
  final IconData? actionIcon;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final VoidCallback onDismissed;

  @override
  State<_GlobalSnackBarOverlay> createState() => _GlobalSnackBarOverlayState();
}

class _GlobalSnackBarOverlayState extends State<_GlobalSnackBarOverlay>
    with SingleTickerProviderStateMixin {
  static const Duration _animationDuration = Duration(milliseconds: 250);
  static const Duration _visibleDuration = Duration(milliseconds: 5000);

  late final AnimationController _animationController;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..forward();
    _dismissTimer = Timer(_visibleDuration, _dismiss);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;
    _dismissTimer?.cancel();
    _animationController.reverse().whenCompleteOrCancel(() {
      if (mounted) widget.onDismissed();
    });
  }

  void _handleActionTap() {
    _dismissTimer?.cancel();
    widget.onActionTap?.call();
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) => Positioned(
    left: 16,
    right: 16,
    // Keep snackbar above the keyboard
    bottom:
        math.max(
          MediaQuery.viewPaddingOf(context).bottom,
          MediaQuery.viewInsetsOf(context).bottom,
        ) +
        16,
    child: SnackBarContent(
      message: widget.message,
      animation: _animationController,
      actionIcon: widget.actionIcon,
      actionLabel: widget.actionLabel,
      onActionTap: widget.onActionTap == null ? null : _handleActionTap,
      onTap: _dismiss,
    ),
  );
}
