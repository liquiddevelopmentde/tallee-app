import 'package:flutter/material.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/presentation/util/name_display.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/player_tile.dart';

class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.team,
    this.compact = false,
    this.width = double.infinity,
    this.margin,
    this.showDragHandle = false,
    this.maxChars,
  });

  final Team team;

  final bool compact;

  final double width;

  final EdgeInsetsGeometry? margin;

  final bool showDragHandle;

  final int? maxChars;

  @override
  Widget build(BuildContext context) {
    final teamColor = getColorFromAppColor(team.color);
    int shownPlayerAmount = getShownPlayerAmount();

    if (compact) {
      return Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: teamColor.withAlpha(50),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: teamColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: buildUnitNameWidget(
                team,
                isTeamMatch: true,
                mainStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 14,
              color: Colors.white.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.people_alt_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              '${team.members.length}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: width,
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: teamColor.withAlpha(50),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: teamColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  buildUnitNameWidget(
                    team,
                    isTeamMatch: true,
                    mainStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CustomTheme.textColor,
                    ),
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ...team.members.take(shownPlayerAmount).map((player) {
                        return PlayerTile(player: player);
                      }),
                      if (team.members.length > shownPlayerAmount)
                        Text(
                          '+ ${team.members.length - shownPlayerAmount}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: CustomTheme.textColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (showDragHandle) ...[
              const SizedBox(width: 8),
              const Icon(Icons.drag_handle),
            ],
          ],
        ),
      );
    }
  }

  /// Returns how many player names will get displayed depending on [maxChars]
  /// and the lengths of the player names.
  int getShownPlayerAmount() {
    if (maxChars == null) {
      return team.members.length;
    } else {
      var combinedLength = 0;
      var amount = 0;

      for (final player in team.members) {
        final nextLength = player.name.length + (amount > 0 ? 1 : 0);
        if (combinedLength + nextLength > maxChars!) {
          break;
        }
        combinedLength += nextLength;
        amount++;
      }

      return amount;
    }
  }
}
