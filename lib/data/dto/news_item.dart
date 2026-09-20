import 'package:flutter/cupertino.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';

class NewsItem {
  final IconData icon;
  final AppColor iconColor;
  final Map<String, String> localizedHeading;
  final Map<String, String> localizedText;

  NewsItem({
    required this.icon,
    required this.iconColor,
    required this.localizedHeading,
    required this.localizedText,
  }) {
    for (final locale in AppLocalizations.supportedLocales.map(
      (e) => e.languageCode,
    )) {
      assert(
        localizedHeading[locale]?.isNotEmpty ?? false,
        'NewsItem is missing a heading for locale "$locale"',
      );
      assert(
        localizedText[locale]?.isNotEmpty ?? false,
        'NewsItem is missing a text for locale "$locale"',
      );
    }
  }
}
