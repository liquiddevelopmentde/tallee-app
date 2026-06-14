import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/live_edit_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/multiple_player_selection.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/placement_drag_list.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/score_enter_list.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/single_player_selection.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';

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

  late final List<Player> allPlayers;
  late final List<Team> allTeams;

  /// Flag to indicate if the save button should be enabled
  bool canSave = false;

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

  @override
  void initState() {
    db = Provider.of<AppDatabase>(context, listen: false);
    ruleset = widget.match.game.ruleset;

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
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                color: CustomTheme.boxColor,
                border: Border.all(color: CustomTheme.boxBorderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTitleForRuleset(loc),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Show player selection
                  if (rulesetSupportsPlayerSelection())
                    if (ruleset == Ruleset.multipleWinners)
                      MultiplePlayerSelection(
                        match: widget.match,
                        onPlayersSelected: (List<Player> players) =>
                            selectedPlayers = players,
                        onTeamsSelected: (List<Team> teams) =>
                            selectedTeams = teams,
                      )
                    else
                      SinglePlayerSelection(
                        match: widget.match,
                        onPlayerSelected: (Player? player) =>
                            selectedPlayer = player,
                        onTeamSelected: (Team? team) => selectedTeam = team,
                      ),

                  // Show score entry
                  if (rulesetSupportsScoreEntry())
                    ScoreEnterList(
                      match: widget.match,
                      initialScores: scores,
                      onScoreChanged: (Map<dynamic, int?> newScores) =>
                          scores = newScores,
                      onCanSaveChanged: (bool canSave) =>
                          setState(() => this.canSave = canSave),
                    ),

                  // Show draggable placement list
                  if (rulesetSupportsDragBehaviour())
                    PlacementDragList(
                      match: widget.match,
                      onPlayerOrderChanged: (List<Player> players) =>
                          allPlayers = players,
                      onTeamOrderChanged: (List<Team> teams) =>
                          allTeams = teams,
                    ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Live Edit Mode Button
                if (rulesetSupportsScoreEntry()) ...[
                  BottomAnimatedButton(
                    sizeRelativeToWidth: 0.95,
                    buttonText: loc.live_edit_mode,
                    buttonType: ButtonType.secondary,
                    onPressed: () => Navigator.push(
                      context,
                      adaptivePageRoute(
                        fullscreenDialog: true,
                        builder: (context) => LiveEditView(
                          match: getMatchWithTempScores(),
                          onScoresChanged: (Map<dynamic, int> newScores) =>
                              onScoresChanged(newScores),
                        ),
                      ),
                    ),
                  ),
                ],

                // Save Changes Button
                BottomAnimatedButton(
                  sizeRelativeToWidth: 0.95,
                  buttonText: loc.save_changes,
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

  void onScoresChanged(Map<dynamic, int> newScores) {
    scores = Map<dynamic, int>.from(newScores);

    final List<dynamic> participants = useTeamLogic ? allTeams : allPlayers;
    final hasScoresForAll = participants.every(
      (entry) => scores.containsKey(entry),
    );
    final hasAnyScore = scores.isNotEmpty;

    setState(() {
      canSave = hasAnyScore && hasScoresForAll;
    });
  }

  void initData() {
    allPlayers = widget.match.players;
    allTeams = widget.match.teams ?? [];

    selectedPlayer = widget.match.mvp.firstOrNull;
    selectedTeam = widget.match.mvt.firstOrNull;
    selectedPlayers = widget.match.mvp;
    selectedTeams = widget.match.mvt;

    if (widget.match.isTeamMatch) {
      scores = Map.fromEntries(
        allTeams.map((team) => MapEntry(team, team.score)),
      );
    } else {
      scores = Map.fromEntries(
        allPlayers.map(
          (player) => MapEntry(player, widget.match.scores[player.id]?.score),
        ),
      );
    }
  }

  /// Creates a match object with the currently entered scores.
  Match getMatchWithTempScores() {
    if (useTeamLogic) {
      final teams = widget.match.teams ?? <Team>[];
      final tempTeams = teams
          .map((team) => team.copyWith(score: scores[team] ?? 0))
          .toList();

      return widget.match.copyWith(teams: tempTeams);
    } else {
      final player = widget.match.players;

      final scoreEntryMap = Map.fromEntries(
        player.map(
          (player) => MapEntry(
            player.id,
            ScoreEntry(roundNumber: 0, score: scores[player] ?? 0, change: 0),
          ),
        ),
      );

      return widget.match.copyWith(scores: scoreEntryMap);
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
