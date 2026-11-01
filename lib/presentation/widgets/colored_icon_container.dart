import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';

class ColoredIconContainer extends StatelessWidget {
  /// A customizable container widget that displays an icon with a colored background.
  /// - [icon]: The icon to be displayed inside the container.
  /// - [color]: The color the container and icon should have.
  /// - [containerSize]: The size of the container (width and height).
  /// - [iconSize]: The size of the icon inside the container.
  /// - [margin]: Optional margin around the container.
  /// - [padding]: Optional padding inside the container.
  /// - [muted]: Whether to render the container in a dimmed, outlined style.
  const ColoredIconContainer({
    super.key,
    required this.icon,
    this.color,
    this.containerSize = 44,
    this.iconSize,
    this.margin,
    this.padding,
    this.muted = false,
  });

  final IconData icon;
  final Color? color;
  final double containerSize;
  final double? iconSize;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    double effectiveIconSize = iconSize ?? containerSize / 1.5;

    Color effectiveIconColor = muted
        ? context.talleeColors.textColor.withAlpha(100)
        : color ?? AppColors.primaryColor.withBlue(40);
    Color effectiveBgColor = muted
        ? Colors.transparent
        : effectiveIconColor.withAlpha(40);

    return DottedBorder(
      options: muted
          ? RoundedRectDottedBorderOptions(
              color: effectiveIconColor,
              radius: const Radius.circular(10),
              strokeWidth: 2,
              dashPattern: const [5, 5],
              padding: EdgeInsets.zero,
            )
          : const RoundedRectDottedBorderOptions(
              radius: Radius.circular(0),
              color: Colors.transparent,
              padding: EdgeInsets.zero,
            ),
      child: Container(
        width: containerSize,
        height: containerSize,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: effectiveIconSize, color: effectiveIconColor),
      ),
    );
  }
}
