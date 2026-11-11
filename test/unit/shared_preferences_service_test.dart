import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tallee/core/theme/app_colors.dart';
import 'package:tallee/core/theme/app_theme.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/services/shared_preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesService.init();
  });

  group('SharedPreferencesService', () {
    test('Delete all preferences works correctly', () async {
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

      SharedPreferencesService.filteredGameIds = [game1.id, game2.id];
      SharedPreferencesService.filteredStatisticTypes = [
        StatisticType.totalMatches,
        StatisticType.totalWins,
        StatisticType.bestScore,
      ];
      SharedPreferencesService.filteredTimeframes = [
        Timeframe.last7Days,
        Timeframe.last30Days,
        Timeframe.allTime,
      ];
      SharedPreferencesService.matchFilter = MatchFilter.team;
      SharedPreferencesService.sharingConsent = true;

      SharedPreferencesService.deleteAllPreferences();

      final filteredGroups = SharedPreferencesService.filteredGroupIds;
      final filteredGames = SharedPreferencesService.filteredGameIds;
      final filteredTypes = SharedPreferencesService.filteredStatisticTypes;
      final filteredTimeframes = SharedPreferencesService.filteredTimeframes;
      final matchFilter = SharedPreferencesService.matchFilter;
      final sharingConsent = SharedPreferencesService.sharingConsent;

      expect(filteredGroups, isEmpty);
      expect(filteredGames, isEmpty);
      expect(filteredTypes, isEmpty);
      expect(filteredTimeframes, isEmpty);
      expect(matchFilter, isNull);
      expect(sharingConsent, isNull);
    });

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

      SharedPreferencesService.filteredGameIds = [game1.id, game2.id];

      SharedPreferencesService.filteredStatisticTypes = [
        StatisticType.totalMatches,
        StatisticType.totalWins,
        StatisticType.bestScore,
      ];

      SharedPreferencesService.filteredTimeframes = [
        Timeframe.last7Days,
        Timeframe.last30Days,
        Timeframe.allTime,
      ];

      SharedPreferencesService.resetStatisticFilter(includeFavourites: false);

      final filteredGroups = SharedPreferencesService.filteredGroupIds;
      final filteredGames = SharedPreferencesService.filteredGameIds;
      final filteredTypes = SharedPreferencesService.filteredStatisticTypes;
      final filteredTimeframes = SharedPreferencesService.filteredTimeframes;

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
      SharedPreferencesService.filteredGameIds = [game1.id, game2.id];

      final group1 = Group(id: 'group1', name: 'Group 1', members: []);
      final group2 = Group(id: 'group2', name: 'Group 2', members: []);
      SharedPreferencesService.filteredGroupIds = [group1.id, group2.id];

      final filteredGames = SharedPreferencesService.filteredGameIds;
      expect(filteredGames, [game1.id, game2.id]);
    });

    test('Get and set filtered groups works correctly', () async {
      final group1 = Group(id: 'group1', name: 'Group 1', members: []);
      final group2 = Group(id: 'group2', name: 'Group 2', members: []);

      SharedPreferencesService.filteredGroupIds = [group1.id, group2.id];
      final filteredGroups = SharedPreferencesService.filteredGroupIds;
      expect(filteredGroups, [group1.id, group2.id]);
    });

    test('Get and set filtered statistic types works correctly', () async {
      SharedPreferencesService.filteredStatisticTypes = [
        StatisticType.totalMatches,
        StatisticType.totalWins,
        StatisticType.bestScore,
      ];

      final filteredTypes = SharedPreferencesService.filteredStatisticTypes;

      expect(filteredTypes, [
        StatisticType.totalMatches,
        StatisticType.totalWins,
        StatisticType.bestScore,
      ]);
    });

    test('Get and set filtered timeframes works correctly', () async {
      SharedPreferencesService.filteredTimeframes = [
        Timeframe.last7Days,
        Timeframe.last30Days,
        Timeframe.allTime,
      ];

      final filteredTimeframes = SharedPreferencesService.filteredTimeframes;

      expect(filteredTimeframes, [
        Timeframe.last7Days,
        Timeframe.last30Days,
        Timeframe.allTime,
      ]);
    });

    test('Get and set sharing consent works correctly', () async {
      expect(SharedPreferencesService.sharingConsent, isNull);

      SharedPreferencesService.sharingConsent = true;
      expect(SharedPreferencesService.sharingConsent, isTrue);

      SharedPreferencesService.sharingConsent = false;
      expect(SharedPreferencesService.sharingConsent, isFalse);
    });

    test('Get and set match filters works correctly', () async {
      var matchFilter = SharedPreferencesService.matchFilter;
      expect(matchFilter, isNull);

      SharedPreferencesService.matchFilter = MatchFilter.finished;
      matchFilter = SharedPreferencesService.matchFilter;
      expect(matchFilter, MatchFilter.finished);

      SharedPreferencesService.matchFilter = MatchFilter.active;
      matchFilter = SharedPreferencesService.matchFilter;
      expect(matchFilter, MatchFilter.active);
    });

    test('Theme mode defaults to system and can be persisted', () {
      expect(SharedPreferencesService.themeMode, ThemeMode.system);

      SharedPreferencesService.themeMode = ThemeMode.light;
      expect(SharedPreferencesService.themeMode, ThemeMode.light);

      SharedPreferencesService.themeMode = ThemeMode.dark;
      expect(SharedPreferencesService.themeMode, ThemeMode.dark);
    });

    test('Light and dark ThemeData remain separate', () {
      expect(lightTheme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);
      expect(
        lightTheme.scaffoldBackgroundColor,
        AppColors.backgroundColorLight,
      );
      expect(darkTheme.scaffoldBackgroundColor, AppColors.backgroundColorDark);
    });
  });
}
