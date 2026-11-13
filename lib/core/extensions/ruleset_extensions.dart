import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:material_ui/material_ui.dart';
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
      case Ruleset.longestTime:
        return loc.longest_time;
      case Ruleset.shortestTime:
        return loc.shortest_time;
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
      case Ruleset.longestTime:
        return Icons.timer;
      case Ruleset.shortestTime:
        return Icons.timer_outlined;
    }
  }

  /// Points are counted, the highest or lowest total wins.
  bool get usesPoints => isHighestScore || isLowestScore;

  /// A numeric value is tracked per player (scores or lives).
  bool get usesNumericScore => usesPoints || isLives;

  /// The result is entered by selecting the winner(s) or the loser.
  bool get usesPlayerSelection => isWinner || isLoser;

  bool get isWinner => this == Ruleset.winner;

  bool get isLoser => this == Ruleset.loser;

  bool get isPlacement => this == Ruleset.placement;

  bool get isLowestScore => this == Ruleset.lowestScore;

  bool get isHighestScore => this == Ruleset.highestScore;

  bool get isLives => this == Ruleset.lives;
}
