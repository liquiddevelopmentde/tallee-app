import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/text_icon_tile.dart';

class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.player,
    this.onTileTap,
    this.backgroundColor,
    this.showIcon = false,
    this.icon = Icons.close,
    this.selected = false,
  });

  final Player player;
  final VoidCallback? onTileTap;
  final Color? backgroundColor;
  final bool showIcon;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return TextIconTile(
      showIcon: showIcon,
      icon: icon,
      muted: player.deleted,
      selected: selected,
      onTileTap: onTileTap,
      backgroundColor: backgroundColor,
      content: Row(
        mainAxisSize: MainAxisSize.min,
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
