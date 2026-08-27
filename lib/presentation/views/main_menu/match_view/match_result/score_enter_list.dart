import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/cards/team_card.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/score_list_tile.dart';

class ScoreEnterList extends StatefulWidget {
  const ScoreEnterList({
    super.key,
    required this.match,
    required this.initialScores,
    this.onScoreChanged,
    this.onCanSaveChanged,
  });

  final Match match;
  final Map<dynamic, int?> initialScores;
  final void Function(Map<dynamic, int?>)? onScoreChanged;
  final void Function(bool)? onCanSaveChanged;

  @override
  State<ScoreEnterList> createState() => _ScoreEnterListState();
}

class _ScoreEnterListState extends State<ScoreEnterList> {
  late List<Player> allPlayers;
  late List<Team> allTeams;

  late List<TextEditingController> controller;
  late List<FocusNode> focusNodes;
  Map<dynamic, int?> scores = {};

  bool canSave = false;

  /// Suppresses the [onTextEnter] listener while controllers are updated
  bool suppressListener = false;

  bool get isTeamMatch => widget.match.isTeamMatch;
  bool get useTeamLogic => widget.match.useTeamLogic;

  @override
  void initState() {
    int entryLength = 0;

    // init data
    if (useTeamLogic) {
      allTeams = (widget.match.teams ?? [])
        ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));
      entryLength = allTeams.length;
    } else {
      allPlayers = widget.match.players
        ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));
      entryLength = allPlayers.length;
    }

    // Init controlelrs
    controller = List.generate(entryLength, (index) => TextEditingController());
    focusNodes = List.generate(entryLength, (index) => FocusNode());
    applyScoresToControllers(widget.initialScores);

    for (final c in controller) {
      c.addListener(onTextEnter);
    }
    reportCanSave();

    super.initState();
  }

  @override
  void didUpdateWidget(ScoreEnterList oldWidget) {
    super.didUpdateWidget(oldWidget);
    scores = widget.initialScores;
    applyScoresToControllers(scores);
  }

  @override
  void dispose() {
    for (final c in controller) {
      c.removeListener(onTextEnter);
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: useTeamLogic
          ? ListView.separated(
              itemCount: allTeams.length,
              itemBuilder: (context, index) {
                return ScoreListTile(
                  content: isTeamMatch
                      ? TeamCard(
                          team: allTeams[index],
                          width: 220,
                          maxChars: 16,
                        )
                      : buildUnitNameWidget(
                          allTeams[index],
                          isTeamMatch: false,
                        ),
                  focusNode: focusNodes[index],
                  textInputAction: index == allTeams.length - 1
                      ? TextInputAction.done
                      : TextInputAction.next,
                  onSubmitted: (_) => focusNextTile(index),
                  horizontalPadding: 0,
                  controller: controller[index],
                  onChanged: (String text) {
                    final score = text.isEmpty ? null : int.tryParse(text);
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
                  focusNode: focusNodes[index],
                  textInputAction: index == allPlayers.length - 1
                      ? TextInputAction.done
                      : TextInputAction.next,
                  onSubmitted: (_) => focusNextTile(index),
                  horizontalPadding: 0,
                  onChanged: (String text) {
                    final score = text.isEmpty ? null : int.tryParse(text);
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

  /// Moves the keyboard focus to the next team tile. If the current tile is the
  /// last one, the focus is dropped and the keyboard is dismissed instead.
  void focusNextTile(int index) {
    if (index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    } else {
      focusNodes[index].unfocus();
    }
  }

  void applyScoresToControllers(Map<dynamic, int?> newScores) {
    final entryLength = useTeamLogic ? allTeams.length : allPlayers.length;
    suppressListener = true;

    // iterate through entries
    for (int i = 0; i < entryLength; i++) {
      dynamic key = useTeamLogic ? allTeams[i] : allPlayers[i];
      final newText = newScores[key]?.toString() ?? '';
      if (controller[i].text != newText) {
        controller[i].text = newText;
      }
    }
    suppressListener = false;
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
}
