import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/statistic.dart';

void main() {
  late AppDatabase database;
  late Player testPlayer1;
  late Player testPlayer2;
  late Player testPlayer3;
  late Player testPlayer4;
  late Group testGroup1;
  late Group testGroup2;
  late Group testGroup3;
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
      testPlayer1 = Player(name: 'Alice');
      testPlayer2 = Player(name: 'Bob');
      testPlayer3 = Player(name: 'Charlie');
      testPlayer4 = Player(name: 'Diana');
      testGroup1 = Group(
        name: 'Group Alpha',
        description: '',
        members: [testPlayer1, testPlayer2],
      );
      testGroup2 = Group(
        name: 'Group Beta',
        description: '',
        members: [testPlayer3],
      );
      testGroup3 = Group(
        name: 'Group Gamma',
        description: 'Empty group',
        members: [],
      );
      testStatistic = Statistic(
        type: StatisticType.totalMatches,
        scopes: [StatisticScope.selectedGroups],
        timeframe: Timeframe.allTime,
        color: AppColor.blue,
      );
    });

    await database.playerDao.addPlayersAsList(
      players: [testPlayer1, testPlayer2, testPlayer3, testPlayer4],
    );
    await database.groupDao.addGroupsAsList(
      groups: [testGroup1, testGroup2, testGroup3],
    );
    await database.statisticDao.addStatistic(statistic: testStatistic);
  });

  tearDown(() async {
    await database.close();
  });

  group('Statistic-Group Tests', () {
    group('READ', () {
      test(
        'getGroupsForStatistic() returns null for non-existing 9d ',
        () async {
          final groups = await database.statisticGroupDao.getGroupsForStatistic(
            'non-existing-id',
          );
          expect(groups, isNull);
        },
      );

      test('getGroupsForStatistic() returns the correct group', () async {
        await database.statisticGroupDao.addStatisticGroups(
          statisticId: testStatistic.id,
          groups: [testGroup1],
        );

        final groups = await database.statisticGroupDao.getGroupsForStatistic(
          testStatistic.id,
        );
        expect(groups, isNotNull);
        expect(groups!.length, 1);
        expect(groups.first.id, testGroup1.id);
        expect(groups.first.name, testGroup1.name);
        expect(groups.first.description, testGroup1.description);
        expect(groups.first.members.length, testGroup1.members.length);
        final memberIds = groups.first.members.map((m) => m.id).toSet();
        expect(memberIds.contains(testPlayer1.id), isTrue);
        expect(memberIds.contains(testPlayer2.id), isTrue);
      });

      test('getGroupsForStatistic() returns all linked groups', () async {
        await database.statisticGroupDao.addStatisticGroups(
          statisticId: testStatistic.id,
          groups: [testGroup1, testGroup2, testGroup3],
        );

        final groups = await database.statisticGroupDao.getGroupsForStatistic(
          testStatistic.id,
        );
        expect(groups, isNotNull);
        expect(groups!.length, 3);

        final ids = groups.map((g) => g.id).toSet();
        expect(ids.contains(testGroup1.id), isTrue);
        expect(ids.contains(testGroup2.id), isTrue);
        expect(ids.contains(testGroup3.id), isTrue);
      });
    });

    group('CREATE', () {
      test('addStatisticGroups() returns true on success', () async {
        final success = await database.statisticGroupDao.addStatisticGroups(
          statisticId: testStatistic.id,
          groups: [testGroup1],
        );
        expect(success, isTrue);
      });

      test('addStatisticGroups() adds a single group correctly', () async {
        await database.statisticGroupDao.addStatisticGroups(
          statisticId: testStatistic.id,
          groups: [testGroup1],
        );

        final groups = await database.statisticGroupDao.getGroupsForStatistic(
          testStatistic.id,
        );
        expect(groups, isNotNull);
        expect(groups!.length, 1);
        expect(groups.first.id, testGroup1.id);
        expect(groups.first.name, testGroup1.name);
        expect(groups.first.description, testGroup1.description);
        expect(groups.first.members.length, testGroup1.members.length);
        final memberIds = groups.first.members.map((m) => m.id).toSet();
        expect(memberIds.contains(testPlayer1.id), isTrue);
        expect(memberIds.contains(testPlayer2.id), isTrue);
      });

      test('addStatisticGroups() adds multiple groups correctly', () async {
        await database.statisticGroupDao.addStatisticGroups(
          statisticId: testStatistic.id,
          groups: [testGroup1, testGroup2],
        );

        final groups = await database.statisticGroupDao.getGroupsForStatistic(
          testStatistic.id,
        );
        expect(groups, isNotNull);
        expect(groups!.length, 2);
      });

      test(
        'addStatisticGroups() with duplicate groups does not create duplicate entries',
        () async {
          await database.statisticGroupDao.addStatisticGroups(
            statisticId: testStatistic.id,
            groups: [testGroup1],
          );
          await database.statisticGroupDao.addStatisticGroups(
            statisticId: testStatistic.id,
            groups: [testGroup1],
          );

          final groups = await database.statisticGroupDao.getGroupsForStatistic(
            testStatistic.id,
          );
          expect(groups!.length, 1);
        },
      );
    });
  });
}
