import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/constants/icon_constants.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';

extension StatisticTypeExtension on StatisticType {
  /// Translates a [StatisticType] enum value to its corresponding localized string.
  String toLocalizedString(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (this) {
      case StatisticType.totalMatches:
        return loc.total_matches;
      case StatisticType.totalWins:
        return loc.total_wins;
      case StatisticType.totalScore:
        return loc.total_score;
      case StatisticType.totalLosses:
        return loc.total_losses;
      case StatisticType.averageScore:
        return loc.average_score;
      case StatisticType.bestScore:
        return loc.best_score;
      case StatisticType.worstScore:
        return loc.worst_score;
      case StatisticType.winrate:
        return loc.winrate;
      case StatisticType.totalTime:
        return loc.total_time;
      case StatisticType.averageTime:
        return loc.average_time;
      case StatisticType.longestTime:
        return loc.longest_time_statistic;
      case StatisticType.shortestTime:
        return loc.shortest_time_statistic;
    }
  }

  /// Returns the icon for the given statistic type.
  IconData get icon {
    switch (this) {
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
      case StatisticType.totalTime:
        return Icons.timer;
      case StatisticType.averageTime:
        return Icons.av_timer;
      case StatisticType.longestTime:
        return Icons.hourglass_bottom;
      case StatisticType.shortestTime:
        return Icons.hourglass_top;
    }
  }

  /// Returns the rulesets which make sense for a given [StatisticType]
  List<Ruleset> get fittingRulesets {
    final scoreBaseRulesets = [Ruleset.lowestScore, Ruleset.highestScore];
    final timeBaseRulesets = [Ruleset.longestTime, Ruleset.shortestTime];
    const allRulesets = Ruleset.values;

    switch (this) {
      case StatisticType.averageScore:
      case StatisticType.bestScore:
      case StatisticType.worstScore:
      case StatisticType.totalScore:
        return scoreBaseRulesets;

      case StatisticType.totalTime:
      case StatisticType.averageTime:
      case StatisticType.longestTime:
      case StatisticType.shortestTime:
        return timeBaseRulesets;

      case StatisticType.totalMatches:
      case StatisticType.totalLosses:
      case StatisticType.winrate:
      case StatisticType.totalWins:
        return allRulesets;
    }
  }

  /// The sort direction a new statistic of this type starts with.
  /// "Worst score" shows ascending, everything else descending.
  SortDirection get defaultSortDirection => this == StatisticType.worstScore
      ? SortDirection.ascending
      : SortDirection.descending;
}

extension StatisticScopeExtension on StatisticScope {
  /// Translates a [StatisticScope] enum value to its corresponding localized string.
  String toLocalizedString(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (this) {
      case StatisticScope.allPlayers:
        return loc.all_players;
      case StatisticScope.selectedGroups:
        return loc.selected_groups;
      case StatisticScope.selectedGames:
        return loc.selected_games;
    }
  }

  IconData get icon {
    switch (this) {
      case StatisticScope.allPlayers:
        return PLAYER_ICON;
      case StatisticScope.selectedGroups:
        return GROUP_ICON;
      case StatisticScope.selectedGames:
        return GAME_ICON;
    }
  }
}

extension TimeframeExtension on Timeframe {
  /// Translates a [Timeframe] enum value to its corresponding localized string.
  String toLocalizedString(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (this) {
      case Timeframe.last7Days:
        return loc.last_7_days;
      case Timeframe.last30Days:
        return loc.last_30_days;
      case Timeframe.last90Days:
        return loc.last_90_days;
      case Timeframe.last180Days:
        return loc.last_180_days;
      case Timeframe.lastYear:
        return loc.last_year;
      case Timeframe.allTime:
        return loc.all_time;
      case Timeframe.custom:
        return loc.custom;
    }
  }
}
