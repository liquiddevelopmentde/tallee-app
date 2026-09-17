import 'package:flutter/cupertino.dart';
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
    this.showIcon = false,
  });

  final Team pair;
  final VoidCallback? onIconTap;
  final VoidCallback? onTileTap;
  final Color? backgroundColor;
  final bool pairIconLeft;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return TextIconTile(
      showIcon: showIcon,
      onIconTap: onIconTap,
      onTileTap: onTileTap,
      content: buildUnitNameWidget(
        pair,
        pairIconLeft: pairIconLeft,
        highlighted: List.generate(
          pair.members.length,
          (index) => pair.members[index].deleted,
        ),
      ),
      backgroundColor: backgroundColor,
      highlighted: pair.members.every((player) => player.deleted),
    );
  }
}
