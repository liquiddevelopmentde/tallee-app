import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/views/main_menu/player_detail_view.dart';
import 'package:tallee/presentation/widgets/cards/team_card.dart';
import 'package:tallee/presentation/widgets/game_label.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/pair_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/player_tile.dart';

class MatchTile extends StatefulWidget {
  /// A tile widget that displays information about a match, including its name,
  /// creation date, associated group, winner, and players.
  /// - [match]: The match data to be displayed.
  /// - [onTap]: The callback invoked when the tile is tapped.
  /// - [onPlayerEdited]: The callback invoked when the players are edited.
  /// - [width]: Optional width for the tile.
  const MatchTile({
    super.key,
    required this.match,
    required this.onTap,
    this.onPlayerEdited,
    this.width,
  });

  final Match match;
  final VoidCallback onTap;
  final VoidCallback? onPlayerEdited;
  final double? width;

  @override
  State<MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends State<MatchTile> {
  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final group = match.group;
    final players = [...match.players]
      ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));
    final loc = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap.call();
      },
      child: Container(
        margin: CustomTheme.tileMargin,
        width: widget.width,
        padding: const EdgeInsets.all(12),
        decoration: CustomTheme.standardBoxDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8,
              children: [
                Expanded(
                  child: Text(
                    match.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formatDate(match.createdAt, context),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            // Group Info
            if (group != null) ...[
              Row(
                children: [
                  const Icon(Icons.group, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${match.group!.name}${getExtraPlayerCount(match)}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ] else ...[
              const SizedBox(height: 8),
            ],

            // Game + Ruleset Badge
            GameLabel(
              title: match.game.name,
              description: translateRulesetToString(
                match.game.ruleset,
                context,
              ),
              color: match.game.color,
            ),

            const SizedBox(height: 12),

            Visibility(
              visible: match.endedAt != null,

              // Match in progress display
              replacement: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.watch_later,
                      size: 20,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.match_in_progress,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: CustomTheme.textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              child: Visibility(
                visible: match.useTeamLogic,

                // MVP Display for player matches
                replacement: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      getMvpIcon(),
                      const SizedBox(width: 8),
                      Expanded(child: getMvpTextWidget(loc)),
                    ],
                  ),
                ),

                // MVT Display for team matches
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      getMvpIcon(),
                      const SizedBox(width: 8),
                      Expanded(child: getMvtTextWidget(loc)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (match.teams != null &&
                match.teams!.isNotEmpty &&
                match.isTeamMatch) ...[
              // Team display
              Text(
                loc.teams,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final useSingleColumn = match.teams!.any(
                    (team) => team.name.length > 10,
                  );

                  const spacing = 8.0;
                  final itemWidth = useSingleColumn
                      ? constraints.maxWidth
                      : (constraints.maxWidth - spacing) / 2;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: match.teams!.map((team) {
                      return TeamCard(
                        team: team,
                        compact: true,
                        width: itemWidth,
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 12),
            ] else if (!match.isTeamMatch &&
                (widget.match.teams?.isNotEmpty ?? false)) ...[
              // Player with Pairs display
              Text(
                loc.players,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: match.teams!.map((pair) {
                  if (pair.members.length > 1) {
                    return PairTile(pair: pair);
                  } else {
                    return PlayerTile(
                      player: pair.members.first,
                      onTileTap: () {
                        Navigator.push(
                          context,
                          adaptivePageRoute(
                            builder: (context) => PlayerDetailView(
                              player: pair.members.first,
                              onPlayerNameUpdated: () {
                                widget.onPlayerEdited?.call();
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                }).toList(),
              ),
            ] else if (players.isNotEmpty) ...[
              // Player display
              Text(
                loc.players,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: players.map((player) {
                  return PlayerTile(
                    player: player,
                    onTileTap: () {
                      Navigator.push(
                        context,
                        adaptivePageRoute(
                          builder: (context) => PlayerDetailView(
                            player: player,
                            onPlayerNameUpdated: () {
                              widget.onPlayerEdited?.call();
                            },
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ] else ...[
              Text(
                loc.no_players_available,
                style: const TextStyle(
                  fontSize: 14,
                  color: CustomTheme.hintColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Formats the given [dateTime] into a human-readable string based on its
  /// difference from the current date.
  String formatDate(DateTime dateTime, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final loc = AppLocalizations.of(context);

    if (difference.inDays == 0) {
      return "${loc.today_at} ${DateFormat('HH:mm').format(dateTime)}";
    } else if (difference.inDays == 1) {
      return "${loc.yesterday_at} ${DateFormat('HH:mm').format(dateTime)}";
    } else if (difference.inDays < 7) {
      return loc.days_ago(difference.inDays);
    } else {
      return '${loc.created_on} ${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(dateTime)}';
    }
  }

  // Returns the appropriate text widget based on the match's ruleset and MVP.
  Widget getMvpTextWidget(AppLocalizations loc) {
    if (widget.match.mvp.isEmpty) return const SizedBox.shrink();
    final ruleset = widget.match.game.ruleset;
    final players = widget.match.mvp;

    const labelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: CustomTheme.textColor,
    );

    const nameStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: CustomTheme.textColor,
    );

    final countStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: CustomTheme.textColor.withAlpha(100),
    );

    final namesToRender =
        ruleset == Ruleset.multipleWinners ||
            ruleset == Ruleset.highestScore ||
            ruleset == Ruleset.lowestScore ||
            ruleset == Ruleset.lives
        ? players
        : [players.first];

    final children = <InlineSpan>[];

    for (var i = 0; i < namesToRender.length; i++) {
      children.add(
        buildPlayerNameCountSpan(
          namesToRender[i],
          mainStyle: nameStyle,
          countStyle: countStyle,
        ),
      );

      if (i < namesToRender.length - 1) {
        children.add(const TextSpan(text: ', ', style: labelStyle));
      }
    }

    if (ruleset == Ruleset.highestScore || ruleset == Ruleset.lowestScore) {
      final mvpScore = widget.match.scores[players.first.id]?.score ?? 0;
      children.add(
        TextSpan(text: ' (${getPointLabel(loc, mvpScore)})', style: labelStyle),
      );
    }

    return Text.rich(
      TextSpan(
        style: const TextStyle(color: CustomTheme.textColor),
        children: children,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  // Returns the appropriate text widget based on the match's ruleset and MVT.
  Widget getMvtTextWidget(AppLocalizations loc) {
    if (widget.match.mvt.isEmpty) return const SizedBox.shrink();
    final ruleset = widget.match.game.ruleset;
    final mvt = widget.match.mvt;

    const mainStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: CustomTheme.textColor,
    );

    final countStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: CustomTheme.textColor.withAlpha(100),
    );

    final score =
        (ruleset == Ruleset.highestScore || ruleset == Ruleset.lowestScore)
        ? widget.match.teams!
                  .firstWhere((team) => team.id == mvt.first.id)
                  .score ??
              0
        : null;

    return Text.rich(
      TextSpan(
        style: const TextStyle(color: CustomTheme.textColor),
        children: [
          for (var i = 0; i < mvt.length; i++) ...[
            if (i > 0) const TextSpan(text: ', ', style: mainStyle),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: buildUnitNameWidget(
                mvt[i],
                isTeamMatch: widget.match.isTeamMatch,
                mainStyle: mainStyle,
                countStyle: countStyle,
              ),
            ),
          ],
          if (score != null)
            TextSpan(text: ' (${getPointLabel(loc, score)})', style: mainStyle),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Returns the appropriate icon based on the match's ruleset.
  Icon getMvpIcon() {
    final icon = getRulesetIcon(widget.match.game.ruleset);

    switch (widget.match.game.ruleset) {
      case Ruleset.singleWinner:
      case Ruleset.multipleWinners:
        return Icon(icon, size: 20, color: Colors.amber);
      case Ruleset.singleLoser:
        return Icon(icon, size: 20, color: Colors.blue);
      case Ruleset.lowestScore:
        return Icon(icon, size: 20, color: Colors.orange);
      case Ruleset.highestScore:
        return Icon(icon, size: 20, color: Colors.green);
      case Ruleset.placement:
        return Icon(icon, size: 20, color: Colors.deepOrangeAccent);
      case Ruleset.lives:
        return Icon(icon, size: 20, color: Colors.red);
    }
  }
}
