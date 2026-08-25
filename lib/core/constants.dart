/// Application-wide constants
class Constants {
  Constants._(); // Private constructor to prevent instantiation

  /// Treshold for fuzzy search
  static const int FUZZY_SEARCH_THRESHOLD = 50;

  /// Minimum duration of all app skeletons
  static const Duration MINIMUM_SKELETON_DURATION = Duration(milliseconds: 250);

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

  /// Maximum length for game descriptions
  static const int MAX_GAME_DESCRIPTION_LENGTH = 256;

  /// Maximum length for player descriptions
  static const int MAX_PLAYER_DESCRIPTION_LENGTH = 256;

  /// Maximum length for group descriptions
  static const int MAX_GROUP_DESCRIPTION_LENGTH = 256;
}
