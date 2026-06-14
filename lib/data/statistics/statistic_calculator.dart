import 'dart:math';

import 'package:tallee/data/models/models.dart';

class StatisticCalculator {
  /// Computes the statistic values for a given [Statistic].
  static List<(Player, num)> computeStatisticValues({
    required Statistic statistic,
    required List<Match> matches,
    required List<Player> players,
  }) {
    final filteredMatches = _getFilteredMatches(statistic, matches);
    final filteredPlayers = _getFilteredPlayers(
      statistic,
      players,
      filteredMatches,
    );

    return _computeValuesForType(
      type: statistic.type,
      matches: filteredMatches,
      players: filteredPlayers,
    );
  }

  /// Returns the list of [Match] objects that should be considered for the
  /// statistic based on the statistic's scopes, games, groups and the timeframe.
  static List<Match> _getFilteredMatches(
    Statistic statistic,
    List<Match> matches,
  ) {
    List<Match> filteredMatches = matches;

    // Filter timeframe
    if (statistic.timeframe != Timeframe.allTime) {
      final minDate = _getMinimumDate(timeframe: statistic.timeframe);
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

    // Score-based stats only make sense for rulesets with numeric points.
    if (_isScoreBasedStatistic(statistic.type)) {
      filteredMatches = filteredMatches
          .where((m) => _isScoreBasedRuleset(m.game.ruleset))
          .toList();
    }

    return filteredMatches;
  }

  /// Returns the list of [Player] objects that should be considered for the
  /// statistic based on the statistic's scopes and the filtered matches.
  static List<Player> _getFilteredPlayers(
    Statistic statistic,
    List<Player> allPlayers,
    List<Match> filteredMatches,
  ) {
    List<Player> scopedPlayers;

    // allPlayers
    if (statistic.scopes.contains(StatisticScope.allPlayers)) {
      scopedPlayers = allPlayers;
    } else if (statistic.scopes.contains(StatisticScope.selectedGroups) &&
        (statistic.selectedGroups?.isNotEmpty ?? false)) {
      // selectedGroups -> only members
      final Set<String> ids = {
        for (final g in statistic.selectedGroups!)
          for (final p in g.members) p.id,
      };
      scopedPlayers = allPlayers.where((p) => ids.contains(p.id)).toList();
    } else {
      // Else -> all players from filtered matches
      final Set<String> ids = {
        for (final m in filteredMatches)
          for (final p in m.players) p.id,
      };
      scopedPlayers = allPlayers.where((p) => ids.contains(p.id)).toList();
    }

    if (_isScoreBasedStatistic(statistic.type)) {
      return scopedPlayers
          .where((p) => _hasAnyScore(p, filteredMatches))
          .toList();
    }

    return scopedPlayers;
  }

  /// Returns a [DateTime] with the minimum time and date the [timeframe] allows
  static DateTime? _getMinimumDate({required Timeframe timeframe}) {
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

  /// Determines if the statistic type is based on scores.
  static bool _isScoreBasedStatistic(StatisticType type) {
    switch (type) {
      case StatisticType.totalScore:
      case StatisticType.averageScore:
      case StatisticType.bestScore:
      case StatisticType.worstScore:
        return true;
      case StatisticType.totalMatches:
      case StatisticType.totalWins:
      case StatisticType.totalLosses:
      case StatisticType.winrate:
        return false;
    }
  }

  /// Determines if the ruleset is based on scores.
  static bool _isScoreBasedRuleset(Ruleset ruleset) {
    switch (ruleset) {
      case Ruleset.highestScore:
      case Ruleset.lowestScore:
        return true;
      case Ruleset.singleWinner:
      case Ruleset.multipleWinners:
      case Ruleset.placement:
      case Ruleset.singleLoser:
        return false;
    }
  }

  /// Computes the statistic values for each player based on the statistic type
  /// and returns a list of (Player, value) tuples sorted descending by value.
  static List<(Player, num)> _computeValuesForType({
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
          players.map((p) => (p, _losses(p, matches) as num)).toList(),
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
                ? 0
                : double.parse(
                    (scores.reduce((a, b) => a + b) / scores.length)
                        .toStringAsFixed(2),
                  );
            return (p, avg);
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

  /// Detemerines how many matches contain the given player.
  static int _matchesPlayed(Player p, List<Match> matches) =>
      matches.where((m) => m.players.any((mp) => mp.id == p.id)).length;

  /// Determines how many matches the player is mvp in the given matches.
  static int _wins(Player p, List<Match> matches) =>
      matches.where((m) => m.mvp.any((mp) => mp.id == p.id)).length;

  /// Determines how many times a player is the loser in single-loser matches.
  static int _losses(Player p, List<Match> matches) => matches
      .where((m) => m.game.ruleset == Ruleset.singleLoser)
      .where((m) => m.mvp.any((mp) => mp.id == p.id))
      .length;

  /// Determines the total score of the player in the given list of matches.
  static int _totalScore(Player p, List<Match> matches) {
    var total = 0;
    for (final m in matches) {
      final s = m.scores[p.id];
      if (s != null) total += s.score;
    }
    return total;
  }

  /// Returns a list of all scores the player has achieved in the given list of matches.
  static List<int> _scoresOf(Player p, List<Match> matches) => [
    for (final m in matches)
      if (m.scores[p.id] != null) m.scores[p.id]!.score,
  ];

  /// Returns true if player has at least one score in the given matches.
  static bool _hasAnyScore(Player p, List<Match> matches) =>
      matches.any((m) => m.scores[p.id] != null);

  /// Returns the list of entries sorted descending by the statistic value.
  static List<(Player, num)> _sortDesc(List<(Player, num)> entries) {
    entries.sort((a, b) => b.$2.compareTo(a.$2));
    return entries;
  }
}
