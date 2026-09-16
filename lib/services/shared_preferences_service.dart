import 'package:shared_preferences/shared_preferences.dart';
import 'package:tallee/data/models/models.dart';

class SharedPreferencesService {
  static SharedPreferences? _prefs;

  /// Loads and caches the [SharedPreferences] instance.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError(
        'SharedPreferencesService.init() must be called before use.',
      );
    }
    return prefs;
  }

  static const String filteredGroupsKey = 'filtered_groups';
  static const String filteredGamesKey = 'filtered_games';
  static const String filteredTimeframesKey = 'filtered_timeframes';
  static const String filteredStatisticTypesKey = 'filtered_statistic_types';
  static const String showFavouritesKey = 'show_favourites';
  static const String sharingConsentKey = 'share_consent';
  static const String showcaseTourSkippedKey = 'showcase_tour_skipped';
  static const String showcaseTourCompletedKey = 'showcase_tour_completed';
  static const String showcaseSeenKey = 'showcase_seen';
  static const String onboardingCompletedKey = 'onboarding_completed';

  static void deleteAllFilters({required bool includeFavourites}) {
    final SharedPreferences prefs = _instance;
    prefs.remove(filteredGroupsKey);
    prefs.remove(filteredGamesKey);
    prefs.remove(filteredTimeframesKey);
    prefs.remove(filteredStatisticTypesKey);
    if (includeFavourites) {
      prefs.remove(showFavouritesKey);
    }
  }

  /// Returns null when the key is not set, so user wasn't asked yet
  static bool? getStoredSharingConsent() {
    return _instance.getBool(sharingConsentKey);
  }

  static Future<void> setSharingConsent(bool hasSharingConsent) async {
    await _instance.setBool(sharingConsentKey, hasSharingConsent);
  }

  static void setShowFavourites(bool showFavourites) {
    _instance.setBool(showFavouritesKey, showFavourites);
  }

  static bool getShowFavourites() {
    return _instance.getBool(showFavouritesKey) ?? false;
  }

  static void setFilteredGroups(List<Group> groups) {
    final List<String> groupJsonList = groups.map((group) => group.id).toList();
    _instance.setStringList(filteredGroupsKey, groupJsonList);
  }

  static List<String> getFilteredGroups() {
    return _instance.getStringList(filteredGroupsKey) ?? [];
  }

  static void setFilteredGames(List<Game> games) {
    final List<String> gameJsonList = games.map((game) => game.id).toList();
    _instance.setStringList(filteredGamesKey, gameJsonList);
  }

  static List<String> getFilteredGames() {
    return _instance.getStringList(filteredGamesKey) ?? [];
  }

  static void setFilteredTimeframes(List<Timeframe> timeframes) {
    final List<String> timeframeJsonList = timeframes
        .map((timeframe) => timeframe.toString())
        .toList();
    _instance.setStringList(filteredTimeframesKey, timeframeJsonList);
  }

  static List<Timeframe> getFilteredTimeframes() {
    final List<String> timeframeStringList =
        _instance.getStringList(filteredTimeframesKey) ?? [];
    return timeframeStringList
        .map(
          (timeframeString) => Timeframe.values.firstWhere(
            (timeframe) => timeframe.toString() == timeframeString,
            orElse: () => Timeframe.allTime,
          ),
        )
        .toList();
  }

  static void setFilteredStatisticTypes(List<StatisticType> types) {
    final List<String> typeJsonList = types
        .map((type) => type.toString())
        .toList();
    _instance.setStringList(filteredStatisticTypesKey, typeJsonList);
  }

  static List<StatisticType> getFilteredStatisticTypes() {
    final List<String> typeStringList =
        _instance.getStringList(filteredStatisticTypesKey) ?? [];
    return typeStringList
        .map(
          (typeString) => StatisticType.values.firstWhere(
            (type) => type.toString() == typeString,
            orElse: () => StatisticType.totalMatches,
          ),
        )
        .toList();
  }

  static bool isOnboardingCompleted() {
    return _instance.getBool(onboardingCompletedKey) ?? false;
  }

  static void setOnboardingCompleted(bool completed) {
    _instance.setBool(onboardingCompletedKey, completed);
  }

  static void setTourSkipped(bool skipped) {
    _instance.setBool(showcaseTourSkippedKey, skipped);
  }

  static bool isTourSkipped() {
    return _instance.getBool(showcaseTourSkippedKey) ?? false;
  }

  static void setTourCompleted(bool completed) {
    _instance.setBool(showcaseTourCompletedKey, completed);
  }

  static bool isTourCompleted() {
    return _instance.getBool(showcaseTourCompletedKey) ?? false;
  }

  static void setShowcaseSeen(List<String> screenKeys) {
    final currentKeys = getShowcaseSeen();
    final updatedKeys = {...currentKeys, ...screenKeys}.toList();
    _instance.setStringList(showcaseSeenKey, updatedKeys);
  }

  static List<String> getShowcaseSeen() {
    return _instance.getStringList(showcaseSeenKey) ?? [];
  }

  static bool hasSeenShowcase(String screenKey) {
    return _instance.getStringList(showcaseSeenKey)?.contains(screenKey) ??
        false;
  }

  static void resetSeenShowcase() {
    _instance.setStringList(showcaseSeenKey, []);
  }
}
