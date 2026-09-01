import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @add_team.
  ///
  /// In en, this message translates to:
  /// **'Add Team'**
  String get add_team;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @all_players.
  ///
  /// In en, this message translates to:
  /// **'All players'**
  String get all_players;

  /// No description provided for @all_players_selected.
  ///
  /// In en, this message translates to:
  /// **'All players selected'**
  String get all_players_selected;

  /// No description provided for @all_time.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get all_time;

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Tallee'**
  String get app_name;

  /// No description provided for @average_score.
  ///
  /// In en, this message translates to:
  /// **'Average score'**
  String get average_score;

  /// No description provided for @best_player.
  ///
  /// In en, this message translates to:
  /// **'Best Player'**
  String get best_player;

  /// No description provided for @best_score.
  ///
  /// In en, this message translates to:
  /// **'Best score'**
  String get best_score;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @choose_date_range.
  ///
  /// In en, this message translates to:
  /// **'Choose date range'**
  String get choose_date_range;

  /// No description provided for @choose_game.
  ///
  /// In en, this message translates to:
  /// **'Choose Game'**
  String get choose_game;

  /// No description provided for @choose_group.
  ///
  /// In en, this message translates to:
  /// **'Choose Group'**
  String get choose_group;

  /// No description provided for @choose_scopes.
  ///
  /// In en, this message translates to:
  /// **'Choose Scopes'**
  String get choose_scopes;

  /// No description provided for @choose_timeframes.
  ///
  /// In en, this message translates to:
  /// **'Choose Timeframes'**
  String get choose_timeframes;

  /// No description provided for @choose_types.
  ///
  /// In en, this message translates to:
  /// **'Choose Types'**
  String get choose_types;

  /// No description provided for @classifier.
  ///
  /// In en, this message translates to:
  /// **'Classifier'**
  String get classifier;

  /// No description provided for @classifier_description.
  ///
  /// In en, this message translates to:
  /// **'Choose which metric is calculated and shown in this statistic.'**
  String get classifier_description;

  /// No description provided for @click_another_player_to_create_a_pair.
  ///
  /// In en, this message translates to:
  /// **'Click another player to create a pair'**
  String get click_another_player_to_create_a_pair;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @color_blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get color_blue;

  /// No description provided for @color_green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get color_green;

  /// No description provided for @color_orange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get color_orange;

  /// No description provided for @color_pink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get color_pink;

  /// No description provided for @color_purple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get color_purple;

  /// No description provided for @color_red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get color_red;

  /// No description provided for @color_teal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get color_teal;

  /// No description provided for @color_yellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get color_yellow;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @could_not_add_player.
  ///
  /// In en, this message translates to:
  /// **'Could not add player {playerName}'**
  String could_not_add_player(String playerName);

  /// No description provided for @create_game.
  ///
  /// In en, this message translates to:
  /// **'Create Game'**
  String get create_game;

  /// No description provided for @create_group.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get create_group;

  /// No description provided for @create_match.
  ///
  /// In en, this message translates to:
  /// **'Create Match'**
  String get create_match;

  /// No description provided for @create_new_group.
  ///
  /// In en, this message translates to:
  /// **'Create new group'**
  String get create_new_group;

  /// No description provided for @create_new_match.
  ///
  /// In en, this message translates to:
  /// **'Create new match'**
  String get create_new_match;

  /// No description provided for @create_statistic.
  ///
  /// In en, this message translates to:
  /// **'Create statistic'**
  String get create_statistic;

  /// No description provided for @create_teams.
  ///
  /// In en, this message translates to:
  /// **'Create teams'**
  String get create_teams;

  /// No description provided for @created_on.
  ///
  /// In en, this message translates to:
  /// **'Created on'**
  String get created_on;

  /// No description provided for @creation_date.
  ///
  /// In en, this message translates to:
  /// **'Creation date'**
  String get creation_date;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @data_successfully_deleted.
  ///
  /// In en, this message translates to:
  /// **'Data successfully deleted'**
  String get data_successfully_deleted;

  /// No description provided for @data_successfully_exported.
  ///
  /// In en, this message translates to:
  /// **'Data successfully exported'**
  String get data_successfully_exported;

  /// No description provided for @data_successfully_imported.
  ///
  /// In en, this message translates to:
  /// **'Data successfully imported'**
  String get data_successfully_imported;

  /// No description provided for @days_ago.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String days_ago(Object count);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @delete_all_data.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get delete_all_data;

  /// No description provided for @delete_game.
  ///
  /// In en, this message translates to:
  /// **'Delete Game'**
  String get delete_game;

  /// No description provided for @delete_game_with_matches_warning.
  ///
  /// In en, this message translates to:
  /// **'If you delete this game template, {count, plural, =1{1 match} other{{count} matches}} using this game template will also be deleted.'**
  String delete_game_with_matches_warning(int count);

  /// No description provided for @delete_group.
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get delete_group;

  /// No description provided for @delete_group_warning_details.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. The group will be removed from all games, but members will remain assigned to the game.'**
  String get delete_group_warning_details;

  /// No description provided for @delete_match.
  ///
  /// In en, this message translates to:
  /// **'Delete Match'**
  String get delete_match;

  /// No description provided for @delete_player.
  ///
  /// In en, this message translates to:
  /// **'Delete player?'**
  String get delete_player;

  /// No description provided for @delete_player_warning_details.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Deleted players will still appear in past matches and be included in statistics.'**
  String get delete_player_warning_details;

  /// No description provided for @delete_statistic.
  ///
  /// In en, this message translates to:
  /// **'Delete statistic'**
  String get delete_statistic;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @displayed_entries.
  ///
  /// In en, this message translates to:
  /// **'Displayed entries'**
  String get displayed_entries;

  /// No description provided for @drag_to_set_placement.
  ///
  /// In en, this message translates to:
  /// **'Drag to set placement'**
  String get drag_to_set_placement;

  /// No description provided for @edit_game.
  ///
  /// In en, this message translates to:
  /// **'Edit Game'**
  String get edit_game;

  /// No description provided for @edit_group.
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get edit_group;

  /// No description provided for @edit_match.
  ///
  /// In en, this message translates to:
  /// **'Edit Match'**
  String get edit_match;

  /// No description provided for @edit_name.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get edit_name;

  /// No description provided for @edit_player.
  ///
  /// In en, this message translates to:
  /// **'Edit player'**
  String get edit_player;

  /// No description provided for @enter_points.
  ///
  /// In en, this message translates to:
  /// **'Enter points'**
  String get enter_points;

  /// No description provided for @enter_results.
  ///
  /// In en, this message translates to:
  /// **'Enter Results'**
  String get enter_results;

  /// No description provided for @error_creating_group.
  ///
  /// In en, this message translates to:
  /// **'Error while creating group, please try again'**
  String get error_creating_group;

  /// No description provided for @error_deleting_game.
  ///
  /// In en, this message translates to:
  /// **'Error while deleting game, please try again'**
  String get error_deleting_game;

  /// No description provided for @error_editing_group.
  ///
  /// In en, this message translates to:
  /// **'Error while editing group, please try again'**
  String get error_editing_group;

  /// No description provided for @error_reading_file.
  ///
  /// In en, this message translates to:
  /// **'Error reading file'**
  String get error_reading_file;

  /// No description provided for @export_canceled.
  ///
  /// In en, this message translates to:
  /// **'Export canceled'**
  String get export_canceled;

  /// No description provided for @export_data.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get export_data;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @file_couldnt_be_accessed.
  ///
  /// In en, this message translates to:
  /// **'The file could not be accessed'**
  String get file_couldnt_be_accessed;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @format_exception.
  ///
  /// In en, this message translates to:
  /// **'Format Exception (see console)'**
  String get format_exception;

  /// No description provided for @game.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get game;

  /// No description provided for @game_name.
  ///
  /// In en, this message translates to:
  /// **'Game Name'**
  String get game_name;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @group_name.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get group_name;

  /// No description provided for @group_profile.
  ///
  /// In en, this message translates to:
  /// **'Group Profile'**
  String get group_profile;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @highest_score.
  ///
  /// In en, this message translates to:
  /// **'Highest Score'**
  String get highest_score;

  /// No description provided for @import_canceled.
  ///
  /// In en, this message translates to:
  /// **'Import canceled'**
  String get import_canceled;

  /// No description provided for @import_data.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get import_data;

  /// No description provided for @import_preview_description.
  ///
  /// In en, this message translates to:
  /// **'The following data will be imported'**
  String get import_preview_description;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @invalid_schema.
  ///
  /// In en, this message translates to:
  /// **'Invalid Schema'**
  String get invalid_schema;

  /// No description provided for @last_180_days.
  ///
  /// In en, this message translates to:
  /// **'Last 180 days'**
  String get last_180_days;

  /// No description provided for @last_30_days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last_30_days;

  /// No description provided for @last_7_days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last_7_days;

  /// No description provided for @last_90_days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get last_90_days;

  /// No description provided for @last_year.
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get last_year;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @legal_notice.
  ///
  /// In en, this message translates to:
  /// **'Legal Notice'**
  String get legal_notice;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @live_edit_mode.
  ///
  /// In en, this message translates to:
  /// **'Live Edit Mode'**
  String get live_edit_mode;

  /// No description provided for @lives.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{life} other{lives}}'**
  String lives(int count);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loser.
  ///
  /// In en, this message translates to:
  /// **'Loser'**
  String get loser;

  /// No description provided for @lowest_score.
  ///
  /// In en, this message translates to:
  /// **'Lowest Score'**
  String get lowest_score;

  /// No description provided for @manage_members.
  ///
  /// In en, this message translates to:
  /// **'Manage Members'**
  String get manage_members;

  /// No description provided for @match_in_progress.
  ///
  /// In en, this message translates to:
  /// **'Match in progress...'**
  String get match_in_progress;

  /// No description provided for @match_name.
  ///
  /// In en, this message translates to:
  /// **'Match name'**
  String get match_name;

  /// No description provided for @match_profile.
  ///
  /// In en, this message translates to:
  /// **'Match Profile'**
  String get match_profile;

  /// No description provided for @matches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// No description provided for @matches_played.
  ///
  /// In en, this message translates to:
  /// **'Matches played'**
  String get matches_played;

  /// No description provided for @matches_won.
  ///
  /// In en, this message translates to:
  /// **'Matches won'**
  String get matches_won;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @multiple_winners.
  ///
  /// In en, this message translates to:
  /// **'Multiple Winners'**
  String get multiple_winners;

  /// No description provided for @names_or_descriptions_too_long.
  ///
  /// In en, this message translates to:
  /// **'The data contains names or descriptions that are too long.'**
  String get names_or_descriptions_too_long;

  /// No description provided for @no_data_available.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get no_data_available;

  /// No description provided for @no_data_to_export.
  ///
  /// In en, this message translates to:
  /// **'No data to export'**
  String get no_data_to_export;

  /// No description provided for @no_games_created_yet.
  ///
  /// In en, this message translates to:
  /// **'No games created yet'**
  String get no_games_created_yet;

  /// No description provided for @no_groups_created_yet.
  ///
  /// In en, this message translates to:
  /// **'No groups created yet'**
  String get no_groups_created_yet;

  /// No description provided for @no_license_text_available.
  ///
  /// In en, this message translates to:
  /// **'No license text available'**
  String get no_license_text_available;

  /// No description provided for @no_matches_created_yet.
  ///
  /// In en, this message translates to:
  /// **'No matches created yet'**
  String get no_matches_created_yet;

  /// No description provided for @no_matches_played_yet.
  ///
  /// In en, this message translates to:
  /// **'No games played yet'**
  String get no_matches_played_yet;

  /// No description provided for @no_players_available.
  ///
  /// In en, this message translates to:
  /// **'No players available'**
  String get no_players_available;

  /// No description provided for @no_players_created_yet.
  ///
  /// In en, this message translates to:
  /// **'No players created yet'**
  String get no_players_created_yet;

  /// No description provided for @no_players_found_with_that_name.
  ///
  /// In en, this message translates to:
  /// **'No players found with that name'**
  String get no_players_found_with_that_name;

  /// No description provided for @no_players_selected.
  ///
  /// In en, this message translates to:
  /// **'No players selected'**
  String get no_players_selected;

  /// No description provided for @no_results_entered_yet.
  ///
  /// In en, this message translates to:
  /// **'No results entered yet'**
  String get no_results_entered_yet;

  /// No description provided for @no_statistics_created_yet.
  ///
  /// In en, this message translates to:
  /// **'No statistics created yet'**
  String get no_statistics_created_yet;

  /// No description provided for @no_statistics_with_filter.
  ///
  /// In en, this message translates to:
  /// **'No statistics with the selected filter'**
  String get no_statistics_with_filter;

  /// No description provided for @no_teams_available.
  ///
  /// In en, this message translates to:
  /// **'No teams available'**
  String get no_teams_available;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @none_group.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none_group;

  /// No description provided for @not_part_of_any_group.
  ///
  /// In en, this message translates to:
  /// **'Not part of any group yet'**
  String get not_part_of_any_group;

  /// No description provided for @place.
  ///
  /// In en, this message translates to:
  /// **'place'**
  String get place;

  /// No description provided for @placement.
  ///
  /// In en, this message translates to:
  /// **'Placement'**
  String get placement;

  /// No description provided for @played_matches.
  ///
  /// In en, this message translates to:
  /// **'Played Matches'**
  String get played_matches;

  /// No description provided for @player_profile.
  ///
  /// In en, this message translates to:
  /// **'Player Profile'**
  String get player_profile;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @point.
  ///
  /// In en, this message translates to:
  /// **'Point'**
  String get point;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @random_color.
  ///
  /// In en, this message translates to:
  /// **'Random color'**
  String get random_color;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @ruleset.
  ///
  /// In en, this message translates to:
  /// **'Ruleset'**
  String get ruleset;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes;

  /// No description provided for @scope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get scope;

  /// No description provided for @scope_description.
  ///
  /// In en, this message translates to:
  /// **'Choose which games or players are included in the calculation.'**
  String get scope_description;

  /// No description provided for @search_for_games.
  ///
  /// In en, this message translates to:
  /// **'Search for games'**
  String get search_for_games;

  /// No description provided for @search_for_groups.
  ///
  /// In en, this message translates to:
  /// **'Search for groups'**
  String get search_for_groups;

  /// No description provided for @search_for_players.
  ///
  /// In en, this message translates to:
  /// **'Search for players'**
  String get search_for_players;

  /// No description provided for @search_for_scopes.
  ///
  /// In en, this message translates to:
  /// **'Search for scopes'**
  String get search_for_scopes;

  /// No description provided for @search_for_timeframes.
  ///
  /// In en, this message translates to:
  /// **'Search for timeframes'**
  String get search_for_timeframes;

  /// No description provided for @search_for_types.
  ///
  /// In en, this message translates to:
  /// **'Search for types'**
  String get search_for_types;

  /// No description provided for @select_a_classifier.
  ///
  /// In en, this message translates to:
  /// **'Select a classifier'**
  String get select_a_classifier;

  /// No description provided for @select_a_display_color.
  ///
  /// In en, this message translates to:
  /// **'Select a display color.'**
  String get select_a_display_color;

  /// No description provided for @select_a_scope.
  ///
  /// In en, this message translates to:
  /// **'Select a scope'**
  String get select_a_scope;

  /// No description provided for @select_a_timeframe.
  ///
  /// In en, this message translates to:
  /// **'Select a timeframe'**
  String get select_a_timeframe;

  /// No description provided for @select_loser.
  ///
  /// In en, this message translates to:
  /// **'Select Loser'**
  String get select_loser;

  /// No description provided for @select_the_filtered_timeframe.
  ///
  /// In en, this message translates to:
  /// **'Select the timeframe you want to filter by.'**
  String get select_the_filtered_timeframe;

  /// No description provided for @select_winner.
  ///
  /// In en, this message translates to:
  /// **'Select Winner'**
  String get select_winner;

  /// No description provided for @select_winners.
  ///
  /// In en, this message translates to:
  /// **'Select Winners'**
  String get select_winners;

  /// No description provided for @selected_games.
  ///
  /// In en, this message translates to:
  /// **'Selected games'**
  String get selected_games;

  /// No description provided for @selected_groups.
  ///
  /// In en, this message translates to:
  /// **'Selected groups'**
  String get selected_groups;

  /// No description provided for @selected_players.
  ///
  /// In en, this message translates to:
  /// **'Selected players'**
  String get selected_players;

  /// No description provided for @set_name.
  ///
  /// In en, this message translates to:
  /// **'Set name'**
  String get set_name;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @single_loser.
  ///
  /// In en, this message translates to:
  /// **'Single Loser'**
  String get single_loser;

  /// No description provided for @single_winner.
  ///
  /// In en, this message translates to:
  /// **'Single Winner'**
  String get single_winner;

  /// No description provided for @statistic.
  ///
  /// In en, this message translates to:
  /// **'Statistic'**
  String get statistic;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Success message when adding a player
  ///
  /// In en, this message translates to:
  /// **'Successfully added player {playerName}'**
  String successfully_added_player(String playerName);

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @team_match.
  ///
  /// In en, this message translates to:
  /// **'Team Match'**
  String get team_match;

  /// No description provided for @teams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get teams;

  /// No description provided for @there_are_no_games_matching_your_search.
  ///
  /// In en, this message translates to:
  /// **'There are no games matching your search'**
  String get there_are_no_games_matching_your_search;

  /// No description provided for @there_is_no_group_matching_your_search.
  ///
  /// In en, this message translates to:
  /// **'There is no group matching your search'**
  String get there_is_no_group_matching_your_search;

  /// No description provided for @there_is_no_match_matching_your_search.
  ///
  /// In en, this message translates to:
  /// **'There is no match matching your search'**
  String get there_is_no_match_matching_your_search;

  /// No description provided for @this_cannot_be_undone.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get this_cannot_be_undone;

  /// No description provided for @tie.
  ///
  /// In en, this message translates to:
  /// **'Tie'**
  String get tie;

  /// No description provided for @timeframe.
  ///
  /// In en, this message translates to:
  /// **'Timeframe'**
  String get timeframe;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @today_at.
  ///
  /// In en, this message translates to:
  /// **'Today at'**
  String get today_at;

  /// No description provided for @total_losses.
  ///
  /// In en, this message translates to:
  /// **'Total losses'**
  String get total_losses;

  /// No description provided for @total_matches.
  ///
  /// In en, this message translates to:
  /// **'Total matches'**
  String get total_matches;

  /// No description provided for @total_score.
  ///
  /// In en, this message translates to:
  /// **'Total score'**
  String get total_score;

  /// No description provided for @total_wins.
  ///
  /// In en, this message translates to:
  /// **'Total wins'**
  String get total_wins;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @unknown_exception.
  ///
  /// In en, this message translates to:
  /// **'Unknown Exception (see console)'**
  String get unknown_exception;

  /// No description provided for @winner.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winner;

  /// No description provided for @winners.
  ///
  /// In en, this message translates to:
  /// **'Winners'**
  String get winners;

  /// No description provided for @winrate.
  ///
  /// In en, this message translates to:
  /// **'Winrate'**
  String get winrate;

  /// No description provided for @worst_score.
  ///
  /// In en, this message translates to:
  /// **'Worst score'**
  String get worst_score;

  /// No description provided for @yesterday_at.
  ///
  /// In en, this message translates to:
  /// **'Yesterday at'**
  String get yesterday_at;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
