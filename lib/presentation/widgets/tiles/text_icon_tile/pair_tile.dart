import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/text_icon_tile.dart';

class PairTile extends StatelessWidget {
  const PairTile({
    super.key,
    required this.pair,
    this.onIconTap,
    this.onTileTap,
    this.pairIconLeft = false,
    this.placement,
  });

  final Team pair;
  final VoidCallback? onIconTap;
  final VoidCallback? onTileTap;
  final bool pairIconLeft;
  final int? placement;

  bool get isValidPlacement =>
      placement != null && (placement! >= 0 && placement! <= 2);

  bool get showPlacementIcon => placement != null && placement! < 3;

  Color? get borderColor =>
      isValidPlacement ? getPlacementColor(placement!) : null;

  Color? get bgColor => isValidPlacement
      ? getPlacementColor(placement!).withAlpha(35)
      : CustomTheme.onBoxColor;

  @override
  Widget build(BuildContext context) {
    return TextIconTile(
      leadingIcon: showPlacementIcon
          ? FaIcon(
              FontAwesomeIcons.crown,
              size: 12,
              color: getPlacementColor(placement!),
            )
          : null,
      onIconTap: onIconTap,
      onTileTap: onTileTap,
      borderColor: borderColor,
      content: buildUnitNameWidget(
        pair,
        pairIconLeft: pairIconLeft,
        highlighted: List.generate(
          pair.members.length,
          (index) => pair.members[index].deleted,
        ),
      ),
      backgroundColor: bgColor,
      highlighted: pair.members.every((player) => player.deleted),
    );
  }

  Color getPlacementColor(int placement) {
    switch (placement) {
      case 0:
        return const Color(0xFFD4A017);
      case 1:
        return const Color(0xFFC0C0C0);
      case 2:
        return const Color(0xFFCD7F32);
      default:
        return Colors.transparent;
    }
  }
}
