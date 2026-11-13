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

    final values = _computeValuesForType(
      type: statistic.type,
      matches: filteredMatches,
      players: filteredPlayers,
    );
    sortValues(values, statistic.sortDirection);
    return values;
  }

  /// Sorts [entries] in place by their value according to [sortDirection].
  ///
  /// Ties are broken by player name and id so the order stays stable between
  /// rebuilds.
  static void sortValues(
    List<(Player, num)> entries,
    SortDirection sortDirection,
  ) {
    entries.sort((a, b) {
      final byValue = sortDirection == SortDirection.ascending
          ? a.$2.compareTo(b.$2)
          : b.$2.compareTo(a.$2);
      if (byValue != 0) return byValue;

      final byName = a.$1.name.compareTo(b.$1.name);
      return byName != 0 ? byName : a.$1.id.compareTo(b.$1.id);
    });
  }

  /// Returns the list of [Match] objects that should be considered for the
  /// statistic based on the statistic's scopes, games, groups and the timeframe.
  static List<Match> _getFilteredMatches(
    Statistic statistic,
    List<Match> matches,
  ) {
    // Unfinished matches are not results yet, so ignore them.
    List<Match> filteredMatches = matches
        .where((m) => m.endedAt != null)
        .toList();

    // Filter timeframe
    if (statistic.timeframe == Timeframe.custom) {
      if (statistic.startDate != null && statistic.endDate != null) {
        final startOfDay = DateTime(
          statistic.startDate!.year,
          statistic.startDate!.month,
          statistic.startDate!.day,
        );
        final endOfDay = DateTime(
          statistic.endDate!.year,
          statistic.endDate!.month,
          statistic.endDate!.day,
          23,
          59,
          59,
        );
        filteredMatches = matches.where((m) {
          if (!m.hasEnded) return false;
          final isAfterOrAtStart =
              m.createdAt.isAtSameMomentAs(startOfDay) ||
              m.createdAt.isAfter(startOfDay);
          final isBeforeOrAtEnd =
              m.createdAt.isAtSameMomentAs(endOfDay) ||
              m.createdAt.isBefore(endOfDay);
          return isAfterOrAtStart && isBeforeOrAtEnd;
        }).toList();
      }
    } else if (statistic.timeframe != Timeframe.allTime) {
      final minDate = _getMinimumDate(timeframe: statistic.timeframe);
      if (minDate != null) {
        filteredMatches = matches
            .where((m) => m.hasEnded && !m.createdAt.isBefore(minDate))
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

    // Score-based stats only make sense for rulesets with numeric points and
    // time-based stats only for duration rulesets.
    if (statistic.type.isScoreBased) {
      filteredMatches = filteredMatches
          .where((m) => _isScoreBasedRuleset(m.game.ruleset))
          .toList();
    } else if (statistic.type.isTimeBased) {
      filteredMatches = filteredMatches
          .where((m) => _isTimeBasedRuleset(m.game.ruleset))
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

    if (statistic.type.isScoreBased || statistic.type.isTimeBased) {
      return scopedPlayers
          .where((p) => _hasAnyScore(p, filteredMatches))
          .toList();
    }

    return scopedPlayers;
  }

  /// Returns a [DateTime] with the minimum time and date the [timeframe] allows
  static DateTime? _getMinimumDate({required Timeframe timeframe}) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    switch (timeframe) {
      case Timeframe.last7Days:
        return todayStart.subtract(const Duration(days: 7));
      case Timeframe.last30Days:
        return todayStart.subtract(const Duration(days: 30));
      case Timeframe.last90Days:
        return todayStart.subtract(const Duration(days: 90));
      case Timeframe.last180Days:
        return todayStart.subtract(const Duration(days: 180));
      case Timeframe.lastYear:
        return todayStart.subtract(const Duration(days: 365));
      case Timeframe.allTime:
      case Timeframe.custom:
        return null;
    }
  }

  /// Determines if the ruleset is based on scores (numeric points).
  static bool _isScoreBasedRuleset(Ruleset ruleset) {
    switch (ruleset) {
      case Ruleset.highestScore:
      case Ruleset.lowestScore:
        return true;
      case Ruleset.winner:
      case Ruleset.placement:
      case Ruleset.loser:
      case Ruleset.lives:
      case Ruleset.longestTime:
      case Ruleset.shortestTime:
        return false;
    }
  }

  /// Determines if the ruleset is based on time (durations in milliseconds).
  static bool _isTimeBasedRuleset(Ruleset ruleset) {
    switch (ruleset) {
      case Ruleset.longestTime:
      case Ruleset.shortestTime:
        return true;
      case Ruleset.winner:
      case Ruleset.loser:
      case Ruleset.highestScore:
      case Ruleset.lowestScore:
      case Ruleset.lives:
      case Ruleset.placement:
        return false;
    }
  }

  /// Computes the statistic values for each player based on the statistic type.
  /// The returned list is unsorted; [computeStatisticValues] applies the
  /// statistic's sort order afterwards.
  static List<(Player, num)> _computeValuesForType({
    required StatisticType type,
    required List<Match> matches,
    required List<Player> players,
  }) {
    switch (type) {
      case StatisticType.totalMatches:
        return players
            .map((p) => (p, _matchesPlayed(p, matches) as num))
            .toList();

      case StatisticType.totalWins:
        return players.map((p) => (p, _wins(p, matches) as num)).toList();

      case StatisticType.totalLosses:
        return players.map((p) => (p, _losses(p, matches) as num)).toList();

      case StatisticType.totalScore:
        return players.map((p) => (p, _totalScore(p, matches) as num)).toList();

      case StatisticType.averageScore:
        return players.map((p) {
          final scores = _scoresOf(p, matches);
          final avg = scores.isEmpty
              ? 0
              : double.parse(
                  (scores.reduce((a, b) => a + b) / scores.length)
                      .toStringAsFixed(2),
                );
          return (p, avg);
        }).toList();

      case StatisticType.bestScore:
        return players.map((p) {
          final scores = _scoresOf(p, matches);
          final best = scores.isEmpty ? 0 : scores.reduce(max);
          return (p, best as num);
        }).toList();

      case StatisticType.worstScore:
        return players.map((p) {
          final scores = _scoresOf(p, matches);
          final worst = scores.isEmpty ? 0 : scores.reduce(min);
          return (p, worst as num);
        }).toList();

      case StatisticType.winrate:
        return players.map((p) {
          final played = _matchesPlayed(p, matches);
          final wins = _wins(p, matches);
          final rate = played == 0
              ? 0.0
              : double.parse((wins / played).toStringAsFixed(2));
          return (p, rate as num);
        }).toList();

      case StatisticType.totalTime:
        return players.map((p) => (p, _totalScore(p, matches) as num)).toList();

      case StatisticType.averageTime:
        return players.map((p) {
          final scores = _scoresOf(p, matches);
          final avg = scores.isEmpty
              ? 0
              : double.parse(
                  (scores.reduce((a, b) => a + b) / scores.length)
                      .toStringAsFixed(2),
                );
          return (p, avg);
        }).toList();

      case StatisticType.longestTime:
        return players.map((p) {
          final scores = _scoresOf(p, matches);
          final longest = scores.isEmpty ? 0 : scores.reduce(max);
          return (p, longest as num);
        }).toList();

      case StatisticType.shortestTime:
        return players.map((p) {
          final scores = _scoresOf(p, matches);
          final shortest = scores.isEmpty ? 0 : scores.reduce(min);
          return (p, shortest as num);
        }).toList();
    }
  }

  /* Helper functions for different statistic types */

  /// Detemerines how many matches contain the given player.
  static int _matchesPlayed(Player p, List<Match> matches) =>
      matches.where((m) => m.players.any((mp) => mp.id == p.id)).length;

  /// Determines how many wins the player has in the given matches.
  ///
  /// - singleLooser: Every player except the mvp gets a win
  /// - Lives: all players that have lives left or no one when all are at 0 lives
  /// - Other rulesets: The mvp gets a win
  static int _wins(Player p, List<Match> matches) =>
      matches.where((m) => m.players.any((mp) => mp.id == p.id)).where((m) {
        if (m.isTie) return false;
        final isMvp = m.mvp.any((mp) => mp.id == p.id);
        return m.game.ruleset.isLoser ? !isMvp : isMvp;
      }).length;

  /// Determines how many losses the player has in the given matches.
  ///
  /// - singleLooser: The mvp is the loser
  /// - Lives: all players that don't have lives left or no one when everyone has 0 lives left
  /// - Other rulesets: Everyone except mvp is the loser
  static int _losses(Player p, List<Match> matches) =>
      matches.where((m) => m.players.any((mp) => mp.id == p.id)).where((m) {
        if (m.isTie) return false;
        final isMvp = m.mvp.any((mp) => mp.id == p.id);
        return m.game.ruleset.isLoser ? isMvp : !isMvp;
      }).length;

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
}
