import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/constants/icon_constants.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/utils/navigation/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_receive/data_association/associate_game_view.dart';
import 'package:tallee/presentation/widgets/buttons/bottom_animated_button.dart';
import 'package:tallee/presentation/widgets/cards/team_card.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/presentation/widgets/game_label.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile/info_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/pair_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/player_tile.dart';

class PreviewMatchView extends StatefulWidget {
  const PreviewMatchView({super.key, required this.match});

  final Match match;

  @override
  State<PreviewMatchView> createState() => _PreviewMatchViewState();
}

class _PreviewMatchViewState extends State<PreviewMatchView> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Preview Match"), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 20),
                children: [
                  // Icon
                  const Center(
                    child: ColoredIconContainer(
                      icon: MATCH_ICON,
                      containerSize: 55,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Match Name
                  Text(
                    widget.match.name,
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
                    '${loc.created_on} ${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(widget.match.createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CustomTheme.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Group Name
                  if (widget.match.group != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(GROUP_ICON),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.match.group!.name}${getExtraPlayerCount(widget.match)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 15),

                  // Teams or Players
                  if (widget.match.useTeamLogic) ...[
                    // Teams or Pairs
                    InfoTile(
                      title: widget.match.isTeamMatch ? loc.teams : loc.players,
                      leadingWidget: Icon(
                        widget.match.isTeamMatch
                            ? Icons.scoreboard
                            : Icons.people,
                      ),
                      horizontalAlignment: CrossAxisAlignment.start,
                      content:
                          widget.match.teams != null &&
                              widget.match.teams!.isNotEmpty
                          ? widget.match.isTeamMatch
                                ? Column(
                                    children: (widget.match.teams ?? []).map((
                                      team,
                                    ) {
                                      return TeamCard(team: team);
                                    }).toList(),
                                  )
                                : Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: (widget.match.teams ?? []).map((
                                      team,
                                    ) {
                                      if (team.members.length > 1) {
                                        return PairTile(pair: team);
                                      } else {
                                        return PlayerTile(
                                          player: team.members.first,
                                        );
                                      }
                                    }).toList(),
                                  )
                          : Text(
                              widget.match.isTeamMatch
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
                      content: widget.match.players.isNotEmpty
                          ? Wrap(
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              spacing: 12,
                              runSpacing: 8,
                              children: widget.match.players.map((player) {
                                return PlayerTile(player: player);
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
                    leadingWidget: const Icon(GAME_ICON),
                    horizontalAlignment: CrossAxisAlignment.start,
                    content: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: GameLabel(
                        title: widget.match.game.name,
                        description: translateRulesetToString(
                          widget.match.game.ruleset,
                          context,
                        ),
                        color: widget.match.game.color,
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

                  const SizedBox(height: 15),

                  // Additional Players in the Group
                  InfoTile(
                    title: loc.group_members,
                    leadingWidget: const Icon(GROUP_ICON),
                    horizontalAlignment: CrossAxisAlignment.start,
                    content: widget.match.players.isNotEmpty
                        ? Wrap(
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            spacing: 12,
                            runSpacing: 8,
                            children: widget.match.players.map((player) {
                              return PlayerTile(player: player);
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
              ),
            ),
            BottomAnimatedButton(
              buttonText: "Confirm",
              sizeRelativeToWidth: 0.95,
              onPressed: () async {
                await Navigator.of(context).push(
                  adaptivePageRoute(
                    builder: (context) =>
                        AssociateGameView(match: widget.match),
                  ),
                );
              },
            ),
            BottomAnimatedButton(
              buttonText: "Cancel",
              sizeRelativeToWidth: 0.95,
              buttonType: ButtonType.secondary,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
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
    final ruleset = widget.match.game.ruleset;

    if (widget.match.mvp.isNotEmpty || widget.match.mvt.isNotEmpty) {
      final label = ruleset == Ruleset.loser ? loc.loser : loc.winner;

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
    final mvtTeams = widget.match.mvt;
    final mvpPlayers = widget.match.mvp;

    const winnerStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: CustomTheme.primaryColor,
    );

    if (widget.match.useTeamLogic) {
      return Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 4,
        children: [
          for (var i = 0; i < mvtTeams.length; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildUnitNameWidget(
                  mvtTeams[i],
                  isTeamMatch: widget.match.isTeamMatch,
                  mainStyle: winnerStyle,
                ),
                if (i != mvtTeams.length - 1) const Text(','),
              ],
            ),
        ],
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < mvpPlayers.length; i++) ...[
            if (i > 0) const TextSpan(text: ', '),
            buildPlayerNameCountSpan(mvpPlayers[i], mainStyle: winnerStyle),
          ],
        ],
      ),
      textAlign: TextAlign.end,
      overflow: TextOverflow.visible,
    );
  }

  /// Returns the result widget for scores or placement
  Widget getMultiResultRows(AppLocalizations loc) {
    List<(Widget, int)> scores = getSortedScores();
    bool hasMatchEnded = widget.match.endedAt != null;

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

    if (widget.match.useTeamLogic) {
      final teams = widget.match.teams ?? [];
      for (var team in teams) {
        Widget nameWidget = buildUnitNameWidget(
          team,
          isTeamMatch: widget.match.isTeamMatch,
          countStyle: const TextStyle(color: CustomTheme.hintColor),
        );
        namedScores.add((nameWidget, team.score ?? 0));
      }
    } else {
      final scores = widget.match.scores;
      final players = widget.match.players
        ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));
      for (var player in players) {
        int score = scores[player.id]?.score ?? 0;
        namedScores.add((
          buildUnitNameWidget(
            player,
            countStyle: const TextStyle(color: CustomTheme.hintColor),
          ),
          score,
        ));
      }
    }

    final ruleset = widget.match.game.ruleset;
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
    final ruleset = widget.match.game.ruleset;

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
    return widget.match.game.ruleset == Ruleset.winner ||
        widget.match.game.ruleset == Ruleset.loser;
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
}
