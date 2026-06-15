import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/name_display.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/presentation/widgets/buttons/haptic_icon_button.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/live_edit_list_tile.dart';

class LiveEditView extends StatefulWidget {
  const LiveEditView({super.key, required this.match});
  final Match match;

  @override
  State<LiveEditView> createState() => _LiveEditViewState();
}

class _LiveEditViewState extends State<LiveEditView> {
  List<Team> get allTeams =>
      (widget.match.teams ?? [])
        ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));
  List<Player> get allPlayers =>
      widget.match.players
        ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));
  List<int> scores = [];

  @override
  void initState() {
    super.initState();

    if (widget.match.isTeamMatch) {
      scores = List.generate(
        allTeams.length,
        (index) => allTeams[index].score ?? 0,
      );
    } else {
      scores = List.generate(
        allPlayers.length,
        (index) => widget.match.scores[allPlayers[index].id]?.score ?? 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.match.name),
        leading: HapticIconButton(
          onPressed: () => Navigator.pop(context, scores),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Column(children: [Expanded(child: buildLiveEditWidget())]),
    );
  }

  Widget buildLiveEditWidget() {
    if (widget.match.useTeamLogic) {
      return ListView.builder(
        itemCount: allTeams.length,
        itemBuilder: (context, index) {
          final team = allTeams[index];
          return LiveEditListTile(
            title: buildUnitNameWidget(
              team,
              isTeamMatch: widget.match.isTeamMatch,
              rowAlignment: MainAxisAlignment.center,
              mainStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onChanged: (value) {
              scores[index] = value;
            },
            value: scores[index],
            color: getColorFromAppColor(team.color),
          );
        },
      );
    } else {
      return ListView.builder(
        itemCount: allPlayers.length,
        itemBuilder: (context, index) {
          return LiveEditListTile(
            title: buildUnitNameWidget(
              allPlayers[index],
              mainStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onChanged: (value) {
              setState(() {
                scores[index] = value;
              });
            },
            value: scores[index],
          );
        },
      );
    }
  }
}
