import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/team.dart';

class TextIconListTile extends StatelessWidget {
  /// A list tile widget that displays text with an optional icon button.
  /// - [text]: The text to display in the tile.
  /// - [onPressed]: The callback to be invoked when the icon is pressed.
  /// - [iconEnabled]: A boolean to determine if the icon should be displayed.
  const TextIconListTile({
    super.key,
    this.player,
    this.text = '',
    this.suffixText = '',
    this.pair,
    this.icon,
    this.color,
    this.onPressed,
  });

  /// An optional player object to display.
  final Player? player;

  /// The text to display if no player is provided.
  final String text;

  /// An optional suffix text to display after the main text.
  final String suffixText;

  /// An optional parameter to show 2 players (a pair) in one tile
  final Team? pair;

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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.5),
            child: buildUnitNameWidget(
              pair ?? player ?? Player(name: text, nameCount: 0),
              mainStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              countStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: CustomTheme.textColor.withAlpha(100),
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
