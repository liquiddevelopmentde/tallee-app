import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/text_icon_tile.dart';

class PairTile extends StatelessWidget {
  const PairTile({
    super.key,
    required this.pair,
    this.onIconTap,
    this.onTileTap,
    this.backgroundColor,
    this.pairIconLeft = false,
  });

  final Team pair;
  final VoidCallback? onIconTap;
  final VoidCallback? onTileTap;
  final Color? backgroundColor;
  final bool pairIconLeft;

  @override
  Widget build(BuildContext context) {
    final areBothDeleted = pair.members.every((player) => player.deleted);
    return TextIconTile(
      onIconTap: onIconTap,
      onTileTap: onTileTap,
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (areBothDeleted)
            Icon(
              Icons.delete_outline,
              size: 16,
              color: context.talleeColors.hintColor,
            ),
          buildUnitNameWidget(
            context,
            pair,
            pairIconLeft: pairIconLeft,
            highlighted: List.generate(
              pair.members.length,
              (index) => pair.members[index].deleted,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      muted: areBothDeleted,
    );
  }
}
