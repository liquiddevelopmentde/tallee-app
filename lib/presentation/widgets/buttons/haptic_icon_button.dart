import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HapticIconButton extends StatelessWidget {
  const HapticIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.padding,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await HapticFeedback.selectionClick();
        onPressed!.call();
      },
      child: Container(
        padding: padding ?? const EdgeInsets.all(6.0),
        child: icon,
      ),
    );
  }
}
