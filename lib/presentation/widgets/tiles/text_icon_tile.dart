import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/team.dart';

class TextIconTile extends StatelessWidget {
  /// A tile widget that displays text with an optional icon that can be tapped.
  /// - [text]: The text to display in the tile.
  /// - [onIconTap]: The callback to be invoked when the icon is tapped.
  /// - [icon]: Optional custom icon. Defaults to [Icons.close].
  const TextIconTile({
    super.key,
    this.player,
    this.text = '',
    this.suffixText = '',
    this.pair,
    this.onIconTap,
    this.icon,
    this.onTileTap,
  });

  /// An optional player object to display.
  final Player? player;

  /// The text to display if no player is provided.
  final String text;

  final String suffixText;

  final Team? pair;

  /// The callback to be invoked when the icon is tapped.
  final VoidCallback? onIconTap;

  /// The icon to display.
  final IconData? icon;

  /// The callback to be invoked when the tile is tapped.
  final VoidCallback? onTileTap;

  @override
  Widget build(BuildContext context) {
    final iconEnabled = onIconTap != null && icon != null;

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
              child: buildUnitNameWidget(
                pair ?? player ?? Player(name: text, nameCount: 0),
                mainStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                countStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: CustomTheme.textColor.withAlpha(100),
                ),
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
