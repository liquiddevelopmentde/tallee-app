import 'dart:core';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/core/enums.dart';
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
      test('addStatistic() adds and fetches a statistic correctly', () async {
        final added = await database.statisticDao.addStatistic(
          statistic: testStatistic1,
        );
        expect(added, isTrue);

        final fetched = await database.statisticDao.getStatisticById(
          testStatistic1.id,
        );
        expect(fetched, isNotNull);
        expect(fetched!.id, testStatistic1.id);
        expect(fetched.type, testStatistic1.type);
        expect(fetched.scopes, testStatistic1.scopes);
        expect(fetched.timeframe, testStatistic1.timeframe);
        expect(fetched.color, testStatistic1.color);
        expect(fetched.displayCount, testStatistic1.displayCount);
        expect(
          fetched.createdAt.millisecondsSinceEpoch ~/ 1000,
          testStatistic1.createdAt.millisecondsSinceEpoch ~/ 1000,
        );
      });

      test(
        'addStatistic() with selectedGames stores games correctly',
        () async {
          await database.statisticDao.addStatistic(statistic: testStatistic2);

          final fetched = await database.statisticDao.getStatisticById(
            testStatistic2.id,
          );
          expect(fetched, isNotNull);
          expect(fetched!.selectedGames, isNotNull);
          expect(fetched.selectedGames!.length, 1);
          expect(fetched.selectedGames!.first.id, testGame1.id);
          expect(fetched.selectedGames!.first.name, testGame1.name);
        },
      );

      test(
        'addStatistic() with selectedGroups stores groups correctly',
        () async {
          await database.statisticDao.addStatistic(statistic: testStatistic3);

          final fetched = await database.statisticDao.getStatisticById(
            testStatistic3.id,
          );
          expect(fetched, isNotNull);
          expect(fetched!.selectedGroups, isNotNull);
          expect(fetched.selectedGroups!.length, 1);
          expect(fetched.selectedGroups!.first.id, testGroup1.id);
          expect(fetched.selectedGroups!.first.name, testGroup1.name);
        },
      );

      test(
        'addStatisticsAsList() adds multiple statistics correctly',
        () async {
          final added = await database.statisticDao.addStatisticsAsList(
            statistics: [testStatistic1, testStatistic2, testStatistic3],
          );
          expect(added, isTrue);

          final all = await database.statisticDao.getAllStatistics();
          expect(all.length, 3);

          final ids = all.map((s) => s.id).toSet();
          expect(ids.contains(testStatistic1.id), isTrue);
          expect(ids.contains(testStatistic2.id), isTrue);
          expect(ids.contains(testStatistic3.id), isTrue);
        },
      );

      test('addStatistic() replaces existing statistic with same id', () async {
        await database.statisticDao.addStatistic(statistic: testStatistic1);

        final updated = testStatistic1.copyWith(type: StatisticType.winrate);
        await database.statisticDao.addStatistic(statistic: updated);

        final all = await database.statisticDao.getAllStatistics();
        expect(all.length, 1);
        expect(all.first.type, StatisticType.winrate);
      });
    });

    group('READ', () {
      test('getAllStatistics() returns empty list when none exist', () async {
        final all = await database.statisticDao.getAllStatistics();
        expect(all, isEmpty);
      });

      test('getAllStatistics() returns all added statistics', () async {
        await database.statisticDao.addStatisticsAsList(
          statistics: [testStatistic1, testStatistic2],
        );

        final all = await database.statisticDao.getAllStatistics();
        expect(all.length, 2);
      });

      test('getStatisticById() returns null for non-existent id', () async {
        final fetched = await database.statisticDao.getStatisticById(
          'non-existent-id',
        );
        expect(fetched, isNull);
      });

      test(
        'getStatisticById() returns correct statistic with scopes',
        () async {
          await database.statisticDao.addStatistic(statistic: testStatistic2);

          final fetched = await database.statisticDao.getStatisticById(
            testStatistic2.id,
          );
          expect(fetched, isNotNull);
          expect(
            fetched!.scopes.contains(StatisticScope.selectedGames),
            isTrue,
          );
          expect(fetched.timeframe, Timeframe.last30Days);
        },
      );

      test('getAllStatistics() preserves all field values', () async {
        await database.statisticDao.addStatistic(statistic: testStatistic1);
        await database.statisticDao.addStatistic(statistic: testStatistic2);
        await database.statisticDao.addStatistic(statistic: testStatistic3);

        final all = await database.statisticDao.getAllStatistics();
        final map = {for (final s in all) s.id: s};

        final s1 = map[testStatistic1.id]!;
        expect(s1.type, testStatistic1.type);
        expect(s1.scopes, testStatistic1.scopes);
        expect(s1.timeframe, testStatistic1.timeframe);
        expect(s1.color, testStatistic1.color);
        expect(s1.displayCount, testStatistic1.displayCount);

        final s2 = map[testStatistic2.id]!;
        expect(s2.selectedGames, isNotNull);
        expect(s2.selectedGames!.first.id, testGame1.id);

        final s3 = map[testStatistic3.id]!;
        expect(s3.selectedGroups, isNotNull);
        expect(s3.selectedGroups!.first.id, testGroup1.id);
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
          testStatistic1.id,
        );
        expect(fetched!.displayCount, 10);
      });

      test(
        'updateDisplayCount() returns false for non-existent statistic',
        () async {
          final updated = await database.statisticDao.updateDisplayCount(
            'non-existent-id',
            10,
          );
          expect(updated, isFalse);
        },
      );

      test('updateDisplayCount() does not change other fields', () async {
        await database.statisticDao.addStatistic(statistic: testStatistic1);
        await database.statisticDao.updateDisplayCount(testStatistic1.id, 3);

        final fetched = await database.statisticDao.getStatisticById(
          testStatistic1.id,
        );
        expect(fetched!.type, testStatistic1.type);
        expect(fetched.timeframe, testStatistic1.timeframe);
        expect(fetched.color, testStatistic1.color);
      });
    });

    group('DELETE', () {
      test('deleteStatistic() works correctly', () async {
        await database.statisticDao.addStatistic(statistic: testStatistic1);

        final deleted = await database.statisticDao.deleteStatistic(
          testStatistic1.id,
        );
        expect(deleted, isTrue);

        final fetched = await database.statisticDao.getStatisticById(
          testStatistic1.id,
        );
        expect(fetched, isNull);
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

    group('Statistic Scope DAO Tests', () {
      test('getScopeForStatistic() returns correct scopes after add', () async {
        await database.statisticDao.addStatistic(statistic: testStatistic2);

        final scopes = await database.statisticScopeDao.getScopeForStatistic(
          testStatistic2.id,
        );
        expect(scopes, contains(StatisticScope.selectedGames));
      });

      test('getScopeForStatistic() returns empty for unknown id', () async {
        final scopes = await database.statisticScopeDao.getScopeForStatistic(
          'non-existent-id',
        );
        expect(scopes, isEmpty);
      });

      test('addStatisticScopes() adds multiple scopes correctly', () async {
        await database.statisticDao.addStatistic(statistic: testStatistic1);

        const extraScopes = [
          StatisticScope.selectedGames,
          StatisticScope.selectedGroups,
        ];
        await database.statisticScopeDao.addStatisticScopes(
          statisticId: testStatistic1.id,
          scopes: extraScopes,
        );

        final scopes = await database.statisticScopeDao.getScopeForStatistic(
          testStatistic1.id,
        );
        for (final scope in extraScopes) {
          expect(scopes, contains(scope));
        }
      });
    });

    group('Statistic Game DAO Tests', () {
      test(
        'getGamesForStatistic() returns null when no games are linked',
        () async {
          await database.statisticDao.addStatistic(statistic: testStatistic1);

          final games = await database.statisticGameDao.getGamesForStatistic(
            testStatistic1.id,
          );
          expect(games, isNull);
        },
      );

      test('getGamesForStatistic() returns correct games', () async {
        await database.statisticDao.addStatistic(statistic: testStatistic2);

        final games = await database.statisticGameDao.getGamesForStatistic(
          testStatistic2.id,
        );
        expect(games, isNotNull);
        expect(games!.length, 1);
        expect(games.first.id, testGame1.id);
        expect(games.first.name, testGame1.name);
        expect(games.first.ruleset, testGame1.ruleset);
      });

      test('addStatisticGames() adds multiple games correctly', () async {
        await database.statisticDao.addStatistic(statistic: testStatistic1);

        await database.statisticGameDao.addStatisticGames(
          statisticId: testStatistic1.id,
          games: [testGame1, testGame2],
        );

        final games = await database.statisticGameDao.getGamesForStatistic(
          testStatistic1.id,
        );
        expect(games, isNotNull);
        expect(games!.length, 2);

        final ids = games.map((g) => g.id).toSet();
        expect(ids.contains(testGame1.id), isTrue);
        expect(ids.contains(testGame2.id), isTrue);
      });
    });

    group('Statistic Group DAO Tests', () {
      test(
        'getGroupsForStatistic() returns null when no groups are linked',
        () async {
          await database.statisticDao.addStatistic(statistic: testStatistic1);

          final groups = await database.statisticGroupDao.getGroupsForStatistic(
            testStatistic1.id,
          );
          expect(groups, isNull);
        },
      );

      test('getGroupsForStatistic() returns correct groups', () async {
        await database.statisticDao.addStatistic(statistic: testStatistic3);

        final groups = await database.statisticGroupDao.getGroupsForStatistic(
          testStatistic3.id,
        );
        expect(groups, isNotNull);
        expect(groups!.length, 1);
        expect(groups.first.id, testGroup1.id);
        expect(groups.first.name, testGroup1.name);
      });

      test(
        'getGroupsForStatistic() returns group with correct members',
        () async {
          await database.statisticDao.addStatistic(statistic: testStatistic3);

          final groups = await database.statisticGroupDao.getGroupsForStatistic(
            testStatistic3.id,
          );
          expect(groups, isNotNull);
          final members = groups!.first.members;
          expect(members.length, testGroup1.members.length);

          final memberIds = members.map((m) => m.id).toSet();
          for (final member in testGroup1.members) {
            expect(memberIds.contains(member.id), isTrue);
          }
        },
      );

      test('addStatisticGroups() adds multiple groups correctly', () async {
        await database.statisticDao.addStatistic(statistic: testStatistic1);

        await database.statisticGroupDao.addStatisticGroups(
          statisticId: testStatistic1.id,
          groups: [testGroup1, testGroup2],
        );

        final groups = await database.statisticGroupDao.getGroupsForStatistic(
          testStatistic1.id,
        );
        expect(groups, isNotNull);
        expect(groups!.length, 2);

        final ids = groups.map((g) => g.id).toSet();
        expect(ids.contains(testGroup1.id), isTrue);
        expect(ids.contains(testGroup2.id), isTrue);
      });
    });
  });
}
