import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_match_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/match_result_view.dart';
import 'package:tallee/presentation/views/main_menu/player_detail_view.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/cards/team_card.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/game_label.dart';
import 'package:tallee/presentation/widgets/text_input/text_input_field.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/info_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/pair_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/player_tile.dart';

class MatchDetailView extends StatefulWidget {
  /// A view that displays the profile of a match
  /// - [match]: The match to display
  /// - [onMatchUpdate]: Callback to refresh the match list
  const MatchDetailView({
    super.key,
    required this.match,
    required this.onMatchUpdate,
  });

  /// The match to display
  final Match match;

  /// Callback to refresh the match list
  final VoidCallback onMatchUpdate;

  @override
  State<MatchDetailView> createState() => _MatchDetailViewState();
}

class _MatchDetailViewState extends State<MatchDetailView> {
  late final AppDatabase db;

  late Match match;

  late TextEditingController nameController;

  bool get useTeamLogic => match.useTeamLogic;

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    match = widget.match;
    nameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        title: Text(loc.match_profile),
        actions: [
          HapticIconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => Navigator.of(context).push(
              adaptivePageRoute(
                builder: (context) => CreateMatchView(
                  matchToPrefill: templateMatch,
                  onWinnerChanged: widget.onMatchUpdate,
                  onMatchesUpdated: widget.onMatchUpdate,
                ),
              ),
            ),
          ),
          HapticIconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              showDialog<bool>(
                context: context,
                builder: (context) => CustomAlertDialog(
                  title: '${loc.delete_match}?',
                  content: Text(
                    loc.this_cannot_be_undone,
                    overflow: TextOverflow.visible,
                  ),
                  actions: [
                    CustomDialogAction(
                      onPressed: () => Navigator.of(context).pop(true),
                      text: loc.delete,
                    ),
                    CustomDialogAction(
                      onPressed: () => Navigator.of(context).pop(false),
                      buttonType: ButtonType.secondary,
                      text: loc.cancel,
                    ),
                  ],
                ),
              ).then((confirmed) async {
                if (confirmed! && context.mounted) {
                  await db.matchDao.deleteMatch(matchId: match.id);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  widget.onMatchUpdate.call();
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            ListView(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 20,
                bottom: 100,
              ),
              children: [
                // Controller Icon
                const Center(
                  child: ColoredIconContainer(
                    icon: Icons.sports_esports,
                    containerSize: 55,
                    iconSize: 38,
                  ),
                ),
                const SizedBox(height: 10),

                // Match Name
                Text(
                  match.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CustomTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 5),

                // Creation Date
                Text(
                  '${loc.created_on} ${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(match.createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CustomTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Group Name
                if (match.group != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.group),
                      const SizedBox(width: 8),
                      Text(
                        '${match.group!.name}${getExtraPlayerCount(match)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Teams or Players
                if (useTeamLogic) ...[
                  // Teams or Pairs
                  InfoTile(
                    title: match.isTeamMatch ? loc.teams : loc.players,
                    leadingWidget: Icon(
                      match.isTeamMatch ? Icons.scoreboard : Icons.people,
                    ),
                    horizontalAlignment: CrossAxisAlignment.start,
                    content: match.teams != null && match.teams!.isNotEmpty
                        ? match.isTeamMatch
                              ? Column(
                                  children: (match.teams ?? []).map((team) {
                                    return TeamCard(team: team);
                                  }).toList(),
                                )
                              : Wrap(
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: (match.teams ?? []).map((team) {
                                    if (team.members.length > 1) {
                                      return PairTile(pair: team);
                                    } else {
                                      return PlayerTile(
                                        player: team.members.first,
                                        onTileTap: () => Navigator.of(context)
                                            .pushReplacement(
                                              adaptivePageRoute(
                                                builder: (context) =>
                                                    PlayerDetailView(
                                                      player:
                                                          team.members.first,
                                                      onPlayerNameUpdated:
                                                          widget.onMatchUpdate,
                                                    ),
                                              ),
                                            ),
                                      );
                                    }
                                  }).toList(),
                                )
                        : Text(
                            match.isTeamMatch
                                ? loc.no_teams_available
                                : loc.no_players_available,
                            style: const TextStyle(
                              fontSize: 14,
                              color: CustomTheme.textColor,
                            ),
                          ),
                  ),
                ] else ...[
                  // Players
                  InfoTile(
                    title: loc.players,
                    leadingWidget: const Icon(Icons.people),
                    horizontalAlignment: CrossAxisAlignment.start,
                    content: match.players.isNotEmpty
                        ? Wrap(
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            spacing: 12,
                            runSpacing: 8,
                            children: match.players.map((player) {
                              return PlayerTile(
                                player: player,
                                onTileTap: () {
                                  Navigator.of(context).pushReplacement(
                                    adaptivePageRoute(
                                      builder: (context) => PlayerDetailView(
                                        player: player,
                                        onPlayerNameUpdated:
                                            widget.onMatchUpdate,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          )
                        : Text(
                            loc.no_players_available,
                            style: const TextStyle(
                              fontSize: 14,
                              color: CustomTheme.textColor,
                            ),
                          ),
                  ),
                ],
                const SizedBox(height: 15),

                // Game
                InfoTile(
                  title: loc.game,
                  leadingWidget: const Icon(RpgAwesome.clovers_card),
                  horizontalAlignment: CrossAxisAlignment.start,
                  content: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: GameLabel(
                      title: match.game.name,
                      description: translateRulesetToString(
                        match.game.ruleset,
                        context,
                      ),
                      color: match.game.color,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Results
                InfoTile(
                  title: loc.results,
                  leadingWidget: const Icon(Icons.emoji_events),
                  content: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: getResultWidget(loc),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: MediaQuery.viewPaddingOf(context).bottom,
              child: Row(
                spacing: 8,
                children: [
                  FloatingAnimatedButton(
                    icon: Icons.edit,
                    onPressed: () => editMatchNavigation(loc),
                  ),
                  FloatingAnimatedButton(
                    text: loc.enter_results,
                    icon: Icons.emoji_events,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        adaptivePageRoute(
                          fullscreenDialog: true,
                          builder: (context) => MatchResultView(
                            match: match,
                            onWinnerChanged: () async {
                              widget.onMatchUpdate.call();
                              await updateScoresForCurrentMatch();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns a copy of the current match without the previous match ID and
  /// scores, used as a template for duplicating a match.
  Match get templateMatch => Match(
    name: widget.match.name,
    game: widget.match.game,
    players: widget.match.players,
    group: widget.match.group,
    isTeamMatch: widget.match.isTeamMatch,
    notes: widget.match.notes,
    teams: widget.match.teams
        ?.map((t) => Team(name: t.name, color: t.color, members: t.members))
        .toList(),
  );

  /// Callback for when the match is updated in the edit view,
  /// updates the match in this view
  void onMatchUpdated(Match editedMatch) {
    setState(() {
      match = editedMatch;
    });
    widget.onMatchUpdate.call();
  }

  /// Returns the widget to be displayed in the result [InfoTile]
  Widget getResultWidget(AppLocalizations loc) {
    if (isSingleRowResult()) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: getSingleResultRow(loc),
      );
    } else {
      return getMultiResultRows(loc);
    }
  }

  /// Returns the result row for single winner/loser rulesets or a placeholder
  /// if no result is entered yet
  List<Widget> getSingleResultRow(AppLocalizations loc) {
    final ruleset = match.game.ruleset;

    if (match.mvp.isNotEmpty || match.mvt.isNotEmpty) {
      final label = ruleset == Ruleset.loser ? loc.loser : loc.winners;

      return [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: CustomTheme.textColor),
        ),
        const SizedBox(width: 20),
        Expanded(child: buildWinnerNameWidget()),
      ];
    } else {
      // No result yet
      return [
        Text(
          loc.no_results_entered_yet,
          style: const TextStyle(fontSize: 14, color: CustomTheme.textColor),
        ),
      ];
    }
  }

  /// Builds the widget that displays the winner(s) or loser(s) name(s)
  Widget buildWinnerNameWidget() {
    final mvtTeams = match.mvt;
    final mvpPlayers = match.mvp;

    const winnerStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: CustomTheme.primaryColor,
    );

    if (useTeamLogic) {
      return Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 4,
        children: [
          for (var i = 0; i < mvtTeams.length; i++)
            buildUnitNameWidget(
              mvtTeams[i],
              isTeamMatch: match.isTeamMatch,
              mainStyle: winnerStyle,
            ),
        ],
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < mvpPlayers.length; i++) ...[
            if (i > 0) const TextSpan(text: ', ', style: winnerStyle),
            buildPlayerNameCountSpan(mvpPlayers[i], mainStyle: winnerStyle),
          ],
        ],
      ),
      textAlign: TextAlign.end,
    );
  }

  /// Returns the result widget for scores or placement
  Widget getMultiResultRows(AppLocalizations loc) {
    List<(Widget, int)> scores = getSortedScores();
    bool hasMatchEnded = match.endedAt != null;

    return Column(
      children: [
        for (var i = 0; i < scores.length; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: scores[i].$1),
              hasMatchEnded
                  ? getResultValueText(loc, i, scores[i].$2)
                  : const Text('-'),
            ],
          ),
      ],
    );
  }

  /// Returns a list of player/team widgets and their corresponding scores, sorted by score according to the ruleset
  List<(Widget, int)> getSortedScores() {
    List<(Widget, int)> namedScores = [];

    if (useTeamLogic) {
      final teams = match.teams ?? [];
      for (var team in teams) {
        Widget nameWidget = buildUnitNameWidget(
          team,
          isTeamMatch: match.isTeamMatch,
        );
        namedScores.add((nameWidget, team.score ?? 0));
      }
    } else {
      final scores = match.scores;
      final players = match.players
        ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));
      for (var player in players) {
        int score = scores[player.id]?.score ?? 0;
        namedScores.add((buildUnitNameWidget(player), score));
      }
    }

    final ruleset = match.game.ruleset;
    if (ruleset == Ruleset.highestScore ||
        ruleset == Ruleset.placement ||
        ruleset == Ruleset.lives) {
      namedScores.sort((a, b) => b.$2.compareTo(a.$2));
    } else if (ruleset == Ruleset.lowestScore) {
      namedScores.sort((a, b) => a.$2.compareTo(b.$2));
    }

    return namedScores;
  }

  /// Returns the text widget for the score or placement value, styled according to the ruleset
  Widget getResultValueText(AppLocalizations loc, int index, int score) {
    final ruleset = match.game.ruleset;

    if (ruleset == Ruleset.placement) {
      return Text(
        getPlacementText(context, index + 1),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: getPlacementTextcolor(index),
        ),
      );
    } else if (ruleset == Ruleset.lives) {
      return Text(
        getLifeLabel(loc, score),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: score > 0 ? CustomTheme.primaryColor : CustomTheme.hintColor,
        ),
      );
    } else {
      return Text(
        getPointLabel(loc, score),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: CustomTheme.primaryColor,
        ),
      );
    }
  }

  Color getPlacementTextcolor(int placement) {
    switch (placement) {
      case 0:
        return const Color(0xFFFFBF00);
      case 1:
        return const Color(0xBBFFFFFF);
      case 2:
        return const Color(0xFFCD7F32);
      default:
        return CustomTheme.textColor;
    }
  }

  // Returns if the result can be displayed in a single row
  bool isSingleRowResult() {
    return match.game.ruleset == Ruleset.winner ||
        match.game.ruleset == Ruleset.loser;
  }

  String getPlacementText(BuildContext context, int rank) {
    final loc = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == 'de') {
      return '$rank. ${loc.place}';
    }

    return '${_ordinalEn(rank)} ${loc.place}';
  }

  String _ordinalEn(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }

    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  Future<void> updateScoresForCurrentMatch() async {
    final match = await db.matchDao.getMatchById(matchId: this.match.id);
    setState(() {
      this.match = match;
    });
  }

  bool isConfirmButtonEnabled() => nameController.text.trim().isNotEmpty;

  /// Navigates to the edit match view if the match hasnt ended yet, otherwise
  /// shows a dialog to only edit the name
  void editMatchNavigation(AppLocalizations loc) {
    // Match hasnt ended yet, allow editing
    if (match.endedAt == null) {
      Navigator.push(
        context,
        adaptivePageRoute(
          fullscreenDialog: true,
          builder: (context) => CreateMatchView(
            matchToPrefill: match,
            editMode: true,
            onMatchUpdated: onMatchUpdated,
          ),
        ),
      );
    } else {
      // Match has ended, only allow name change
      nameController.text = match.name;
      showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            return CustomAlertDialog(
              title: loc.edit_name,
              content: TextInputField(
                maxLength: Constants.MAX_MATCH_NAME_LENGTH,
                controller: nameController,
                hintText: loc.set_name,
                onChanged: (_) => setDialogState(() {}),
              ),
              actions: [
                CustomDialogAction(
                  onPressed: isConfirmButtonEnabled()
                      ? () => Navigator.of(context).pop(true)
                      : null,
                  text: loc.confirm,
                ),
                CustomDialogAction(
                  onPressed: () => Navigator.of(context).pop(false),
                  buttonType: ButtonType.secondary,
                  text: loc.cancel,
                ),
              ],
            );
          },
        ),
      ).then((confirmed) async {
        if (confirmed! && context.mounted) {
          final newName = nameController.text.trim();

          if (newName != match.name) {
            await db.matchDao.updateMatchName(matchId: match.id, name: newName);
            onMatchUpdated(match.copyWith(name: newName));
          }
        }
      });
    }
  }
}
