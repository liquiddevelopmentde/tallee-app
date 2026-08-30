// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get add_team => 'Team hinzufügen';

  @override
  String get all => 'Alle';

  @override
  String get all_players => 'Alle Spieler:innen';

  @override
  String get all_players_selected => 'Alle Spieler:innen ausgewählt';

  @override
  String get all_time => 'Gesamter Zeitraum';

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
  String get choose_game => 'Spielvorlage wählen';

  @override
  String get choose_group => 'Gruppe wählen';

  @override
  String get choose_scopes => 'Bereiche wählen';

  @override
  String get choose_timeframes => 'Zeiträume wählen';

  @override
  String get choose_types => 'Typen wählen';

  @override
  String get classifier => 'Klassifikator';

  @override
  String get classifier_description =>
      'Lege fest, welche Kennzahl berechnet und in der Statistik angezeigt wird.';

  @override
  String get click_another_player_to_create_a_pair =>
      'Klicke einen weiteren Spieler an, um ein Paar zu erstellen';

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
  String get create_teams => 'Teams erstellen';

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
  String get delete_group_warning_details =>
      'Dies kann nicht rückgängig gemacht werden. Die Gruppe wird aus allen Spielen entfernt, die Mitglieder:innen bleiben jedoch weiterhin dem Spiel zugeordnet.';

  @override
  String get delete_match => 'Spiel löschen';

  @override
  String get delete_player => 'Spieler:in löschen';

  @override
  String get delete_player_warning_details =>
      'Dies kann nicht rückgängig gemacht werden. Gelöschte Spieler:innen werden weiterhin in vergangenen Spielen angezeigt und in Statistiken berücksichtigt.';

  @override
  String get delete_statistic => 'Statistik löschen';

  @override
  String get deleted => 'Gelöscht';

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
  String get edit_match => 'Match bearbeiten';

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
  String get error_editing_group =>
      'Fehler beim Bearbeiten der Gruppe, bitte erneut versuchen';

  @override
  String get error_reading_file => 'Fehler beim Lesen der Datei';

  @override
  String get export_canceled => 'Export abgebrochen';

  @override
  String get export_data => 'Daten exportieren';

  @override
  String get favourites => 'Favoriten';

  @override
  String get file_couldnt_be_accessed =>
      'Die Datei konnte nicht geöffnet werden';

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
  String get group_associated => 'Gruppe erfolgreich verknüpft';

  @override
  String get group_name => 'Gruppenname';

  @override
  String get group_profile => 'Gruppenprofil';

  @override
  String get groups => 'Gruppen';

  @override
  String get highest_score => 'Höchste Punkte';

  @override
  String get import_canceled => 'Import abgebrochen';

  @override
  String get import_data => 'Daten importieren';

  @override
  String get import_preview_description =>
      'Die folgenden Daten werden importiert';

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
  String get manage_members => 'Mitglieder bearbeiten';

  @override
  String get match_in_progress => 'Spiel läuft...';

  @override
  String get match_name => 'Spieltitel';

  @override
  String get match_profile => 'Spielprofil';

  @override
  String get matches => 'Spiele';

  @override
  String get matches_played => 'Spiele gespielt';

  @override
  String get matches_won => 'Spiele gewonnen';

  @override
  String get member => 'Mitglied';

  @override
  String get members => 'Mitglieder';

  @override
  String get multiple_winners => 'Mehrere Gewinner:innen';

  @override
  String get names_or_descriptions_too_long =>
      'Die Daten enthalten zu lange Namen oder Beschreibungen.';

  @override
  String get new_group_will_be_created => 'Neue Gruppe wird erstellt';

  @override
  String get new_game_will_be_created => 'Neue Spielvorlage wird erstellt';

  @override
  String get tap_to_choose_different_game =>
      'Tippe die Spielvorlage an, um eine andere auszuwählen';

  @override
  String get tap_to_choose_different_group =>
      'Tippe die Gruppe an, um eine andere auszuwählen';

  @override
  String get no_data_available => 'Keine Daten verfügbar';

  @override
  String get no_data_to_export => 'Keine Daten zum exportieren';

  @override
  String get no_games_created_yet => 'Noch keine Spielvorlagen erstellt';

  @override
  String get no_groups_created_yet => 'Noch keine Gruppen erstellt';

  @override
  String get no_license_text_available => 'Kein Lizenztext verfügbar';

  @override
  String get no_matches_created_yet => 'Noch keine Spiele erstellt';

  @override
  String get no_matches_played_yet => 'Noch kein Spiel gespielt';

  @override
  String get no_matching_local_group_found =>
      'Keine passende lokale Gruppe gefunden. Eine neue Gruppe wird erstellt.';

  @override
  String get no_players_available => 'Keine Spieler:innen verfügbar';

  @override
  String get no_players_created_yet => 'Noch keine Spieler:in erstellt';

  @override
  String get no_players_found_with_that_name =>
      'Keine Spieler:in mit diesem Namen gefunden';

  @override
  String get no_players_selected => 'Keine Spieler:innen ausgewählt';

  @override
  String get no_results_entered_yet => 'Noch keine Ergebnisse eingetragen';

  @override
  String get no_statistics_created_yet => 'Noch keine Statistiken erstellt';

  @override
  String get no_statistics_with_filter =>
      'Keine Statistiken mit den ausgewählten Filteroptionen';

  @override
  String get no_teams_available => 'Keine Teams verfügbar';

  @override
  String get none => 'Kein';

  @override
  String get none_group => 'Keine';

  @override
  String get not_part_of_any_group => 'Noch keiner Gruppe hinzugefügt';

  @override
  String get place => 'Platz';

  @override
  String get placement => 'Platzierung';

  @override
  String get played_matches => 'Gespielte Spiele';

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
  String get random_color => 'Zufällige Farbe';

  @override
  String get results => 'Ergebnisse';

  @override
  String get ruleset => 'Regelwerk';

  @override
  String get save_changes => 'Änderungen speichern';

  @override
  String get save_match => 'Spiel speichern';

  @override
  String get scope => 'Bereich';

  @override
  String get scope_description =>
      'Bestimme, welche Spielvorlagen oder Spieler in die Berechnung einfließen.';

  @override
  String get search_for_games => 'Nach Spielvorlagen suchen';

  @override
  String get search_for_groups => 'Nach Gruppen suchen';

  @override
  String get search_for_players => 'Nach Spieler:innen suchen';

  @override
  String get search_for_scopes => 'Nach Bereichen suchen';

  @override
  String get search_for_timeframes => 'Nach Zeiträumen suchen';

  @override
  String get search_for_types => 'Nach Typen suchen';

  @override
  String get select_a_classifier => 'Klassifikator auswählen';

  @override
  String get select_a_display_color => 'Wähle eine Anzeigefarbe aus';

  @override
  String get select_a_scope => 'Bereich auswählen';

  @override
  String get select_a_timeframe => 'Zeitraum auswählen';

  @override
  String get select_loser => 'Verlierer:in wählen';

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
  String get statistic => 'Statistik';

  @override
  String get statistics => 'Statistiken';

  @override
  String successfully_added_player(String playerName) {
    return 'Spieler:in $playerName erfolgreich hinzugefügt';
  }

  @override
  String get tap_to_choose_existing => 'Tippen zum manuellen Auswählen';

  @override
  String get team => 'Team';

  @override
  String get team_match => 'Teamspiel';

  @override
  String get teams => 'Teams';

  @override
  String get there_are_no_games_matching_your_search =>
      'Es gibt keine Spielvorlagen, die deiner Suche entspricht';

  @override
  String get there_is_no_group_matching_your_search =>
      'Es gibt keine Gruppe, die deiner Suche entspricht';

  @override
  String get there_is_no_match_matching_your_search =>
      'Es gibt kein Spiel, das deiner Suche entspricht';

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
  String get type => 'Typ';

  @override
  String get unknown_exception => 'Unbekannter Fehler (siehe Konsole)';

  @override
  String get winner => 'Gewinner:in';

  @override
  String get winners => 'Gewinner:innen';

  @override
  String get winrate => 'Siegquote';

  @override
  String get worst_score => 'Schlechteste Punktzahl';

  @override
  String get yesterday_at => 'Gestern um';

  @override
  String get match_share => 'Match teilen';

  @override
  String get qr_code_expired => 'QR-Code abgelaufen';

  @override
  String get token_expired => 'Token expired';

  @override
  String expires_in(String time) {
    return 'Läuft ab in $time';
  }

  @override
  String get scan_qr_code_instruction =>
      'Scanne den QR-Code mit einer anderen Tallee-Instanz, um das Match zu teilen.';

  @override
  String get online_sharing_disabled => 'Online-Teilen ist deaktiviert';

  @override
  String get go_to_settings_to_enable =>
      'Gehe in die Einstellungen, um es manuell zu aktivieren.';

  @override
  String get open_settings => 'Einstellungen öffnen';

  @override
  String get send_code_instruction =>
      'Sende diesen Code an eine Person, die ebenfalls Tallee hat, um das aktuelle Match zu teilen.';

  @override
  String get copy_code => 'Code kopieren';

  @override
  String get code_copied => 'Code in die Zwischenablage kopiert';

  @override
  String share_match_text(String code) {
    return 'Hier sind die Match-Daten für unser Spiel! Gib den Code $code in Tallee ein.';
  }

  @override
  String get share_match_title => 'Tallee Match teilen';

  @override
  String get file_share_instruction =>
      'Match-Daten manuell in einer Datei teilen für eine vollständige lokale Übertragung.';

  @override
  String get save_file => 'Datei speichern';

  @override
  String player_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Spieler:innen',
      one: '1 Spieler:in',
    );
    return '$_temp0';
  }

  @override
  String get network_error =>
      'Netzwerkfehler. Bitte überprüfe deine Verbindung.';

  @override
  String server_error(int statusCode) {
    return 'Serverfehler: $statusCode';
  }

  @override
  String get parsing_error =>
      'Fehler beim Verarbeiten der Daten. Bitte versuche es später erneut.';

  @override
  String get unexpected_error => 'Ein unerwarteter Fehler ist aufgetreten.';

  @override
  String get online_sharing_title => 'Online-Teilen';

  @override
  String get online_sharing_consent_text =>
      'Damit andere dein Match laden können, müssen die Spieldaten an unseren Server übertragen werden. Der Share-Token ist nur vorübergehend gültig und die Daten werden nach 10 Minuten automatisch gelöscht. Möchtest du Online-Teilen aktivieren?';

  @override
  String get enable => 'Aktivieren';

  @override
  String get disable => 'Deaktivieren';

  @override
  String get match_receive => 'Match empfangen';

  @override
  String get scan_qr_receive_instruction =>
      'Scanne den QR-Code einer anderen Tallee-Instanz, um das Match zu empfangen.';

  @override
  String get loading_match => 'Lade Match...';

  @override
  String get invalid_qr_code => 'Dieser QR-Code ist ungültig oder abgelaufen.';

  @override
  String get qr_code_parsing_error =>
      'Der gescannte Code enthält keine gültigen Match-Daten.';

  @override
  String error_loading_match(String error) {
    return 'Fehler beim Laden: $error';
  }

  @override
  String get input_token_instruction =>
      'Gib einen Match-Share-Token ein, den eine andere Person mit Tallee erstellt hat, um das Match zu importieren.';

  @override
  String get invalid_token => 'Ungültiger Token.';

  @override
  String get import_match => 'Match importieren';

  @override
  String get share_token_format_info =>
      'Share-Token bestehen aus 6 alphanumerischen Zeichen.';

  @override
  String get match_import_failed => 'Match-Import fehlgeschlagen';

  @override
  String get choose_match_file => 'Match-Datei auswählen';

  @override
  String get tap_to_browse => 'Tippen zum Durchsuchen';

  @override
  String get successfully_processed_file => 'Datei erfolgreich verarbeitet';

  @override
  String get tap_import_to_continue =>
      'Tippe auf Match importieren, um fortzufahren';

  @override
  String get import_file_instruction =>
      'Wähle eine Match-Datei (.tallee), die aus einem Tallee-Match-Share exportiert wurde, um die Daten zu importieren.';

  @override
  String here_is_shared_match(String matchName) {
    return 'Hier ist das geteilte Match \"$matchName\"';
  }

  @override
  String get choose_where_to_save =>
      'Wähle aus, wo du dein Match speichern möchtest:';

  @override
  String get associate_players => 'Spieler:innen verknüpfen';

  @override
  String get remaining => 'verbleibend';

  @override
  String get all_players_associated =>
      'Alle Spieler:innen erfolgreich verknüpft';

  @override
  String new_players_will_be_created(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neue Spieler:innen werden erstellt',
      one: '1 neue Spieler:in wird erstellt',
    );
    return '$_temp0';
  }

  @override
  String get create_as_new => 'Neu erstellen';

  @override
  String get associate_game => 'Spielvorlage verknüpfen';

  @override
  String get game_associated => 'Spielvorlage erfolgreich verknüpft';

  @override
  String get no_matching_local_game_found =>
      'Keine passende lokale Spielvorlage gefunden. Eine neue wird erstellt.';

  @override
  String get associate_group => 'Gruppe verknüpfen';

  @override
  String get match_not_ended_share_warning =>
      'Spiele können erst geteilt werden, wenn sie beendet wurden.';
}
