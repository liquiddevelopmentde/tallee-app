import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/presentation/utils/name_display.dart';

class TextIconListTile extends StatelessWidget {
  /// A list tile widget that displays text with an optional icon button.
  /// - [player]: An optional player object to display.
  /// - [pair]: An optional team object representing a pair of players.
  /// - [text]: The text to display if no player or pair is provided.
  /// - [onIconTap]: The callback to be invoked when the icon is pressed.
  /// - [onTileTap]: The callback to be invoked when the tile is pressed.
  /// - [icon]: The icon to display in the tile.
  const TextIconListTile({
    super.key,
    this.text = '',
    this.description,
    this.player,
    this.pair,
    this.pairIconLeft = false,
    this.icon,
    this.onIconTap,
    this.onTileTap,
  });

  final String text;
  final String? description;
  final Player? player;
  final Team? pair;
  final bool pairIconLeft;
  final IconData? icon;
  final VoidCallback? onTileTap;
  final VoidCallback? onIconTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTileTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: CustomTheme.boxColor,
          border: Border.all(
            color: CustomTheme.boxBorderColor,
            width: 1,
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
              GestureDetector(onTap: onIconTap, child: Icon(icon, size: 20)),
          ],
        ),
      ),
    );
  }
}
