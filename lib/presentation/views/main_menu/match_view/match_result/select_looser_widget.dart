import 'dart:core' hide Match;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/cards/team_card.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/custom_radio_list_tile.dart';

class SelectLooserWidget extends StatefulWidget {
  /// A list widget for the [MatchResultView] that lets the user select a single player or team.
  /// - [match]: The match whose players / teams are being selected.
  /// - [onPlayerSelected]: The callback invoked with the selected player whenever a player is selected.
  /// - [onTeamSelected]: The callback invoked with the selected team whenever a team is selected.
  const SelectLooserWidget({
    super.key,
    required this.match,
    this.onPlayerSelected,
    this.onTeamSelected,
  });

  final Match match;
  final void Function(Player?)? onPlayerSelected;
  final void Function(Team?)? onTeamSelected;

  @override
  State<SelectLooserWidget> createState() => _SelectLooserWidgetState();
}

class _SelectLooserWidgetState extends State<SelectLooserWidget> {
  Team? selectedTeam;
  late List<Team> allTeams;

  Player? selectedPlayer;
  late List<Player> allPlayers;

  bool get isTeamMatch => widget.match.isTeamMatch;
  bool get useTeamLogic => widget.match.useTeamLogic;

  @override
  void initState() {
    allTeams = (widget.match.teams ?? [])
      ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));
    allPlayers = widget.match.players
      ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));

    selectedTeam = widget.match.mvt.firstOrNull;
    selectedPlayer = widget.match.mvp.firstOrNull;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: useTeamLogic
          ? RadioGroup<Team>(
              groupValue: selectedTeam,
              onChanged: (Team? team) async {
                HapticFeedback.selectionClick();
                setState(() {
                  selectedTeam = team;
                  widget.onTeamSelected?.call(selectedTeam);
                });
              },
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allTeams.length,
                itemBuilder: (context, index) {
                  return CustomRadioListTile(
                    content: isTeamMatch
                        ? TeamCard(
                            team: allTeams[index],
                            compact: true,
                            showTeamMembers: false,
                          )
                        : buildUnitNameWidget(
                            allTeams[index],
                            isTeamMatch: false,
                          ),
                    value: allTeams[index],
                    onContainerTap: (team) async {
                      HapticFeedback.selectionClick();
                      setState(() {
                        // Check if the already selected player is the same as the newly tapped player.
                        if (selectedTeam == team) {
                          // If yes deselected the player by setting it to null.
                          selectedTeam = null;
                        } else {
                          // If no assign the newly tapped player to the selected player.
                          (selectedTeam = team);
                        }
                        widget.onTeamSelected?.call(selectedTeam);
                      });
                    },
                  );
                },
              ),
            )
          : RadioGroup<Player>(
              groupValue: selectedPlayer,
              onChanged: (Player? player) => setState(() {
                HapticFeedback.selectionClick();
                selectedPlayer = player;
                widget.onPlayerSelected?.call(selectedPlayer);
              }),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allPlayers.length,
                itemBuilder: (context, index) {
                  return CustomRadioListTile(
                    content: buildUnitNameWidget(
                      allPlayers[index],
                      mainStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    value: allPlayers[index],
                    onContainerTap: (player) async {
                      HapticFeedback.selectionClick();
                      setState(() {
                        // Check if the already selected player is the same as the newly tapped player.
                        if (selectedPlayer == player) {
                          // If yes deselected the player by setting it to null.
                          selectedPlayer = null;
                        } else {
                          // If no assign the newly tapped player to the selected player.
                          selectedPlayer = player;
                        }
                        widget.onPlayerSelected?.call(selectedPlayer);
                      });
                    },
                  );
                },
              ),
            ),
    );
  }
}
