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
  });

  /// An optional player object to display.
  final Player? player;

  /// The text to display if no player is provided.
  final String text;

  final Team? pair;

  final bool pairIconLeft;

  /// The callback to be invoked when the icon is tapped.
  final VoidCallback? onIconTap;

  /// The icon to display.
  final IconData? icon;

  /// The callback to be invoked when the tile is tapped.
  final VoidCallback? onTileTap;

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final iconEnabled = onIconTap != null && icon != null;

    return GestureDetector(
      onTap: onTileTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: backgroundColor ?? CustomTheme.onBoxColor,
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
