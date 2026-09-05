import 'dart:core' hide Match;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_numeric_text/flutter_numeric_text.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/route_names.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/match_result_view.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_list_tile.dart';

/// Displays the given [teams] as a flat reorderable list where every team is
/// preceded by a header row and followed by its members. Members can be
/// dragged across team boundaries to be reassigned to another team.
class ManageMembersView extends StatefulWidget {
  const ManageMembersView({
    super.key,
    required this.match,
    required this.onWinnerChanged,
  });

  final Match match;
  final VoidCallback? onWinnerChanged;

  @override
  State<ManageMembersView> createState() => _ManageMembersViewState();
}

class _ManageMembersViewState extends State<ManageMembersView> {
  late AppDatabase db;

  List<Team> get teams => widget.match.teams!;

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);

    final hasAssignedPlayers = teams.any((t) => t.members.isNotEmpty);
    if (!hasAssignedPlayers) redistributePlayers();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(title: Text(loc.manage_members)),
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Positioned.fill(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 96),
              buildDefaultDragHandles: false,
              itemCount: allItemsCount,
              onReorderItem: onReorderItem,
              onReorderStart: (_) => HapticFeedback.heavyImpact(),
              onReorderEnd: (_) => HapticFeedback.selectionClick(),
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    final t = Curves.easeInOut.transform(animation.value);
                    return Material(
                      type: MaterialType.transparency,
                      child: Stack(
                        children: [
                          child,
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: 0.10 * t,
                                    ),
                                    borderRadius:
                                        CustomTheme.standardBorderRadiusAll,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              itemBuilder: (context, index) {
                final teamIndex = teamIndexForFlat(index);
                final memberIndex = memberIndexForFlat(index, teamIndex);
                final team = teams[teamIndex];

                if (memberIndex == -1) {
                  return buildTeamTile(team: team);
                }

                final player = team.members[memberIndex];
                return ReorderableDelayedDragStartListener(
                  key: ValueKey('player_${player.id}'),
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: TextIconListTile(
                      player: player,
                      icon: Icons.drag_handle,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).viewPadding.bottom + 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingAnimatedButton(
                  onPressed: () => setState(() {
                    redistributePlayers();
                  }),
                  icon: Icons.cached,
                ),
                const SizedBox(width: 16),
                FloatingAnimatedButton(
                  onPressed: allTeamsHaveMembers
                      ? () async => submitMatch()
                      : null,
                  text: loc.create_match,
                  icon: RpgAwesome.clovers_card,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTeamTile({required Team team}) {
    final color = getColorFromAppColor(team.color);
    final loc = AppLocalizations.of(context);
    final length = team.members.length;
    final memberText = length == 1 ? loc.member : loc.members;

    return Padding(
      key: ValueKey(team.id),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          // Color circle
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),

          const SizedBox(width: 10),

          // Team name
          Expanded(
            child: Text(
              team.name,
              style: const TextStyle(
                color: CustomTheme.textColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Member length
          SizedBox(
            width: 150,
            child: NumericText(
              '$length $memberText',
              duration: const Duration(milliseconds: 200),
              maxLines: 1,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CustomTheme.hintColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Iterates through all teams and redistributes players randomly and
  // as evenly as possible.
  void redistributePlayers() {
    for (final team in teams) {
      team.members.clear();
    }
    var matchPlayers = widget.match.players;
    Random random = Random();

    if (matchPlayers.isEmpty || teams.isEmpty) {
      return;
    }

    final shuffledPlayers = [...matchPlayers]..shuffle(random);

    for (int i = 0; i < shuffledPlayers.length; i++) {
      final teamIndex = i % teams.length;
      teams[teamIndex].members.add(shuffledPlayers[i]);
    }
  }

  /// Handles moving a member from one team to another
  void onReorderItem(int oldIndex, int newIndex) {
    final sourceTeamIndex = teamIndexForFlat(oldIndex);
    final sourceMemberIndex = memberIndexForFlat(oldIndex, sourceTeamIndex);

    // Headers themselves can't be reordered.
    if (sourceMemberIndex == -1) return;

    // When moving down, the target index is shifted by 1
    // because the item is removed first.
    var targetIndex = newIndex;
    if (newIndex > oldIndex) targetIndex -= 1;
    targetIndex = targetIndex.clamp(0, allItemsCount - 1);

    // Resolve target location based on the item currently
    // at targetIndex before the move.
    int destTeamIndex;
    int insertPositionInTeam;

    if (targetIndex >= allItemsCount - 1 && newIndex >= allItemsCount) {
      // dropped at the very end, append to the last team.
      destTeamIndex = teams.length - 1;
      insertPositionInTeam = teams[destTeamIndex].members.length;
    } else {
      destTeamIndex = teamIndexForFlat(targetIndex);
      final anchorMemberIndex = memberIndexForFlat(targetIndex, destTeamIndex);

      if (anchorMemberIndex == -1) {
        // dropped on a header, direction decides which team the player gets added
        // if moving down, insert as first member of that team.
        // if moving UP, append to the previous team.
        final isMovingDown = newIndex > oldIndex;
        if (isMovingDown) {
          insertPositionInTeam = 0;
        } else {
          final previousTeamIndex = destTeamIndex - 1;
          if (previousTeamIndex < 0) {
            // above the very first header, stay at top of team 0.
            insertPositionInTeam = 0;
          } else {
            destTeamIndex = previousTeamIndex;
            insertPositionInTeam = teams[destTeamIndex].members.length;
          }
        }
      } else {
        insertPositionInTeam = anchorMemberIndex;
      }
    }

    setState(() {
      final sourceMembers = teams[sourceTeamIndex].members;
      final player = sourceMembers.removeAt(sourceMemberIndex);

      // Adjust insert index if removed from before the insert point in the
      // same team.
      if (sourceTeamIndex == destTeamIndex &&
          insertPositionInTeam > sourceMembers.length) {
        insertPositionInTeam = sourceMembers.length;
      }

      teams[destTeamIndex].members.insert(insertPositionInTeam, player);
    });
  }

  /// Total players + teams length
  int get allItemsCount {
    var count = 0;
    for (final team in teams) {
      count += 1 + team.members.length;
    }
    return count;
  }

  /// Returns the index of the team that owns the flat-list item at [flatIndex].
  int teamIndexForFlat(int flatIndex) {
    var remaining = flatIndex;
    for (var i = 0; i < teams.length; i++) {
      final size = 1 + teams[i].members.length;
      if (remaining < size) return i;
      remaining -= size;
    }
    return teams.length - 1;
  }

  /// Returns the member index within its team, or `-1` if the item at
  /// [flatIndex] is the team header.
  int memberIndexForFlat(int flatIndex, int teamIndex) {
    var offset = 0;
    for (var i = 0; i < teamIndex; i++) {
      offset += 1 + teams[i].members.length;
    }
    // offset now points to the header of [teamIndex]. Anything beyond is a
    // member of that team.
    final localIndex = flatIndex - offset;
    return localIndex == 0 ? -1 : localIndex - 1;
  }

  bool get allTeamsHaveMembers =>
      teams.every((team) => team.members.isNotEmpty);

  void submitMatch() async {
    final match = widget.match;
    await db.matchDao.addMatch(match: match);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: RouteNames.matchResultView),
          builder: (_) => MatchResultView(
            match: match,
            onWinnerChanged: widget.onWinnerChanged,
          ),
        ),
        (route) => route.isFirst,
      );
    }
  }
}
