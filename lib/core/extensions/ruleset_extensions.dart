import 'package:cupertino_ui/cupertino_ui.dart';
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
}
