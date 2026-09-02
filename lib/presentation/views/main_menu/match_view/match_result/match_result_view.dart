import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/live_edit_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/multiple_player_selection.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/placement_drag_list.dart';
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
      ruleset == Ruleset.lowestScore ||
      ruleset == Ruleset.highestScore ||
      ruleset == Ruleset.lives;

  @override
  void initState() {
    db = Provider.of<AppDatabase>(context, listen: false);
    ruleset = widget.match.game.ruleset;
    canSave = ruleset == Ruleset.placement || ruleset == Ruleset.lives;

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
            child: rulesetSupportsScoreEntry()
                ? LiveEditView(
                    match: widget.match,
                    initialScores: scores,
                    onScoresChanged: onScoresChanged,
                    minValue: ruleset == Ruleset.lives ? 0 : -9999,
                    maxValue: ruleset == Ruleset.lives
                        ? widget.match.game.lives!
                        : 9999,
                    livesMode: ruleset == Ruleset.lives,
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
                              onPlayersSelected: (List<Player> players) {
                                selectedPlayers = players;
                                setState(() {
                                  canSave = players.isNotEmpty;
                                });
                              },
                              onTeamsSelected: (List<Team> teams) {
                                selectedTeams = teams;
                                setState(() {
                                  canSave = teams.isNotEmpty;
                                });
                              },
                            )
                          else
                            SinglePlayerSelection(
                              match: widget.match,
                              onPlayerSelected: (Player? player) {
                                selectedPlayer = player;
                                setState(() {
                                  canSave = player != null;
                                });
                              },
                              onTeamSelected: (Team? team) {
                                selectedTeam = team;
                                setState(() {
                                  canSave = team != null;
                                });
                              },
                            ),

                        // Show draggable placement list
                        if (ruleset == Ruleset.placement)
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

          if (ruleset != Ruleset.lives)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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

  /// Callback function to handle score changes from the LiveEditView / ScoreEnterList
  void onScoresChanged(Map<dynamic, int?> newScores) {
    // Update the map
    scores = Map<dynamic, int?>.from(newScores);

    // update canSave state
    final List<dynamic> units = useTeamLogic ? allTeams : allPlayers;
    final isEveryUnitInScores = units.every(
      (unit) => scores.containsKey(unit) && scores[unit] != null,
    );
    final hasScores = scores.isNotEmpty;

    setState(() {
      canSave = hasScores && isEveryUnitInScores;
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

    if (ruleset == Ruleset.lives) {
      final int defaultLives = widget.match.game.lives!;
      scores = scores.map(
        (unit, value) => MapEntry(unit, value ?? defaultLives),
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
    } else if (ruleset == Ruleset.lives) {
      await handleLives();
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

  /// Handles saving the remaining lives for each player/team in the database.
  Future<void> handleLives() async {
    final int fallbackLives = widget.match.game.lives ?? 0;

    if (useTeamLogic) {
      for (final team in allTeams) {
        final lives = scores[team] ?? fallbackLives;
        await db.teamDao.updateTeamScore(
          matchId: widget.match.id,
          teamId: team.id,
          score: lives,
        );
      }
    } else {
      for (final player in allPlayers) {
        final lives = scores[player] ?? fallbackLives;
        await db.scoreEntryDao.addScore(
          matchId: widget.match.id,
          playerId: player.id,
          entry: ScoreEntry(roundNumber: 0, score: lives, change: 0),
        );
      }
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
      case Ruleset.lowestScore:
      case Ruleset.highestScore:
        return loc.enter_points;
      default:
        return '';
    }
  }
}
