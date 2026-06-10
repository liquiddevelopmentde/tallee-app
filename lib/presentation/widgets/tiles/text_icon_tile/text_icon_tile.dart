import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class TextIconTile extends StatelessWidget {
  /// A tile widget that displays text with an optional icon that can be tapped.
  /// - `text`: The text to display in the tile.
  /// - `suffixText`: Optional text to display after the main text, styled with a smaller font and lighter color.
  /// - `onIconTap`: The callback to be invoked when the icon is tapped.
  /// - `icon`: Optional custom icon. Defaults to `Icons.close`.
  /// - `onTileTap`: The callback to be invoked when the tile is tapped.
  const TextIconTile({
    super.key,
    required this.text,
    this.suffixText = '',
    this.onIconTap,
    this.icon = Icons.close,
    this.onTileTap,
    this.highlighted = false,
  });

  final String text;
  final String suffixText;
  final VoidCallback? onIconTap;
  final IconData icon;
  final VoidCallback? onTileTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final iconEnabled = onIconTap != null;
    final backgroundColor = highlighted
        ? CustomTheme.onBoxColor.withAlpha((140).round())
        : CustomTheme.onBoxColor;
    final textClr = highlighted
        ? CustomTheme.textColor.withAlpha((140).round())
        : CustomTheme.textColor;
    final suffixColor = highlighted
        ? CustomTheme.textColor.withAlpha((80).round())
        : CustomTheme.textColor.withAlpha((150).round());

    return GestureDetector(
      onTap: onTileTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: backgroundColor,
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textClr,
                      ),
                    ),
                    TextSpan(
                      text: suffixText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: suffixColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (iconEnabled) ...<Widget>[
              const SizedBox(width: 3),
              GestureDetector(
                onTap: onIconTap,
                child: const Icon(Icons.close, size: 20),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
