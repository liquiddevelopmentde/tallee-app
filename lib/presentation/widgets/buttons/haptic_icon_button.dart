import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HapticIconButton extends StatelessWidget {
  const HapticIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.iconSize,
    this.color,
    this.padding,
    this.alignment,
    this.constraints,
    this.style,
    this.isSelected,
    this.selectedIcon,
  });

  final Widget icon;
  final VoidCallback? onPressed;

  final String? tooltip;
  final double? iconSize;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;
  final ButtonStyle? style;
  final bool? isSelected;
  final Widget? selectedIcon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      iconSize: iconSize,
      color: color,
      padding: padding,
      alignment: alignment ?? Alignment.center,
      constraints: constraints,
      style: style,
      isSelected: isSelected,
      selectedIcon: selectedIcon,
      icon: icon,
      onPressed: onPressed == null
          ? null
          : () async {
              await HapticFeedback.selectionClick();
              onPressed!.call();
            },
    );
  }
}
