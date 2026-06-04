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
  });

  final Team team;

  final bool compact;

  final double width;

  @override
  Widget build(BuildContext context) {
    final teamColor = getColorFromAppColor(team.color);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
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
              children: team.members.map((player) {
                return TextIconTile(
                  text: player.name,
                  suffixText: getNameCountText(player),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }
  }
}
