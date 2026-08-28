import 'package:flutter/cupertino.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/text_icon_tile.dart';

class PairTile extends StatelessWidget {
  const PairTile({
    super.key,
    required this.pair,
    this.icon,
    this.onIconTap,
    this.onTileTap,
    this.backgroundColor,
    this.pairIconLeft = false,
    this.leading,
    this.nameColor,
    this.borderColor,
  });

  final Team pair;
  final IconData? icon;
  final VoidCallback? onIconTap;
  final VoidCallback? onTileTap;
  final Color? backgroundColor;
  final bool pairIconLeft;
  final Widget? leading;
  final Color? nameColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return TextIconTile(
      onIconTap: onIconTap,
      onTileTap: onTileTap,
      leading: leading,
      borderColor: borderColor,
      content: buildUnitNameWidget(
        pair,
        pairIconLeft: pairIconLeft,
        highlighted: List.generate(
          pair.members.length,
          (index) => pair.members[index].deleted,
        ),
        mainStyle: nameColor == null
            ? null
            : TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: nameColor,
              ),
      ),
      backgroundColor: backgroundColor,
      highlighted: pair.members.every((player) => player.deleted),
    );
  }
}