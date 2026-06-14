import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/team.dart';
import 'package:tallee/presentation/util/name_display.dart';
import 'package:tallee/presentation/widgets/cards/team_card.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/score_list_tile.dart';

class ScoreEnterList extends StatefulWidget {
  const ScoreEnterList({
    super.key,
    required this.match,
    this.initialScores,
    this.onScoreChanged,
    this.onCanSaveChanged,
  });

  final Match match;
  final Map<dynamic, int?>? initialScores;
  final void Function(Map<dynamic, int?>)? onScoreChanged;
  final void Function(bool)? onCanSaveChanged;

  @override
  State<ScoreEnterList> createState() => _ScoreEnterListState();
}

class _ScoreEnterListState extends State<ScoreEnterList> {
  late List<Player> allPlayers;
  late List<Team> allTeams;

  late List<TextEditingController> controller;
  Map<dynamic, int?> scores = {};

  bool canSave = false;

  /// Suppresses the [onTextEnter] listener while controllers are updated
  bool suppressListener = false;

  @override
  void initState() {
    super.initState();
    allTeams = (widget.match.teams ?? [])
      ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));
    allPlayers = widget.match.players
      ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));

    final entryLength = hasTeams ? allTeams.length : allPlayers.length;

    controller = List.generate(entryLength, (index) => TextEditingController());

    applyScores(getScoreMap(entryLength));

    for (final c in controller) {
      c.addListener(onTextEnter);
    }

    reportCanSave();
  }

  @override
  void didUpdateWidget(ScoreEnterList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync the scores when they are changed in live edit view
    if (widget.initialScores != null && applyScores(widget.initialScores!)) {
      reportCanSave();
    }
  }

  bool get hasTeams => widget.match.useTeamLogic;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: hasTeams
          ? ListView.separated(
              itemCount: allTeams.length,
              itemBuilder: (context, index) {
                return ScoreListTile(
                  content: hasTeams
                      ? TeamCard(
                          team: allTeams[index],
                          width: 220,
                          maxChars: 16,
                        )
                      : buildUnitNameWidget(
                          allTeams[index],
                          isTeamMatch: false,
                        ),
                  horizontalPadding: 0,
                  controller: controller[index],
                  onChanged: (String text) {
                    final score = int.tryParse(text) ?? 0;
                    scores[allTeams[index]] = score;
                    widget.onScoreChanged?.call(scores);
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(indent: 20),
                );
              },
            )
          : ListView.separated(
              itemCount: allPlayers.length,
              itemBuilder: (context, index) {
                return ScoreListTile(
                  content: buildUnitNameWidget(
                    allPlayers[index],
                    mainStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  controller: controller[index],
                  onChanged: (String text) {
                    final score = int.tryParse(text) ?? 0;
                    scores[allPlayers[index]] = score;
                    widget.onScoreChanged?.call(scores);
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(indent: 20),
                );
              },
            ),
    );
  }

  Map<dynamic, int?> getScoreMap(int entryLength) {
    if (widget.initialScores != null &&
        widget.initialScores!.length == entryLength) {
      return Map<dynamic, int?>.from(widget.initialScores!);
    }

    final Map<dynamic, int> scores = {};
    for (int i = 0; i < entryLength; i++) {
      if (hasTeams) {
        final teamScore = widget.match.teams?[i].score;
        if (teamScore != null) scores[allTeams[i]] = teamScore;
      } else {
        final scoreEntry = widget.match.scores[allPlayers[i].id];
        if (scoreEntry != null) scores[allPlayers[i]] = scoreEntry.score;
      }
    }
    return scores;
  }

  /// Applies the [newScores] scores to the controllers and the internal [scores]
  /// map.
  bool applyScores(Map<dynamic, int?> newScores) {
    final entryLength = hasTeams ? allTeams.length : allPlayers.length;
    bool changed = false;
    suppressListener = true;

    for (int i = 0; i < entryLength; i++) {
      final entry = hasTeams ? allTeams[i] : allPlayers[i];
      if (!newScores.containsKey(entry)) continue;

      scores[entry] = newScores[entry];
      final newText = newScores[entry]?.toString() ?? '';
      if (controller[i].text != newText) {
        controller[i].text = newText;
        changed = true;
      }
    }
    suppressListener = false;

    return changed;
  }

  void reportCanSave() {
    canSave = controller.every((c) => c.text.isNotEmpty);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onCanSaveChanged?.call(canSave);
    });
  }

  /// Updated canSave everytime a text is entered
  void onTextEnter() {
    if (suppressListener) return;
    canSave = controller.every((c) => c.text.isNotEmpty);
    widget.onCanSaveChanged?.call(canSave);
  }

  @override
  void dispose() {
    for (final c in controller) {
      c.removeListener(onTextEnter);
      c.dispose();
    }
    super.dispose();
  }
}
