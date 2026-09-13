import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_icon_button.dart';

class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    Key? key,
    required String message,
    IconData? actionIcon,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) : this._internal(
         key: key,
         message: message,
         actionIcon: actionIcon,
         actionLabel: actionLabel,
         onActionTap: onActionTap,
         duration: const Duration(milliseconds: 5000),
         proxy: ProxyAnimation(),
       );

  CustomSnackBar._internal({
    super.key,
    required String message,
    required this.proxy,
    this.actionIcon,
    this.actionLabel,
    this.onActionTap,
    super.duration,
  }) : super(
         animation: proxy,
         behavior: SnackBarBehavior.floating,
         backgroundColor: Colors.transparent,
         elevation: 0,
         content: AnimatedContent(
           message: message,
           animation: proxy,
           actionIcon: actionIcon,
           actionLabel: actionLabel,
           onActionTap: onActionTap,
         ),
       );

  final ProxyAnimation proxy;
  final IconData? actionIcon;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  SnackBar withAnimation(Animation<double> newAnimation, {Key? fallbackKey}) {
    proxy.parent = newAnimation;
    final animatedContent = content as AnimatedContent;

    return CustomSnackBar._internal(
      key: key ?? fallbackKey,
      message: animatedContent.message,
      actionIcon: animatedContent.actionIcon,
      actionLabel: animatedContent.actionLabel,
      onActionTap: animatedContent.onActionTap,
      duration: duration,
      proxy: proxy,
    );
  }
}

class AnimatedContent extends StatelessWidget {
  const AnimatedContent({
    super.key,
    required this.message,
    required this.animation,
    this.actionIcon,
    this.actionLabel,
    this.onActionTap,
  });

  final String message;
  final IconData? actionIcon;
  final String? actionLabel;
  final VoidCallback? onActionTap;
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
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: CustomTheme.boxColor,
              border: Border.all(color: CustomTheme.boxBorderColor),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12.5,
                  spreadRadius: 5,
                  offset: Offset.zero,
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
                    style: const TextStyle(
                      color: CustomTheme.textColor,
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
                      foregroundColor: CustomTheme.primaryColor,
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
                      actionIcon!,
                      color: CustomTheme.textColor,
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
    );
  }
}
