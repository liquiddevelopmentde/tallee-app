import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';

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
}

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
