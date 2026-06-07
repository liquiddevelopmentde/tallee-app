import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/team.dart';

class TextIconTile extends StatelessWidget {
  /// A tile widget that displays text with an optional icon that can be tapped.
  /// - [text]: The text to display in the tile.
  /// - [onIconTap]: The callback to be invoked when the icon is tapped.
  /// - [icon]: Optional custom icon. Defaults to [Icons.close].
  const TextIconTile({
    super.key,
    required this.text,
    this.suffixText = '',
    this.pair,
    this.onIconTap,
    this.icon = Icons.close,
    this.onTileTap,
  });

  /// The text to display in the tile.
  final String text;

  final String suffixText;

  final Team? pair;

  /// The callback to be invoked when the icon is tapped.
  final VoidCallback? onIconTap;

  /// The icon to display. Defaults to [Icons.close].
  final IconData icon;

  /// The callback to be invoked when the tile is tapped.
  final VoidCallback? onTileTap;

  @override
  Widget build(BuildContext context) {
    final iconEnabled = onIconTap != null;

    return GestureDetector(
      onTap: onTileTap,
      child: Container(
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
                    if (pair == null) ...[
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
                          color: CustomTheme.textColor.withAlpha(100),
                        ),
                      ),
                    ] else ...[
                      TextSpan(
                        text: pair!.members[0].name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: getNameCountText(pair!.members[0]),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: CustomTheme.textColor.withAlpha(100),
                        ),
                      ),
                      const TextSpan(
                        text: ' & ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: pair!.members[1].name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: getNameCountText(pair!.members[1]),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: CustomTheme.textColor.withAlpha(100),
                        ),
                      ),
                    ],
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
