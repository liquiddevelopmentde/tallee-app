/// Application-wide constants
class Constants {
  Constants._(); // Private constructor to prevent instantiation

  /// URL to the LIQUID website
  static const String LIQUID_WEBSITE_URL = 'https://liquid-dev.de/';

  /// URL to the LIQUID github organization profile
  static const String LIQUID_GITHUB_URL =
      'https://github.com/liquiddevelopmentde';

  /// URL to the legal section on the LIQUID website
  static const String LIQUID_WEBSITE_LEGAL_URL = 'https://liquid-dev.de/legal';

  /// Email for contacting LIQUID
  static const String LIQUID_CONTACT_EMAIL = 'hello@liquid-dev.de';

  /// Schema version of the whole app data
  static const int APP_DATA_SCHEMA_VERSION = 1;

  /// Schema version of the match data
  static const int MATCH_DATA_SCHEMA_VERSION = 1;

  /// Treshold for fuzzy search
  static const int FUZZY_SEARCH_THRESHOLD = 50;

  static const int _MINIMUM_SKELETON_MS = 250;

  /// Minimum duration of all app skeletons
  static const Duration MINIMUM_SKELETON_DURATION = Duration(
    milliseconds: _MINIMUM_SKELETON_MS,
  );

  /// Delay before navigating to a view after opening the app
  static const Duration OPEN_WITH_NAVIGATION_DELAY = Duration(
    milliseconds: _MINIMUM_SKELETON_MS + 200,
  );

  /// Maximum length for player names
  static const int MAX_PLAYER_NAME_LENGTH = 32;

  /// Maximum length for group names
  static const int MAX_GROUP_NAME_LENGTH = 32;

  /// Maximum length for match names
  static const int MAX_MATCH_NAME_LENGTH = 32;

  /// Maximum length for game names
  static const int MAX_GAME_NAME_LENGTH = 32;

  /// Maximum length for team names
  static const int MAX_TEAM_NAME_LENGTH = 32;

  /// Maximum length for player descriptions
  static const int MAX_PLAYER_DESCRIPTION_LENGTH = 256;

  /// Maximum length for group descriptions
  static const int MAX_GROUP_DESCRIPTION_LENGTH = 256;

  /// Maximum length for game descriptions
  static const int MAX_GAME_DESCRIPTION_LENGTH = 256;

  /// Maximum length for feedback message
  static const int MAX_FEEDBACK_MESSAGE_LENGTH = 1000;

  /// File extension for match files
  static const String MATCH_FILE_EXTENSION = 'tallee';

  /// File extension for app data
  static const String APP_DATA_FILE_EXTENSION = 'tallee';

  /// Range for score input
  static const ({int min, int max}) SCORE_INPUT_BOUNDARIES = (
    min: -99999,
    max: 99999,
  );

  /// Range for live input
  static const ({int min, int max}) LIVE_INPUT_BOUNDARIES = (min: 0, max: 99);
}
