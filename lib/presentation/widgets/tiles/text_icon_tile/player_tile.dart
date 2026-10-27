import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/text_icon_tile.dart';

class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.player,
    this.onIconTap,
    this.onTileTap,
    this.backgroundColor,
  });

  final Player player;
  final VoidCallback? onIconTap;
  final VoidCallback? onTileTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TextIconTile(
      muted: player.deleted,
      onIconTap: onIconTap,
      onTileTap: onTileTap,
      backgroundColor: backgroundColor,
      content: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 1,
        children: [
          if (player.deleted)
            Icon(
              Icons.delete_outline,
              size: 16,
              color: context.talleeColors.hintColor,
            ),
          buildUnitNameWidget(
            context,
            player,
            highlighted: [player.deleted],
            countStyle: TextStyle(color: context.talleeColors.hintColor),
          ),
        ],
      ),
    );
  }
}
