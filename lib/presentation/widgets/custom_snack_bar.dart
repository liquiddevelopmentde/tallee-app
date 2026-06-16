import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    Key? key,
    required String message,
    String? actionText,
    VoidCallback? onActionTap,
  }) : this._internal(
         key: key,
         message: message,
         actionText: actionText,
         onActionTap: onActionTap,
         duration: const Duration(milliseconds: 5000),
         proxy: ProxyAnimation(),
       );

  CustomSnackBar._internal({
    super.key,
    required String message,
    required this.proxy,
    this.actionText,
    this.onActionTap,
    super.duration,
  }) : super(
         animation: proxy,
         behavior: SnackBarBehavior.floating,
         backgroundColor: Colors.transparent,
         elevation: 0,
         content: _AnimatedContent(
           message: message,
           animation: proxy,
           actionText: actionText,
           onActionTap: onActionTap,
         ),
       );

  final ProxyAnimation proxy;
  final String? actionText;
  final VoidCallback? onActionTap;

  @override
  SnackBar withAnimation(Animation<double> newAnimation, {Key? fallbackKey}) {
    proxy.parent = newAnimation;
    final animatedContent = content as _AnimatedContent;

    return CustomSnackBar._internal(
      key: key ?? fallbackKey,
      message: animatedContent.message,
      actionText: animatedContent.actionText,
      onActionTap: animatedContent.onActionTap,
      duration: duration,
      proxy: proxy,
    );
  }
}

class _AnimatedContent extends StatelessWidget {
  const _AnimatedContent({
    required this.message,
    required this.animation,
    this.actionText,
    this.onActionTap,
  });

  final String message;
  final String? actionText;
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    message,
                    overflow: TextOverflow.visible,
                    textWidthBasis: TextWidthBasis.longestLine,
                    textAlign: actionText != null
                        ? TextAlign.left
                        : TextAlign.center,
                    style: const TextStyle(
                      color: CustomTheme.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (onActionTap != null && actionText != null) ...[
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: onActionTap,
                    child: Text(
                      actionText!,
                      style: const TextStyle(
                        color: CustomTheme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
