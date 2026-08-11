import 'package:clock/clock.dart';
import 'package:tallee/data/models/models.dart';

export 'app_color_utils.dart';
export 'icon_utils.dart';
export 'translations.dart';

/// Returns true if the given [date] is today.
bool isToday(DateTime date) {
  final now = clock.now();
  return date.year == now.year && date.month == now.month && date.day == now.day;
}

/// Returns null if the given [date] is today, otherwise returns the date.
DateTime? nullIfToday(DateTime date) => isToday(date) ? null : date;

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

extension Comparison on String {
  /// Compares this string with [other] ignoring upper-/lowercase.
  int compareIgnoringCaseTo(String other) =>
      toLowerCase().compareTo(other.toLowerCase());
}
