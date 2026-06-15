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
  });

  final Player player;
  final IconData? icon;
  final VoidCallback? onIconTap;
  final VoidCallback? onTileTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TextIconTile(
      highlighted: player.deleted,
      onIconTap: onIconTap,
      onTileTap: onTileTap,
      backgroundColor: backgroundColor,
      content: buildUnitNameWidget(player, highlighted: [player.deleted]),
    );
  }
}
