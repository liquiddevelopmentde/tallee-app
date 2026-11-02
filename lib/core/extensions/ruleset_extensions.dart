import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';

extension RulesetExtension on Ruleset {
  /// Translates a [Ruleset] enum value to its corresponding localized string.
  String toLocalizedString(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (this) {
      case Ruleset.highestScore:
        return loc.highest_score;
      case Ruleset.lowestScore:
        return loc.lowest_score;
      case Ruleset.loser:
        return loc.loser;
      case Ruleset.winner:
        return loc.winner;
      case Ruleset.placement:
        return loc.placement;
      case Ruleset.lives:
        return loc.lives(0);
    }
  }

  /// Returns [IconData] corresponding to a [Ruleset] enum value.
  IconData get icon {
    switch (this) {
      case Ruleset.highestScore:
        return Icons.arrow_upward;
      case Ruleset.lowestScore:
        return Icons.arrow_downward;
      case Ruleset.winner:
        return Icons.emoji_events;
      case Ruleset.loser:
        return Icons.sentiment_dissatisfied;
      case Ruleset.placement:
        return RpgAwesome.podium;
      case Ruleset.lives:
        return Icons.favorite;
    }
  }

  bool get isScoreRuleset => isHighestScoreRuleset || isLowestScoreRuleset;

  bool get isScoreBasedRuleset => isScoreRuleset || isLivesRuleset;

  bool get isSelectionRuleset => isWinnerRuleset || isLoserRuleset;

  bool get isWinnerRuleset => this == Ruleset.winner;

  bool get isLoserRuleset => this == Ruleset.loser;

  bool get isPlacementRuleset => this == Ruleset.placement;

  bool get isLowestScoreRuleset => this == Ruleset.lowestScore;

  bool get isHighestScoreRuleset => this == Ruleset.highestScore;

  bool get isLivesRuleset => this == Ruleset.lives;
}
