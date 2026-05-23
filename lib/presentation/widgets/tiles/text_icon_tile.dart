import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class TextIconTile extends StatelessWidget {
  /// A tile widget that displays text with an optional icon that can be tapped.
  /// - [text]: The text to display in the tile.
  /// - [onIconTap]: The callback to be invoked when the icon is tapped.
  /// - [icon]: Optional custom icon. Defaults to [Icons.close].
  const TextIconTile({
    super.key,
    required this.text,
    this.suffixText = '',
    this.onIconTap,
    this.icon = Icons.close,
  });

  /// The text to display in the tile.
  final String text;

  final String suffixText;

  /// The callback to be invoked when the icon is tapped.
  final VoidCallback? onIconTap;

  /// The icon to display. Defaults to [Icons.close].
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final iconEnabled = onIconTap != null;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: CustomTheme.onBoxColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconEnabled) const SizedBox(width: 3),
          Flexible(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: suffixText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: CustomTheme.textColor.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (iconEnabled) ...<Widget>[
            const SizedBox(width: 3),
            GestureDetector(onTap: onIconTap, child: Icon(icon, size: 20)),
          ],
        ],
      ),
    );
  }
}
