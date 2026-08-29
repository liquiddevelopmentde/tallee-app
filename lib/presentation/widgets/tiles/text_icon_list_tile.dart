import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/presentation/utils/name_display.dart';

class TextIconListTile extends StatelessWidget {
  /// A list tile widget that displays text with an optional icon button.
  /// - [player]: An optional player object to display.
  /// - [pair]: An optional team object representing a pair of players.
  /// - [text]: The text to display if no player or pair is provided.
  /// - [onPressed]: The callback to be invoked when the icon is pressed.
  /// - [icon]: The icon to display in the tile.
  const TextIconListTile({
    super.key,
    this.text = '',
    this.description,
    this.player,
    this.pair,
    this.pairIconLeft = false,
    this.icon,
    this.onPressed,
  });

  final String text;
  final String? description;
  final Player? player;
  final Team? pair;
  final bool pairIconLeft;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: CustomTheme.onBoxColor,
        borderRadius: CustomTheme.standardBorderRadiusAll,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildUnitNameWidget(
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
                    pairIconLeft: pairIconLeft,
                  ),
                  if (description != null)
                    Text(
                      description!,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 12,
                        color: CustomTheme.textColor.withAlpha(100),
                      ),
                    ),
                ],
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
