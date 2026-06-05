import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile.dart';

class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.team,
    this.compact = false,
    this.width = double.infinity,
    this.showDragHandle = false,
    this.maxChars,
  });

  final Team team;

  final bool compact;

  final double width;

  final bool showDragHandle;

  final int? maxChars;

  @override
  Widget build(BuildContext context) {
    final teamColor = getColorFromAppColor(team.color);
    final playerAmount = maxChars == null
        ? team.members.length
        : () {
            var combinedLength = 0;
            var count = 0;

            for (final player in team.members) {
              final nextLength = player.name.length + (count > 0 ? 1 : 0);
              if (combinedLength + nextLength > maxChars!) {
                break;
              }
              combinedLength += nextLength;
              count++;
            }

            return count;
          }();

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
              child: Text(
                team.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
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
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: teamColor.withAlpha(50),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: teamColor, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  team.name,
                  style: const TextStyle(
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
                    ...team.members.take(playerAmount).map((player) {
                      return TextIconTile(
                        text: player.name,
                        suffixText: getNameCountText(player),
                      );
                    }),
                    if (team.members.length > playerAmount)
                      Text(
                        '+ ${team.members.length - playerAmount}',
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
            const Icon(Icons.drag_handle),
          ],
        ),
      );
    }
  }
}
