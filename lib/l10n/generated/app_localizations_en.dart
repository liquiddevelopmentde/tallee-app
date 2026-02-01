// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get all_players => 'All players';

  @override
  String get all_players_selected => 'All players selected';

  @override
  String get amount_of_matches => 'Amount of Matches';

  @override
  String get app_name => 'Tallee';

  @override
  String get best_player => 'Best Player';

  @override
  String get cancel => 'Cancel';

  @override
  String get choose_game => 'Choose Game';

  @override
  String get choose_group => 'Choose Group';

  @override
  String get choose_ruleset => 'Choose Ruleset';

  @override
  String could_not_add_player(Object playerName) {
    return 'Could not add player';
  }

  @override
  String get create_group => 'Create Group';

  @override
  String get create_match => 'Create match';

  @override
  String get create_new_group => 'Create new group';

  @override
  String get created_on => 'Created on';

  @override
  String get create_new_match => 'Create new match';

  @override
  String get data => 'Data';

  @override
  String get data_successfully_deleted => 'Data successfully deleted';

  @override
  String get data_successfully_exported => 'Data successfully exported';

  @override
  String get data_successfully_imported => 'Data successfully imported';

  @override
  String days_ago(int count) {
    return '$count days ago';
  }

  @override
  String get delete => 'Delete';

  @override
  String get delete_all_data => 'Delete all data';

  @override
  String get delete_group => 'Delete Group';

  @override
  String get edit_group => 'Edit Group';

  @override
  String get error_creating_group =>
      'Error while creating group, please try again';

  @override
  String get error_reading_file => 'Error reading file';

  @override
  String get export_canceled => 'Export canceled';

  @override
  String get export_data => 'Export data';

  @override
  String get format_exception => 'Format Exception (see console)';

  @override
  String get game => 'Game';

  @override
  String get game_name => 'Game Name';

  @override
  String get group => 'Group';

  @override
  String get group_name => 'Group name';

  @override
  String get group_profile => 'Group Profile';

  @override
  String get groups => 'Groups';

  @override
  String get home => 'Home';

  @override
  String get import_canceled => 'Import canceled';

  @override
  String get import_data => 'Import data';

  @override
  String get info => 'Info';

  @override
  String get invalid_schema => 'Invalid Schema';

  @override
  String get least_points => 'Least Points';

  @override
  String get legal => 'Legal';

  @override
  String get legal_notice => 'Legal Notice';

  @override
  String get licenses => 'Licenses';

  @override
  String get match_in_progress => 'Match in progress...';

  @override
  String get match_name => 'Match name';

  @override
  String get matches => 'Matches';

  @override
  String get members => 'Members';

  @override
  String get most_points => 'Most Points';

  @override
  String get no_data_available => 'No data available';

  @override
  String get no_groups_created_yet => 'No groups created yet';

  @override
  String get no_licenses_found => 'No licenses found';

  @override
  String get no_license_text_available => 'No license text available';

  @override
  String get no_matches_created_yet => 'No matches created yet';

  @override
  String get no_players_created_yet => 'No players created yet';

  @override
  String get no_players_found_with_that_name =>
      'No players found with that name';

  @override
  String get no_players_selected => 'No players selected';

  @override
  String get no_recent_matches_available => 'No recent matches available';

  @override
  String get no_second_match_available => 'No second match available';

  @override
  String get no_statistics_available => 'No statistics available';

  @override
  String get none => 'None';

  @override
  String get none_group => 'None';

  @override
  String get not_available => 'Not available';

  @override
  String get played_matches => 'Played Matches';

  @override
  String get player_name => 'Player name';

  @override
  String get players => 'Players';

  @override
  String players_count(int count) {
    return '$count Players';
  }

  @override
  String get privacy_policy => 'Privacy Policy';

  @override
  String get quick_create => 'Quick Create';

  @override
  String get recent_matches => 'Recent Matches';

  @override
  String get ruleset => 'Ruleset';

  @override
  String get ruleset_least_points =>
      'Inverse scoring: the player with the fewest points wins.';

  @override
  String get ruleset_most_points =>
      'Traditional ruleset: the player with the most points wins.';

  @override
  String get ruleset_single_loser =>
      'Exactly one loser is determined; last place receives the penalty or consequence.';

  @override
  String get ruleset_single_winner =>
      'Exactly one winner is chosen; ties are resolved by a predefined tiebreaker.';

  @override
  String get search_for_groups => 'Search for groups';

  @override
  String get search_for_players => 'Search for players';

  @override
  String get select_winner => 'Select Winner:';

  @override
  String get selected_players => 'Selected players';

  @override
  String get settings => 'Settings';

  @override
  String get single_loser => 'Single Loser';

  @override
  String get single_winner => 'Single Winner';

  @override
  String get highest_score => 'Highest Score';

  @override
  String get lowest_score => 'Lowest Score';

  @override
  String get multiple_winners => 'Multiple Winners';

  @override
  String get statistics => 'Statistics';

  @override
  String get stats => 'Stats';

  @override
  String successfully_added_player(String playerName) {
    return 'Successfully added player $playerName';
  }

  @override
  String get there_is_no_group_matching_your_search =>
      'There is no group matching your search';

  @override
  String get this_cannot_be_undone => 'This can\'t be undone.';

  @override
  String get today_at => 'Today at';

  @override
  String get undo => 'Undo';

  @override
  String get unknown_exception => 'Unknown Exception (see console)';

  @override
  String get winner => 'Winner';

  @override
  String get winrate => 'Winrate';

  @override
  String get wins => 'Wins';

  @override
  String get yesterday_at => 'Yesterday at';
}
