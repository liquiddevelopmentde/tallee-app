import 'package:tallee/data/models/match.dart';

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
