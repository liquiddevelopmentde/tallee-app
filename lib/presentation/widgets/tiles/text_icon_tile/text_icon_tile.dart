import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/name_display.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/team.dart';

class TextIconTile extends StatelessWidget {
  /// A tile widget that displays text with an optional icon that can be tapped.
  /// - [player]: An optional player object to display.
  /// - [pair]: An optional team object representing a pair of players.
  /// - [text]: The text to display if no player or pair is provided.
  /// - [onIconTap]: The callback to be invoked when the icon is tapped.
  /// - [icon]: Optional custom icon. Defaults to [Icons.close].
  /// - [onTileTap]: The callback to be invoked when the tile is tapped.
  /// - `text`: The text to display in the tile.
  /// - `suffixText`: Optional text to display after the main text, styled with a smaller font and lighter color.
  /// - `onIconTap`: The callback to be invoked when the icon is tapped.
  /// - `icon`: Optional custom icon. Defaults to `Icons.close`.
  /// - `onTileTap`: The callback to be invoked when the tile is tapped.
  const TextIconTile({
    super.key,
    this.player,
    this.text = '',
    this.pair,
    this.pairIconLeft = false,
    this.onIconTap,
    this.icon,
    this.onTileTap,
    this.backgroundColor,
    this.highlighted = false,
  });

  /// An optional player object to display.
  final Player? player;

  /// The text to display if no player is provided.
  final String text;

  final Team? pair;

  final bool pairIconLeft;

  /// The callback to be invoked when the icon is tapped.
  final String suffixText;
  final VoidCallback? onIconTap;

  /// The icon to display.
  final IconData? icon;

  /// The callback to be invoked when the tile is tapped.
  final IconData icon;
  final VoidCallback? onTileTap;
  final bool highlighted;

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final iconEnabled = onIconTap != null && icon != null;
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
              child: buildUnitNameWidget(
                pair ?? player ?? Player(name: text, nameCount: 0),
                mainStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textClr
                ),
                countStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: suffixColor,
                ),
                pairIconLeft: pairIconLeft,
              ),
            ),
            if (iconEnabled) ...<Widget>[
              const SizedBox(width: 3),
              GestureDetector(onTap: onIconTap, child: Icon(icon!, size: 20)),
            ],
          ],
        ),
      ),
    );
  }
}
