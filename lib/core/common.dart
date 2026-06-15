import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/statistic.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';

/// Returns the [Color] object corresponding to a [AppColor] enum value.
Color getColorFromAppColor(AppColor color) {
  switch (color) {
    case AppColor.red:
      return Colors.red;
    case AppColor.blue:
      return Colors.blue;
    case AppColor.green:
      return Colors.green;
    case AppColor.yellow:
      return const Color(0xFFF7CA28);
    case AppColor.purple:
      return Colors.purple;
    case AppColor.orange:
      return const Color(0xFFef681f);
    case AppColor.pink:
      return const Color(0xFFE91E63);
    case AppColor.teal:
      return const Color(0xFF00BCD4);
  }
}

/// Returns a random color from the app colors.
AppColor getRandomAppColor() {
  const appColors = AppColor.values;
  return appColors[Random().nextInt(appColors.length)];
}

/// Returns a random color from the app colors.
Color getRandomAppColorValue() {
  return getColorFromAppColor(getRandomAppColor());
}

// Returns a AppColor enum value based on the provided team [index].
AppColor getTeamColor(int index) {
  final colors = [
    AppColor.red,
    AppColor.blue,
    AppColor.green,
    AppColor.yellow,
    AppColor.purple,
    AppColor.orange,
    AppColor.pink,
    AppColor.teal,
  ];
  return colors[index % colors.length];
}

/// Returns a color from the palette based on the statistic's ID as random seed.
Color getStatisticColor(Statistic stat) {
  final seed = stat.id.hashCode;
  final appColors = AppColor.values
      .map((c) => getColorFromAppColor(c))
      .toList();
  return appColors[seed.abs() % appColors.length];
}

/// Returns [IconData] corresponding to a [Ruleset] enum value.
IconData getRulesetIcon(Ruleset ruleset) {
  switch (ruleset) {
    case Ruleset.highestScore:
      return Icons.arrow_upward;
    case Ruleset.lowestScore:
      return Icons.arrow_downward;
    case Ruleset.singleWinner:
    case Ruleset.multipleWinners:
      return Icons.emoji_events;
    case Ruleset.singleLoser:
      return Icons.sentiment_dissatisfied;
    case Ruleset.placement:
      return RpgAwesome.podium;
  }
}

/// Returns the icon for the given statistic type.
IconData getStatisticIcon({required StatisticType type}) {
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

/// Counts how many players in the [match] are not part of the group
///
/// Returns the text you append after the group name, e.g. " + 5" or an empty
/// string if there are no extra players
String getExtraPlayerCount(Match match) {
  int count = 0;

  if (match.group == null) {
    return '';
  }

  final groupMembers = match.group!.members;
  final players = match.players;

  for (var player in players) {
    if (!groupMembers.any((member) => member.id == player.id)) {
      count++;
    }
  }

  if (count == 0) {
    return '';
  }
  return ' + ${count.toString()}';
}

/// Returns the correct singular or plural form of "point(s)" based on the [points] value.
String getPointLabel(AppLocalizations loc, int points) {
  if (points == 1) {
    return '$points ${loc.point}';
  } else {
    return '$points ${loc.points}';
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

extension Comparison on String {
  /// Compares this string with [other] ignoring upper-/lowercase.
  int compareIgnoringCaseTo(String other) =>
      toLowerCase().compareTo(other.toLowerCase());
}
