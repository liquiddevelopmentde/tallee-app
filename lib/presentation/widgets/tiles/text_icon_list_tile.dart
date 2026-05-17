import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class TextIconListTile extends StatelessWidget {
  /// A list tile widget that displays text with an optional icon button.
  /// - [text]: The text to display in the tile.
  /// - [onPressed]: The callback to be invoked when the icon is pressed.
  /// - [iconEnabled]: A boolean to determine if the icon should be displayed.
  const TextIconListTile({
    super.key,
    required this.text,
    this.suffixText = '',
    this.icon,
    this.color,
    this.onPressed,
  });

  /// The text to display in the tile.
  final String text;

  /// An optional suffix text to display after the main text.
  final String suffixText;

  /// The icon to display in the tile.
  final IconData? icon;

  final Color? color;

  /// The callback to be invoked when the icon is pressed.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color:
            Color.lerp(CustomTheme.onBoxColor, color?.withAlpha(10), 0.1) ??
            CustomTheme.boxColor,
        border: Border.all(
          color: color ?? CustomTheme.boxBorderColor,
          width: color != null ? 2 : 1,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
        borderRadius: CustomTheme.standardBorderRadiusAll,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.5),
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: suffixText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: CustomTheme.textColor.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (icon != null)
            GestureDetector(onTap: onPressed, child: Icon(icon, size: 20)),
        ],
      ),
    );
  }
}
