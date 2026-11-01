import 'package:tallee/l10n/generated/app_localizations.dart';

/// Returns the correct singular or plural form of "point(s)" based on the [amount] value.
String getPointLabel(AppLocalizations loc, int amount) {
  if (amount == 1) {
    return '$amount ${loc.point}';
  } else {
    return '$amount ${loc.points}';
  }
}

String getLifeLabel(AppLocalizations loc, int amount) {
  return '$amount ${loc.lives(amount)}';
}
