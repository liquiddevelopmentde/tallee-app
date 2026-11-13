import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/live_edit_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/placement_drag_list.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/select_looser_widget.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/select_winner_widget.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/state/rate_dialog_provider.dart';

class MatchResultView extends StatefulWidget {
  /// A view that allows selecting and saving the winner of a match
  /// [match]: The match for which the winner is to be selected
  /// [onWinnerChanged]: Optional callback invoked when the winner is changed
  const MatchResultView({
    super.key,
    required this.match,
    this.onWinnerChanged,
    this.defaultLives = 3,
  });

  final Match match;
  final VoidCallback? onWinnerChanged;
  final int defaultLives;

  @override
  State<MatchResultView> createState() => _MatchResultViewState();
}

class _MatchResultViewState extends State<MatchResultView> {
  late final AppDatabase db;

  List<Player> allPlayers = [];
  List<Team> allTeams = [];

  /// Currently selected player(s)/team(s) (winner / loser)
  List<Player> selectedPlayers = [];
  List<Team> selectedTeams = [];

  /// Scores entered for each player/team
  Map<dynamic, int?> scores = {};

  Match get match => widget.match;

  Ruleset get ruleset => match.game.ruleset;

  bool get useTeamLogic => widget.match.useTeamLogic;

  bool get isTeamMatch => widget.match.isTeamMatch;

  bool get canSave {
    if (ruleset.isPlacement || ruleset.isLives) return true;
    if (selectedPlayers.isNotEmpty || selectedTeams.isNotEmpty) return true;
    return areScoresValid;
  }

  bool get areScoresValid {
    final List<dynamic> units = useTeamLogic ? allTeams : allPlayers;
    final isEveryUnitInScores = units.every(
      (unit) => scores.containsKey(unit) && scores[unit] != null,
    );
    final hasScores = scores.isNotEmpty;
    return hasScores && isEveryUnitInScores;
  }

  /// Whether the current input differs from the scores stored in the [match].
  bool get hasChangedResult {
    switch (ruleset) {
      case Ruleset.winner:
      case Ruleset.loser:
        return hasChangedSelection();
      default:
        return hasChangedScores();
    }
  }

