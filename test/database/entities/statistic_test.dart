import 'dart:core';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/statistic.dart';

void main() {
  late AppDatabase database;
  late Player testPlayer1;
  late Player testPlayer2;
  late Player testPlayer3;
  late Player testPlayer4;
  late Player testPlayer5;
  late Group testGroup1;
  late Group testGroup2;
  late Game testGame1;
  late Game testGame2;
  late Statistic testStatistic1;
  late Statistic testStatistic2;
  late Statistic testStatistic3;
  final fixedDate = DateTime(2025, 11, 19, 00, 11, 23);
  final fakeClock = Clock(() => fixedDate);

  setUp(() async {
    database = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        // Recommended for widget tests to avoid test errors.
        closeStreamsSynchronously: true,
      ),
    );

    withClock(fakeClock, () {
      testPlayer1 = Player(name: 'Alice');
      testPlayer2 = Player(name: 'Bob');
      testPlayer3 = Player(name: 'Charlie');
      testPlayer4 = Player(name: 'Diana');
      testPlayer5 = Player(name: 'Eve');
      testGroup1 = Group(
        name: 'Test Group 1',
        description: '',
        members: [testPlayer1, testPlayer2, testPlayer3],
      );
      testGroup2 = Group(
        name: 'Test Group 2',
        description: '',
        members: [testPlayer4, testPlayer5],
      );
      testGame1 = Game(
        name: 'Test Game 1',
        ruleset: Ruleset.singleWinner,
        description: 'A test game',
        color: AppColor.blue,
        icon: '',
      );
      testGame2 = Game(
        name: 'Test Game 2',
        ruleset: Ruleset.highestScore,
        description: 'Another test game',
        color: AppColor.red,
        icon: '',
      );
      testStatistic1 = Statistic(
        type: StatisticType.totalWins,
        scopes: [StatisticScope.allPlayers],
        timeframe: Timeframe.allTime,
        color: AppColor.blue,
      );
      testStatistic2 = Statistic(
        type: StatisticType.averageScore,
        scopes: [StatisticScope.selectedGames],
        timeframe: Timeframe.last30Days,
        selectedGames: [testGame1],
        color: AppColor.green,
      );
      testStatistic3 = Statistic(
        type: StatisticType.totalMatches,
        scopes: [StatisticScope.selectedGroups],
        timeframe: Timeframe.last7Days,
        selectedGroups: [testGroup1],
        color: AppColor.red,
      );
    });

    await database.playerDao.addPlayersAsList(
      players: [
        testPlayer1,
        testPlayer2,
        testPlayer3,
        testPlayer4,
        testPlayer5,
      ],
    );
    await database.groupDao.addGroupsAsList(groups: [testGroup1, testGroup2]);
    await database.gameDao.addGamesAsList(games: [testGame1, testGame2]);
  });

  tearDown(() async {
    await database.close();
  });

  group('Statistic Tests', () {
    group('CREATE', () {
      test('Adding and fetching a single statistic works correctly', () async {
        final added = await database.statisticDao.addStatistic(
          statistic: testStatistic1,
        );
        expect(added, isTrue);

        final fetched = await database.statisticDao.getStatisticById(
          statisticId: testStatistic1.id,
        );
        expect(fetched, isNotNull);
        expect(fetched!.id, testStatistic1.id);
        expect(fetched.createdAt, testStatistic1.createdAt);
        expect(fetched.type, testStatistic1.type);
        expect(fetched.scopes, testStatistic1.scopes);
        expect(fetched.timeframe, testStatistic1.timeframe);
        expect(fetched.color, testStatistic1.color);
        expect(fetched.displayCount, testStatistic1.displayCount);
        expect(fetched.isFavourite, testStatistic1.isFavourite);
      });

      test('Adding and fetching multiple statistics works correctly', () async {
        final added = await database.statisticDao.addStatisticsAsList(
          statistics: [testStatistic1, testStatistic2, testStatistic3],
        );
        expect(added, isTrue);

        final allStatistics = await database.statisticDao.getAllStatistics();
        expect(allStatistics.length, 3);

        // Map for connecting fetched stats with expected stats
        final testGames = {
          testStatistic1.id: testStatistic1,
          testStatistic2.id: testStatistic2,
          testStatistic3.id: testStatistic3,
        };

        for (final stat in allStatistics) {
          final testStat = testGames[stat.id]!;

          expect(stat.id, testStat.id);
          expect(stat.createdAt, testStat.createdAt);
          expect(stat.type, testStat.type);
          expect(stat.scopes, testStat.scopes);
          expect(stat.timeframe, testStat.timeframe);
          expect(stat.color, testStat.color);
          expect(stat.displayCount, testStat.displayCount);
          expect(stat.isFavourite, testStat.isFavourite);
        }
      });

      test('addStatisticsAsList() returns false for empty list', () async {
        final result = await database.statisticDao.addStatisticsAsList(
          statistics: [],
        );
        expect(result, isFalse);

        final allStats = await database.statisticDao.getAllStatistics();
        expect(allStats.length, 0);
      });

      test('addStatisticsAsList() ignores duplicate stats', () async {
        final added = await database.statisticDao.addStatisticsAsList(
          statistics: [testStatistic1, testStatistic2, testStatistic1],
        );
        expect(added, isTrue);

        final allStats = await database.statisticDao.getAllStatistics();
        expect(allStats.length, 2);
      });
    });

    group('READ', () {
      test('getStatisticById() works correctly', () async {
        await database.statisticDao.addStatistic(statistic: testStatistic1);

        final fetched = await database.statisticDao.getStatisticById(
          statisticId: testStatistic1.id,
        );

        expect(fetched, isNotNull);
        expect(fetched!.id, testStatistic1.id);
        expect(fetched.createdAt, testStatistic1.createdAt);
        expect(fetched.type, testStatistic1.type);
        expect(fetched.scopes, testStatistic1.scopes);
        expect(fetched.timeframe, testStatistic1.timeframe);
        expect(fetched.color, testStatistic1.color);
        expect(fetched.displayCount, testStatistic1.displayCount);
      });

      test(
        'getStatisticById() returns null for non-existent statistic',
        () async {
          final fetched = await database.statisticDao.getStatisticById(
            statisticId: 'non-existent-id',
          );
          expect(fetched, isNull);
        },
      );

      test('getAllStatistics() works correctly', () async {
        await database.statisticDao.addStatisticsAsList(
          statistics: [testStatistic1, testStatistic2],
        );

        final all = await database.statisticDao.getAllStatistics();
        expect(all.length, 2);
      });

      test('getAllStatistics() returns empty list when none exist', () async {
        final all = await database.statisticDao.getAllStatistics();
        expect(all, isEmpty);
      });
    });

    group('UPDATE', () {
      test('updateDisplayCount() works correctly', () async {
        await database.statisticDao.addStatistic(statistic: testStatistic1);

        final updated = await database.statisticDao.updateDisplayCount(
          testStatistic1.id,
          10,
        );
        expect(updated, isTrue);

        final fetched = await database.statisticDao.getStatisticById(
          statisticId: testStatistic1.id,
        );
        expect(fetched!.displayCount, 10);
      });

      test(
        'updateDisplayCount() does nothing for non-existent statistic',
        () async {
          final updated = await database.statisticDao.updateDisplayCount(
            'non-existent-id',
            10,
          );
          expect(updated, isFalse);

          final allStats = await database.statisticDao.getAllStatistics();
          expect(allStats, isEmpty);
        },
      );

      test('updateIsFavourite() works correctly', () async {
        await database.statisticDao.addStatistic(statistic: testStatistic1);

        final updated = await database.statisticDao.updateIsFavourite(
          testStatistic1.id,
          true,
        );
        expect(updated, isTrue);

        final fetched = await database.statisticDao.getStatisticById(
          statisticId: testStatistic1.id,
        );
        expect(fetched!.isFavourite, isTrue);
      });

      test(
        'updateIsFavourite() does nothing for non-existent statistic',
        () async {
          final updated = await database.statisticDao.updateIsFavourite(
            'non-existent-id',
            true,
          );
          expect(updated, isFalse);

          final allStats = await database.statisticDao.getAllStatistics();
          expect(allStats, isEmpty);
        },
      );
    });

    group('DELETE', () {
      test('deleteStatistic() works correctly', () async {
        await database.statisticDao.addStatistic(statistic: testStatistic1);

        final deleted = await database.statisticDao.deleteStatistic(
          testStatistic1.id,
        );
        expect(deleted, isTrue);

        final allStats = await database.statisticDao.getAllStatistics();
        expect(allStats, isEmpty);
      });

      test(
        'deleteStatistic() returns false for non-existent statistic',
        () async {
          final deleted = await database.statisticDao.deleteStatistic(
            'non-existent-id',
          );
          expect(deleted, isFalse);
        },
      );

      test('deleteAllStatistics() removes all statistics', () async {
        await database.statisticDao.addStatisticsAsList(
          statistics: [testStatistic1, testStatistic2, testStatistic3],
        );

        var all = await database.statisticDao.getAllStatistics();
        expect(all.length, 3);

        final deleted = await database.statisticDao.deleteAllStatistics();
        expect(deleted, isTrue);

        all = await database.statisticDao.getAllStatistics();
        expect(all, isEmpty);
      });

      test(
        'deleteAllStatistics() returns false when no statistics exist',
        () async {
          final deleted = await database.statisticDao.deleteAllStatistics();
          expect(deleted, isFalse);
        },
      );
    });
  });
}
