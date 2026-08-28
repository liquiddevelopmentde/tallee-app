import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/cards/team_card.dart';
import 'package:tallee/presentation/widgets/tiles/match_result_view/match_result_list_tile.dart';

class MatchResultView extends StatefulWidget {
  /// A view that allows selecting and saving the winner of a match
  /// [match]: The match for which the winner is to be selected
  /// [onWinnerChanged]: Optional callback invoked when the winner is changed
  const MatchResultView({super.key, required this.match, this.onWinnerChanged});

  /// The match for which the winner is to be selected
  final Match match;

  /// Optional callback invoked when the winner is changed
  final VoidCallback? onWinnerChanged;

  @override
  State<MatchResultView> createState() => _MatchResultViewState();
}

class _MatchResultViewState extends State<MatchResultView> {
  late final AppDatabase db;

  late final Ruleset ruleset;

  late List<Player> allPlayers;
  late List<Team> allTeams;

  /// Flag to indicate if the save button should be enabled
  late bool canSave;

  /// Currently selected player(s)/team(s) (winner / loser)
  Player? selectedPlayer;
  Team? selectedTeam;
  List<Player> selectedPlayers = [];
  List<Team> selectedTeams = [];

  /// Scores entered for each player/team
  Map<dynamic, int?> scores = {};

  bool get useTeamLogic => widget.match.useTeamLogic;

  bool get isTeamMatch => widget.match.isTeamMatch;

  bool rulesetSupportsPlayerSelection() =>
      ruleset == Ruleset.singleWinner ||
      ruleset == Ruleset.singleLoser ||
      ruleset == Ruleset.multipleWinners;

  bool rulesetSupportsScoreEntry() =>
      ruleset == Ruleset.lowestScore || ruleset == Ruleset.highestScore;

  bool rulesetSupportsDragBehaviour() => ruleset == Ruleset.placement;

  /// Number of participating units (players or teams).
  int get unitCount => useTeamLogic ? allTeams.length : allPlayers.length;

  dynamic getUnit(int index) => useTeamLogic ? allTeams[index] : allPlayers[index];

