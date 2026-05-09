import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
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
      onTap: widget.onTap,
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
              IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Game
                    Container(
                      decoration: BoxDecoration(
                        color: CustomTheme.primaryColor.withAlpha(230),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Text(
                        match.game.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Ruleset
                    Container(
                      decoration: BoxDecoration(
                        color: CustomTheme.primaryColor.withAlpha(140),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Text(
                        translateRulesetToString(match.game.ruleset, context),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Winner / In Progress Info
            if (match.mvp.isNotEmpty) ...[
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

            // Players List
            if (players.isNotEmpty && widget.compact == false) ...[
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
    }
    return '${loc.winner}: n.A.';
  }

  Icon getMvpIcon() {
    const Icon(Icons.emoji_events, size: 20, color: Colors.amber);

    switch (widget.match.game.ruleset) {
      case Ruleset.singleWinner:
        return const Icon(Icons.emoji_events, size: 20, color: Colors.amber);
      case Ruleset.singleLoser:
        return const Icon(
          Icons.sentiment_dissatisfied_outlined,
          size: 20,
          color: Colors.blue,
        );
      case Ruleset.lowestScore:
        return const Icon(Icons.arrow_downward, size: 20, color: Colors.orange);
      case Ruleset.highestScore:
        return const Icon(Icons.arrow_upward, size: 20, color: Colors.green);
      default:
        return const Icon(Icons.emoji_events, size: 20, color: Colors.amber);
    }
  }
}
