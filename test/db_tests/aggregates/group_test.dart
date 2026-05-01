import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';

void main() {
  late AppDatabase database;
  late Player testPlayer1;
  late Player testPlayer2;
  late Player testPlayer3;
  late Player testPlayer4;
  late Group testGroup1;
  late Group testGroup2;
  late Group testGroup3;
  late Group testGroup4;
  final fixedDate = DateTime(2025, 19, 11, 00, 11, 23);
  final fakeClock = Clock(() => fixedDate);

  setUp(() {
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
      testGroup1 = Group(
        name: 'Test Group',
        members: [testPlayer1, testPlayer2, testPlayer3],
        description: 'description of the test group 1',
      );
      testGroup2 = Group(
        id: 'gr2',
        name: 'Second Group',
        members: [testPlayer2, testPlayer3, testPlayer4],
        description: 'description of the test group 2',
      );
      testGroup3 = Group(
        id: 'gr2',
        name: 'Second Group',
        members: [testPlayer2, testPlayer4],
      );
      testGroup4 = Group(
        id: 'gr2',
        name: 'Second Group',
        members: [testPlayer1, testPlayer2, testPlayer3, testPlayer4],
      );
    });
  });
  tearDown(() async {
    await database.close();
  });
  group('Group Tests', () {
    group('CREATE', () {
      test('Adding and fetching a single group works correctly', () async {
        await database.groupDao.addGroup(group: testGroup1);

        final fetchedGroup = await database.groupDao.getGroupById(
          groupId: testGroup1.id,
        );

        expect(fetchedGroup.id, testGroup1.id);
        expect(fetchedGroup.name, testGroup1.name);
        expect(fetchedGroup.createdAt, testGroup1.createdAt);

        expect(fetchedGroup.members.length, testGroup1.members.length);
        for (int i = 0; i < testGroup1.members.length; i++) {
          expect(fetchedGroup.members[i].id, testGroup1.members[i].id);
          expect(fetchedGroup.members[i].name, testGroup1.members[i].name);
          expect(
            fetchedGroup.members[i].createdAt,
            testGroup1.members[i].createdAt,
          );
        }
      });

      test('Adding the same group twice does not create duplicates', () async {
        await database.groupDao.addGroup(group: testGroup1);
        await database.groupDao.addGroup(group: testGroup1);

        final allGroups = await database.groupDao.getAllGroups();
        expect(allGroups.length, 1);

        final fetchedGroup = await database.groupDao.getGroupById(
          groupId: testGroup1.id,
        );
        expect(fetchedGroup.id, testGroup1.id);
        expect(fetchedGroup.members.length, testGroup1.members.length);
      });

      test('addGroup() returns false when group already exists', () async {
        final firstAdd = await database.groupDao.addGroup(group: testGroup1);
        expect(firstAdd, isTrue);

        final secondAdd = await database.groupDao.addGroup(group: testGroup1);
        expect(secondAdd, isFalse);

        final allGroups = await database.groupDao.getAllGroups();
        expect(allGroups.length, 1);
      });

      test('Adding and fetching multiple groups works correctly', () async {
        await database.groupDao.addGroupsAsList(
          groups: [testGroup1, testGroup2, testGroup3, testGroup4],
        );

        final allGroups = await database.groupDao.getAllGroups();
        expect(allGroups.length, 2);

        final testGroups = {
          testGroup1.id: testGroup1,
          testGroup2.id: testGroup2,
        };

        for (final group in allGroups) {
          final testGroup = testGroups[group.id]!;

          expect(group.id, testGroup.id);
          expect(group.name, testGroup.name);
          expect(group.createdAt, testGroup.createdAt);

          expect(group.members.length, testGroup.members.length);
          for (int i = 0; i < testGroup.members.length; i++) {
            expect(group.members[i].id, testGroup.members[i].id);
            expect(group.members[i].name, testGroup.members[i].name);
            expect(group.members[i].createdAt, testGroup.members[i].createdAt);
          }
        }
      });

      test('addGroupsAsList() handles empty list correctly', () async {
        await database.groupDao.addGroupsAsList(groups: []);

        final allGroups = await database.groupDao.getAllGroups();
        expect(allGroups.length, 0);
      });
    });

    group('READ', () {
      test('groupExists() works correctly', () async {
        var groupExists = await database.groupDao.groupExists(
          groupId: testGroup1.id,
        );
        expect(groupExists, isFalse);

        await database.groupDao.addGroup(group: testGroup1);

        groupExists = await database.groupDao.groupExists(
          groupId: testGroup1.id,
        );
        expect(groupExists, isTrue);
      });

      test('getGroupCount() works correctly', () async {
        var count = await database.groupDao.getGroupCount();
        expect(count, 0);

        var added = await database.groupDao.addGroup(group: testGroup1);
        expect(added, isTrue);
        count = await database.groupDao.getGroupCount();
        expect(count, 1);

        added = await database.groupDao.addGroup(group: testGroup2);
        expect(added, isTrue);
        count = await database.groupDao.getGroupCount();
        expect(count, 2);

        final removed = await database.groupDao.deleteGroup(
          groupId: testGroup1.id,
        );
        expect(removed, isTrue);
        count = await database.groupDao.getGroupCount();
        expect(count, 1);
      });

      test('getGroupById() throws exception for non-existent group', () async {
        expect(
          () => database.groupDao.getGroupById(groupId: 'non-existent-id'),
          throwsA(isA<StateError>()),
        );
      });

      test('getAllGroups() returns empty list when no groups exist', () async {
        final allGroups = await database.groupDao.getAllGroups();
        expect(allGroups, isEmpty);
      });

      test('addGroupsAsList() with duplicate groups only adds once', () async {
        await database.groupDao.addGroupsAsList(
          groups: [testGroup1, testGroup1, testGroup1],
        );

        final allGroups = await database.groupDao.getAllGroups();
        expect(allGroups.length, 1);
      });
    });

    group('UPDATE', () {
      test('updateGroupName() works correctly', () async {
        await database.groupDao.addGroup(group: testGroup1);

        const newName = 'New name';
        await database.groupDao.updateGroupName(
          groupId: testGroup1.id,
          name: newName,
        );

        final result = await database.groupDao.getGroupById(
          groupId: testGroup1.id,
        );
        expect(result.name, newName);
      });

      test('updateGroupName() returns false for non-existent group', () async {
        final updated = await database.groupDao.updateGroupName(
          groupId: 'non-existent-id',
          name: 'New name',
        );
        expect(updated, isFalse);
      });

      test('updateGroupDescription() works correctly', () async {
        await database.groupDao.addGroup(group: testGroup1);

        const newDescription = 'New description';
        final updated = await database.groupDao.updateGroupDescription(
          groupId: testGroup1.id,
          description: newDescription,
        );
        expect(updated, isTrue);

        final group = await database.groupDao.getGroupById(
          groupId: testGroup1.id,
        );
        expect(group.description, newDescription);
      });

      test(
        'updateGroupDescription() returns false for non-existent group',
        () async {
          final updated = await database.groupDao.updateGroupDescription(
            groupId: 'non-existent-id',
            description: 'New description',
          );
          expect(updated, isFalse);
        },
      );

      test('Multiple updates to the same group work correctly', () async {
        await database.groupDao.addGroup(group: testGroup1);
        const newName = 'New name';
        const newDescription = 'New description';

        await database.groupDao.updateGroupName(
          groupId: testGroup1.id,
          name: newName,
        );
        await database.groupDao.updateGroupDescription(
          groupId: testGroup1.id,
          description: newDescription,
        );

        final updatedGroup = await database.groupDao.getGroupById(
          groupId: testGroup1.id,
        );
        expect(updatedGroup.name, newName);
        expect(updatedGroup.description, newDescription);
      });

      test('replaceGroupPlayers() works correctly', () async {
        await database.groupDao.addGroup(group: testGroup1);

        final initialGroup = await database.groupDao.getGroupById(
          groupId: testGroup1.id,
        );
        expect(initialGroup.members.length, 3);
        expect(
          initialGroup.members
              .map((p) => p.id)
              .toList()
              .contains(testPlayer1.id),
          isTrue,
        );
        expect(
          initialGroup.members
              .map((p) => p.id)
              .toList()
              .contains(testPlayer2.id),
          isTrue,
        );
        expect(
          initialGroup.members
              .map((p) => p.id)
              .toList()
              .contains(testPlayer3.id),
          isTrue,
        );

        final newPlayers = [testPlayer2, testPlayer4];
        final replaced = await database.playerGroupDao.replaceGroupPlayers(
          groupId: testGroup1.id,
          newPlayers: newPlayers,
        );
        expect(replaced, isTrue);

        final updatedGroup = await database.groupDao.getGroupById(
          groupId: testGroup1.id,
        );
        expect(updatedGroup.members.length, 2);

        final memberIds = updatedGroup.members.map((p) => p.id).toList();
        expect(memberIds.contains(testPlayer2.id), isTrue);
        expect(memberIds.contains(testPlayer4.id), isTrue);
        expect(memberIds.contains(testPlayer1.id), isFalse);
        expect(memberIds.contains(testPlayer3.id), isFalse);
      });

      test('replaceGroupPlayers() ignores empty list ', () async {
        await database.groupDao.addGroup(group: testGroup1);

        final replaced = await database.playerGroupDao.replaceGroupPlayers(
          groupId: testGroup1.id,
          newPlayers: [],
        );
        expect(replaced, isFalse);

        final updatedGroup = await database.groupDao.getGroupById(
          groupId: testGroup1.id,
        );
        expect(updatedGroup.members.length, testGroup1.members.length);
      });

      test(
        'replaceGroupPlayers() returns false for non-existent group',
        () async {
          final replaced = await database.playerGroupDao.replaceGroupPlayers(
            groupId: 'non-existent-id',
            newPlayers: [testPlayer1],
          );
          expect(replaced, isFalse);
        },
      );
    });

    group('DELETE', () {
      test('deleteGroup() works correctly', () async {
        await database.groupDao.addGroup(group: testGroup1);

        final groupDeleted = await database.groupDao.deleteGroup(
          groupId: testGroup1.id,
        );
        expect(groupDeleted, isTrue);

        final groupExists = await database.groupDao.groupExists(
          groupId: testGroup1.id,
        );
        expect(groupExists, isFalse);
      });

      test('deleteGroup() returns false for non-existent group', () async {
        final deleted = await database.groupDao.deleteGroup(
          groupId: 'non-existent-id',
        );
        expect(deleted, isFalse);
      });

      test('deleteAllGroups() works correctly', () async {
        await database.groupDao.addGroupsAsList(
          groups: [testGroup1, testGroup2],
        );

        var count = await database.groupDao.getGroupCount();
        expect(count, 2);

        final deleted = await database.groupDao.deleteAllGroups();
        expect(deleted, isTrue);

        count = await database.groupDao.getGroupCount();
        expect(count, 0);
      });

      test('deleteAllGroups() returns false when no groups exist', () async {
        final deleted = await database.groupDao.deleteAllGroups();
        expect(deleted, isFalse);
      });
    });

    group('Edge Cases', () {
      test('Group with special characters is stored correctly', () async {
        final specialGroup = Group(
          name: 'Group\'s & "Special" <Name>',
          description: 'Description with émojis 🎮🎲',
          members: [testPlayer1],
        );
        await database.groupDao.addGroup(group: specialGroup);

        final fetchedGroup = await database.groupDao.getGroupById(
          groupId: specialGroup.id,
        );
        expect(fetchedGroup.name, 'Group\'s & "Special" <Name>');
        expect(fetchedGroup.description, 'Description with émojis 🎮🎲');
      });
    });
  });
}
