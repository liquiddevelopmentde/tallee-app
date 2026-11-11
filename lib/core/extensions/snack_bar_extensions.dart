import 'package:material_ui/material_ui.dart';
import 'package:tallee/presentation/widgets/custom_snack_bar.dart';

extension SnackBarContextExtension on BuildContext {
  /// Hides the current snackbar and shows a [CustomSnackBar] on the nearest
  /// [ScaffoldMessenger] above this context.
  void showSnackBar({
    required String message,
    IconData? actionIcon,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) => ScaffoldMessenger.of(this)._showCustomSnackBar(
    message: message,
    actionIcon: actionIcon,
    actionLabel: actionLabel,
    onActionTap: onActionTap,
  );
}

extension SnackBarMessengerKeyExtension on GlobalKey<ScaffoldMessengerState> {
  /// Hides the current snackbar and shows a [CustomSnackBar] on the
  /// [ScaffoldMessenger] this key is attached to.
  void showSnackBar({
    required String message,
    IconData? actionIcon,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) => currentState?._showCustomSnackBar(
    message: message,
    actionIcon: actionIcon,
    actionLabel: actionLabel,
    onActionTap: onActionTap,
  );

  /// Hides the currently visible snackbar, if any.
  void hideSnackBar() => currentState?.hideCurrentSnackBar();
}

extension _CustomSnackBarMessenger on ScaffoldMessengerState {
  void _showCustomSnackBar({
    required String message,
    IconData? actionIcon,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) {
    this
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackBar(
          message: message,
          actionIcon: actionIcon,
          actionLabel: actionLabel,
          onActionTap: onActionTap,
        ),
      );
  }
}