  @override
  void initState() {
    db = Provider.of<AppDatabase>(context, listen: false);
    ruleset = widget.match.game.ruleset;
    canSave = rulesetSupportsDragBehaviour() || rulesetSupportsScoreEntry();

    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: HapticIconButton(
          icon: const Icon(Icons.close),
          onPressed: () => {
            widget.onWinnerChanged?.call(),
            Navigator.pop(context),
          },
        ),
        title: Text(widget.match.name),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                getTitleForRuleset(loc),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CustomTheme.hintColor,
                ),
              ),
            ),
          ),
          Expanded(child: _buildContent()),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Finish Button
                BottomAnimatedButton(
                  sizeRelativeToWidth: 0.95,
                  buttonText: loc.finish_match,
                  onPressed: canSave
                      ? () async {
                          final ending = DateTime.now();
                          await db.matchDao.updateMatchEndedAt(
                            matchId: widget.match.id,
                            endedAt: ending,
                          );
                          await handleSaving();
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the unified participant list for the current ruleset.
  Widget _buildContent() {
    if (rulesetSupportsPlayerSelection()) {
      return _buildSelectionList();
    } else if (rulesetSupportsScoreEntry()) {
      return _buildScoreList();
    } else {
      return _buildPlacementList();
    }
  }

  /// Builds a unified tile for a participant.
  Widget _buildTile({
    required dynamic unit,
    bool selected = false,
    VoidCallback? onTap,
    Widget? leading,
    Widget? trailing,
  }) {
    return MatchResultListTile(
      key: ValueKey(unit.id),
      selected: selected,
      onTap: onTap,
      leading: leading,
      trailing: trailing,
      child: useTeamLogic && isTeamMatch
          ? TeamCard(team: unit as Team, maxChars: 24)
          : buildUnitNameWidget(
              unit,
              isTeamMatch: false,
              mainStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }

  /// Builds the selection list for winner/loser/multiple-winner rulesets.
  Widget _buildSelectionList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: unitCount,
      itemBuilder: (context, index) {
        final unit = getUnit(index);
        final selected = _isSelected(unit);
        return _buildTile(
          unit: unit,
          selected: selected,
          onTap: () => _toggleSelection(unit),
          trailing: Icon(
            selected
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 24,
            color: selected ? CustomTheme.primaryColor : CustomTheme.hintColor,
          ),
        );
      },
    );
  }

  /// Builds the score stepper list for score-based rulesets.
  Widget _buildScoreList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: unitCount,
      itemBuilder: (context, index) {
        final unit = getUnit(index);
        return _buildTile(
          unit: unit,
          trailing: _buildStepper(unit),
        );
      },
    );
  }

  /// Builds the stepper control for adjusting a participant's score.
  Widget _buildStepper(dynamic unit) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: Icons.remove_rounded,
          onTap: () => _adjustScore(unit, -1),
          onLongPress: () => _adjustScore(unit, -10),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _ScoreInput(
            score: scores[unit] ?? 0,
            onChanged: (value) => setState(() {
              scores[unit] = value;
            }),
          ),
        ),
        _StepButton(
          icon: Icons.add_rounded,
          onTap: () => _adjustScore(unit, 1),
          onLongPress: () => _adjustScore(unit, 10),
        ),
      ],
    );
  }

  void _adjustScore(dynamic unit, int delta) {
    setState(() {
      scores[unit] = (scores[unit] ?? 0) + delta;
    });
  }

  /// Builds the draggable placement list for the placement ruleset.
  Widget _buildPlacementList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      buildDefaultDragHandles: false,
      onReorderItem: _onReorder,
      itemCount: unitCount,
      itemBuilder: (context, index) {
        final unit = getUnit(index);
        return _buildTile(
          unit: unit,
          leading: _placementBadge(index),
          trailing: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle, color: CustomTheme.hintColor),
          ),
        );
      },
    );
  }

  Widget _placementBadge(int index) => Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: CustomTheme.boxBorderColor,
          borderRadius: CustomTheme.standardBorderRadiusAll,
        ),
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            color: CustomTheme.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      );

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (useTeamLogic) {
        final team = allTeams.removeAt(oldIndex);
        allTeams.insert(newIndex, team);
      } else {
        final player = allPlayers.removeAt(oldIndex);
        allPlayers.insert(newIndex, player);
      }
    });
  }

  bool _isSelected(dynamic unit) {
    if (ruleset == Ruleset.multipleWinners) {
      return useTeamLogic
          ? selectedTeams.contains(unit)
          : selectedPlayers.contains(unit);
    }
    return useTeamLogic ? selectedTeam == unit : selectedPlayer == unit;
  }

  void _toggleSelection(dynamic unit) {
    setState(() {
      if (ruleset == Ruleset.multipleWinners) {
        if (useTeamLogic) {
          if (selectedTeams.contains(unit)) {
            selectedTeams.remove(unit);
          } else {
            selectedTeams.add(unit as Team);
          }
        } else {
          if (selectedPlayers.contains(unit)) {
            selectedPlayers.remove(unit);
          } else {
            selectedPlayers.add(unit as Player);
          }
        }
        canSave = (useTeamLogic ? selectedTeams : selectedPlayers).isNotEmpty;
      } else {
        if (useTeamLogic) {
          selectedTeam = selectedTeam == unit ? null : unit as Team;
          canSave = selectedTeam != null;
        } else {
          selectedPlayer = selectedPlayer == unit ? null : unit as Player;
          canSave = selectedPlayer != null;
        }
      }
    });
  }

  void initData() {
    if (widget.match.useTeamLogic) {
      allTeams = widget.match.teams ?? [];
      selectedTeam = widget.match.mvt.firstOrNull;
      selectedTeams = widget.match.mvt;

      scores = Map.fromEntries(
        allTeams.map((team) => MapEntry(team, team.score)),
      );
    } else {
      allPlayers = widget.match.players;
      selectedPlayer = widget.match.mvp.firstOrNull;
      selectedPlayers = widget.match.mvp;

      scores = Map.fromEntries(
        allPlayers.map(
          (player) => MapEntry(player, widget.match.scores[player.id]?.score),
        ),
      );
    }
  }

  /// Handles saving or removing the winner in the database
  /// based on the current selection.
  Future<void> handleSaving() async {
    if (ruleset == Ruleset.singleWinner) {
      await handleWinner();
    } else if (ruleset == Ruleset.singleLoser) {
      await handleLoser();
    } else if (ruleset == Ruleset.lowestScore ||
        ruleset == Ruleset.highestScore) {
      await handleScores();
    } else if (ruleset == Ruleset.placement) {
      await handlePlacement();
    } else if (ruleset == Ruleset.multipleWinners) {
      await handleWinners();
    }

    widget.onWinnerChanged?.call();
  }

  /// Handles saving or removing the (single) winner in the database.
  Future<bool> handleWinner() async {
    if (useTeamLogic) {
      if (selectedTeam == null) {
        return await db.teamDao.removeWinnerTeam(matchId: widget.match.id);
      } else {
        return await db.teamDao.setWinnerTeam(
          matchId: widget.match.id,
          teamId: selectedTeam!.id,
        );
      }
    } else {
      if (selectedPlayer == null) {
        return await db.scoreEntryDao.removeWinner(matchId: widget.match.id);
      } else {
        return await db.scoreEntryDao.setWinner(
          matchId: widget.match.id,
          playerId: selectedPlayer!.id,
        );
      }
    }
  }

  /// Handles saving the (multiple) winners to the database.
  Future<bool> handleWinners() async {
    if (useTeamLogic) {
      if (selectedTeams.isEmpty) {
        return await db.teamDao.removeWinnerTeam(matchId: widget.match.id);
      } else {
        return await db.teamDao.setWinnerTeams(
          matchId: widget.match.id,

          winners: selectedTeams.toList(),
        );
      }
    } else {
      if (selectedPlayers.isEmpty) {
        return await db.scoreEntryDao.removeWinner(matchId: widget.match.id);
      } else {
        return await db.scoreEntryDao.setWinners(
          matchId: widget.match.id,
          winners: selectedPlayers.toList(),
        );
      }
    }
  }

  /// Handles saving or removing the loser in the database.
  Future<bool> handleLoser() async {
    if (useTeamLogic) {
      if (selectedTeam == null) {
        return await db.teamDao.removeLoserTeam(matchId: widget.match.id);
      } else {
        return await db.teamDao.setLoserTeam(
          matchId: widget.match.id,
          teamId: selectedTeam!.id,
        );
      }
    } else {
      if (selectedPlayer == null) {
        return await db.scoreEntryDao.removeLoser(matchId: widget.match.id);
      } else {
        return await db.scoreEntryDao.setLoser(
          matchId: widget.match.id,
          playerId: selectedPlayer!.id,
        );
      }
    }
  }

  /// Handles saving the scores for each player in the database.
  Future<void> handleScores() async {
    if (useTeamLogic) {
      for (int i = 0; i < allTeams.length; i++) {
        final team = allTeams[i];
        final score = scores[team] ?? 0;
        await db.teamDao.updateTeamScore(
          matchId: widget.match.id,
          teamId: allTeams[i].id,
          score: score,
        );
      }
    } else {
      for (int i = 0; i < allPlayers.length; i++) {
        final player = allPlayers[i];
        final score = scores[player] ?? 0;
        await db.scoreEntryDao.addScore(
          matchId: widget.match.id,
          playerId: allPlayers[i].id,
          entry: ScoreEntry(roundNumber: 0, score: score, change: 0),
        );
      }
    }
  }

  /// Handles saving the placement for each player in the database.
  Future<void> handlePlacement() async {
    if (useTeamLogic) {
      await db.teamDao.setTeamPlacements(
        matchId: widget.match.id,
        teams: allTeams,
      );
    } else {
      await db.scoreEntryDao.setPlacements(
        matchId: widget.match.id,
        players: allPlayers,
      );
    }
  }

  String getTitleForRuleset(AppLocalizations loc) {
    switch (ruleset) {
      case Ruleset.singleWinner:
        return loc.select_winner;
      case Ruleset.singleLoser:
        return loc.select_loser;
      case Ruleset.placement:
        return loc.drag_to_set_placement;
      case Ruleset.multipleWinners:
        return loc.select_winners;
      default:
        return loc.enter_points;
    }
  }
}

