import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/dto/news_item.dart';

final news = {
  NewsItem(
    icon: Icons.palette_rounded,
    iconColor: AppColor.purple,
    localizedHeading: {'de': 'UI Verbesserungen', 'en': 'UI Improvements'},
    localizedText: {
      'de': 'Kleine **Anzeige-** und **Konsistenzfehler** wurden behoben.',
      'en': 'Fixed minor **display bugs** and **consistency issues**.',
    },
  ),
  NewsItem(
    icon: Icons.feedback_rounded,
    iconColor: AppColor.blue,
    localizedHeading: {'de': 'Bug gefunden?', 'en': 'Found a Bug?'},
    localizedText: {
      'de': 'Gib uns gerne Feedback oder melde Fehler über den **Feedback-Button** in den Einstellungen, um Tallee weiter zu verbessern!',
      'en': 'Feel free to share feedback or report bugs via the **feedback button** in the settings to help us improve Tallee!',
    },
  ),
};
