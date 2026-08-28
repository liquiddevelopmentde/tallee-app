import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/adaptive_page_route.dart';
import 'package:tallee/presentation/views/main_menu/player_detail_view.dart';
import 'package:tallee/presentation/widgets/cards/team_card.dart';
import 'package:tallee/presentation/widgets/colored_icon_container.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/pair_tile.dart';
import 'package:tallee/presentation/widgets/tiles/text_icon_tile/player_tile.dart';

/// A modern list tile for a match, used for both running and finished matches.
///
/// Follows the card style used across statistics/settings views: a leading
/// colored icon container, the match name with its date below, a trailing
/// chevron, and the game, group and participants as content. Winners are
/// listed first with a crown and a golden badge background.
class MatchTile extends StatelessWidget {
  const MatchTile({
    super.key,
    required this.match,
    required this.onTap,
    this.onPlayerEdited,
    this.width,
  });

  /// Golden yellow used to highlight winners.
  /// Muted golden yellow used to highlight winners, in the same family as the
  /// silver/bronze podium accents.
  static const Color _winnerGold = Color(0xFFD4A017);

  final Match match;
  final VoidCallback onTap;
  final VoidCallback? onPlayerEdited;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () async {
        await HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        margin: CustomTheme.tileMargin,
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: CustomTheme.standardBoxDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ColoredIconContainer(
                  icon: getRulesetIcon(match.game.ruleset),
                  color: getColorFromAppColor(match.game.color),
                  containerSize: 44,
                  iconSize: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${match.game.name} · ${translateRulesetToString(match.game.ruleset, context)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: CustomTheme.hintColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatDate(match.createdAt, context),
                      style: const TextStyle(
                        fontSize: 12,
                        color: CustomTheme.hintColor,
                      ),
                    ),
                      if (match.group != null) ...[
                        const SizedBox(height: 2),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: Text(
                            '${match.group!.name}${getExtraPlayerCount(match)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: CustomTheme.hintColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: CustomTheme.hintColor,
                ),
              ],
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
                  const spacing = 8.0;

                  // Chrome a compact TeamCard adds around the name: padding,
                  // divider, member-count icon and number.
                  const cardChrome = 80.0;
                  final maxNameWidth = match.teams!.fold<double>(
                    0,
                    (max, team) {
                      final painter = TextPainter(
                        text: TextSpan(
                          text: team.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        maxLines: 1,
                        textDirection: Directionality.of(context),
                      )..layout();
                      return painter.width > max ? painter.width : max;
                    },
                  );

                  // Show the teams side by side when the widest name fits.
                  final fitsSideBySide =
                      2 * (maxNameWidth + cardChrome) + spacing <=
                      constraints.maxWidth;
                  final itemWidth = fitsSideBySide
                      ? (constraints.maxWidth - spacing) / 2
                      : constraints.maxWidth;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: orderedTeams.map((entry) {
                      return TeamCard(
                        team: entry.team,
                        compact: true,
                        subtle: true,
                        width: itemWidth,
                        leading: entry.leading,
                        backgroundColor: entry.badge,
                        borderColor: entry.bordered ? entry.accent : null,
                        nameColor: entry.bordered ? entry.accent : null,
                      );
                    }).toList(),
                  );
                },
              ),
            ] else if (!match.isTeamMatch &&
                (match.teams?.isNotEmpty ?? false)) ...[
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
                children: orderedPairs.map((entry) {
                  if (entry.pair.members.length > 1) {
                    return PairTile(
                      pair: entry.pair,
                      leading: entry.leading,
                      backgroundColor: entry.badge,
                      borderColor: entry.bordered ? entry.accent : null,
                      nameColor: entry.bordered ? entry.accent : null,
                    );
                  } else {
                    return PlayerTile(
                      player: entry.pair.members.first,
                      leading: entry.leading,
                      backgroundColor: entry.badge,
                      borderColor: entry.bordered ? entry.accent : null,
                      nameColor: entry.bordered ? entry.accent : null,
                      onTileTap: () =>
                          openPlayerDetail(context, entry.pair.members.first),
                    );
                  }
                }).toList(),
              ),
            ] else if (match.players.isNotEmpty) ...[
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
                children: orderedPlayers.map((entry) {
                  return PlayerTile(
                    player: entry.player,
                    leading: entry.leading,
                    backgroundColor: entry.badge,
                    borderColor: entry.bordered ? entry.accent : null,
                    nameColor: entry.bordered ? entry.accent : null,
                    onTileTap: () => openPlayerDetail(context, entry.player),
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

  void openPlayerDetail(BuildContext context, Player player) {
    Navigator.push(
      context,
      adaptivePageRoute(
        builder: (context) => PlayerDetailView(
          player: player,
          onPlayerNameUpdated: () => onPlayerEdited?.call(),
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
      return DateFormat.yMMMd(
        Localizations.localeOf(context).toString(),
      ).format(dateTime);
    }
  }

// Podium accent + badge + border for a placement rank (0 = first place).
  ({Color? accent, Color? badge, bool bordered, Widget? leading}) _podium(
    int rank,
  ) {
    switch (rank) {
      case 0:
        return (
          accent: _winnerGold,
          badge: _winnerGold.withAlpha(45),
          bordered: true,
          leading: const FaIcon(
            FontAwesomeIcons.crown,
            size: 12,
            color: _winnerGold,
          ),
        );
      case 1:
        const silver = Color(0xFFC0C0C0);
        return (
          accent: silver,
          badge: silver.withAlpha(15),
          bordered: true,
          leading: const Icon(RpgAwesome.podium, size: 12, color: silver),
        );
      case 2:
        const bronze = Color(0xFFCD7F32);
        return (
          accent: bronze,
          badge: bronze.withAlpha(15),
          bordered: true,
          leading: const Icon(RpgAwesome.podium, size: 12, color: bronze),
        );
      default:
        return (accent: null, badge: null, bordered: false, leading: null);
    }
  }

  // Players ordered with winners first, each with an optional winner badge.
  List<
    ({Player player, Color? accent, Color? badge, bool bordered, Widget? leading})
  >
  get orderedPlayers {
    final players = [...match.players]
      ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));

    if (match.game.ruleset == Ruleset.placement) {
      final sorted = [...players]
        ..sort(
          (a, b) =>
              (match.scores[b.id]?.score ?? 0).compareTo(
                match.scores[a.id]?.score ?? 0,
              ),
        );
      final entries =
          <
            ({
              Player player,
              Color? accent,
              Color? badge,
              bool bordered,
              Widget? leading,
            })
          >[];
      for (var i = 0; i < sorted.length; i++) {
        final podium = _podium(i);
        entries.add((
          player: sorted[i],
          accent: podium.accent,
          badge: podium.badge,
          bordered: podium.bordered,
          leading: podium.leading,
        ));
      }
      return entries;
    }

    final winnerIds = match.mvp.map((p) => p.id).toSet();
    final ordered = [
      ...match.mvp,
      ...players.where((p) => !winnerIds.contains(p.id)),
    ];
    return [
      for (final player in ordered)
        (
          player: player,
          accent: winnerIds.contains(player.id) ? _winnerGold : null,
          badge: winnerIds.contains(player.id)
              ? _winnerGold.withAlpha(45)
              : null,
          bordered: winnerIds.contains(player.id),
          leading: winnerIds.contains(player.id)
              ? const FaIcon(
                  FontAwesomeIcons.crown,
                  size: 12,
                  color: _winnerGold,
                )
              : null,
        ),
    ];
  }

  // Teams ordered with winners first, each with an optional winner badge.
  List<
    ({Team team, Color? accent, Color? badge, bool bordered, Widget? leading})
  >
  get orderedTeams {
    final teams = match.teams ?? [];

    if (match.game.ruleset == Ruleset.placement) {
      final sorted = [...teams]
        ..sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));
      final entries =
          <
            ({
              Team team,
              Color? accent,
              Color? badge,
              bool bordered,
              Widget? leading,
            })
          >[];
      for (var i = 0; i < sorted.length; i++) {
        final podium = _podium(i);
        entries.add((
          team: sorted[i],
          accent: podium.accent,
          badge: podium.badge,
          bordered: podium.bordered,
          leading: podium.leading,
        ));
      }
      return entries;
    }

    final winnerIds = match.mvt.map((t) => t.id).toSet();
    final ordered = [
      ...match.mvt,
      ...teams.where((t) => !winnerIds.contains(t.id)),
    ];
    return [
      for (final team in ordered)
        (
          team: team,
          accent: winnerIds.contains(team.id) ? _winnerGold : null,
          badge: winnerIds.contains(team.id)
              ? _winnerGold.withAlpha(45)
              : null,
          bordered: winnerIds.contains(team.id),
          leading: winnerIds.contains(team.id)
              ? const FaIcon(
                  FontAwesomeIcons.crown,
                  size: 12,
                  color: _winnerGold,
                )
              : null,
        ),
    ];
  }

  // Pairs ordered with winner-containing pairs first, optionally colored.
  List<
    ({Team pair, Color? accent, Color? badge, bool bordered, Widget? leading})
  >
  get orderedPairs {
    final winnerIds = match.mvp.map((p) => p.id).toSet();
    final pairs = [...(match.teams ?? [])]..sort((a, b) {
      final aWins = a.members.any((m) => winnerIds.contains(m.id));
      final bWins = b.members.any((m) => winnerIds.contains(m.id));
      if (aWins != bWins) return aWins ? -1 : 1;
      return 0;
    });
    return [
      for (final pair in pairs)
        (
          pair: pair,
          accent: pair.members.any((m) => winnerIds.contains(m.id))
              ? _winnerGold
              : null,
          badge: pair.members.any((m) => winnerIds.contains(m.id))
              ? _winnerGold.withAlpha(45)
              : null,
          bordered: pair.members.any((m) => winnerIds.contains(m.id)),
          leading: pair.members.any((m) => winnerIds.contains(m.id))
              ? const FaIcon(
                  FontAwesomeIcons.crown,
                  size: 12,
                  color: _winnerGold,
                )
              : null,
        ),
    ];
  }
}