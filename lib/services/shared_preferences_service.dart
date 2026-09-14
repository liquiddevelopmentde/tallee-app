import 'package:collection/collection.dart';
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
  static const String matchFilterKey = 'match_filter';

  static void deleteAllPreferences() {
    _instance.remove(filteredGroupsKey);
    _instance.remove(filteredGamesKey);
    _instance.remove(filteredTimeframesKey);
    _instance.remove(filteredStatisticTypesKey);
    _instance.remove(showFavouritesKey);
    _instance.remove(sharingConsentKey);
    _instance.remove(matchFilterKey);
  }

  static void resetStatisticFilter({required bool includeFavourites}) {
    setFilteredGroups([]);
    setFilteredGames([]);
    setFilteredTimeframes([]);
    setFilteredStatisticTypes([]);
    if (includeFavourites) setShowFavourites(false);
  }

  static void setMatchFilter(MatchFilter filter) {
    _instance.setString(matchFilterKey, filter.toString());
  }

  static MatchFilter? getMatchFilter() {
    final filterString = _instance.getString(matchFilterKey);

    return MatchFilter.values.firstWhereOrNull(
      (filter) => filter.toString() == filterString,
    );
  }

  /// Returns null when the key is not set, so user wasn't asked yet
  static bool? getSharingConsent() {
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
}
