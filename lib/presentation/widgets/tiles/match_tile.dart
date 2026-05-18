import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/cards/team_card.dart';
import 'package:tallee/presentation/widgets/game_label.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile.dart';

class MatchTile extends StatefulWidget {
  /// A tile widget that displays information about a match, including its name,
  /// creation date, associated group, winner, and players.
  /// - [match]: The match data to be displayed.
  /// - [onTap]: The callback invoked when the tile is tapped.
  /// - [width]: Optional width for the tile.
  /// - [compact]: Whether to display the tile in a compact mode
  const MatchTile({
    super.key,
    required this.match,
    required this.onTap,
    this.width,
    this.compact = false,
  });

  /// The match data to be displayed.
  final Match match;

  /// The callback invoked when the tile is tapped.
  final VoidCallback onTap;

  /// Optional width for the tile.
  final double? width;

  /// Whether to display the tile in a compact mode
  final bool compact;

  @override
  State<MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends State<MatchTile> {
  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final group = match.group;
    final players = [...match.players]
      ..sort((a, b) => a.name.compareTo(b.name));
    final loc = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () async {
        await HapticFeedback.selectionClick();
        widget.onTap.call();
      },
      child: Container(
        margin: EdgeInsets.zero,
        width: widget.width,
        padding: const EdgeInsets.all(12),
        decoration: CustomTheme.standardBoxDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    match.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatDate(match.createdAt, context),
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
            ] else if (widget.compact) ...[
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${match.players.length} ${loc.players}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ] else ...[
              const SizedBox(height: 8),
            ],

            // Game + Ruleset Badge
            if (!widget.compact)
              GameLabel(
                title: match.game.name,
                description: translateRulesetToString(
                  match.game.ruleset,
                  context,
                ),
                color: match.game.color,
              ),

            const SizedBox(height: 12),

            // Winner / In Progress Info
            if (match.isTeamMatch && match.mvt.isNotEmpty) ...[
              Container(
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
                    Expanded(
                      child: Text(
                        getMvtText(loc),
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
              const SizedBox(height: 12),
            ] else if (match.mvp.isNotEmpty) ...[
              Container(
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
                    Expanded(
                      child: Text(
                        getMvpText(loc),
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
              const SizedBox(height: 12),
            ] else ...[
              Container(
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
              const SizedBox(height: 12),
            ],

            if (match.teams != null && match.teams!.isNotEmpty) ...[
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
                    (team) => team.name.length > 14,
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
            ] else if (players.isNotEmpty && widget.compact == false) ...[
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
                  return TextIconTile(
                    text: player.name,
                    suffixText: getNameCountText(player),
                    iconEnabled: false,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Formats the given [dateTime] into a human-readable string based on its
  /// difference from the current date.
  String _formatDate(DateTime dateTime, BuildContext context) {
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

  String getMvpText(AppLocalizations loc) {
    if (widget.match.mvp.isEmpty) return '';
    final ruleset = widget.match.game.ruleset;

    if (ruleset == Ruleset.singleWinner) {
      return '${loc.winner}: ${widget.match.mvp.first.name}';
    } else if (ruleset == Ruleset.singleLoser) {
      return '${loc.loser}: ${widget.match.mvp.first.name}';
    } else if (ruleset == Ruleset.highestScore ||
        ruleset == Ruleset.lowestScore) {
      final mvp = widget.match.mvp;
      final mvpScore = widget.match.scores[mvp.first.id]?.score ?? 0;
      final mvpNames = mvp.map((player) => player.name).join(', ');
      return '${loc.winner}: $mvpNames (${getPointLabel(loc, mvpScore)})';
    } else if (ruleset == Ruleset.placement) {
      return '${loc.winner}: ${widget.match.mvp.first.name}';
    } else if (ruleset == Ruleset.multipleWinners) {
      final mvpNames = widget.match.mvp.map((player) => player.name).join(', ');
      return '${loc.winners}: $mvpNames';
    }
    return '${loc.winner}: n.A.';
  }

  String getMvtText(AppLocalizations loc) {
    if (widget.match.mvt.isEmpty) return '';
    final ruleset = widget.match.game.ruleset;

    switch (ruleset) {
      case Ruleset.singleWinner:
        return '${loc.winner}: ${widget.match.mvt.first.name}';
      case Ruleset.singleLoser:
        return '${loc.loser}: ${widget.match.mvt.first.name}';
      case Ruleset.highestScore:
      case Ruleset.lowestScore:
        final mvt = widget.match.mvt;
        final mvtScore =
            widget.match.teams!
                .firstWhere((team) => team.id == mvt.first.id)
                .score ??
            0;
        final mvtNames = mvt.map((team) => team.name).join(', ');
        return '${loc.winner}: $mvtNames (${getPointLabel(loc, mvtScore)})';
      case Ruleset.placement:
        return '${loc.winner}: ${widget.match.mvt.first.name}';
      case Ruleset.multipleWinners:
        final mvtNames = widget.match.mvt.map((team) => team.name).join(', ');
        return '${loc.winners}: $mvtNames';
    }
  }

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
    }
  }
}
