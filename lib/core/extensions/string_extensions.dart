extension StringExtension on String {
  /// Compares this string with [other] ignoring upper-/lowercase.
  int compareIgnoringCaseTo(String other) =>
      toLowerCase().compareTo(other.toLowerCase());

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
