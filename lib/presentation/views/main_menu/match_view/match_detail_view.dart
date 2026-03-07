import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/adaptive_page_route.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/dto/match.dart';
import 'package:tallee/data/dto/player.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/create_match/create_match_view.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result_view.dart';
import 'package:tallee/presentation/widgets/buttons/animated_dialog_button.dart';
import 'package:tallee/presentation/widgets/buttons/main_menu_button.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/presentation/widgets/custom_alert_dialog.dart';
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

  late Player? currentWinner;

  late Match match;

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    currentWinner = widget.match.winner;
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
                  content: loc.this_cannot_be_undone,
                  actions: [
                    AnimatedDialogButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        loc.cancel,
                        style: const TextStyle(color: CustomTheme.textColor),
                      ),
                    ),
                    AnimatedDialogButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        loc.delete,
                        style: const TextStyle(
                          color: CustomTheme.secondaryColor,
                        ),
                      ),
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
                const Center(
                  child: ColoredIconContainer(
                    icon: Icons.sports_esports,
                    containerSize: 55,
                    iconSize: 38,
                  ),
                ),
                const SizedBox(height: 10),
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
                Text(
                  '${loc.created_on} ${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(match.createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CustomTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                if (match.group != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.group),
                      const SizedBox(width: 8),
                      Text(
                        // TODO: Update after DB changes
                        '${match.group!.name}${getExtraPlayerCount(match)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
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
                        iconEnabled: false,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 15),
                InfoTile(
                  title: loc.results,
                  icon: Icons.emoji_events,
                  content: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// TODO: Implement different ruleset results display
                        if (currentWinner != null) ...[
                          Text(
                            loc.winner,
                            style: const TextStyle(
                              fontSize: 16,
                              color: CustomTheme.textColor,
                            ),
                          ),
                          Text(
                            currentWinner!.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: match.winner != null
                                  ? CustomTheme.primaryColor
                                  : CustomTheme.textColor,
                            ),
                          ),
                        ] else ...[
                          Text(
                            loc.no_results_entered_yet,
                            style: const TextStyle(
                              fontSize: 14,
                              color: CustomTheme.textColor,
                            ),
                          ),
                        ],
                      ],
                    ),
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
                          match: match,
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
                      currentWinner = await Navigator.push(
                        context,
                        adaptivePageRoute(
                          fullscreenDialog: true,
                          builder: (context) => MatchResultView(
                            match: match,
                            onWinnerChanged: () {
                              widget.onMatchUpdate.call();
                              setState(() {});
                            },
                          ),
                        ),
                      );
                      match.winner = currentWinner;
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
}
