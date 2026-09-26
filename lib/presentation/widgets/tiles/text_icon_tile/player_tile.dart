import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/custom_theme.dart';
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
    this.showIcon = false,
  });

  final Player player;
  final VoidCallback? onIconTap;
  final VoidCallback? onTileTap;
  final Color? backgroundColor;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return TextIconTile(
      showIcon: showIcon,
      highlighted: player.deleted,
      onIconTap: onIconTap,
      onTileTap: onTileTap,
      backgroundColor: backgroundColor,
      content: buildUnitNameWidget(
        player,
        highlighted: [player.deleted],
        countStyle: const TextStyle(color: CustomTheme.hintColor),
      ),
    );
  }
}
