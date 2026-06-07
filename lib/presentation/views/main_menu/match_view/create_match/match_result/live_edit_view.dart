import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
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
      (widget.match.teams ?? [])..sort((a, b) => a.name.compareTo(b.name));
  List<Player> get allPlayers =>
      widget.match.players..sort((a, b) => a.name.compareTo(b.name));
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
    if (widget.match.isTeamMatch) {
      return ListView.builder(
        itemCount: allTeams.length,
        itemBuilder: (context, index) {
          return LiveEditListTile(
            title: allTeams[index].name,
            onChanged: (value) {
              scores[index] = value;
            },
            value: scores[index],
            color: getColorFromAppColor(allTeams[index].color),
          );
        },
      );
    } else if (!widget.match.isTeamMatch &&
        (widget.match.teams?.isNotEmpty ?? false)) {
      return ListView.builder(
        itemCount: allTeams.length,
        itemBuilder: (context, index) {
          return LiveEditListTile(
            title: allTeams[index].displayName,
            onChanged: (value) {
              scores[index] = value;
            },
            value: scores[index],
          );
        },
      );
    } else {
      return ListView.builder(
        itemCount: allPlayers.length,
        itemBuilder: (context, index) {
          return LiveEditListTile(
            title: allPlayers[index].name,
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
