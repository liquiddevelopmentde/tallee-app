import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_match_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result_view.dart';
import 'package:tallee/presentation/widgets/buttons/main_menu_button.dart';
import 'package:tallee/presentation/widgets/cards/team_card.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/presentation/widgets/dialog/custom_alert_dialog.dart';
import 'package:tallee/presentation/widgets/dialog/custom_dialog_action.dart';
import 'package:tallee/presentation/widgets/game_label.dart';
import 'package:tallee/presentation/widgets/tiles/info_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile.dart';

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

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    match = widget.match;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        title: Text(loc.match_profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              showDialog<bool>(
                context: context,
                builder: (context) => CustomAlertDialog(
                  title: '${loc.delete_match}?',
                  content: Text(loc.this_cannot_be_undone),
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
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: CustomTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
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

                if (match.isTeamMatch) ...[
                  // Teams
                  InfoTile(
                    title: loc.teams,
                    icon: Icons.scoreboard,
                    horizontalAlignment: CrossAxisAlignment.start,
                    content: Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      spacing: 12,
                      runSpacing: 8,
                      children: match.teams!.map((team) {
                        return TeamCard(team: team);
                      }).toList(),
                    ),
                  ),
                ] else ...[
                  // Players
                  InfoTile(
                    title: loc.players,
                    icon: Icons.people,
                    horizontalAlignment: CrossAxisAlignment.start,
                    content: Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      spacing: 12,
                      runSpacing: 8,
                      children: match.players.map((player) {
                        return TextIconTile(
                          text: player.name,
                          suffixText: getNameCountText(player),
                          iconEnabled: false,
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 15),

                // Game
                InfoTile(
                  title: loc.game,
                  icon: RpgAwesome.clovers_card,
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
                  icon: Icons.emoji_events,
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
              bottom: MediaQuery.paddingOf(context).bottom,
              child: Row(
                children: [
                  MainMenuButton(
                    icon: Icons.edit,
                    onPressed: () => Navigator.push(
                      context,
                      adaptivePageRoute(
                        fullscreenDialog: true,
                        builder: (context) => CreateMatchView(
                          matchToEdit: match,
                          onMatchUpdated: onMatchUpdated,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  MainMenuButton(
                    text: loc.enter_results,
                    icon: Icons.emoji_events,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        adaptivePageRoute(
                          fullscreenDialog: true,
                          builder: (context) => MatchResultView(
                            match: match,
                            onWinnerChanged: () {
                              widget.onMatchUpdate.call();
                              setState(() {
                                updateScoresForCurrentMatch();
                              });
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
    // Single Winner
    if (match.mvp.isNotEmpty && match.game.ruleset == Ruleset.singleWinner) {
      return [
        Text(
          loc.winner,
          style: const TextStyle(fontSize: 16, color: CustomTheme.textColor),
        ),
        Text(
          match.mvp.first.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CustomTheme.primaryColor,
          ),
        ),
      ];
      // Single Loser
    } else if (match.game.ruleset == Ruleset.singleLoser) {
      return [
        Text(
          loc.loser,
          style: const TextStyle(fontSize: 16, color: CustomTheme.textColor),
        ),
        Text(
          match.mvp.first.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CustomTheme.primaryColor,
          ),
        ),
      ];
      // No result entered yet
    } else {
      return [
        Text(
          loc.no_results_entered_yet,
          style: const TextStyle(fontSize: 14, color: CustomTheme.textColor),
        ),
      ];
    }
  }

  /// Returns the result widget for scores or placement
  Widget getMultiResultRows(AppLocalizations loc) {
    List<(String, int)> playerScores = [];
    for (var player in match.players) {
      int score = match.scores[player.id]?.score ?? 0;
      playerScores.add((player.name, score));
    }

    final ruleset = match.game.ruleset;

    if (ruleset == Ruleset.highestScore || ruleset == Ruleset.placement) {
      playerScores.sort((a, b) => b.$2.compareTo(a.$2));
    } else if (ruleset == Ruleset.lowestScore) {
      playerScores.sort((a, b) => a.$2.compareTo(b.$2));
    }

    return Column(
      children: [
        for (var i = 0; i < playerScores.length; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                playerScores[i].$1,
                style: const TextStyle(
                  fontSize: 16,
                  color: CustomTheme.textColor,
                ),
              ),
              getResultValueText(loc, i, playerScores[i].$2),
            ],
          ),
      ],
    );
  }

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
    return match.game.ruleset == Ruleset.singleWinner ||
        match.game.ruleset == Ruleset.singleLoser;
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

  void updateScoresForCurrentMatch() {
    db.scoreEntryDao
        .getAllMatchScores(matchId: match.id)
        .then((scores) => match.scores = scores);
  }
}
