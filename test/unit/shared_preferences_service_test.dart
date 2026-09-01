import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/services/shared_preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesService.init();
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

      SharedPreferencesService.setFilteredGames([game1, game2]);

      SharedPreferencesService.setFilteredStatisticTypes([
        StatisticType.totalMatches,
        StatisticType.totalWins,
        StatisticType.bestScore,
      ]);

      SharedPreferencesService.setFilteredTimeframes([
        Timeframe.last7Days,
        Timeframe.last30Days,
        Timeframe.allTime,
      ]);

      SharedPreferencesService.deleteAllFilters(includeFavourites: false);

      final filteredGroups = SharedPreferencesService.getFilteredGroups();
      final filteredGames = SharedPreferencesService.getFilteredGames();
      final filteredTypes =
          SharedPreferencesService.getFilteredStatisticTypes();
      final filteredTimeframes =
          SharedPreferencesService.getFilteredTimeframes();

      expect(filteredGroups, isEmpty);
      expect(filteredGames, isEmpty);
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
      SharedPreferencesService.setFilteredGames([game1, game2]);

      final group1 = Group(id: 'group1', name: 'Group 1', members: []);
      final group2 = Group(id: 'group2', name: 'Group 2', members: []);
      SharedPreferencesService.setFilteredGroups([group1, group2]);

      final filteredGames = SharedPreferencesService.getFilteredGames();
      expect(filteredGames, [game1.id, game2.id]);
    });

    test('Get and set sharing consent works correctly', () async {
      // initially null
      expect(SharedPreferencesService.getStoredSharingConsent(), isNull);

      await SharedPreferencesService.setSharingConsent(true);
      expect(SharedPreferencesService.getStoredSharingConsent(), isTrue);

      await SharedPreferencesService.setSharingConsent(false);
      expect(SharedPreferencesService.getStoredSharingConsent(), isFalse);
    });

    test('Get and set filtered groups works correctly', () async {
      final group1 = Group(id: 'group1', name: 'Group 1', members: []);
      final group2 = Group(id: 'group2', name: 'Group 2', members: []);

      SharedPreferencesService.setFilteredGroups([group1, group2]);
      final filteredGroups = SharedPreferencesService.getFilteredGroups();
      expect(filteredGroups, [group1.id, group2.id]);
    });

    test('Get and set filtered statistic types works correctly', () async {
      SharedPreferencesService.setFilteredStatisticTypes([
        StatisticType.totalMatches,
        StatisticType.totalWins,
        StatisticType.bestScore,
      ]);

      final filteredTypes =
          SharedPreferencesService.getFilteredStatisticTypes();

      expect(filteredTypes, [
        StatisticType.totalMatches,
        StatisticType.totalWins,
        StatisticType.bestScore,
      ]);
    });

    test('Get and set filtered timeframes works correctly', () async {
      SharedPreferencesService.setFilteredTimeframes([
        Timeframe.last7Days,
        Timeframe.last30Days,
        Timeframe.allTime,
      ]);

      final filteredTimeframes =
          SharedPreferencesService.getFilteredTimeframes();

      expect(filteredTimeframes, [
        Timeframe.last7Days,
        Timeframe.last30Days,
        Timeframe.allTime,
      ]);
    });
  });
}
