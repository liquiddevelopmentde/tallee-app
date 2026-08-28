import 'package:flutter/material.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/text_icon_tile.dart';

class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.player,
    this.icon,
    this.onIconTap,
    this.onTileTap,
    this.backgroundColor,
    this.leading,
    this.nameColor,
    this.borderColor,
  });

  final Player player;
  final IconData? icon;
  final VoidCallback? onIconTap;
  final VoidCallback? onTileTap;
  final Color? backgroundColor;
  final Widget? leading;
  final Color? nameColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return TextIconTile(
      highlighted: player.deleted,
      onIconTap: onIconTap,
      onTileTap: onTileTap,
      backgroundColor: backgroundColor,
      leading: leading,
      borderColor: borderColor,
      content: buildUnitNameWidget(
        player,
        highlighted: [player.deleted],
        mainStyle: nameColor == null
            ? null
            : TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: nameColor,
              ),
      ),
    );
  }
}