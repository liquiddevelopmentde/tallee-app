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

  /// Label for all players list
  ///
  /// In en, this message translates to:
  /// **'All players'**
  String get all_players;

  /// Message when all players are added to selection
  ///
  /// In en, this message translates to:
  /// **'All players selected'**
  String get all_players_selected;

  /// Label for amount of matches statistic
  ///
  /// In en, this message translates to:
  /// **'Amount of Matches'**
  String get amount_of_matches;

  /// The name of the App
  ///
  /// In en, this message translates to:
  /// **'Tallee'**
  String get app_name;

  /// Label for best player statistic
  ///
  /// In en, this message translates to:
  /// **'Best Player'**
  String get best_player;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label for choosing a game
  ///
  /// In en, this message translates to:
  /// **'Choose Game'**
  String get choose_game;

  /// Label for choosing a group
  ///
  /// In en, this message translates to:
  /// **'Choose Group'**
  String get choose_group;

  /// Label for choosing a ruleset
  ///
  /// In en, this message translates to:
  /// **'Choose Ruleset'**
  String get choose_ruleset;

  /// Error message when adding a player fails
  ///
  /// In en, this message translates to:
  /// **'Could not add player'**
  String could_not_add_player(Object playerName);

  /// Button text to create a group
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get create_group;

  /// Button text to create a match
  ///
  /// In en, this message translates to:
  /// **'Create match'**
  String get create_match;

  /// Appbar text to create a new group
  ///
  /// In en, this message translates to:
  /// **'Create new group'**
  String get create_new_group;

  /// Label for creation date
  ///
  /// In en, this message translates to:
  /// **'Created on'**
  String get created_on;

  /// Appbar text to create a new match
  ///
  /// In en, this message translates to:
  /// **'Create new match'**
  String get create_new_match;

  /// Data label
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// Success message after deleting data
  ///
  /// In en, this message translates to:
  /// **'Data successfully deleted'**
  String get data_successfully_deleted;

  /// Success message after exporting data
  ///
  /// In en, this message translates to:
  /// **'Data successfully exported'**
  String get data_successfully_exported;

  /// Success message after importing data
  ///
  /// In en, this message translates to:
  /// **'Data successfully imported'**
  String get data_successfully_imported;

  /// Date format for days ago
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String days_ago(int count);

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Confirmation dialog for deleting all data
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get delete_all_data;

  /// Confirmation dialog for deleting a group
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get delete_group;

  /// Button & Appbar label for editing a group
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get edit_group;

  /// Error message when group creation fails
  ///
  /// In en, this message translates to:
  /// **'Error while creating group, please try again'**
  String get error_creating_group;

  /// Error message when group deletion fails
  ///
  /// In en, this message translates to:
  /// **'Error while deleting group, please try again'**
  String get error_deleting_group;

  /// Error message when group editing fails
  ///
  /// In en, this message translates to:
  /// **'Error while editing group, please try again'**
  String get error_editing_group;

  /// Error message when file cannot be read
  ///
  /// In en, this message translates to:
  /// **'Error reading file'**
  String get error_reading_file;

  /// Message when export is canceled
  ///
  /// In en, this message translates to:
  /// **'Export canceled'**
  String get export_canceled;

  /// Export data menu item
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get export_data;

  /// Error message for format exceptions
  ///
  /// In en, this message translates to:
  /// **'Format Exception (see console)'**
  String get format_exception;

  /// Game label
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get game;

  /// Placeholder for game name search
  ///
  /// In en, this message translates to:
  /// **'Game Name'**
  String get game_name;

  /// Group label
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// Placeholder for group name input
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get group_name;

  /// Title for group profile view
  ///
  /// In en, this message translates to:
  /// **'Group Profile'**
  String get group_profile;

  /// Label for groups
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Message when import is canceled
  ///
  /// In en, this message translates to:
  /// **'Import canceled'**
  String get import_canceled;

  /// Import data menu item
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get import_data;

  /// Info label
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// Error message for invalid schema
  ///
  /// In en, this message translates to:
  /// **'Invalid Schema'**
  String get invalid_schema;

  /// Title for least points ruleset
  ///
  /// In en, this message translates to:
  /// **'Least Points'**
  String get least_points;

  /// Legal section header
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// Legal notice menu item
  ///
  /// In en, this message translates to:
  /// **'Legal Notice'**
  String get legal_notice;

  /// Licenses menu item
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// Message when match is in progress
  ///
  /// In en, this message translates to:
  /// **'Match in progress...'**
  String get match_in_progress;

  /// Placeholder for match name input
  ///
  /// In en, this message translates to:
  /// **'Match name'**
  String get match_name;

  /// Label for matches
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// Label for group members
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// Title for most points ruleset
  ///
  /// In en, this message translates to:
  /// **'Most Points'**
  String get most_points;

  /// Message when no data in the statistic tiles is given
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get no_data_available;

  /// Message when no groups exist
  ///
  /// In en, this message translates to:
  /// **'No groups created yet'**
  String get no_groups_created_yet;

  /// Message when no licenses are found
  ///
  /// In en, this message translates to:
  /// **'No licenses found'**
  String get no_licenses_found;

  /// Message when no license text is available
  ///
  /// In en, this message translates to:
  /// **'No license text available'**
  String get no_license_text_available;

  /// Message when no matches exist
  ///
  /// In en, this message translates to:
  /// **'No matches created yet'**
  String get no_matches_created_yet;

  /// Message when no players exist
  ///
  /// In en, this message translates to:
  /// **'No players created yet'**
  String get no_players_created_yet;

  /// Message when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No players found with that name'**
  String get no_players_found_with_that_name;

  /// Message when no players are selected
  ///
  /// In en, this message translates to:
  /// **'No players selected'**
  String get no_players_selected;

  /// Message when no recent matches exist
  ///
  /// In en, this message translates to:
  /// **'No recent matches available'**
  String get no_recent_matches_available;

  /// Message when no second match exists
  ///
  /// In en, this message translates to:
  /// **'No second match available'**
  String get no_second_match_available;

  /// Message when no statistics are available, because no matches were played yet
  ///
  /// In en, this message translates to:
  /// **'No statistics available'**
  String get no_statistics_available;

  /// None option label
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// None group option label
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none_group;

  /// Abbreviation for not available
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get not_available;

  /// Label for played matches statistic
  ///
  /// In en, this message translates to:
  /// **'Played Matches'**
  String get played_matches;

  /// Placeholder for player name input
  ///
  /// In en, this message translates to:
  /// **'Player name'**
  String get player_name;

  /// Players label
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// Shows the number of players
  ///
  /// In en, this message translates to:
  /// **'{count} Players'**
  String players_count(int count);

  /// Privacy policy menu item
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// Title for quick create section
  ///
  /// In en, this message translates to:
  /// **'Quick Create'**
  String get quick_create;

  /// Title for recent matches section
  ///
  /// In en, this message translates to:
  /// **'Recent Matches'**
  String get recent_matches;

  /// Ruleset label
  ///
  /// In en, this message translates to:
  /// **'Ruleset'**
  String get ruleset;

  /// Description for least points ruleset
  ///
  /// In en, this message translates to:
  /// **'Inverse scoring: the player with the fewest points wins.'**
  String get ruleset_least_points;

  /// Description for most points ruleset
  ///
  /// In en, this message translates to:
  /// **'Traditional ruleset: the player with the most points wins.'**
  String get ruleset_most_points;

  /// Description for single loser ruleset
  ///
  /// In en, this message translates to:
  /// **'Exactly one loser is determined; last place receives the penalty or consequence.'**
  String get ruleset_single_loser;

  /// Description for single winner ruleset
  ///
  /// In en, this message translates to:
  /// **'Exactly one winner is chosen; ties are resolved by a predefined tiebreaker.'**
  String get ruleset_single_winner;

  /// Hint text for group search input field
  ///
  /// In en, this message translates to:
  /// **'Search for groups'**
  String get search_for_groups;

  /// Hint text for player search input field
  ///
  /// In en, this message translates to:
  /// **'Search for players'**
  String get search_for_players;

  /// Label to select the winner
  ///
  /// In en, this message translates to:
  /// **'Select Winner:'**
  String get select_winner;

  /// Shows the number of selected players
  ///
  /// In en, this message translates to:
  /// **'Selected players'**
  String get selected_players;

  /// Label for the App Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Title for single loser ruleset
  ///
  /// In en, this message translates to:
  /// **'Single Loser'**
  String get single_loser;

  /// Title for single winner ruleset
  ///
  /// In en, this message translates to:
  /// **'Single Winner'**
  String get single_winner;

  /// No description provided for @highest_score.
  ///
  /// In en, this message translates to:
  /// **'Highest Score'**
  String get highest_score;

  /// No description provided for @lowest_score.
  ///
  /// In en, this message translates to:
  /// **'Lowest Score'**
  String get lowest_score;

  /// No description provided for @multiple_winners.
  ///
  /// In en, this message translates to:
  /// **'Multiple Winners'**
  String get multiple_winners;

  /// Statistics tab label
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Stats tab label (short)
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// Success message when adding a player
  ///
  /// In en, this message translates to:
  /// **'Successfully added player {playerName}'**
  String successfully_added_player(String playerName);

  /// Message when search returns no groups
  ///
  /// In en, this message translates to:
  /// **'There is no group matching your search'**
  String get there_is_no_group_matching_your_search;

  /// Warning message for irreversible actions
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get this_cannot_be_undone;

  /// Date format for today
  ///
  /// In en, this message translates to:
  /// **'Today at'**
  String get today_at;

  /// Undo button text
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Error message for unknown exceptions
  ///
  /// In en, this message translates to:
  /// **'Unknown Exception (see console)'**
  String get unknown_exception;

  /// Winner label
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winner;

  /// Label for winrate statistic
  ///
  /// In en, this message translates to:
  /// **'Winrate'**
  String get winrate;

  /// Label for wins statistic
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// Date format for yesterday
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