/// An inline score input that shows the current score and reveals a cursor
/// and number pad when tapped. Losing focus commits the entered value.
class _ScoreInput extends StatefulWidget {
  const _ScoreInput({required this.score, required this.onChanged});

  final int score;
  final ValueChanged<int> onChanged;

  @override
  State<_ScoreInput> createState() => _ScoreInputState();
}

class _ScoreInputState extends State<_ScoreInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.score}');
    _focusNode = FocusNode();
    _controller.addListener(_onChanged);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        final value = int.tryParse(_controller.text.trim());
        if (value == null) {
          _controller.text = '${widget.score}';
        }
      }
    });
  }

  void _onChanged() {
    final value = int.tryParse(_controller.text.trim());
    if (value != null) {
      widget.onChanged(value);
    }
  }

  @override
  void didUpdateWidget(_ScoreInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != oldWidget.score && !_focusNode.hasFocus) {
      _controller.text = '${widget.score}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
        ],
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: CustomTheme.boxColor,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 4,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: CustomTheme.boxBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: CustomTheme.primaryColor),
          ),
        ),
      ),
    );
  }
}

/// A small circular stepper button styled to match the app's dark theme.
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await HapticFeedback.selectionClick();
        onTap();
      },
      onLongPress: onLongPress == null
          ? null
          : () async {
              await HapticFeedback.selectionClick();
              onLongPress!();
            },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: CustomTheme.boxColor,
          border: Border.all(color: CustomTheme.boxBorderColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 20, color: CustomTheme.textColor),
      ),
    );
  }
}