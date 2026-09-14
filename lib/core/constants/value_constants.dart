import 'package:rate_my_app/rate_my_app.dart';
import 'package:tallee/core/enums.dart';

/// The current environment
AppEnvironment environment = AppEnvironment.development;

/// URL to the LIQUID website
const String LIQUID_WEBSITE_URL = 'https://liquid-dev.de/';

/// URL to the legal section on the LIQUID website
const String LIQUID_WEBSITE_LEGAL_URL = 'https://liquid-dev.de/legal';

/// URL to the LIQUID github organization profile
const String LIQUID_GITHUB_URL = 'https://github.com/liquiddevelopmentde';

/// Email for contacting LIQUID
const String LIQUID_CONTACT_EMAIL = 'hello@liquid-dev.de';

/// Treshold for fuzzy search
const int FUZZY_SEARCH_THRESHOLD = 50;

const int _MINIMUM_SKELETON_MS = 250;

/// Minimum duration of all app skeletons
const Duration MINIMUM_SKELETON_DURATION = Duration(
  milliseconds: _MINIMUM_SKELETON_MS,
);

/// Delay before navigating to a view after opening the app
const Duration OPEN_WITH_NAVIGATION_DELAY = Duration(
  milliseconds: _MINIMUM_SKELETON_MS + 200,
);

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

/// Maximum length for player descriptions
const int MAX_PLAYER_DESCRIPTION_LENGTH = 256;

/// Maximum length for group descriptions
const int MAX_GROUP_DESCRIPTION_LENGTH = 256;

/// Maximum length for feedback message
const int MAX_FEEDBACK_MESSAGE_LENGTH = 1000;

/// Range for score input
const ({int min, int max}) SCORE_INPUT_BOUNDARIES = (min: -99999, max: 99999);

/// Range for live input
const ({int min, int max}) LIVE_INPUT_BOUNDARIES = (min: 0, max: 99);

/// Schema version of the whole app data
const int APP_DATA_SCHEMA_VERSION = 1;

/// Schema version of the match data
const int MATCH_DATA_SCHEMA_VERSION = 1;

/// File extension for match files
const String MATCH_FILE_EXTENSION = 'tallee';

/// File extension for app data
const String APP_DATA_FILE_EXTENSION = 'json';

// Config for rate my app package
// ignore: non_constant_identifier_names
final RateMyApp RATE_MY_APP = RateMyApp(
  preferencesPrefix: 'rateMyApp_',
  minDays: 28,
  minLaunches: 20,
  remindDays: 28,
  remindLaunches: 10,
  googlePlayIdentifier: '',
  appStoreIdentifier: '',
);
