// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get active_matches => 'Aktive Spiele';

  @override
  String get add_team => 'Team hinzufügen';

  @override
  String get all => 'Alle';

  @override
  String get all_players => 'Alle Spieler:innen';

  @override
  String get all_players_associated =>
      'Alle Spieler:innen erfolgreich verknüpft';

  @override
  String get all_players_selected => 'Alle Spieler:innen ausgewählt';

  @override
  String get all_time => 'Gesamter Zeitraum';

  @override
  String get app_name => 'Tallee';

  @override
  String get associate_game => 'Spielvorlage verknüpfen';

  @override
  String get associate_group => 'Gruppe verknüpfen';

  @override
  String get associate_players => 'Spieler:innen verknüpfen';

  @override
  String get average_score => 'Durchschnittliche Punktzahl';

  @override
  String get best_player => 'Beste:r Spieler:in';

  @override
  String get best_score => 'Beste Punktzahl';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get choose_date_range => 'Datumsbereich auswählen';

  @override
  String get choose_game => 'Spielvorlage wählen';

  @override
  String get choose_group => 'Gruppe wählen';

  @override
  String get choose_match_file => 'Spiel-Datei auswählen';

  @override
  String get choose_other_file => 'Bitte wähle eine andere Datei aus.';

  @override
  String get choose_scopes => 'Bereiche wählen';

  @override
  String get choose_timeframes => 'Zeiträume wählen';

  @override
  String get choose_types => 'Typen wählen';

  @override
  String get choose_where_to_save =>
      'Wähle aus, wo du dein Match speichern möchtest:';

  @override
  String get classifier => 'Klassifikator';

  @override
  String get classifier_description =>
      'Lege fest, welche Kennzahl berechnet und in der Statistik angezeigt wird.';

  @override
  String get click_another_player_to_create_a_pair =>
      'Klicke einen weiteren Spieler an, um ein Paar zu erstellen';

  @override
  String get close => 'Schließen';

  @override
  String get code_copied => 'Code in die Zwischenablage kopiert';

  @override
  String get code_pasted_from_clipboard =>
      'Code aus der Zwischenablage eingefügt';

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
  String get continue_ => 'Weiter';

  @override
  String get copy_code => 'Code kopieren';

  @override
  String could_not_add_player(String playerName) {
    return 'Spieler:in $playerName konnte nicht hinzugefügt werden';
  }

  @override
  String get create_as_new => 'Neu erstellen';

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
  String create_statistic(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Statistiken erstellen ($count)',
      one: 'Statistik erstellen',
      zero: 'Statistiken erstellen',
    );
    return '$_temp0';
  }

  @override
  String get create_teams => 'Teams erstellen';

  @override
  String get created_on => 'Erstellt am';

  @override
  String get creation_date => 'Erstellungsdatum';

  @override
  String get custom => 'Benutzerdefiniert';

  @override
  String get danger_zone => 'Gefahrenzone';

  @override
  String get data => 'Daten';

  @override
  String get data_backup => 'Daten & Backup';

  @override
  String get data_successfully_deleted => 'Daten erfolgreich gelöscht';

  @override
  String get data_successfully_exported => 'Daten erfolgreich exportiert';

  @override
  String get data_successfully_imported => 'Daten erfolgreich importiert';

  @override
  String get data_transfer => 'Datentransfer';

  @override
  String get data_transfer_description =>
      'Exportiere und Importiere alle deine Spiele, Spieler:innen, Gruppen, Spielvorlagen, Statistiken in eine Datei. Dies dient als Backup oder zum Übertragen der Daten auf ein neues Gerät. Um deine Spiele mit Freunden zu Teilen, öffne ein Spiel und wähle \"Teilen\".';

  @override
  String days_ago(Object count) {
    return 'vor $count Tagen';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get delete_all_data => 'Alle Daten löschen';

  @override
  String get delete_app_data_description =>
      'Lösche all deine lokalen Daten unwiderruflich. Dieser Vorgang kann nicht rückgängig gemacht werden.';

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
  String get dont_update => 'Nicht aktualisieren';

  @override
  String get drag_to_set_placement => 'Ziehen um Platzierung zu setzen';

  @override
  String get duplicate => 'Duplizieren';

  @override
  String get edit_game => 'Spielvorlage bearbeiten';

  @override
  String get edit_group => 'Gruppe bearbeiten';

  @override
  String get edit_match => 'Spiel bearbeiten';

  @override
  String get edit_name => 'Name ändern';

  @override
  String get edit_player => 'Spieler bearbeiten';

  @override
  String get email => 'E-Mail-Adresse';

  @override
  String get enable => 'Aktivieren';

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
  String get error_editing_player =>
      'Fehler beim Bearbeiten des Spielers, bitte erneut versuchen';

  @override
  String error_loading_match(String error) {
    return 'Fehler beim Laden: $error';
  }

  @override
  String get error_loading_privacy_policy =>
      'Fehler beim Laden der Datenschutzerklärung';

  @override
  String get error_reading_file => 'Fehler beim Lesen der Datei';

  @override
  String get error_report_hint =>
      'Bitte beschreibe die Schritte, die du vor dem Fehler durchgeführt hast, und in welcher Form dieser aufgetreten ist';

  @override
  String get error_report_info_text =>
      'Das Melden eines Fehlers hilft uns, Probleme in Tallee zu finden und zu beheben!';

  @override
  String get error_sending_feedback =>
      'Feedback konnte nicht gesendet werden. Bitte versuche es erneut.';

  @override
  String get error_while_processing_file_try_again =>
      'Fehler beim Verarbeiten der Datei. Bitte versuche es erneut';

  @override
  String expires_in(String time) {
    return 'Läuft ab in $time';
  }

  @override
  String get export_canceled => 'Export abgebrochen';

  @override
  String get export_data => 'Daten exportieren';

  @override
  String get favourites => 'Favoriten';

  @override
  String get feedback_hint => 'Deine Nachricht oder Kritik';

  @override
  String get feedback_info_text =>
      'Dein Feedback hilft uns, Tallee stetig zu verbessern!';

  @override
  String get file_couldnt_be_accessed =>
      'Die Datei konnte nicht geöffnet werden';

  @override
  String get file_share_instruction =>
      'Spiel-Daten manuell in einer Datei teilen für eine vollständige lokale Übertragung.';

  @override
  String get filter => 'Filter';

  @override
  String get finished_matches => 'Beendete Spiele';

  @override
  String get format_exception => 'Formatfehler (siehe Konsole)';

  @override
  String get game => 'Spielvorlage';

  @override
  String get game_associated => 'Spielvorlage erfolgreich verknüpft';

  @override
  String get game_name => 'Spielvorlagenname';

  @override
  String get games => 'Spielvorlagen';

  @override
  String get general => 'Allgemein';

  @override
  String get get_started => 'Loslegen';

  @override
  String get group => 'Gruppe';

  @override
  String get group_associated => 'Gruppe erfolgreich verknüpft';

  @override
  String get group_members => 'Gruppenmitglieder';

  @override
  String get group_name => 'Gruppenname';

  @override
  String get group_profile => 'Gruppenprofil';

  @override
  String get groups => 'Gruppen';

  @override
  String here_is_shared_match(String matchName) {
    return 'Hier ist das geteilte Match \"$matchName\"';
  }

  @override
  String get highest_score => 'Höchste Punkte';

  @override
  String get import_canceled => 'Import abgebrochen';

  @override
  String get import_data => 'Daten importieren';

  @override
  String get import_description =>
      'Importiere deine Tallee-Daten (.json) aus einer zuvor exportierten Datei. Dies dient zum Wiederherstellen eines Backups oder zum Übertragen von Daten auf ein neues Gerät. Um geteilte Spiele zu importieren, tippe auf das QR-Code-Symbol in der Spielansicht.';

  @override
  String get import_file_instruction =>
      'Wähle eine Spiel-Datei (.tallee), die aus einem Tallee-Spiel-Share exportiert wurde, um die Daten zu importieren.';

  @override
  String get import_match => 'Spiel importieren';

  @override
  String get import_preview_description =>
      'Die folgenden Daten werden importiert';

  @override
  String get incompatible_version =>
      'Diese Datei wurde mit einer anderen Version von Tallee erstellt und kann nicht importiert werden. Bitte aktualisiere deine App und versuche es erneut.';

  @override
  String get info => 'Info';

  @override
  String get input_token_instruction =>
      'Gib einen Match-Share-Token ein, den eine andere Person mit Tallee erstellt hat, um das Match zu importieren.';

  @override
  String get invalid_email => 'Bitte gib eine gültige E-Mail-Adresse ein.';

  @override
  String get invalid_extension => 'Ungültige Dateiendung.';

  @override
  String get invalid_file => 'Ungültige Datei.';

  @override
  String get invalid_qr_code => 'Dieser QR-Code ist ungültig oder abgelaufen.';

  @override
  String get invalid_schema => 'Ungültiges Schema';

  @override
  String get invalid_token => 'Ungültiger Token';

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
  String get later => 'Später';

  @override
  String get legal => 'Rechtliches';

  @override
  String get legal_notice => 'Impressum';

  @override
  String get licenses => 'Lizenzen';

  @override
  String lives(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Leben',
      one: 'Leben',
    );
    return '$_temp0';
  }

  @override
  String get loading => 'Lädt...';

  @override
  String get loading_match => 'Lade Match...';

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
  String get match_not_ended_share_warning =>
      'Spiele können erst geteilt werden, wenn sie beendet wurden.';

  @override
  String get match_profile => 'Spielprofil';

  @override
  String get match_receive => 'Spiel empfangen';

  @override
  String get match_share => 'Spiel teilen';

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
  String get name => 'Name';

  @override
  String get names_or_descriptions_too_long =>
      'Die Daten enthalten zu lange Namen oder Beschreibungen.';

  @override
  String get network_error =>
      'Netzwerkfehler. Bitte überprüfe deine Verbindung.';

  @override
  String get new_game_will_be_created => 'Neue Spielvorlage wird erstellt';

  @override
  String get new_group_will_be_created => 'Neue Gruppe wird erstellt';

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
  String get next => 'Weiter';

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
  String get no_matching_local_game_found =>
      'Keine passende lokale Spielvorlage gefunden. Eine neue wird erstellt.';

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
  String get onboarding_players_teams_desc =>
      'Organisiere deine Spielrunde in Gruppen und teile Spieler:innen in Teams ein.';

  @override
  String get onboarding_players_teams_title => 'Spieler:innen & Teams';

  @override
  String get onboarding_privacy_desc =>
      'Teile Spiele ganz einfach per QR-Code oder exportiere bestimmte Spiele und vollständige Backups als lokale Dateien. Deine Daten bleiben standardmäßig privat.';

  @override
  String get onboarding_privacy_title => 'Teilen & Datenschutz';

  @override
  String get onboarding_rulesets_desc =>
      'Erstelle eigene Spielvorlagen und wähle den passenden Regelsatz: Höchste Punktzahl, Leben, Platzierung und mehr.';

  @override
  String get onboarding_rulesets_title => 'Flexible Regelsätze';

  @override
  String get onboarding_statistics_desc =>
      'Erhalte aussagekräftige Einblicke in deine Spiele mit Statistiken, die individuell auf deine Bedürfnisse zugeschnitten sind.';

  @override
  String get onboarding_statistics_title => 'Spielstatistiken';

  @override
  String get onboarding_welcome_desc =>
      'Dein Begleiter für Spieleabende. Erfasse Spiele, verfolge Sieger und verwalte deine Spielhistorie.';

  @override
  String get onboarding_welcome_title => 'Willkommen bei Tallee';

  @override
  String get online_sharing_consent_text =>
      'Damit andere dein Match laden können, müssen die Spieldaten an unseren Server übertragen werden. Der Share-Token ist nur vorübergehend gültig und die Daten werden nach 10 Minuten automatisch gelöscht. Möchtest du Online-Teilen aktivieren?';

  @override
  String get online_sharing_disabled => 'Online-Teilen ist deaktiviert';

  @override
  String get online_sharing_info_text =>
      'Für das Teilen von Spielen per QR Code oder Token stellt die App eine Verbindung zu externen Servern her. Zum Schutz deiner Daten ist diese Funktion standardmäßig deaktiviert. Alle übertragenen Daten werden nach 10 Minuten automatisch gelöscht. Du kannst Spiele auch lokal als Datei teilen.';

  @override
  String get online_sharing_title => 'Online-Teilen aktivieren';

  @override
  String get open_settings => 'Einstellungen öffnen';

  @override
  String get optional => 'optional';

  @override
  String pair(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Paare',
      one: 'Paar',
    );
    return '$_temp0';
  }

  @override
  String get parsing_error =>
      'Fehler beim Verarbeiten der Daten. Bitte versuche es später erneut.';

  @override
  String get place => 'Platz';

  @override
  String get placement => 'Platzierung';

  @override
  String get played_matches => 'Gespielte Spiele';

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
  String get player_name => 'Name des/der Spieler:in';

  @override
  String get player_profile => 'Spieler:in-Profil';

  @override
  String get players => 'Spieler:innen';

  @override
  String get point => 'Punkt';

  @override
  String get points => 'Punkte';

  @override
  String get preview_match => 'Spielvorschau';

  @override
  String get privacy_policy => 'Datenschutzerklärung';

  @override
  String get qr_code_expired => 'QR-Code abgelaufen';

  @override
  String get qr_code_parsing_error =>
      'Der gescannte Code enthält keine gültigen Match-Daten.';

  @override
  String get random_color => 'Zufällige Farbe';

  @override
  String get remaining => 'verbleibend';

  @override
  String get report_error => 'Fehler melden';

  @override
  String get required => 'erforderlich';

  @override
  String get results => 'Ergebnisse';

  @override
  String get ruleset => 'Regelwerk';

  @override
  String get save_changes => 'Änderungen speichern';

  @override
  String get save_file => 'Datei speichern';

  @override
  String get save_match => 'Spiel speichern';

  @override
  String get scan_qr_code_instruction =>
      'Scanne den QR-Code mit einer anderen Tallee-App, um das Match zu teilen.';

  @override
  String get scan_qr_receive_instruction =>
      'Scanne den QR-Code einer anderen Tallee-App, um das Match zu empfangen.';

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
  String get select_a_display_color => 'Wähle eine Anzeigefarbe aus.';

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
  String get select_winners => 'Gewinner:innen wählen';

  @override
  String get selected_games => 'Ausgewählte Spielvorlagen';

  @override
  String get selected_groups => 'Ausgewählte Gruppen';

  @override
  String get selected_players => 'Ausgewählte Spieler:innen';

  @override
  String get send_code_instruction =>
      'Sende diesen Code an eine Person, die ebenfalls Tallee hat, um das aktuelle Match zu teilen.';

  @override
  String get send_feedback => 'Feedback senden';

  @override
  String get sending => 'Wird gesendet...';

  @override
  String get server_error => 'Interner Server Fehler';

  @override
  String get set_name => 'Name setzen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get share => 'Teilen';

  @override
  String get share_as_qr_code_info =>
      'Damit du ein Spiel als QR-Code mit anderen teilen kannst, muss Online-Teilen aktiviert sein';

  @override
  String get share_as_token_info =>
      'Damit du ein Spiel als Code mit anderen teilen kannst, muss Online-Teilen aktiviert sein';

  @override
  String share_match_text(String code) {
    return 'Hier sind die Match-Daten für unser Spiel! Gib den Code $code in Tallee ein.';
  }

  @override
  String get share_match_title => 'Tallee Match teilen';

  @override
  String get share_token_format_info =>
      'Share-Token bestehen aus 6 alphanumerischen Zeichen.';

  @override
  String get show_app_walkthrough => 'App-Führung';

  @override
  String get showcase_create_game_button =>
      'Tippe auf „Spielvorlage erstellen“, sobald du bereit bist.';

  @override
  String get showcase_create_game_name =>
      'Gib der Spielvorlage hier einen Namen.';

  @override
  String get showcase_create_game_ruleset =>
      'Standardmäßig ist der Regelsatz „Gewinner“ ausgewählt, den wir für dieses Beispiel verwenden. Für andere Regelsätze tippe auf die Kachel..';

  @override
  String get showcase_create_match_button =>
      'Sobald du alle Einstellungen vorgenommen hast, tippe hier, um das Spiel zu erstellen.';

  @override
  String get showcase_create_match_game =>
      'Wähle die zuvor erstellte Spielvorlage aus, indem du hier tippst.';

  @override
  String get showcase_create_match_name => 'Gib deinem Spiel einen Namen.';

  @override
  String get showcase_create_match_players =>
      'Wähle hier die teilnehmenden Spieler:innen aus. Um neue zu erstellen, tippe nach der Namenseingabe auf das Plus-Symbol neben der Suchleiste.';

  @override
  String get showcase_game_view_create =>
      'Tippe auf die Schaltfläche unten, um eine neue Spielvorlage zu erstellen.';

  @override
  String get showcase_match_view_create =>
      'Lass uns dein erstes Spiel erfassen. Tippe dazu auf die Schaltfläche \"Spiel erstellen\".';

  @override
  String get showcase_nav_game =>
      'Um ein Spiel zu erstellen zu können, musst du zuerst eine Spielvorlage erstellen. Lass uns damit anfangen, zum Spielvorlagen-Reiter zu wechseln.';

  @override
  String get showcase_nav_match =>
      'Da wir nun eine Spielvorlage erstellt haben, können wir zum Spiele-Reiter wechseln.';

  @override
  String get showcase_select_winner =>
      'Um deine Gewinner:innen festzulegen, wähle sie einfach hier aus und tippe unten auf die Speichern-Schaltfläche.';

  @override
  String get skip => 'Überspringen';

  @override
  String get statistic => 'Statistik';

  @override
  String get statistics => 'Statistiken';

  @override
  String successfully_added_player(String playerName) {
    return 'Spieler:in $playerName erfolgreich hinzugefügt';
  }

  @override
  String get successfully_processed_file => 'Datei erfolgreich verarbeitet';

  @override
  String get tap_import_to_continue =>
      'Tippe auf Match importieren, um fortzufahren';

  @override
  String get tap_to_browse => 'Tippen zum Durchsuchen';

  @override
  String get tap_to_choose_different_game =>
      'Tippe die Spielvorlage an, um eine andere auszuwählen';

  @override
  String get tap_to_choose_different_group =>
      'Tippe die Gruppe an, um eine andere auszuwählen';

  @override
  String get tap_to_choose_existing => 'Tippen zum manuellen Auswählen';

  @override
  String get team => 'Team';

  @override
  String get team_match => 'Teamspiel';

  @override
  String get team_matches => 'Teamspiele';

  @override
  String get teams => 'Teams';

  @override
  String get thank_you_for_feedback => 'Vielen Dank für dein Feedback!';

  @override
  String get thank_you_for_report => 'Vielen Dank für deine Fehlermeldung!';

  @override
  String get there_are_no_games_matching_your_search =>
      'Es gibt keine Spielvorlagen, die deiner Suche entspricht';

  @override
  String get there_is_no_game_matching_your_search =>
      'Es gibt keine Spielvorlage, die deiner Suche entspricht';

  @override
  String get there_is_no_group_matching_your_search =>
      'Es gibt keine Gruppe, die deiner Suche entspricht';

  @override
  String get there_is_no_match_matching_your_filter =>
      'Es gibt kein Spiel, das deinem Filter entspricht';

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
  String get today => 'Heute';

  @override
  String get today_at => 'Heute um';

  @override
  String get token_expired => 'Token expired';

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
  String get unexpected_error => 'Ein unerwarteter Fehler ist aufgetreten.';

  @override
  String get unknown_exception => 'Unbekannter Fehler (siehe Konsole)';

  @override
  String get update_app_export_desc =>
      'Du hast nicht die neueste App-Version, was zu Problemen beim Datenimport in eine andere Tallee-App führen kann.';

  @override
  String get update_app_import_desc =>
      'Du hast nicht die neueste App-Version, was zu Problemen beim Importieren deiner Daten führen kann.';

  @override
  String get update_app_version =>
      'Bitte aktualisiert eure Apps auf die neueste Version und versucht es erneut.';

  @override
  String get update_available => 'Update verfügbar';

  @override
  String get update_available_content => 'Eine neue Version ist verfügbar.';

  @override
  String get update_features_fixes_desc =>
      'Bitte aktualisiere die App, um die neuesten Funktionen und Verbesserungen zu nutzen.';

  @override
  String get update_now => 'Jetzt aktualisieren';

  @override
  String get version => 'Version';

  @override
  String get whats_new => 'Neuigkeiten';

  @override
  String get winner => 'Gewinner:in';

  @override
  String get winrate => 'Siegquote';

  @override
  String get worst_score => 'Schlechteste Punktzahl';

  @override
  String get yesterday_at => 'Gestern um';
}
