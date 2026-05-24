import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/presentation/views/main_menu/statistics_view/create_statistic_view.dart'
    show translateStatisticTypeToString;
import 'package:tallee/presentation/widgets/tiles/statistics_tile.dart';

List<Color> _colorPalette = AppColor.values
    .map((c) => getColorFromAppColor(c))
    .toList();

/// Build the [StatisticsTile] for a given [Statistic].
Widget buildStatisticTile({
  required Statistic statistic,
  required List<Match> matches,
  required List<Player> players,
  required BuildContext context,
  double? width,
  int itemCount = 5,
}) {
  final filteredMatches = _getFilterMatches(statistic, matches);
  final filteredPlayers = _getFilteredPlayers(
    statistic,
    players,
    filteredMatches,
  );

  print('Building tile for statistic: $statistic');
  print('Filtered matches count: ${filteredMatches.length}');
  print('Filtered players count: ${filteredPlayers.length}');

  final values = _computeValuesForType(
    type: statistic.type,
    matches: filteredMatches,
    players: filteredPlayers,
  );
  print(values);

  return StatisticsTile(
    icon: _getStatisticIcon(type: statistic.type),
    title: translateStatisticTypeToString(statistic.type, context),
    width: width ?? MediaQuery.sizeOf(context).width * 0.95,
    values: values,
    itemCount: itemCount,
    barColor: _getStatisticColor(statistic),
    statistic: statistic,
  );
}

List<Match> _getFilterMatches(Statistic statistic, List<Match> matches) {
  List<Match> filteredMatches = matches;

  // Filter timeframe
  if (statistic.scopes.contains(StatisticScope.timeframe) &&
      statistic.timeframe != null) {
    final minDate = _getMinimumDate(timeframe: statistic.timeframe!);
    print(
      'Filtering matches by timeframe: ${statistic.timeframe}, minDate: $minDate',
    );
    if (minDate != null) {
      filteredMatches = matches
          .where((m) => m.endedAt != null && m.endedAt!.isAfter(minDate))
          .toList();
    }
  }

  // Filter games
  if (statistic.scopes.contains(StatisticScope.selectedGames) &&
      (statistic.selectedGames?.isNotEmpty ?? false)) {
    final gameIds = statistic.selectedGames!.map((g) => g.id).toSet();
    filteredMatches = filteredMatches
        .where((match) => gameIds.contains(match.game.id))
        .toList();
  }

  // Filter groups
  if (statistic.scopes.contains(StatisticScope.selectedGroups) &&
      (statistic.selectedGroups?.isNotEmpty ?? false)) {
    final groupIds = statistic.selectedGroups!.map((g) => g.id).toSet();
    filteredMatches = filteredMatches
        .where((m) => m.group != null && groupIds.contains(m.group!.id))
        .toList();
  }

  return filteredMatches;
}

/// Returns a [Player] List with the selected players depending on
List<Player> _getFilteredPlayers(
  Statistic statistic,
  List<Player> allPlayers,
  List<Match> filteredMatches,
) {
  // allPlayers
  if (statistic.scopes.contains(StatisticScope.allPlayers)) {
    return allPlayers;
  }

  // selectedGroups -> only members
  if (statistic.scopes.contains(StatisticScope.selectedGroups) &&
      (statistic.selectedGroups?.isNotEmpty ?? false)) {
    final Set<String> ids = {
      for (final g in statistic.selectedGroups!)
        for (final p in g.members) p.id,
    };
    return allPlayers.where((p) => ids.contains(p.id)).toList();
  }

  // Else -> all players from filtered matches
  final Set<String> ids = {
    for (final m in filteredMatches)
      for (final p in m.players) p.id,
  };
  return allPlayers.where((p) => ids.contains(p.id)).toList();
}

/// Returns a [DateTime] with the minimum time and date the [timeframe] allows
DateTime? _getMinimumDate({required Timeframe timeframe}) {
  final now = DateTime.now();
  switch (timeframe) {
    case Timeframe.last7Days:
      return now.subtract(const Duration(days: 7));
    case Timeframe.last30Days:
      return now.subtract(const Duration(days: 30));
    case Timeframe.last90Days:
      return now.subtract(const Duration(days: 90));
    case Timeframe.last180Days:
      return now.subtract(const Duration(days: 180));
    case Timeframe.lastYear:
      return now.subtract(const Duration(days: 365));
    case Timeframe.allTime:
      return null;
  }
}

