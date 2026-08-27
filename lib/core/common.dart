import 'package:tallee/data/models/models.dart';

export 'app_color_utils.dart';
export 'icon_utils.dart';
export 'translations.dart';

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

extension FilenameSanitization on String {
  /// Sanitizes a string to be used as a filename.
  ///
  /// Replaces spaces with underscores, normalizes German umlauts,
  /// and removes any characters that are not alphanumeric, dots, underscores, or hyphens.
  /// If the resulting string is empty, returns the [fallback].
  String toSafeFilename({String fallback = 'match'}) {
    final sanitized = replaceAll(' ', '_')
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('Ä', 'Ae')
        .replaceAll('Ö', 'Oe')
        .replaceAll('Ü', 'Ue')
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '');

    return sanitized.isEmpty ? fallback : sanitized;
  }
}
