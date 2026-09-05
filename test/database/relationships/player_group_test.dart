import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
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
  late Group testGroup;
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
      testGroup = Group(
        name: 'Test Group',
        description: '',
        members: [testPlayer1, testPlayer2, testPlayer3],
      );
    });
  });
  tearDown(() async {
    await database.close();
  });

  group('Player-Group Tests', () {
    group('CREATE', () {
      test('addPlayerToGroup() works correctly', () async {
        await database.groupDao.addGroup(group: testGroup);
        await database.playerDao.addPlayer(player: testPlayer4);
        await database.playerGroupDao.addPlayerToGroup(
          groupId: testGroup.id,
          player: testPlayer4,
        );

        var playerAdded = await database.playerGroupDao.isPlayerInGroup(
          groupId: testGroup.id,
          playerId: testPlayer4.id,
        );

        expect(playerAdded, isTrue);
      });

      test(
        'addPlayerToGroup() returns false when player already in group',
        () async {
          await database.groupDao.addGroup(group: testGroup);

          final added = await database.playerGroupDao.addPlayerToGroup(
            player: testPlayer1,
            groupId: testGroup.id,
          );
          expect(added, isFalse);
        },
      );

      test(
        'addPlayerToGroup() adds player to player table if not exists',
        () async {
          await database.groupDao.addGroup(group: testGroup);

          var playerExists = await database.playerDao.playerExists(
            playerId: testPlayer4.id,
          );
          expect(playerExists, isFalse);

          await database.playerGroupDao.addPlayerToGroup(
            player: testPlayer4,
            groupId: testGroup.id,
          );

          playerExists = await database.playerDao.playerExists(
            playerId: testPlayer4.id,
          );
          expect(playerExists, isTrue);
        },
      );
    });
    group('READ', () {
      test(
        'isPlayerInGroup() returns false for non-existent player or group',
        () async {
          await database.groupDao.addGroup(group: testGroup);

          var isInGroup = await database.playerGroupDao.isPlayerInGroup(
            playerId: 'non-existent-player-id',
            groupId: testGroup.id,
          );
          expect(isInGroup, isFalse);

          isInGroup = await database.playerGroupDao.isPlayerInGroup(
            playerId: testPlayer1.id,
            groupId: 'non-existent-group-id',
          );
          expect(isInGroup, isFalse);

          isInGroup = await database.playerGroupDao.isPlayerInGroup(
            playerId: 'non-existent-player-id',
            groupId: 'non-existent-group-id',
          );
          expect(isInGroup, isFalse);
        },
      );

      test('getPlayersOfGroup() works correctly', () async {
        await database.groupDao.addGroup(group: testGroup);
        final players = await database.playerGroupDao.getPlayersOfGroup(
          groupId: testGroup.id,
        );

        for (int i = 0; i < players.length; i++) {
          expect(players[i].id, testGroup.members[i].id);
          expect(players[i].name, testGroup.members[i].name);
          expect(players[i].createdAt, testGroup.members[i].createdAt);
        }
      });

      test('getPlayersOfGroup() returns empty list for empty group', () async {
        final emptyGroup = Group(name: 'Empty Group', members: []);
        await database.groupDao.addGroup(group: emptyGroup);

        final players = await database.playerGroupDao.getPlayersOfGroup(
          groupId: emptyGroup.id,
        );
        expect(players, isEmpty);
      });

      test(
        'getPlayersOfGroup() returns empty list for non-existent group',
        () async {
          final players = await database.playerGroupDao.getPlayersOfGroup(
            groupId: 'non-existent-group-id',
          );
          expect(players, isEmpty);
        },
      );
    });
    group('UPDATE', () {
      test('replaceGroupPlayers() works correctly ', () async {
        await database.groupDao.addGroup(group: testGroup);

        var groupMembers = await database.groupDao.getGroupById(
          groupId: testGroup.id,
        );
        expect(groupMembers.members.length, testGroup.members.length);

        final newPlayersList = [testPlayer3, testPlayer4];

        final replaced = await database.playerGroupDao.replaceGroupPlayers(
          groupId: testGroup.id,
          newPlayers: newPlayersList,
        );
        expect(replaced, isTrue);

        groupMembers = await database.groupDao.getGroupById(
          groupId: testGroup.id,
        );
        expect(groupMembers.members.length, 2);
        expect(groupMembers.members.any((p) => p.id == testPlayer3.id), isTrue);
        expect(groupMembers.members.any((p) => p.id == testPlayer4.id), isTrue);
      });
    });
    group('DELETE', () {
      test('removePlayerFromGroup() works correctly', () async {
        await database.groupDao.addGroup(group: testGroup);

        final removed = await database.playerGroupDao.removePlayerFromGroup(
          playerId: testPlayer1.id,
          groupId: testGroup.id,
        );
        expect(removed, isTrue);

        final result = await database.groupDao.getGroupById(
          groupId: testGroup.id,
        );
        expect(result.members.length, testGroup.members.length - 1);

        final playerExists = result.members.any((p) => p.id == testPlayer1.id);
        expect(playerExists, isFalse);
      });
    });

    test('Removing all players from a group leaves group empty', () async {
      await database.groupDao.addGroup(group: testGroup);

      for (final player in testGroup.members) {
        await database.playerGroupDao.removePlayerFromGroup(
          playerId: player.id,
          groupId: testGroup.id,
        );
      }

      final players = await database.playerGroupDao.getPlayersOfGroup(
        groupId: testGroup.id,
      );
      expect(players, isEmpty);

      final groupExists = await database.groupDao.groupExists(
        groupId: testGroup.id,
      );
      expect(groupExists, isTrue);
    });

    test('removePlayerFromGroup() works correctly', () async {
      await database.groupDao.addGroup(group: testGroup);

      var removed = await database.playerGroupDao.removePlayerFromGroup(
        playerId: testPlayer1.id,
        groupId: testGroup.id,
      );
      expect(removed, isTrue);

      removed = await database.playerGroupDao.removePlayerFromGroup(
        playerId: testPlayer1.id,
        groupId: testGroup.id,
      );
      expect(removed, isFalse);
    });

    test(
      'removePlayerFromGroup() returns false for non-existent player or group',
      () async {
        await database.groupDao.addGroup(group: testGroup);

        await database.groupDao.addGroup(group: testGroup);

        var removed = await database.playerGroupDao.removePlayerFromGroup(
          playerId: 'non-existent-player-id',
          groupId: testGroup.id,
        );
        expect(removed, isFalse);

        removed = await database.playerGroupDao.removePlayerFromGroup(
          playerId: testPlayer1.id,
          groupId: 'non-existent-group-id',
        );
        expect(removed, isFalse);

        removed = await database.playerGroupDao.removePlayerFromGroup(
          playerId: 'non-existent-player-id',
          groupId: 'non-existent-group-id',
        );
        expect(removed, isFalse);
      },
    );
  });
}
