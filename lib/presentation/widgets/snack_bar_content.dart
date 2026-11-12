import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';

/// The visual content of a snackbar.
///
/// Used by the custom snackbar and by snackbars shown in an overlay.
class SnackBarContent extends StatelessWidget {
  const SnackBarContent({
    super.key,
    required this.message,
    required this.animation,
    this.actionIcon,
    this.actionLabel,
    this.onActionTap,
    this.onTap,
  }) : assert(
         (actionLabel == null && actionIcon == null) || onActionTap != null,
         'actionLabel or actionIcon require onActionTap to be set',
       ),
       assert(
         actionLabel == null || actionIcon == null,
         'actionLabel and actionIcon can\'t be simultaneously set',
       );

  final String message;
  final IconData? actionIcon;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final VoidCallback? onTap;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = animation.drive(
      CurveTween(curve: Curves.easeInOut),
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: ScaleTransition(
        scale: curvedAnimation.drive(Tween<double>(begin: 0.8, end: 1.0)),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap:
                  onTap ??
                  () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: context.talleeColors.boxColor,
                  border: Border.all(color: context.talleeColors.boxBorderColor),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12.5,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        message,
                        overflow: TextOverflow.visible,
                        textWidthBasis: TextWidthBasis.longestLine,
                        textAlign: (actionIcon != null || actionLabel != null)
                            ? TextAlign.left
                            : TextAlign.center,
                        style: TextStyle(
                          color: context.talleeColors.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    if (onActionTap != null && actionLabel != null) ...[
                      const SizedBox(width: 12),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: AppColors.primaryColor,
                        ),
                        onPressed: onActionTap,
                        child: Text(
                          actionLabel!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ] else if (onActionTap != null && actionIcon != null) ...[
                      const SizedBox(width: 12),
                      HapticIconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          actionIcon,
                          color: context.talleeColors.textColor,
                          size: 20,
                        ),
                        onPressed: onActionTap,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