/// Computes the statistic values for each player based on the statistic type
/// and returns a list of (Player, value) tuples sorted descending by value.
List<(Player, num)> _computeValuesForType({
  required StatisticType type,
  required List<Match> matches,
  required List<Player> players,
}) {
  switch (type) {
    case StatisticType.totalMatches:
      return _sortDesc(
        players.map((p) => (p, _matchesPlayed(p, matches) as num)).toList(),
      );

    case StatisticType.totalWins:
      return _sortDesc(
        players.map((p) => (p, _wins(p, matches) as num)).toList(),
      );

    case StatisticType.totalLosses:
      return _sortDesc(
        players
            .map(
              (p) =>
                  (p, (_matchesPlayed(p, matches) - _wins(p, matches)) as num),
            )
            .toList(),
      );

    case StatisticType.totalScore:
      return _sortDesc(
        players.map((p) => (p, _totalScore(p, matches) as num)).toList(),
      );

    case StatisticType.averageScore:
      return _sortDesc(
        players.map((p) {
          final scores = _scoresOf(p, matches);
          final avg = scores.isEmpty
              ? 0.0
              : double.parse(
                  (scores.reduce((a, b) => a + b) / scores.length)
                      .toStringAsFixed(2),
                );
          return (p, avg as num);
        }).toList(),
      );

    case StatisticType.bestScore:
      return _sortDesc(
        players.map((p) {
          final scores = _scoresOf(p, matches);
          final best = scores.isEmpty ? 0 : scores.reduce(max);
          return (p, best as num);
        }).toList(),
      );

    case StatisticType.worstScore:
      // Ascending here is more meaningful for "worst", but keep the
      // existing tile semantics (largest bar = top entry) by sorting
      // descending on the inverse — i.e. show smallest score on top.
      final entries = players.map((p) {
        final scores = _scoresOf(p, matches);
        final worst = scores.isEmpty ? 0 : scores.reduce(min);
        return (p, worst as num);
      }).toList();
      entries.sort((a, b) => a.$2.compareTo(b.$2));
      return entries;

    case StatisticType.winrate:
      return _sortDesc(
        players.map((p) {
          final played = _matchesPlayed(p, matches);
          final wins = _wins(p, matches);
          final rate = played == 0
              ? 0.0
              : double.parse((wins / played).toStringAsFixed(2));
          return (p, rate as num);
        }).toList(),
      );
  }
}

/* Helper functions for different statistic types */

/// Detemerines how many matches the player has played in the given list of matches.
int _matchesPlayed(Player p, List<Match> matches) =>
    matches.where((m) => m.players.any((mp) => mp.id == p.id)).length;

/// Determines how many matches the player has won in the given list of matches.
int _wins(Player p, List<Match> matches) =>
    matches.where((m) => m.mvp.any((mp) => mp.id == p.id)).length;

/// Determines the total score of the player in the given list of matches.
int _totalScore(Player p, List<Match> matches) {
  var total = 0;
  for (final m in matches) {
    final s = m.scores[p.id];
    if (s != null) total += s.score;
  }
  return total;
}

/// Returns a list of all scores the player has achieved in the given list of matches.
List<int> _scoresOf(Player p, List<Match> matches) => [
  for (final m in matches)
    if (m.scores[p.id] != null) m.scores[p.id]!.score,
];

/// Returns the list of entries sorted descending by the statistic value.
List<(Player, num)> _sortDesc(List<(Player, num)> entries) {
  entries.sort((a, b) => b.$2.compareTo(a.$2));
  return entries;
}

/* Icon and color */

/// Returns the icon for the given statistic type.
IconData _getStatisticIcon({required StatisticType type}) {
  switch (type) {
    case StatisticType.totalMatches:
      return Icons.casino;
    case StatisticType.totalWins:
      return Icons.emoji_events;
    case StatisticType.totalLosses:
      return Icons.sentiment_dissatisfied;
    case StatisticType.totalScore:
      return Icons.scoreboard;
    case StatisticType.averageScore:
      return Icons.show_chart;
    case StatisticType.bestScore:
      return Icons.trending_up;
    case StatisticType.worstScore:
      return Icons.trending_down;
    case StatisticType.winrate:
      return Icons.percent;
  }
}

/// Returns a color from the palette based on the statistic's ID as random seed.
Color _getStatisticColor(Statistic stat) {
  final seed = stat.id.hashCode;
  return _colorPalette[seed.abs() % _colorPalette.length];
}

/* Skeleton data */

/// A placeholder tile with mock data for the loading state.
Widget buildSkeletonStatisticTile({required BuildContext context}) {
  final count = 4 + Random().nextInt(5); // 4..8
  final values = <(Player, num)>[
    for (var i = 0; i < count; i++)
      (Player(name: 'Player ${i + 1}'), count - i),
  ];

  return StatisticsTile(
    icon: Icons.bar_chart,
    title: 'Skeleton title',
    width: MediaQuery.sizeOf(context).width * 0.95,
    values: values,
    itemCount: count,
    barColor: _colorPalette[Random().nextInt(_colorPalette.length)],
    statistic: Statistic(
      type: StatisticType.totalMatches,
      scopes: [StatisticScope.allPlayers],
      timeframe: Timeframe.last7Days,
    ),
  );
}
