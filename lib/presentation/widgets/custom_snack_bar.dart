import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class CustomSnackBar extends SnackBar {
  CustomSnackBar({Key? key, required String message})
    : this._internal(
        key: key,
        message: message,
        duration: const Duration(milliseconds: 5000),
        proxy: ProxyAnimation(),
      );

  CustomSnackBar._internal({
    super.key,
    required String message,
    required this.proxy,
    super.duration,
  }) : super(
         animation: proxy,
         behavior: SnackBarBehavior.floating,
         backgroundColor: Colors.transparent,
         elevation: 0,
         content: _AnimatedContent(message: message, animation: proxy),
       );

  final ProxyAnimation proxy;

  @override
  SnackBar withAnimation(Animation<double> newAnimation, {Key? fallbackKey}) {
    proxy.parent = newAnimation;
    return CustomSnackBar._internal(
      key: key ?? fallbackKey,
      message: (content as _AnimatedContent).message,
      duration: duration,
      proxy: proxy,
    );
  }
}

class _AnimatedContent extends StatelessWidget {
  const _AnimatedContent({required this.message, required this.animation});

  final String message;
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
            child: Text(
              message,
              textAlign: TextAlign.center,
              softWrap: true,
              maxLines: null,
              textWidthBasis: TextWidthBasis.longestLine,
              style: const TextStyle(
                color: CustomTheme.textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
