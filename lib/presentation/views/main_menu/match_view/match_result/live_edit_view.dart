import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/live_edit_list_tile.dart';

class LiveEditView extends StatefulWidget {
  /// A live editing list of large stepper tiles, one per player or team, used
  /// to adjust their value live while playing.
  /// - [match]: The match whose players / teams are being edited.
  /// - [initialScores]: The current value per unit.
  /// - [onScoresChanged]: The callback invoked with the updated value map
  ///   whenever a value changes.

  /// Creates a live editor for score entry.
  const LiveEditView.score({
    super.key,
    required this.match,
    required this.initialScores,
    this.onScoresChanged,
  }) : minValue = -9999,
       maxValue = 9999,
       livesMode = false;

  /// Creates a live editor for the lives ruleset
  const LiveEditView.lives({
    super.key,
    required this.match,
    required this.initialScores,
    this.onScoresChanged,
  }) : minValue = 0,
       maxValue = 9999,
       livesMode = true;

  final bool livesMode;
  final Match match;
  final Map<dynamic, int?> initialScores;
  final void Function(Map<dynamic, int?>)? onScoresChanged;
  final int minValue;
  final int maxValue;

  @override
  State<LiveEditView> createState() => _LiveEditViewState();
}

class _LiveEditViewState extends State<LiveEditView> {
  late final int fallbackValue = widget.livesMode ? 3 : 0;
  Map<dynamic, int?> scores = {};
  List<FocusNode> focusNodes = [];

  List<Team> get allTeams =>
      (widget.match.teams ?? [])
        ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));

  List<Player> get allPlayers =>
      widget.match.players
        ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));

  List<dynamic> get allUnits => useTeamLogic ? allTeams : allPlayers;

  @override
  void initState() {
    super.initState();
    seedScores();
    focusNodes = List.generate(allUnits.length, (_) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onScoresChanged?.call(scores);
    });
  }

  @override
  void didUpdateWidget(LiveEditView oldWidget) {
    super.didUpdateWidget(oldWidget);
    seedScores();
  }

  @override
  void dispose() {
    for (final node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: allUnits.length,
      itemBuilder: (context, index) {
        final unit = allUnits[index];
        return LiveEditListTile(
          isLivesRuleset: widget.livesMode,
          focusNode: index < focusNodes.length ? focusNodes[index] : null,
          textInputAction: index == allUnits.length - 1
              ? TextInputAction.done
              : TextInputAction.next,
          onSubmitted: () => focusNextTile(index),
          title: buildUnitNameWidget(
            unit,
            isTeamMatch: isTeamMatch,
            rowAlignment: MainAxisAlignment.center,
            mainStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          value: scores[unit] ?? fallbackValue,
          minValue: widget.minValue,
          maxValue: widget.maxValue,
          color: isTeamMatch && unit is Team
              ? getColorFromAppColor(unit.color)
              : null,
          onChanged: (value) {
            scores[unit] = value;
            widget.onScoresChanged?.call(scores);
          },
        );
      },
    );
  }

  bool get useTeamLogic => widget.match.useTeamLogic;

  bool get isTeamMatch => widget.match.isTeamMatch;

  void seedScores() {
    scores = Map<dynamic, int?>.from(widget.initialScores);
    for (final unit in allUnits) {
      scores[unit] ??= fallbackValue;
    }
  }

  void focusNextTile(int index) {
    if (index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    } else if (index < focusNodes.length) {
      focusNodes[index].unfocus();
    }
  }
}
