// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get all_players => 'Alle Spieler:innen';

  @override
  String get all_players_selected => 'Alle Spieler:innen ausgewählt';

  @override
  String get all_time => 'Gesamter Zeitraum';

  @override
  String get amount_of_matches => 'Anzahl der Spiele';

  @override
  String get app_name => 'Tallee';

  @override
  String get average_score => 'Durchschnittliche Punktzahl';

  @override
  String get best_player => 'Beste:r Spieler:in';

  @override
  String get best_score => 'Beste Punktzahl';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get choose_color => 'Farbe wählen';

  @override
  String get choose_game => 'Spielvorlage wählen';

  @override
  String get choose_group => 'Gruppe wählen';

  @override
  String get choose_ruleset => 'Regelwerk wählen';

  @override
  String get classifier => 'Klassifikator';

  @override
  String get color => 'Farbe';

  @override
  String get color_blue => 'Blau';

  @override
  String get color_green => 'Grün';

  @override
  String get color_orange => 'Orange';

  @override
  String get color_pink => 'Rosa';

  @override
  String get color_purple => 'Lila';

  @override
  String get color_red => 'Rot';

  @override
  String get color_teal => 'Türkis';

  @override
  String get color_yellow => 'Gelb';

  @override
  String get confirm => 'Bestätigen';

  @override
  String could_not_add_player(String playerName) {
    return 'Spieler:in $playerName konnte nicht hinzugefügt werden';
  }

  @override
  String get create_game => 'Spielvorlage erstellen';

  @override
  String get create_group => 'Gruppe erstellen';

  @override
  String get create_match => 'Spiel erstellen';

  @override
  String get create_new_group => 'Neue Gruppe erstellen';

  @override
  String get create_new_match => 'Neues Spiel erstellen';

  @override
  String get create_statistic => 'Statistik erstellen';

  @override
  String get created_on => 'Erstellt am';

  @override
  String get data => 'Daten';

  @override
  String get data_successfully_deleted => 'Daten erfolgreich gelöscht';

  @override
  String get data_successfully_exported => 'Daten erfolgreich exportiert';

  @override
  String get data_successfully_imported => 'Daten erfolgreich importiert';

  @override
  String days_ago(Object count) {
    return 'vor $count Tagen';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get delete_all_data => 'Alle Daten löschen';

  @override
  String get delete_game => 'Spielvorlage löschen';

  @override
  String delete_game_with_matches_warning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'werden $count Spiele',
      one: 'wird 1 Spiel',
    );
    return 'Wenn du diese Spielvorlage löschst, $_temp0 mit dieser Spielvorlage ebenfalls gelöscht.';
  }

  @override
  String get delete_group => 'Gruppe löschen';

  @override
  String get delete_match => 'Spiel löschen';

  @override
  String get delete_player => 'Spieler:in löschen';

  @override
  String get description => 'Beschreibung';

  @override
  String get displayed_entries => 'Angezeigte Einträge';

  @override
  String get drag_to_set_placement => 'Ziehen um Platzierung zu setzen';

  @override
  String get edit_game => 'Spielvorlage bearbeiten';

  @override
  String get edit_group => 'Gruppe bearbeiten';

  @override
  String get edit_match => 'Gruppe bearbeiten';

  @override
  String get edit_name => 'Name ändern';

  @override
  String get edit_player => 'Spieler bearbeiten';

  @override
  String get enter_points => 'Punkte eingeben';

  @override
  String get enter_results => 'Ergebnisse eintragen';

  @override
  String get error_creating_group =>
      'Fehler beim Erstellen der Gruppe, bitte erneut versuchen';

  @override
  String get error_deleting_game =>
      'Fehler beim Löschen der Spielvorlage, bitte erneut versuchen';

  @override
  String get error_deleting_group =>
      'Fehler beim Löschen der Gruppe, bitte erneut versuchen';

  @override
  String get error_editing_group =>
      'Fehler beim Bearbeiten der Gruppe, bitte erneut versuchen';

  @override
  String get error_reading_file => 'Fehler beim Lesen der Datei';

  @override
  String get exit_view => 'Ansicht verlassen';

  @override
  String get export_canceled => 'Export abgebrochen';

  @override
  String get export_data => 'Daten exportieren';

  @override
  String get filter => 'Filter';

  @override
  String get format_exception => 'Formatfehler (siehe Konsole)';

  @override
  String get game => 'Spielvorlage';

  @override
  String get game_name => 'Spielvorlagenname';

  @override
  String get games => 'Spielvorlagen';

  @override
  String get group => 'Gruppe';

  @override
  String get group_name => 'Gruppenname';

  @override
  String get group_profile => 'Gruppenprofil';

  @override
  String get groups => 'Gruppen';

  @override
  String get groups_part_of => 'Gruppen Teil von';

  @override
  String get highest_score => 'Höchste Punkte';

  @override
  String get home => 'Startseite';

  @override
  String get import_canceled => 'Import abgebrochen';

  @override
  String get import_data => 'Daten importieren';

  @override
  String get info => 'Info';

  @override
  String get invalid_schema => 'Ungültiges Schema';

  @override
  String get last_180_days => 'Letzte 180 Tage';

  @override
  String get last_30_days => 'Letzte 30 Tage';

  @override
  String get last_7_days => 'Letzte 7 Tage';

  @override
  String get last_90_days => 'Letzte 90 Tage';

  @override
  String get last_year => 'Letztes Jahr';

  @override
  String get least_points => 'Niedrigste Punkte';

  @override
  String get legal => 'Rechtliches';

  @override
  String get legal_notice => 'Impressum';

  @override
  String get licenses => 'Lizenzen';

  @override
  String get live_edit_mode => 'Live-Bearbeitungsmodus';

  @override
  String get loading => 'Lädt...';

  @override
  String get loser => 'Verlierer:in';

  @override
  String get lowest_score => 'Niedrigste Punkte';

  @override
  String get match_in_progress => 'Spiel läuft...';

  @override
  String get match_name => 'Spieltitel';

  @override
  String get match_profile => 'Spielprofil';

  @override
  String get matches => 'Spiele';

  @override
  String get matches_part_of => 'Spiele Teil von';

  @override
  String get matches_played => 'Spiele gespielt';

  @override
  String get matches_won => 'Spiele gewonnen';

  @override
  String get members => 'Mitglieder';

  @override
  String get most_points => 'Höchste Punkte';

  @override
  String get multiple_winners => 'Mehrere Gewinner:innen';

  @override
  String get no_data_available => 'Keine Daten verfügbar';

  @override
  String get no_games_created_yet => 'Noch keine Spielvorlagen erstellt';

  @override
  String get no_groups_created_yet => 'Noch keine Gruppen erstellt';

  @override
  String get no_license_text_available => 'Kein Lizenztext verfügbar';

  @override
  String get no_licenses_found => 'Keine Lizenzen gefunden';

  @override
  String get no_matches_created_yet => 'Noch keine Spiele erstellt';

  @override
  String get no_matches_played_yet => 'Noch kein Spiel gespielt';

  @override
  String get no_players_created_yet => 'Noch keine Spieler:in erstellt';

  @override
  String get no_players_found_with_that_name =>
      'Keine Spieler:in mit diesem Namen gefunden';

  @override
  String get no_players_selected => 'Keine Spieler:innen ausgewählt';

  @override
  String get no_recent_matches_available => 'Keine letzten Spiele verfügbar';

  @override
  String get no_results_entered_yet => 'Noch keine Ergebnisse eingetragen';

  @override
  String get no_second_match_available => 'Kein zweites Spiel verfügbar';

  @override
  String get no_statistics_available => 'Keine Statistiken verfügbar';

  @override
  String get no_statistics_created_yet => 'Noch keine Statistiken erstellt';

  @override
  String get none => 'Kein';

  @override
  String get none_group => 'Keine';

  @override
  String get not_available => 'Nicht verfügbar';

  @override
  String get not_part_of_any_group => 'Noch keiner Gruppe hinzugefügt';

  @override
  String get place => 'Platz';

  @override
  String get placement => 'Platzierung';

  @override
  String get played_matches => 'Gespielte Spiele';

  @override
  String get player_name => 'Spieler:innenname';

  @override
  String get player_profile => 'Spieler:in-Profil';

  @override
  String get players => 'Spieler:innen';

  @override
  String get point => 'Punkt';

  @override
  String get points => 'Punkte';

  @override
  String get privacy_policy => 'Datenschutzerklärung';

  @override
  String get quick_create => 'Schnellzugriff';

  @override
  String get recent_matches => 'Letzte Spiele';

  @override
  String get results => 'Ergebnisse';

  @override
  String get ruleset => 'Regelwerk';

  @override
  String get ruleset_least_points =>
      'Umgekehrte Wertung: Der/die Spieler:in mit den wenigsten Punkten gewinnt.';

  @override
  String get ruleset_most_points =>
      'Traditionelles Regelwerk: Der/die Spieler:in mit den meisten Punkten gewinnt.';

  @override
  String get ruleset_placement =>
      'Spieler:innen können in einer Reihenfolge angeordnet werden, die ihre Platzierung reflektiert.';

  @override
  String get ruleset_single_loser =>
      'Genau ein:e Verlierer:in wird bestimmt; der letzte Platz erhält die Strafe oder Konsequenz.';

  @override
  String get ruleset_single_winner =>
      'Genau ein:e Gewinner:in wird gewählt; Unentschieden werden durch einen vordefinierten Tie-Breaker aufgelöst.';

  @override
  String get save_changes => 'Änderungen speichern';

  @override
  String get scope => 'Bereich';

  @override
  String get search_for_groups => 'Nach Gruppen suchen';

  @override
  String get search_for_players => 'Nach Spieler:innen suchen';

  @override
  String get select_a_classifier => 'Klassifikator auswählen';

  @override
  String get select_a_game => 'Spielvorlage auswählen';

  @override
  String get select_a_group => 'Gruppe auswählen';

  @override
  String get select_a_scope => 'Bereich auswählen';

  @override
  String get select_a_timeframe => 'Zeitraum auswählen';

  @override
  String get select_loser => 'Verlierer:in wählen';

  @override
  String get select_the_filtered_games =>
      'Wähle Spiele, nach denen gefiltert werden soll.';

  @override
  String get select_the_filtered_groups =>
      'Wähle Gruppen, nach denen gefiltert werden soll.';

  @override
  String get select_the_filtered_timeframe =>
      'Wähle einen Zeitraum, nach dem gefiltert werden soll.';

  @override
  String get select_winner => 'Gewinner:in wählen';

  @override
  String get select_winners => 'Gewinner:innen wählen';

  @override
  String get selected_games => 'Ausgewählte Spielvorlagen';

  @override
  String get selected_groups => 'Ausgewählte Gruppen';

  @override
  String get selected_players => 'Ausgewählte Spieler:innen';

  @override
  String get set_name => 'Name setzen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get single_loser => 'Ein:e Verlierer:in';

  @override
  String get single_winner => 'Ein:e Gewinner:in';

  @override
  String get statistics => 'Statistiken';

  @override
  String get stats => 'Statistiken';

  @override
  String successfully_added_player(String playerName) {
    return 'Spieler:in $playerName erfolgreich hinzugefügt';
  }

  @override
  String get there_are_no_games_matching_your_search =>
      'Es gibt keine Spielvorlagen, die deiner Suche entspricht';

  @override
  String get there_is_no_group_matching_your_search =>
      'Es gibt keine Gruppe, die deiner Suche entspricht';

  @override
  String get this_cannot_be_undone =>
      'Dies kann nicht rückgängig gemacht werden.';

  @override
  String get tie => 'Unentschieden';

  @override
  String get timeframe => 'Zeitraum';

  @override
  String get today_at => 'Heute um';

  @override
  String get total_losses => 'Niederlagen insgesamt';

  @override
  String get total_matches => 'Spiele insgesamt';

  @override
  String get total_score => 'Punktzahl insgesamt';

  @override
  String get total_wins => 'Siege insgesamt';

  @override
  String get undo => 'Rückgängig';

  @override
  String get unknown_exception => 'Unbekannter Fehler (siehe Konsole)';

  @override
  String get winner => 'Gewinner:in';

  @override
  String get winners => 'Gewinner:innen';

  @override
  String get winrate => 'Siegquote';

  @override
  String get wins => 'Siege';

  @override
  String get worst_score => 'Schlechteste Punktzahl';

  @override
  String get yesterday_at => 'Gestern um';
}
