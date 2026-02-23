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
  late Group testgroup;
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
      testgroup = Group(
        name: 'Test Group',
        members: [testPlayer1, testPlayer2, testPlayer3],
      );
    });
  });
  tearDown(() async {
    await database.close();
  });

  group('Player-Group Tests', () {
    /// No need to test if group has players since the members attribute is
    /// not nullable

    test('Adding a player to a group works correctly', () async {
      await database.groupDao.addGroup(group: testgroup);
      await database.playerDao.addPlayer(player: testPlayer4);
      await database.playerGroupDao.addPlayerToGroup(
        groupId: testgroup.id,
        player: testPlayer4,
      );

      var playerAdded = await database.playerGroupDao.isPlayerInGroup(
        groupId: testgroup.id,
        playerId: testPlayer4.id,
      );

      expect(playerAdded, true);

      playerAdded = await database.playerGroupDao.isPlayerInGroup(
        groupId: testgroup.id,
        playerId: '',
      );

      expect(playerAdded, false);
    });

    test('Removing player from group works correctly', () async {
      await database.groupDao.addGroup(group: testgroup);

      final playerToRemove = testgroup.members[0];

      final removed = await database.playerGroupDao.removePlayerFromGroup(
        playerId: playerToRemove.id,
        groupId: testgroup.id,
      );
      expect(removed, true);

      final result = await database.groupDao.getGroupById(
        groupId: testgroup.id,
      );
      expect(result.members.length, testgroup.members.length - 1);

      final playerExists = result.members.any((p) => p.id == playerToRemove.id);
      expect(playerExists, false);
    });

    test('Retrieving players of a group works correctly', () async {
      await database.groupDao.addGroup(group: testgroup);
      final players = await database.playerGroupDao.getPlayersOfGroup(
        groupId: testgroup.id,
      );

      for (int i = 0; i < players.length; i++) {
        expect(players[i].id, testgroup.members[i].id);
        expect(players[i].name, testgroup.members[i].name);
        expect(players[i].createdAt, testgroup.members[i].createdAt);
      }
    });
  });
}
