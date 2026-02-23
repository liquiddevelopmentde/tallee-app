import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/dto/player.dart';

void main() {
  late AppDatabase database;
  late Player testPlayer1;
  late Player testPlayer2;
  late Player testPlayer3;
  late Player testPlayer4;
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
      testPlayer1 = Player(name: 'Test Player');
      testPlayer2 = Player(name: 'Second Player');
      testPlayer3 = Player(name: 'Charlie');
      testPlayer4 = Player(name: 'Diana');
    });
  });
  tearDown(() async {
    await database.close();
  });

  group('Player Tests', () {
    test('Adding and fetching single player works correctly', () async {
      await database.playerDao.addPlayer(player: testPlayer1);
      await database.playerDao.addPlayer(player: testPlayer2);

      final allPlayers = await database.playerDao.getAllPlayers();
      expect(allPlayers.length, 2);

      final fetchedPlayer1 = allPlayers.firstWhere(
        (g) => g.id == testPlayer1.id,
      );
      expect(fetchedPlayer1.name, testPlayer1.name);
      expect(fetchedPlayer1.createdAt, testPlayer1.createdAt);

      final fetchedPlayer2 = allPlayers.firstWhere(
        (g) => g.id == testPlayer2.id,
      );
      expect(fetchedPlayer2.name, testPlayer2.name);
      expect(fetchedPlayer2.createdAt, testPlayer2.createdAt);
    });

    test('Adding and fetching multiple players works correctly', () async {
      await database.playerDao.addPlayersAsList(
        players: [testPlayer1, testPlayer2, testPlayer3, testPlayer4],
      );

      final allPlayers = await database.playerDao.getAllPlayers();
      expect(allPlayers.length, 4);

      // Map for connencting fetched players with expected players
      final testPlayers = {
        testPlayer1.id: testPlayer1,
        testPlayer2.id: testPlayer2,
        testPlayer3.id: testPlayer3,
        testPlayer4.id: testPlayer4,
      };

      for (final player in allPlayers) {
        final testPlayer = testPlayers[player.id]!;

        expect(player.id, testPlayer.id);
        expect(player.name, testPlayer.name);
        expect(player.createdAt, testPlayer.createdAt);
      }
    });

    test('Adding the same player twice does not create duplicates', () async {
      await database.playerDao.addPlayer(player: testPlayer1);
      await database.playerDao.addPlayer(player: testPlayer1);

      final allPlayers = await database.playerDao.getAllPlayers();
      expect(allPlayers.length, 1);
    });

    test('Player existence check works correctly', () async {
      var playerExists = await database.playerDao.playerExists(
        playerId: testPlayer1.id,
      );
      expect(playerExists, false);

      await database.playerDao.addPlayer(player: testPlayer1);

      playerExists = await database.playerDao.playerExists(
        playerId: testPlayer1.id,
      );
      expect(playerExists, true);
    });

    test('Deleting a player works correctly', () async {
      await database.playerDao.addPlayer(player: testPlayer1);
      final playerDeleted = await database.playerDao.deletePlayer(
        playerId: testPlayer1.id,
      );
      expect(playerDeleted, true);

      final playerExists = await database.playerDao.playerExists(
        playerId: testPlayer1.id,
      );
      expect(playerExists, false);
    });

    test('Updating a player name works correcly', () async {
      await database.playerDao.addPlayer(player: testPlayer1);

      const newPlayerName = 'new player name';

      await database.playerDao.updatePlayername(
        playerId: testPlayer1.id,
        newName: newPlayerName,
      );

      final result = await database.playerDao.getPlayerById(
        playerId: testPlayer1.id,
      );
      expect(result.name, newPlayerName);
    });

    test('Getting the player count works correctly', () async {
      var playerCount = await database.playerDao.getPlayerCount();
      expect(playerCount, 0);

      await database.playerDao.addPlayer(player: testPlayer1);

      playerCount = await database.playerDao.getPlayerCount();
      expect(playerCount, 1);

      await database.playerDao.addPlayer(player: testPlayer2);

      playerCount = await database.playerDao.getPlayerCount();
      expect(playerCount, 2);

      await database.playerDao.deletePlayer(playerId: testPlayer1.id);

      playerCount = await database.playerDao.getPlayerCount();
      expect(playerCount, 1);

      await database.playerDao.deletePlayer(playerId: testPlayer2.id);

      playerCount = await database.playerDao.getPlayerCount();
      expect(playerCount, 0);
    });
  });
}