  @override
  void initState() {
    db = context.read<AppDatabase>();
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return PopScope(
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          try {
            ShowcaseView.get().dismiss();
          } catch (_) {}
        }
        // Auto-Save if match is still ongoing
        if (match.endedAt == null) saveResults();
      },
      child: Scaffold(
        backgroundColor: context.talleeColors.backgroundColor,
        appBar: AppBar(title: Text(widget.match.name)),
        body: Column(
          children: [
            Expanded(
              child: ruleset.usesNumericScore
                  ? ruleset.isLives
                        ? LiveEditView.lives(
                            match: widget.match,
                            initialScores: scores,
                            onScoresChanged: (newScores) => setState(
                              () => scores = Map<dynamic, int?>.from(newScores),
                            ),
                          )
                        : LiveEditView.score(
                            match: widget.match,
                            initialScores: scores,
                            onScoresChanged: (newScores) => setState(
                              () => scores = Map<dynamic, int?>.from(newScores),
                            ),
                          )
                  : Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: context.talleeColors.boxColor,
                        border: Border.all(
                          color: context.talleeColors.boxBorderColor,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
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
                          if (ruleset.usesPlayerSelection)
                            if (ruleset.isWinner)
                              SelectWinnerWidget(
                                match: widget.match,
                                onPlayersSelected: (List<Player> players) {
                                  setState(() => selectedPlayers = players);
                                },
                                onTeamsSelected: (List<Team> teams) {
                                  setState(() => selectedTeams = teams);
                                },
                              )
                            else
                              SelectLooserWidget(
                                match: widget.match,
                                onPlayerSelected: (Player? player) {
                                  setState(() => selectedPlayers = [?player]);
                                },
                                onTeamSelected: (Team? team) {
                                  setState(() => selectedTeams = [?team]);
                                },
                              ),

                          // Show draggable placement list
                          if (ruleset.isPlacement)
                            PlacementDragList(
                              match: widget.match,
                              teams: allTeams,
                              players: allPlayers,
                              onTeamOrderChanged: (teams) {
                                setState(() => allTeams = teams);
                              },
                              onPlayerOrderChanged: (players) {
                                setState(() => allPlayers = players);
                              },
                            ),
                        ],
                      ),
                    ),
            ),

            // Saving button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.match.endedAt == null)
                    BottomAnimatedButton(
                      text: loc.end_match,
                      onPressed: canSave
                          ? () async {
                              await saveResults();
                              await endMatch();
                              if (context.mounted) Navigator.pop(context);
                            }
                          : null,
                    )
                  else
                    // Save Changes Button
                    BottomAnimatedButton(
                      text: loc.save_changes,
                      onPressed: canSave && hasChangedResult
                          ? () async {
                              await saveResults();
                              widget.onWinnerChanged?.call();
                              if (context.mounted) Navigator.pop(context);
                            }
                          : null,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Checks if the scores from [match] differ from the current entered [scores]
  bool hasChangedScores() {
    if (useTeamLogic) {
      for (int i = 0; i < allTeams.length; i++) {
        final team = allTeams[i];
        final currentScore =
            team.score ?? (ruleset.isLives ? widget.defaultLives : null);
        final newScore = getNewScore(team, i);
        if (currentScore != newScore) {
          return true;
        }
      }
    } else {
      for (int i = 0; i < allPlayers.length; i++) {
        final player = allPlayers[i];
        final currentScore =
            match.scores[player.id]?.score ??
            (ruleset.isLives ? widget.defaultLives : null);
        final newScore = getNewScore(player, i);
        if (currentScore != newScore) return true;
      }
    }
    return false;
  }

  /// Checks if the selected player(s) differ from the mvp(s) in [match]
  bool hasChangedSelection() {
    const winnerScore = 1;
    const loserScore = 0;

    final rulesetScore = ruleset.isWinner ? winnerScore : loserScore;

    if (useTeamLogic) {
      return allTeams.any(
        (team) =>
            selectedTeams.contains(team) && team.score != rulesetScore ||
            !selectedTeams.contains(team) && team.score == rulesetScore,
      );
    } else {
      return allPlayers.any(
        (player) =>
            selectedPlayers.contains(player) &&
                getPlayerScore(player) != rulesetScore ||
            !selectedPlayers.contains(player) &&
                getPlayerScore(player) == rulesetScore,
      );
    }
  }

  /// Helper function to get a score from a player
  int? getPlayerScore(Player player) =>
      match.scoresByRound[player.id]?.firstOrNull?.change;

  /// Helper function returning the new score of [unit] saved in the [scores] Map
  int? getNewScore(Object unit, int index) {
    if (ruleset.isPlacement) {
      final count = useTeamLogic ? allTeams.length : allPlayers.length;
      return count - index;
    }
    return scores[unit];
  }

  /// Initializes the variables based on the ruleset
  void initData() {
    if (match.useTeamLogic) {
      allTeams = List.of(widget.match.teams ?? []);

      switch (ruleset) {
        case Ruleset.winner:
        case Ruleset.loser:
          selectedTeams = match.mvt;

        case Ruleset.placement:
          mergeSort(
            allTeams,
            compare: (a, b) => (b.score ?? 0).compareTo(a.score ?? 0),
          );

        case Ruleset.lives:
        case Ruleset.lowestScore:
        case Ruleset.highestScore:
          final int defaultLives = widget.defaultLives;
          scores = Map.fromEntries(
            allTeams.map(
              (team) => MapEntry(
                team,
                team.score ?? (ruleset.isLives ? defaultLives : null),
              ),
            ),
          );
      }
    } else {
      allPlayers = List.of(widget.match.players);

      switch (ruleset) {
        case Ruleset.winner:
        case Ruleset.loser:
          selectedPlayers = widget.match.mvp;

        case Ruleset.placement:
          mergeSort(
            allPlayers,
            compare: (a, b) => (widget.match.scores[b.id]?.score ?? 0)
                .compareTo(widget.match.scores[a.id]?.score ?? 0),
          );

        case Ruleset.lives:
        case Ruleset.lowestScore:
        case Ruleset.highestScore:
          final int defaultLives = widget.defaultLives;
          scores = Map.fromEntries(
            allPlayers.map(
              (player) => MapEntry(
                player,
                widget.match.scores[player.id]?.score ??
                    (ruleset.isLives ? defaultLives : null),
              ),
            ),
          );
      }
    }
  }

  /// Handles saving the current input of values based on the ruleset.
  Future<void> saveResults() async {
    if (ruleset.isWinner) {
      await handleWinners();
    } else if (ruleset.isLoser) {
      await handleLoser();
    } else if (ruleset.usesPoints) {
      await handleScores();
    } else if (ruleset.isPlacement) {
      await handlePlacement();
    } else if (ruleset.isLives) {
      await handleLives();
    }
  }

  /// Sets Match.endedAt to the current time and requests a rating dialog to be shown.
  Future<void> endMatch() async {
    await db.matchDao.updateMatchEndedAt(
      matchId: widget.match.id,
      endedAt: DateTime.now(),
    );
    widget.onWinnerChanged?.call();

    if (!mounted) return;
    final rateProvider = context.read<RateDialogProvider>();
    rateProvider.request();
  }

  /// Handles saving the (multiple) winners to the database.
  Future<bool> handleWinners() async {
    if (useTeamLogic) {
      if (selectedTeams.isEmpty) {
        return await db.teamDao.removeWinnerTeams(matchId: widget.match.id);
      } else {
        return await db.teamDao.setWinnerTeams(
          matchId: widget.match.id,

          winners: selectedTeams.toList(),
        );
      }
    } else {
      if (selectedPlayers.isEmpty) {
        return await db.scoreEntryDao.removeWinners(matchId: widget.match.id);
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
      if (selectedTeams.isEmpty) {
        return await db.teamDao.removeLoserTeam(matchId: widget.match.id);
      } else {
        return await db.teamDao.setLoserTeam(
          matchId: widget.match.id,
          teamId: selectedTeams.first.id,
        );
      }
    } else {
      if (selectedPlayers.isEmpty) {
        return await db.scoreEntryDao.removeLoser(matchId: widget.match.id);
      } else {
        return await db.scoreEntryDao.setLoser(
          matchId: widget.match.id,
          playerId: selectedPlayers.first.id,
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
          entry: ScoreEntry(change: score),
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

  /// Handles saving the remaining lives for each player/team in the database.
  Future<void> handleLives() async {
    if (useTeamLogic) {
      for (final team in allTeams) {
        final lives = scores[team] ?? widget.defaultLives;
        await db.teamDao.updateTeamScore(
          matchId: widget.match.id,
          teamId: team.id,
          score: lives,
        );
      }
    } else {
      for (final player in allPlayers) {
        final lives = scores[player] ?? widget.defaultLives;
        await db.scoreEntryDao.addScore(
          matchId: widget.match.id,
          playerId: player.id,
          entry: ScoreEntry(change: lives),
        );
      }
    }
  }

  String getTitleForRuleset(AppLocalizations loc) {
    switch (ruleset) {
      case Ruleset.loser:
        return loc.select_loser;
      case Ruleset.placement:
        return loc.drag_to_set_placement;
      case Ruleset.winner:
        return loc.select_winners;
      default:
        return '';
    }
  }
}
