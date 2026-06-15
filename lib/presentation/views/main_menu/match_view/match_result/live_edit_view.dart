import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/live_edit_list_tile.dart';

class LiveEditView extends StatefulWidget {
  const LiveEditView({
    super.key,
    required this.match,
    required this.initialScores,
    this.onScoresChanged,
  });

  final Match match;
  final Map<dynamic, int?> initialScores;
  final void Function(Map<dynamic, int?>)? onScoresChanged;

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
  Map<dynamic, int?> scores = {};

  bool get useTeamLogic => widget.match.useTeamLogic;
  bool get isTeamMatch => widget.match.isTeamMatch;

  @override
  void initState() {
    scores = widget.initialScores;
    super.initState();
  }

  @override
  void didUpdateWidget(LiveEditView oldWidget) {
    super.didUpdateWidget(oldWidget);
    scores = widget.initialScores;
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
      body: Column(
        children: [
          Expanded(
            child: useTeamLogic
                ? ListView.builder(
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
                          scores[team] = value;
                          widget.onScoresChanged?.call(scores);
                        },
                        value: scores[team] ?? 0,
                        color: isTeamMatch
                            ? getColorFromAppColor(team.color)
                            : null,
                      );
                    },
                  )
                : ListView.builder(
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
                            scores[allPlayers[index]] = value;
                            widget.onScoresChanged?.call(scores);
                          });
                        },
                        value: scores[allPlayers[index]] ?? 0,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
