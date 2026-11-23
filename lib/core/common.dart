import 'package:material_ui/material_ui.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/state/showcase_provider.dart';

/// Returns the correct singular or plural form of "point(s)" based on the [amount] value.
String getPointLabel(AppLocalizations loc, int amount) {
  if (amount == 1) return '$amount ${loc.point}';
  return '$amount ${loc.points}';
}

String getLifeLabel(AppLocalizations loc, int amount) =>
    '$amount ${loc.lives(amount)}';

void handleShowcase({
  required List<GlobalKey> widgetKeys,
  required List<String> identifiers,
  required BuildContext context,
  required ShowcaseProvider showcaseProvider,
  bool isStart = false,
}) {
  assert(
    widgetKeys.length == identifiers.length,
    'widgetKeys and identifiers have to have the same length',
  );
  if (identifiers.isEmpty) return;

  final String firstIdentifier = identifiers.first;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (showcaseProvider.shouldShowShowcase(firstIdentifier)) {
      ShowcaseView.get().startShowCase(
        widgetKeys,
        delay: const Duration(milliseconds: 400),
      );
    }
  });
}
