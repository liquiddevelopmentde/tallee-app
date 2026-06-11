import 'package:flutter/material.dart';
import 'package:tallee/core/name_display.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/text_icon_tile.dart';

class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.player,
    this.icon,
    this.onIconTap,
    this.onTileTap,
  });

  final Player player;
  final IconData? icon;
  final VoidCallback? onIconTap;
  final VoidCallback? onTileTap;

  @override
  Widget build(BuildContext context) {
    return TextIconTile(
      text: player.name,
      highlighted: player.deleted,
      suffixText: getNameCountText(player),
      onIconTap: onIconTap,
      onTileTap: onTileTap,
    );
  }
}
