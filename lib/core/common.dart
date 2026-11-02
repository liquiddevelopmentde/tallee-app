import 'package:material_ui/material_ui.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/state/showcase_provider.dart';

export 'extensions/string_extensions.dart';

/// Returns the correct singular or plural form of "point(s)" based on the [amount] value.
String getPointLabel(AppLocalizations loc, int amount) {
  if (amount == 1) return '$amount ${loc.point}';
  return '$amount ${loc.points}';
}

String getLifeLabel(AppLocalizations loc, int amount) =>
    '$amount ${loc.lives(amount)}';

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
