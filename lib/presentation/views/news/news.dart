import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/dto/news_item.dart';

final news = {
  NewsItem(
    icon: Icons.insights_rounded,
    iconColor: AppColor.purple,
    localizedHeading: {'de': 'Spielprofil', 'en': 'Gameprofile'},
    localizedText: {
      'de': 'Es gibt jetzt eine **neue Profil-Ansicht für Spiele**, um Statistiken und Verläufe übersichtlich einzusehen.',
      'en': 'Added a **new profile view for games** to easily browse statistics and history for your games.',
    },
  ),
  NewsItem(
    icon: Icons.rule_rounded,
    iconColor: AppColor.orange,
    localizedHeading: {
      'de': 'Anpassbare Regelwerke',
      'en': 'Editable Rulesets',
    },
    localizedText: {
      'de': 'Regelwerke können nun **nachträglich geändert** werden. Zudem helfen **neue Erklärungen** bei der Auswahl.',
      'en': 'Rulesets can now be **edited afterwards**. Additionally, **new explanations** help you pick the right ruleset.',
    },
  ),
  NewsItem(
    icon: Icons.auto_awesome_rounded,
    iconColor: AppColor.teal,
    localizedHeading: {
      'de': 'Verbesserungen & Fixes',
      'en': 'Improvements & Fixes',
    },
    localizedText: {
      'de': 'Optimiertes **Scrollverhalten**, verbesserte **Filteranzeigen** sowie **Fehlerbehebungen** bei Gruppen und der Spielerauswahl.',
      'en': 'Optimized **scrolling behavior**, improved **empty filter screens**, and **bug fixes** for groups and player selection.',
    },
  ),
  NewsItem(
    icon: Icons.feedback_rounded,
    iconColor: AppColor.blue,
    localizedHeading: {'de': 'Feedback & Fehler', 'en': 'Feedback & Bugs'},
    localizedText: {
      'de': 'Hast du Wünsche oder einen Fehler gefunden? Melde dich gerne über den **Feedback-Button** in den Einstellungen!',
      'en': 'Have suggestions or found a bug? Feel free to reach out via the **feedback button** in settings!',
    },
  ),
};
