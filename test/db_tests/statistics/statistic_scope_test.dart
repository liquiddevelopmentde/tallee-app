import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/statistic.dart';

void main() {
  late AppDatabase database;
  late Statistic testStatistic;
  final fixedDate = DateTime(2025, 11, 19, 00, 11, 23);
  final fakeClock = Clock(() => fixedDate);

  setUp(() async {
    database = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );

    withClock(fakeClock, () {
      testStatistic = Statistic(
        type: StatisticType.totalWins,
        scopes: [StatisticScope.allPlayers],
        timeframe: Timeframe.allTime,
        color: AppColor.blue,
      );
    });

    await database.statisticDao.addStatistic(statistic: testStatistic);
  });

  tearDown(() async {
    await database.close();
  });

  group('Statistic Scope Tests', () {
    group('READ', () {
      test(
        'getScopeForStatistic() returns empty for non-existing id',
        () async {
          final scopes = await database.statisticScopeDao.getScopeForStatistic(
            'non-existing-id',
          );
          expect(scopes, isEmpty);
        },
      );

      test('getScopeForStatistic() returns the correct scope', () async {
        final scopes = await database.statisticScopeDao.getScopeForStatistic(
          testStatistic.id,
        );
        expect(scopes.length, 1);
        expect(scopes.first, StatisticScope.allPlayers);
      });

      test('getScopeForStatistic() returns all linked scopes', () async {
        final multi = Statistic(
          type: StatisticType.totalMatches,
          scopes: [
            StatisticScope.allPlayers,
            StatisticScope.selectedGames,
            StatisticScope.selectedGroups,
          ],
          timeframe: Timeframe.allTime,
          color: AppColor.red,
        );
        await database.statisticDao.addStatistic(statistic: multi);

        final scopes = await database.statisticScopeDao.getScopeForStatistic(
          multi.id,
        );
        expect(scopes.length, 3);

        final values = scopes.toSet();
        expect(values.contains(StatisticScope.allPlayers), isTrue);
        expect(values.contains(StatisticScope.selectedGames), isTrue);
        expect(values.contains(StatisticScope.selectedGroups), isTrue);
      });
    });

    group('CREATE', () {
      test('addStatisticScopes() returns true on success', () async {
        final success = await database.statisticScopeDao.addStatisticScopes(
          statisticId: testStatistic.id,
          scopes: [StatisticScope.selectedGames],
        );
        expect(success, isTrue);
      });

      test('addStatisticScopes() adds a single scope correctly', () async {
        final newStatistic = Statistic(
          type: StatisticType.winrate,
          scopes: [StatisticScope.selectedGames],
          timeframe: Timeframe.last7Days,
          color: AppColor.green,
        );
        await database.statisticDao.addStatistic(statistic: newStatistic);

        await database.statisticScopeDao.addStatisticScopes(
          statisticId: newStatistic.id,
          scopes: [StatisticScope.selectedGames],
        );

        final scopes = await database.statisticScopeDao.getScopeForStatistic(
          newStatistic.id,
        );
        expect(scopes.length, 1);
        expect(scopes.first, StatisticScope.selectedGames);
      });

      test('addStatisticScopes() adds multiple scopes correctly', () async {
        final newStatistic = Statistic(
          type: StatisticType.bestScore,
          scopes: [],
          timeframe: Timeframe.last30Days,
          color: AppColor.orange,
        );
        await database.statisticDao.addStatistic(statistic: newStatistic);

        await database.statisticScopeDao.addStatisticScopes(
          statisticId: newStatistic.id,
          scopes: [StatisticScope.selectedGames, StatisticScope.selectedGroups],
        );

        final scopes = await database.statisticScopeDao.getScopeForStatistic(
          newStatistic.id,
        );
        expect(scopes.length, 2);
        expect(scopes.toSet().contains(StatisticScope.selectedGames), isTrue);
        expect(scopes.toSet().contains(StatisticScope.selectedGroups), isTrue);
      });

      test(
        'addStatisticScopes() with duplicate scope does not create duplicate entries',
        () async {
          await database.statisticScopeDao.addStatisticScopes(
            statisticId: testStatistic.id,
            scopes: [StatisticScope.allPlayers],
          );
          await database.statisticScopeDao.addStatisticScopes(
            statisticId: testStatistic.id,
            scopes: [StatisticScope.allPlayers],
          );

          final scopes = await database.statisticScopeDao.getScopeForStatistic(
            testStatistic.id,
          );
          expect(scopes.where((s) => s == StatisticScope.allPlayers).length, 1);
        },
      );
    });
  });
}
