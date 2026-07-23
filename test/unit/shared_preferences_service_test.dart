import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/services/shared_preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPreferencesService', () {
    test('Reset all filter works correctly', () async {
      final game1 = Game(
        id: 'game1',
        name: 'Game 1',
        ruleset: Ruleset.highestScore,
      );
      final game2 = Game(
        id: 'game2',
        name: 'Game 2',
        ruleset: Ruleset.highestScore,
      );

      await SharedPreferencesService.setFilteredGames([game1, game2]);

      await SharedPreferencesService.setFilteredStatisticScopes([
        StatisticScope.allPlayers,
        StatisticScope.selectedGroups,
      ]);

      await SharedPreferencesService.setFilteredStatisticTypes([
        StatisticType.totalMatches,
        StatisticType.totalWins,
        StatisticType.bestScore,
      ]);

      await SharedPreferencesService.setFilteredTimeframes([
        Timeframe.last7Days,
        Timeframe.last30Days,
        Timeframe.allTime,
      ]);

      await SharedPreferencesService.deleteAllFilteredPreferences();

      final filteredGroups = await SharedPreferencesService.getFilteredGroups();
      final filteredGames = await SharedPreferencesService.getFilteredGames();
      final filteredScopes =
          await SharedPreferencesService.getFilteredStatisticScopes();
      final filteredTypes =
          await SharedPreferencesService.getFilteredStatisticTypes();
      final filteredTimeframes =
          await SharedPreferencesService.getFilteredTimeframes();

      expect(filteredGroups, isEmpty);
      expect(filteredGames, isEmpty);
      expect(filteredScopes, isEmpty);
      expect(filteredTypes, isEmpty);
      expect(filteredTimeframes, isEmpty);
    });

    test('Get and set filtered games works correctly', () async {
      final game1 = Game(
        id: 'game1',
        name: 'Game 1',
        ruleset: Ruleset.highestScore,
      );
      final game2 = Game(
        id: 'game2',
        name: 'Game 2',
        ruleset: Ruleset.highestScore,
      );
      await SharedPreferencesService.setFilteredGames([game1, game2]);

      final group1 = Group(id: 'group1', name: 'Group 1', members: []);
      final group2 = Group(id: 'group2', name: 'Group 2', members: []);
      await SharedPreferencesService.setFilteredGroups([group1, group2]);

      final filteredGames = await SharedPreferencesService.getFilteredGames();
      expect(filteredGames, [game1.id, game2.id]);
    });

    test('Get and set filtered groups works correctly', () async {
      final group1 = Group(id: 'group1', name: 'Group 1', members: []);
      final group2 = Group(id: 'group2', name: 'Group 2', members: []);

      await SharedPreferencesService.setFilteredGroups([group1, group2]);
      final filteredGroups = await SharedPreferencesService.getFilteredGroups();
      expect(filteredGroups, [group1.id, group2.id]);
    });

    test('Get and set filtered statistic scopes works correctly', () async {
      await SharedPreferencesService.setFilteredStatisticScopes([
        StatisticScope.allPlayers,
        StatisticScope.selectedGroups,
      ]);

      final filteredScopes =
          await SharedPreferencesService.getFilteredStatisticScopes();

      expect(filteredScopes, [
        StatisticScope.allPlayers,
        StatisticScope.selectedGroups,
      ]);
    });

    test('Get and set filtered statistic types works correctly', () async {
      await SharedPreferencesService.setFilteredStatisticTypes([
        StatisticType.totalMatches,
        StatisticType.totalWins,
        StatisticType.bestScore,
      ]);

      final filteredTypes =
          await SharedPreferencesService.getFilteredStatisticTypes();

      expect(filteredTypes, [
        StatisticType.totalMatches,
        StatisticType.totalWins,
        StatisticType.bestScore,
      ]);
    });

    test('Get and set filtered timeframes works correctly', () async {
      await SharedPreferencesService.setFilteredTimeframes([
        Timeframe.last7Days,
        Timeframe.last30Days,
        Timeframe.allTime,
      ]);

      final filteredTimeframes =
          await SharedPreferencesService.getFilteredTimeframes();

      expect(filteredTimeframes, [
        Timeframe.last7Days,
        Timeframe.last30Days,
        Timeframe.allTime,
      ]);
    });
  });
}
