import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/news/news.dart';

void main() {
  group('News tests', () {
    test('Fallback news (english) are set', () {
      const fallbackLoc = 'en';
      expect(news, isNotEmpty, reason: 'News list is empty');

      for (final item in news) {
        expect(
          item.localizedHeading[fallbackLoc],
          isNotNull,
          reason: 'Fallback news title for locale $fallbackLoc is null',
        );
        expect(
          item.localizedHeading[fallbackLoc],
          isNotEmpty,
          reason: 'Fallback news title for locale $fallbackLoc is empty',
        );
        expect(
          item.localizedText[fallbackLoc],
          isNotNull,
          reason: 'Fallback news text for locale $fallbackLoc is null',
        );
        expect(
          item.localizedText[fallbackLoc],
          isNotEmpty,
          reason: 'Fallback news text for locale $fallbackLoc is empty',
        );
      }
    });

    test('For every locale there is a news', () {
      final loc = AppLocalizations.supportedLocales
          .map((e) => e.languageCode)
          .toList();
      for (final locale in loc) {
        for (final entry in news) {
          expect(
            entry.localizedHeading[locale],
            isNotNull,
            reason: 'News title for locale $locale is null',
          );
          expect(
            entry.localizedHeading[locale],
            isNotEmpty,
            reason: 'News title for locale $locale is empty',
          );
          expect(
            entry.localizedText[locale],
            isNotNull,
            reason: 'News text for locale $locale is null',
          );
          expect(
            entry.localizedText[locale],
            isNotEmpty,
            reason: 'News text for locale $locale is empty',
          );
        }
      }
    });
  });
}
