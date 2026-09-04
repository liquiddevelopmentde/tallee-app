import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:tallee/core/enums.dart';

/// Returns [IconData] corresponding to a [Ruleset] enum value.
IconData getRulesetIcon(Ruleset ruleset) {
  switch (ruleset) {
    case Ruleset.highestScore:
      return Icons.arrow_upward;
    case Ruleset.lowestScore:
      return Icons.arrow_downward;
    case Ruleset.winners:
      return Icons.emoji_events;
    case Ruleset.loser:
      return Icons.sentiment_dissatisfied;
    case Ruleset.placement:
      return RpgAwesome.podium;
    case Ruleset.lives:
      return Icons.favorite;
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
