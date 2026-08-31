import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/live_edit_list_tile.dart';

/// A live editing list of large stepper tiles, one per player / team.
class LiveEditView extends StatefulWidget {
  const LiveEditView({
    super.key,
    required this.match,
    required this.initialScores,
    this.onScoresChanged,
    this.minValue = -9999,
    this.maxValue = 9999,
    this.livesMode = false,
  });

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

  List<Team> get teams =>
      (widget.match.teams ?? [])
        ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));

  List<Player> get players =>
      widget.match.players
        ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));

  List<dynamic> get units => useTeamLogic ? teams : players;

  @override
  void initState() {
    super.initState();
    seedScores();
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
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: units.length,
      itemBuilder: (context, index) {
        final unit = units[index];
        return LiveEditListTile(
          isLivesRuleset: widget.livesMode,
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
    for (final unit in units) {
      scores[unit] ??= fallbackValue;
    }
  }
}
