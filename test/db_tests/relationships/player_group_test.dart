import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/dto/group.dart';
import 'package:tallee/data/dto/player.dart';

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
      testPlayer1 = Player(name: 'Alice', description: '');
      testPlayer2 = Player(name: 'Bob', description: '');
      testPlayer3 = Player(name: 'Charlie', description: '');
      testPlayer4 = Player(name: 'Diana', description: '');
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

    // Verifies that a player can be added to an existing group and isPlayerInGroup returns true.
    test('Adding a player to a group works correctly', () async {
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

      expect(playerAdded, true);

      playerAdded = await database.playerGroupDao.isPlayerInGroup(
        groupId: testGroup.id,
        playerId: '',
      );

      expect(playerAdded, false);
    });

    // Verifies that a player can be removed from a group and the group's member count decreases.
    test('Removing player from group works correctly', () async {
      await database.groupDao.addGroup(group: testGroup);

      final playerToRemove = testGroup.members[0];

      final removed = await database.playerGroupDao.removePlayerFromGroup(
        playerId: playerToRemove.id,
        groupId: testGroup.id,
      );
      expect(removed, true);

      final result = await database.groupDao.getGroupById(
        groupId: testGroup.id,
      );
      expect(result.members.length, testGroup.members.length - 1);

      final playerExists = result.members.any((p) => p.id == playerToRemove.id);
      expect(playerExists, false);
    });

    // Verifies that getPlayersOfGroup returns all members of a group with correct data.
    test('Retrieving players of a group works correctly', () async {
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

    // Verifies that isPlayerInGroup returns false for non-existent player.
    test('isPlayerInGroup returns false for non-existent player', () async {
      await database.groupDao.addGroup(group: testGroup);

      final result = await database.playerGroupDao.isPlayerInGroup(
        playerId: 'non-existent-player-id',
        groupId: testGroup.id,
      );

      expect(result, false);
    });

    // Verifies that isPlayerInGroup returns false for non-existent group.
    test('isPlayerInGroup returns false for non-existent group', () async {
      await database.playerDao.addPlayer(player: testPlayer1);

      final result = await database.playerGroupDao.isPlayerInGroup(
        playerId: testPlayer1.id,
        groupId: 'non-existent-group-id',
      );

      expect(result, false);
    });

    // Verifies that addPlayerToGroup returns false when player already in group.
    test('addPlayerToGroup returns false when player already in group', () async {
      await database.groupDao.addGroup(group: testGroup);

      // testPlayer1 is already in testGroup via group creation
      final result = await database.playerGroupDao.addPlayerToGroup(
        player: testPlayer1,
        groupId: testGroup.id,
      );

      expect(result, false);
    });

    // Verifies that addPlayerToGroup adds player to player table if not exists.
    test('addPlayerToGroup adds player to player table if not exists', () async {
      await database.groupDao.addGroup(group: testGroup);

      // testPlayer4 is not in the database yet
      var playerExists = await database.playerDao.playerExists(
        playerId: testPlayer4.id,
      );
      expect(playerExists, false);

      await database.playerGroupDao.addPlayerToGroup(
        player: testPlayer4,
        groupId: testGroup.id,
      );

      // Now player should exist in player table
      playerExists = await database.playerDao.playerExists(
        playerId: testPlayer4.id,
      );
      expect(playerExists, true);
    });

    // Verifies that removePlayerFromGroup returns false for non-existent player.
    test('removePlayerFromGroup returns false for non-existent player', () async {
      await database.groupDao.addGroup(group: testGroup);

      final result = await database.playerGroupDao.removePlayerFromGroup(
        playerId: 'non-existent-player-id',
        groupId: testGroup.id,
      );

      expect(result, false);
    });

    // Verifies that removePlayerFromGroup returns false for non-existent group.
    test('removePlayerFromGroup returns false for non-existent group', () async {
      await database.playerDao.addPlayer(player: testPlayer1);

      final result = await database.playerGroupDao.removePlayerFromGroup(
        playerId: testPlayer1.id,
        groupId: 'non-existent-group-id',
      );

      expect(result, false);
    });

    // Verifies that getPlayersOfGroup returns empty list for group with no members.
    test('getPlayersOfGroup returns empty list for empty group', () async {
      final emptyGroup = Group(name: 'Empty Group', description: '', members: []);
      await database.groupDao.addGroup(group: emptyGroup);

      final players = await database.playerGroupDao.getPlayersOfGroup(
        groupId: emptyGroup.id,
      );

      expect(players, isEmpty);
    });

    // Verifies that getPlayersOfGroup returns empty list for non-existent group.
    test('getPlayersOfGroup returns empty list for non-existent group', () async {
      final players = await database.playerGroupDao.getPlayersOfGroup(
        groupId: 'non-existent-group-id',
      );

      expect(players, isEmpty);
    });

    // Verifies that removing all players from a group leaves the group empty.
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

      // Group should still exist
      final groupExists = await database.groupDao.groupExists(
        groupId: testGroup.id,
      );
      expect(groupExists, true);
    });

    // Verifies that a player can be in multiple groups.
    test('Player can be in multiple groups', () async {
      final secondGroup = Group(name: 'Second Group', description: '', members: []);
      await database.groupDao.addGroup(group: testGroup);
      await database.groupDao.addGroup(group: secondGroup);

      // Add testPlayer1 to second group (already in testGroup)
      await database.playerGroupDao.addPlayerToGroup(
        player: testPlayer1,
        groupId: secondGroup.id,
      );

      final inFirstGroup = await database.playerGroupDao.isPlayerInGroup(
        playerId: testPlayer1.id,
        groupId: testGroup.id,
      );
      final inSecondGroup = await database.playerGroupDao.isPlayerInGroup(
        playerId: testPlayer1.id,
        groupId: secondGroup.id,
      );

      expect(inFirstGroup, true);
      expect(inSecondGroup, true);
    });

    // Verifies that removing player from one group doesn't affect other groups.
    test('Removing player from one group does not affect other groups', () async {
      final secondGroup = Group(name: 'Second Group', description: '', members: [testPlayer1]);
      await database.groupDao.addGroup(group: testGroup);
      await database.groupDao.addGroup(group: secondGroup);

      // Remove testPlayer1 from testGroup
      await database.playerGroupDao.removePlayerFromGroup(
        playerId: testPlayer1.id,
        groupId: testGroup.id,
      );

      final inFirstGroup = await database.playerGroupDao.isPlayerInGroup(
        playerId: testPlayer1.id,
        groupId: testGroup.id,
      );
      final inSecondGroup = await database.playerGroupDao.isPlayerInGroup(
        playerId: testPlayer1.id,
        groupId: secondGroup.id,
      );

      expect(inFirstGroup, false);
      expect(inSecondGroup, true);
    });

    // Verifies that addPlayerToGroup returns true on successful addition.
    test('addPlayerToGroup returns true on successful addition', () async {
      await database.groupDao.addGroup(group: testGroup);
      await database.playerDao.addPlayer(player: testPlayer4);

      final result = await database.playerGroupDao.addPlayerToGroup(
        player: testPlayer4,
        groupId: testGroup.id,
      );

      expect(result, true);
    });

    // Verifies that removing the same player twice returns false on second attempt.
    test('Removing same player twice returns false on second attempt', () async {
      await database.groupDao.addGroup(group: testGroup);

      final firstRemoval = await database.playerGroupDao.removePlayerFromGroup(
        playerId: testPlayer1.id,
        groupId: testGroup.id,
      );
      expect(firstRemoval, true);

      final secondRemoval = await database.playerGroupDao.removePlayerFromGroup(
        playerId: testPlayer1.id,
        groupId: testGroup.id,
      );
      expect(secondRemoval, false);
    });
  });
}
