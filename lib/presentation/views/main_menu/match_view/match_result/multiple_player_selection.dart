import 'dart:core' hide Match;

import 'package:flutter/cupertino.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/util/name_display.dart';
import 'package:tallee/presentation/widgets/cards/team_card.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/custom_checkbox_list_tile.dart';

class MultiplePlayerSelection extends StatefulWidget {
  const MultiplePlayerSelection({
    super.key,
    required this.match,
    this.onPlayersSelected,
    this.onTeamsSelected,
  });

  final Match match;
  final void Function(List<Player>)? onPlayersSelected;
  final void Function(List<Team>)? onTeamsSelected;

  @override
  State<MultiplePlayerSelection> createState() =>
      _MultiplePlayerSelectionState();
}

class _MultiplePlayerSelectionState extends State<MultiplePlayerSelection> {
  late List<Team> allTeams;
  List<Team> selectedTeams = [];

  late List<Player> allPlayers;
  List<Player> selectedPlayers = [];

  bool get useTeamLogic => widget.match.useTeamLogic;

  @override
  void initState() {
    if (useTeamLogic) {
      allTeams = widget.match.teams ?? [];
      selectedTeams = widget.match.mvt;
    } else {
      allPlayers = widget.match.players;
      selectedPlayers = widget.match.mvp;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: useTeamLogic
          ? ListView.builder(
              itemCount: allTeams.length,
              itemBuilder: (context, index) {
                return CustomCheckboxListTile(
                  content: widget.match.isTeamMatch
                      ? TeamCard(team: allTeams[index], maxChars: 24)
                      : buildUnitNameWidget(
                          allTeams[index],
                          isTeamMatch: false,
                        ),
                  value: selectedTeams.contains(allTeams[index]),
                  onChanged: (bool value) {
                    setState(() {
                      if (value) {
                        selectedTeams.add(allTeams[index]);
                      } else {
                        selectedTeams.remove(allTeams[index]);
                      }
                      widget.onTeamsSelected?.call(selectedTeams);
                    });
                  },
                );
              },
            )
          : ListView.builder(
              itemCount: allPlayers.length,
              itemBuilder: (context, index) {
                return CustomCheckboxListTile(
                  content: buildUnitNameWidget(
                    allPlayers[index],
                    mainStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: selectedPlayers.contains(allPlayers[index]),
                  onChanged: (bool value) {
                    setState(() {
                      if (value) {
                        selectedPlayers.add(allPlayers[index]);
                      } else {
                        selectedPlayers.remove(allPlayers[index]);
                      }
                      widget.onPlayersSelected?.call(selectedPlayers);
                    });
                  },
                );
              },
            ),
    );
  }
}
