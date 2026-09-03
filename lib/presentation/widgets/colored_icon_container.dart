import 'package:flutter/cupertino.dart';
import 'package:tallee/core/custom_theme.dart';

class ColoredIconContainer extends StatelessWidget {
  /// A customizable container widget that displays an icon with a colored background.
  /// - [icon]: The icon to be displayed inside the container.
  /// - [color]: The color the container and icon should have.
  /// - [containerSize]: The size of the container (width and height).
  /// - [iconSize]: The size of the icon inside the container.
  /// - [margin]: Optional margin around the container.
  /// - [padding]: Optional padding inside the container.
  const ColoredIconContainer({
    super.key,
    required this.icon,
    this.color,
    this.containerSize = 44,
    this.iconSize = 28,
    this.margin,
    this.padding,
  });

  final IconData icon;
  final Color? color;
  final double containerSize;
  final double iconSize;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: containerSize,
          height: containerSize,
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color:
                color?.withAlpha(40) ?? CustomTheme.primaryColor.withAlpha(40),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: color ?? CustomTheme.primaryColor.withBlue(40),
          ),
        ),
      ],
    );
  }
}
