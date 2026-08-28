// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get add_team => 'Add Team';

  @override
  String get all => 'All';

  @override
  String get all_players => 'All players';

  @override
  String get all_players_selected => 'All players selected';

  @override
  String get all_time => 'All time';

  @override
  String get app_name => 'Tallee';

  @override
  String get average_score => 'Average score';

  @override
  String get best_player => 'Best Player';

  @override
  String get best_score => 'Best score';

  @override
  String get cancel => 'Cancel';

  @override
  String get choose_game => 'Choose Game';

  @override
  String get choose_group => 'Choose Group';

  @override
  String get choose_scopes => 'Choose Scopes';

  @override
  String get choose_timeframes => 'Choose Timeframes';

  @override
  String get choose_types => 'Choose Types';

  @override
  String get classifier => 'Classifier';

  @override
  String get classifier_description =>
      'Choose which metric is calculated and shown in this statistic.';

  @override
  String get click_another_player_to_create_a_pair =>
      'Click another player to create a pair';

  @override
  String get color => 'Color';

  @override
  String get color_blue => 'Blue';

  @override
  String get color_green => 'Green';

  @override
  String get color_orange => 'Orange';

  @override
  String get color_pink => 'Pink';

  @override
  String get color_purple => 'Purple';

  @override
  String get color_red => 'Red';

  @override
  String get color_teal => 'Teal';

  @override
  String get color_yellow => 'Yellow';

  @override
  String get confirm => 'Confirm';

  @override
  String could_not_add_player(String playerName) {
    return 'Could not add player $playerName';
  }

  @override
  String get create_game => 'Create Game';

  @override
  String get create_group => 'Create Group';

  @override
  String get create_match => 'Create Match';

  @override
  String get create_new_group => 'Create new group';

  @override
  String get create_new_match => 'Create new match';

  @override
  String get create_statistic => 'Create statistic';

  @override
  String get create_teams => 'Create teams';

  @override
  String get created_on => 'Created on';

  @override
  String get current => 'Current';

  @override
  String get data => 'Data';

  @override
  String get data_successfully_deleted => 'Data successfully deleted';

  @override
  String get data_successfully_exported => 'Data successfully exported';

  @override
  String get data_successfully_imported => 'Data successfully imported';

  @override
  String days_ago(Object count) {
    return '$count days ago';
  }

  @override
  String get delete => 'Delete';

  @override
  String get delete_all_data => 'Delete all data';

  @override
  String get delete_game => 'Delete Game';

  @override
  String delete_game_with_matches_warning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
    );
    return 'If you delete this game template, $_temp0 using this game template will also be deleted.';
  }

  @override
  String get delete_group => 'Delete Group';

  @override
  String get delete_group_warning_details =>
      'This action cannot be undone. The group will be removed from all games, but members will remain assigned to the game.';

  @override
  String get delete_match => 'Delete Match';

  @override
  String get delete_player => 'Delete player?';

  @override
  String get delete_player_warning_details =>
      'This action cannot be undone. Deleted players will still appear in past matches and be included in statistics.';

  @override
  String get delete_statistic => 'Delete statistic';

  @override
  String get deleted => 'Deleted';

  @override
  String get description => 'Description';

  @override
  String get displayed_entries => 'Displayed entries';

  @override
  String get drag_to_set_placement => 'Drag to set placement';

  @override
  String get edit_game => 'Edit Game';

  @override
  String get edit_group => 'Edit Group';

  @override
  String get edit_match => 'Edit Match';

  @override
  String get edit_name => 'Edit name';

  @override
  String get edit_player => 'Edit player';

  @override
  String get enter_points => 'Enter points';

  @override
  String get enter_results => 'Enter Results';

  @override
  String get error_creating_group =>
      'Error while creating group, please try again';

  @override
  String get error_deleting_game =>
      'Error while deleting game, please try again';

  @override
  String get error_editing_group =>
      'Error while editing group, please try again';

  @override
  String get error_reading_file => 'Error reading file';

  @override
  String get export_canceled => 'Export canceled';

  @override
  String get export_data => 'Export data';

  @override
  String get favourites => 'Favourites';

  @override
  String get file_couldnt_be_accessed => 'The file could not be accessed';

  @override
  String get filter => 'Filter';

  @override
  String get finish_match => 'Finish';

  @override
  String get format_exception => 'Format Exception (see console)';

  @override
  String get game => 'Game';

  @override
  String get game_name => 'Game Name';

  @override
  String get games => 'Games';

  @override
  String get group => 'Group';

  @override
  String get group_name => 'Group name';

  @override
  String get group_profile => 'Group Profile';

  @override
  String get groups => 'Groups';

  @override
  String get highest_score => 'Highest Score';

  @override
  String get history => 'History';

  @override
  String get import_canceled => 'Import canceled';

  @override
  String get import_data => 'Import data';

  @override
  String get import_preview_description =>
      'The following data will be imported';

  @override
  String get info => 'Info';

  @override
  String get invalid_schema => 'Invalid Schema';

  @override
  String get last_180_days => 'Last 180 days';

  @override
  String get last_30_days => 'Last 30 days';

  @override
  String get last_7_days => 'Last 7 days';

  @override
  String get last_90_days => 'Last 90 days';

  @override
  String get last_year => 'Last year';

  @override
  String get legal => 'Legal';

  @override
  String get legal_notice => 'Legal Notice';

  @override
  String get licenses => 'Licenses';

  @override
  String get loading => 'Loading...';

  @override
  String get loser => 'Loser';

  @override
  String get lowest_score => 'Lowest Score';

  @override
  String get manage_members => 'Manage Members';

  @override
  String get match_in_progress => 'Match in progress...';

  @override
  String get match_name => 'Match name';

  @override
  String get match_profile => 'Match Profile';

  @override
  String get matches => 'Matches';

  @override
  String get matches_played => 'Matches played';

  @override
  String get matches_won => 'Matches won';

  @override
  String get member => 'Member';

  @override
  String get members => 'Members';

  @override
  String get multiple_winners => 'Multiple Winners';

  @override
  String get names_or_descriptions_too_long =>
      'The data contains names or descriptions that are too long.';

  @override
  String get no_data_available => 'No data available';

  @override
  String get no_data_to_export => 'No data to export';

  @override
  String get no_games_created_yet => 'No games created yet';

  @override
  String get no_groups_created_yet => 'No groups created yet';

  @override
  String get no_license_text_available => 'No license text available';

  @override
  String get no_matches_created_yet => 'No matches created yet';

  @override
  String get no_matches_in_progress => 'No matches in progress';

  @override
  String get no_matches_played_yet => 'No games played yet';

  @override
  String get no_players_available => 'No players available';

  @override
  String get no_players_created_yet => 'No players created yet';

  @override
  String get no_players_found_with_that_name =>
      'No players found with that name';

  @override
  String get no_players_selected => 'No players selected';

  @override
  String get no_results_entered_yet => 'No results entered yet';

  @override
  String get no_statistics_created_yet => 'No statistics created yet';

  @override
  String get no_statistics_with_filter =>
      'No statistics with the selected filter';

  @override
  String get no_teams_available => 'No teams available';

  @override
  String get none => 'None';

  @override
  String get none_group => 'None';

  @override
  String get not_part_of_any_group => 'Not part of any group yet';

  @override
  String get place => 'place';

  @override
  String get placement => 'Placement';

  @override
  String get played_matches => 'Played Matches';

  @override
  String get player_profile => 'Player Profile';

  @override
  String get players => 'Players';

  @override
  String get point => 'Point';

  @override
  String get points => 'Points';

  @override
  String get privacy_policy => 'Privacy Policy';

  @override
  String get random_color => 'Random color';

  @override
  String get results => 'Results';

  @override
  String get ruleset => 'Ruleset';

  @override
  String get save_changes => 'Save Changes';

  @override
  String get scope => 'Scope';

  @override
  String get scope_description =>
      'Choose which games or players are included in the calculation.';

  @override
  String get search_for_games => 'Search for games';

  @override
  String get search_for_groups => 'Search for groups';

  @override
  String get search_for_players => 'Search for players';

  @override
  String get search_for_scopes => 'Search for scopes';

  @override
  String get search_for_timeframes => 'Search for timeframes';

  @override
  String get search_for_types => 'Search for types';

  @override
  String get select_a_classifier => 'Select a classifier';

  @override
  String get select_a_display_color => 'Select a display color';

  @override
  String get select_a_scope => 'Select a scope';

  @override
  String get select_a_timeframe => 'Select a timeframe';

  @override
  String get select_loser => 'Select Loser';

  @override
  String get select_the_filtered_timeframe =>
      'Select the timeframe you want to filter by.';

  @override
  String get select_winner => 'Select Winner';

  @override
  String get select_winners => 'Select Winners';

  @override
  String get selected_games => 'Selected games';

  @override
  String get selected_groups => 'Selected groups';

  @override
  String get selected_players => 'Selected players';

  @override
  String get set_name => 'Set name';

  @override
  String get settings => 'Settings';

  @override
  String get single_loser => 'Single Loser';

  @override
  String get single_winner => 'Single Winner';

  @override
  String get statistic => 'Statistic';

  @override
  String get statistics => 'Statistics';

  @override
  String successfully_added_player(String playerName) {
    return 'Successfully added player $playerName';
  }

  @override
  String get team => 'Team';

  @override
  String get team_match => 'Team Match';

  @override
  String get teams => 'Teams';

  @override
  String get there_are_no_games_matching_your_search =>
      'There are no games matching your search';

  @override
  String get there_is_no_group_matching_your_search =>
      'There is no group matching your search';

  @override
  String get there_is_no_match_matching_your_search =>
      'There is no match matching your search';

  @override
  String get this_cannot_be_undone => 'This can\'t be undone.';

  @override
  String get tie => 'Tie';

  @override
  String get timeframe => 'Timeframe';

  @override
  String get today_at => 'Today at';

  @override
  String get total_losses => 'Total losses';

  @override
  String get total_matches => 'Total matches';

  @override
  String get total_score => 'Total score';

  @override
  String get total_wins => 'Total wins';

  @override
  String get type => 'Type';

  @override
  String get unknown_exception => 'Unknown Exception (see console)';

  @override
  String get winner => 'Winner';

  @override
  String get winners => 'Winners';

  @override
  String get winrate => 'Winrate';

  @override
  String get worst_score => 'Worst score';

  @override
  String get yesterday_at => 'Yesterday at';
}
