/// URL to the legal section on the LIQUID website
const String LIQUID_WEBSITE_LEGAL_URL = 'https://liquid-dev.de/legal';

/// Treshold for fuzzy search
const int FUZZY_SEARCH_THRESHOLD = 50;

/// Minimum duration of all app skeletons
const Duration MINIMUM_SKELETON_DURATION = Duration(milliseconds: 250);

/// Maximum length for player names
const int MAX_PLAYER_NAME_LENGTH = 32;

/// Maximum length for group names
const int MAX_GROUP_NAME_LENGTH = 32;

/// Maximum length for match names
const int MAX_MATCH_NAME_LENGTH = 32;

/// Maximum length for game names
const int MAX_GAME_NAME_LENGTH = 32;

/// Maximum length for team names
const int MAX_TEAM_NAME_LENGTH = 32;

/// Maximum length for game descriptions
const int MAX_GAME_DESCRIPTION_LENGTH = 256;

/// Range for score input
const ({int min, int max}) SCORE_INPUT_BOUNDARIES = (min: -99999, max: 99999);

/// Range for live input
const ({int min, int max}) LIVE_INPUT_BOUNDARIES = (min: 0, max: 99);
