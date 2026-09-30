import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    this.placement,
    this.enabledTransparentBg = false,
    this.isPressed = false,
  });

  final Player player;
  final VoidCallback? onIconTap;
  final VoidCallback? onTileTap;
  final int? placement;
  final bool enabledTransparentBg;
  final bool isPressed;

  bool get isValidPlacement =>
      placement != null && (placement! >= 0 && placement! <= 2);

  bool get showPlacementIcon => placement != null && placement! < 3;

  Color? get borderColor {
    if (enabledTransparentBg) return CustomTheme.boxBorderColor;
    if (isValidPlacement) return getPlacementColor(placement!);
    return null;
  }

  Color? get bgColor {
    if (isPressed) return Colors.grey.shade800;
    if (enabledTransparentBg) return Colors.transparent;
    if (isValidPlacement) return getPlacementColor(placement!).withAlpha(35);
    return CustomTheme.onBoxColor;
  }

  @override
  Widget build(BuildContext context) {
    return TextIconTile(
      highlighted: player.deleted,
      onIconTap: onIconTap,
      onTileTap: onTileTap,
      backgroundColor: bgColor,
      borderColor: borderColor,
      leadingIcon: showPlacementIcon
          ? FaIcon(
              FontAwesomeIcons.crown,
              size: 12,
              color: getPlacementColor(placement!),
            )
          : null,
      content: buildUnitNameWidget(
        player,
        highlighted: [player.deleted],
        countStyle: const TextStyle(color: CustomTheme.hintColor),
      ),
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
