import 'package:shared_preferences/shared_preferences.dart';
import 'package:tallee/data/models/models.dart';

class SharedPreferencesService {
  static const String filteredGroupsKey = 'filtered_groups';
  static const String filteredGamesKey = 'filtered_games';
  static const String filteredTimeframesKey = 'filtered_timeframes';
  static const String filteredStatisticTypesKey = 'filtered_statistic_types';
  static const String filteredStatisticScopesKey = 'filtered_statistic_scopes';

  static Future<void> deleteAllFilteredPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(filteredGroupsKey);
    await prefs.remove(filteredGamesKey);
    await prefs.remove(filteredTimeframesKey);
    await prefs.remove(filteredStatisticTypesKey);
    await prefs.remove(filteredStatisticScopesKey);
  }

  static Future<void> setFilteredGroups(List<Group> groups) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> groupJsonList = groups.map((group) => group.id).toList();
    await prefs.setStringList(filteredGroupsKey, groupJsonList);
  }

  static Future<List<String>> getFilteredGroups() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(filteredGroupsKey) ?? [];
  }

  static Future<void> setFilteredGames(List<Game> games) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> gameJsonList = games.map((game) => game.id).toList();
    await prefs.setStringList(filteredGamesKey, gameJsonList);
  }

  static Future<List<String>> getFilteredGames() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(filteredGamesKey) ?? [];
  }

  static Future<void> setFilteredTimeframes(List<Timeframe> timeframes) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> timeframeJsonList = timeframes
        .map((timeframe) => timeframe.toString())
        .toList();
    await prefs.setStringList(filteredTimeframesKey, timeframeJsonList);
  }

  static Future<List<Timeframe>> getFilteredTimeframes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> timeframeStringList =
        prefs.getStringList(filteredTimeframesKey) ?? [];
    return timeframeStringList
        .map(
          (timeframeString) => Timeframe.values.firstWhere(
            (timeframe) => timeframe.toString() == timeframeString,
            orElse: () => Timeframe.allTime,
          ),
        )
        .toList();
  }

  static Future<void> setFilteredStatisticTypes(
    List<StatisticType> types,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> typeJsonList = types
        .map((type) => type.toString())
        .toList();
    await prefs.setStringList(filteredStatisticTypesKey, typeJsonList);
  }

  static Future<List<StatisticType>> getFilteredStatisticTypes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> typeStringList =
        prefs.getStringList(filteredStatisticTypesKey) ?? [];
    return typeStringList
        .map(
          (typeString) => StatisticType.values.firstWhere(
            (type) => type.toString() == typeString,
            orElse: () => StatisticType.totalMatches,
          ),
        )
        .toList();
  }

  static Future<void> setFilteredStatisticScopes(
    List<StatisticScope> scopes,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> scopeJsonList = scopes
        .map((scope) => scope.name.toString())
        .toList();
    await prefs.setStringList(filteredStatisticScopesKey, scopeJsonList);
  }

  static Future<List<StatisticScope>> getFilteredStatisticScopes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> scopeStringList =
        prefs.getStringList(filteredStatisticScopesKey) ?? [];
    return scopeStringList
        .map(
          (scopeString) => StatisticScope.values.firstWhere(
            (scope) => scope.name.toString() == scopeString,
            orElse: () => StatisticScope.allPlayers,
          ),
        )
        .toList();
  }
}
