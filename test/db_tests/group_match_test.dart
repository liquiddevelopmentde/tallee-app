import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/dto/group.dart';
import 'package:tallee/data/dto/match.dart';
import 'package:tallee/data/dto/player.dart';

void main() {
  late AppDatabase database;
  late Player testPlayer1;
  late Player testPlayer2;
  late Player testPlayer3;
  late Player testPlayer4;
  late Player testPlayer5;
  late Group testGroup1;
  late Group testGroup2;
  late Match testMatchWithGroup;
  late Match testMatchWithPlayers;
  final fixedDate = DateTime(2025, 19, 11, 00, 11, 23);
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
        name: 'Test Group',
        members: [testPlayer1, testPlayer2, testPlayer3],
      );
      testGroup2 = Group(
        name: 'Test Group',
        members: [testPlayer3, testPlayer2],
      );
      testMatchWithPlayers = Match(
        name: 'Test Match with Players',
        players: [testPlayer4, testPlayer5],
      );
      testMatchWithGroup = Match(
        name: 'Test Match with Group',
        group: testGroup1,
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
  });
  tearDown(() async {
    await database.close();
  });
  group('Group-Match Tests', () {
    test('matchHasGroup() has group works correctly', () async {
      await database.matchDao.addMatch(match: testMatchWithPlayers);
      await database.groupDao.addGroup(group: testGroup1);

      var matchHasGroup = await database.groupMatchDao.matchHasGroup(
        matchId: testMatchWithPlayers.id,
      );

      expect(matchHasGroup, false);

      await database.groupMatchDao.addGroupToMatch(
        matchId: testMatchWithPlayers.id,
        groupId: testGroup1.id,
      );

      matchHasGroup = await database.groupMatchDao.matchHasGroup(
        matchId: testMatchWithPlayers.id,
      );

      expect(matchHasGroup, true);
    });

    test('Adding a group to a match works correctly', () async {
      await database.matchDao.addMatch(match: testMatchWithPlayers);
      await database.groupDao.addGroup(group: testGroup1);
      await database.groupMatchDao.addGroupToMatch(
        matchId: testMatchWithPlayers.id,
        groupId: testGroup1.id,
      );

      var groupAdded = await database.groupMatchDao.isGroupInMatch(
        matchId: testMatchWithPlayers.id,
        groupId: testGroup1.id,
      );
      expect(groupAdded, true);

      groupAdded = await database.groupMatchDao.isGroupInMatch(
        matchId: testMatchWithPlayers.id,
        groupId: '',
      );
      expect(groupAdded, false);
    });

    test('Removing group from match works correctly', () async {
      await database.matchDao.addMatch(match: testMatchWithGroup);

      final groupToRemove = testMatchWithGroup.group!;

      final removed = await database.groupMatchDao.removeGroupFromMatch(
        groupId: groupToRemove.id,
        matchId: testMatchWithGroup.id,
      );
      expect(removed, true);

      final result = await database.matchDao.getMatchById(
        matchId: testMatchWithGroup.id,
      );
      expect(result.group, null);
    });

    test('Retrieving group of a match works correctly', () async {
      await database.matchDao.addMatch(match: testMatchWithGroup);
      final group = await database.groupMatchDao.getGroupOfMatch(
        matchId: testMatchWithGroup.id,
      );

      if (group == null) {
        fail('Group should not be null');
      }

      expect(group.id, testGroup1.id);
      expect(group.name, testGroup1.name);
      expect(group.createdAt, testGroup1.createdAt);
      expect(group.members.length, testGroup1.members.length);
      for (int i = 0; i < group.members.length; i++) {
        expect(group.members[i].id, testGroup1.members[i].id);
        expect(group.members[i].name, testGroup1.members[i].name);
        expect(group.members[i].createdAt, testGroup1.members[i].createdAt);
      }
    });

    test('Updating the group of a match works correctly', () async {
      await database.matchDao.addMatch(match: testMatchWithGroup);

      var group = await database.groupMatchDao.getGroupOfMatch(
        matchId: testMatchWithGroup.id,
      );

      if (group == null) {
        fail('Initial group should not be null');
      } else {
        expect(group.id, testGroup1.id);
        expect(group.name, testGroup1.name);
        expect(group.createdAt, testGroup1.createdAt);
        expect(group.members.length, testGroup1.members.length);
      }

      await database.groupDao.addGroup(group: testGroup2);
      await database.groupMatchDao.updateGroupOfMatch(
        matchId: testMatchWithGroup.id,
        newGroupId: testGroup2.id,
      );

      group = await database.groupMatchDao.getGroupOfMatch(
        matchId: testMatchWithGroup.id,
      );

      if (group == null) {
        fail('Updated group should not be null');
      } else {
        expect(group.id, testGroup2.id);
        expect(group.name, testGroup2.name);
        expect(group.createdAt, testGroup2.createdAt);
        expect(group.members.length, testGroup2.members.length);
        for (int i = 0; i < group.members.length; i++) {
          expect(group.members[i].id, testGroup2.members[i].id);
          expect(group.members[i].name, testGroup2.members[i].name);
          expect(group.members[i].createdAt, testGroup2.members[i].createdAt);
        }
      }
    });

    test('Adding the same group to seperate matches works correctly', () async {
      final match1 = Match(name: 'Match 1', group: testGroup1);
      final match2 = Match(name: 'Match 2', group: testGroup1);

      await Future.wait([
        database.matchDao.addMatch(match: match1),
        database.matchDao.addMatch(match: match2),
      ]);

      final group1 = await database.groupMatchDao.getGroupOfMatch(
        matchId: match1.id,
      );
      final group2 = await database.groupMatchDao.getGroupOfMatch(
        matchId: match2.id,
      );

      expect(group1, isNotNull);
      expect(group2, isNotNull);

      final groups = [group1!, group2!];
      for (final group in groups) {
        expect(group.members.length, testGroup1.members.length);
        expect(group.id, testGroup1.id);
        expect(group.name, testGroup1.name);
        expect(group.createdAt, testGroup1.createdAt);
      }
    });
  });
}
