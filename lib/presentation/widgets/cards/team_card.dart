import 'package:flutter/material.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/player_tile.dart';

class TeamCard extends StatelessWidget {
  /// A card to display a team with its name, color, and its members.
  /// - [team]: The team to display.
  /// - [compact]: When `true`, shows only the team name and member count.
  /// - [width]: The width of the card. Defaults to [double.infinity].
  /// - [margin]: Optional outer margin around the card.
  /// - [showDragHandle]: Whether to show a drag handle for reordering.
  /// - [showTeamMembers]: Whether to display the list of team members.
  const TeamCard({
    super.key,
    required this.team,
    this.compact = false,
    this.width = double.infinity,
    this.margin,
    this.showDragHandle = false,
    this.showTeamMembers = true,
  });

  final Team team;
  final bool compact;
  final double width;
  final EdgeInsetsGeometry? margin;
  final bool showDragHandle;
  final bool showTeamMembers;

  @override
  Widget build(BuildContext context) {
    final teamColor = getColorFromAppColor(team.color);

    // Show only team name and member count
    if (compact) {
      return Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: CustomTheme.onBoxColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          spacing: 10,
          children: [
            // Colored circle
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: teamColor,
                shape: BoxShape.circle,
              ),
            ),

            // Team name
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

            // Members
            if (showTeamMembers)
              Row(
                spacing: 12,
                children: [
                  // Divider
                  Container(
                    width: 1,
                    height: 14,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),

                  // Teammember count
                  Row(
                    spacing: 5,
                    children: [
                      const Icon(
                        Icons.people_alt_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
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
                ],
              ),
          ],
        ),
      );
    } else {
      /// Full size card
      return Container(
        width: width,
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: CustomTheme.onBoxColor,
        ),
        child: Row(
          spacing: 8,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: showTeamMembers
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                spacing: 8,
                children: [
                  // Team name row
                  Row(
                    spacing: 10,
                    children: [
                      // Colored circle
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: teamColor,
                          shape: BoxShape.circle,
                        ),
                      ),

                      // Team name
                      buildUnitNameWidget(
                        team,
                        isTeamMatch: true,
                        mainStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: CustomTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                  if (showTeamMembers)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Player tiles
                        ...team.members.map((player) {
                          return PlayerTile(
                            player: player,
                            backgroundColor: Colors.transparent,
                          );
                        }),
                      ],
                    ),
                ],
              ),
            ),
            if (showDragHandle) const Icon(Icons.drag_handle),
          ],
        ),
      );
    }
  }
}
