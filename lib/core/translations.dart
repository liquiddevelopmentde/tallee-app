import 'package:flutter/cupertino.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';

/// Returns the correct singular or plural form of "point(s)" based on the [points] value.
String getPointLabel(AppLocalizations loc, int points) {
  if (points == 1) {
    return '$points ${loc.point}';
  } else {
    return '$points ${loc.points}';
  }
}

/// Translates a [ImportResult] enum value to its corresponding localized string.
String translateImportResultToString(
  ImportResult importResult,
  BuildContext context,
) {
  final loc = AppLocalizations.of(context);
  switch (importResult) {
    case ImportResult.success:
      return loc.data_successfully_imported;
    case ImportResult.invalidSchema:
      return loc.invalid_schema;
    case ImportResult.invalidData:
      return loc.names_or_descriptions_too_long;
    case ImportResult.fileReadError:
      return loc.error_reading_file;
    case ImportResult.fileNotFound:
      return loc.file_couldnt_be_accessed;
    case ImportResult.canceled:
      return loc.import_canceled;
    case ImportResult.formatException:
      return loc.format_exception;
    case ImportResult.unknownException:
      return loc.unknown_exception;
    case ImportResult.singleMatchDetected:
      return '';
  }
}

/// Translates a [ExportResult] enum value to its corresponding localized string.
String translateExportResultToString(
  ExportResult exportResult,
  BuildContext context,
) {
  final loc = AppLocalizations.of(context);
  switch (exportResult) {
    case ExportResult.success:
      return loc.data_successfully_exported;
    case ExportResult.noData:
      return loc.no_data_to_export;
    case ExportResult.canceled:
      return loc.export_canceled;
    case ExportResult.unknownException:
      return loc.unknown_exception;
  }
}

/// Translates a [Ruleset] enum value to its corresponding localized string.
String translateRulesetToString(Ruleset ruleset, BuildContext context) {
  final loc = AppLocalizations.of(context);
  switch (ruleset) {
    case Ruleset.highestScore:
      return loc.highest_score;
    case Ruleset.lowestScore:
      return loc.lowest_score;
    case Ruleset.singleWinner:
      return loc.single_winner;
    case Ruleset.singleLoser:
      return loc.single_loser;
    case Ruleset.multipleWinners:
      return loc.multiple_winners;
    case Ruleset.placement:
      return loc.placement;
  }
}

/// Translates a [AppColor] enum value to its corresponding localized string.
String translateAppColorToString(AppColor color, BuildContext context) {
  final loc = AppLocalizations.of(context);
  switch (color) {
    case AppColor.red:
      return loc.color_red;
    case AppColor.blue:
      return loc.color_blue;
    case AppColor.green:
      return loc.color_green;
    case AppColor.yellow:
      return loc.color_yellow;
    //return const Color(0xFFF7CA28);
    case AppColor.purple:
      return loc.color_purple;
    case AppColor.orange:
      return loc.color_orange;
    case AppColor.pink:
      return loc.color_pink;
    case AppColor.teal:
      return loc.color_teal;
  }
}

/// Translates a [Timeframe] enum value to its corresponding localized string.
String translateTimeframeToString(Timeframe timeframe, BuildContext context) {
  final loc = AppLocalizations.of(context);
  switch (timeframe) {
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

/// Translates a [StatisticScope] enum value to its corresponding localized string.
String translateScopeToString(StatisticScope scope, BuildContext context) {
  final loc = AppLocalizations.of(context);
  switch (scope) {
    case StatisticScope.allPlayers:
      return loc.all_players;
    case StatisticScope.selectedGroups:
      return loc.selected_groups;
    case StatisticScope.selectedGames:
      return loc.selected_games;
  }
}

/// Translates a [StatisticType] enum value to its corresponding localized string.
String translateStatisticTypeToString(
  StatisticType type,
  BuildContext context,
) {
  final loc = AppLocalizations.of(context);
  switch (type) {
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
