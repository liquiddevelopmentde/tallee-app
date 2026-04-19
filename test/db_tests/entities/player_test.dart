import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/player.dart';

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
      testPlayer1 = Player(name: 'Test Player', description: '');
      testPlayer2 = Player(name: 'Second Player', description: '');
      testPlayer3 = Player(name: 'Charlie', description: '');
      testPlayer4 = Player(name: 'Diana', description: '');
    });
  });
  tearDown(() async {
    await database.close();
  });

  group('Player Tests', () {
    // Verifies that players can be added and retrieved with all fields intact.
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

    // Verifies that multiple players can be added at once and retrieved correctly.
    test('Adding and fetching multiple players works correctly', () async {
      await database.playerDao.addPlayersAsList(
        players: [testPlayer1, testPlayer2, testPlayer3, testPlayer4],
      );

      final allPlayers = await database.playerDao.getAllPlayers();
      expect(allPlayers.length, 4);

      // Map for connecting fetched players with expected players
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

    // Verifies that adding the same player twice does not create duplicates.
    test('Adding the same player twice does not create duplicates', () async {
      await database.playerDao.addPlayer(player: testPlayer1);
      await database.playerDao.addPlayer(player: testPlayer1);

      final allPlayers = await database.playerDao.getAllPlayers();
      expect(allPlayers.length, 1);
    });

    // Verifies that playerExists returns correct boolean based on player presence.
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

    // Verifies that deletePlayer removes the player and returns true.
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

    // Verifies that updatePlayerName correctly updates only the name field.
    test('Updating a player name works correctly', () async {
      await database.playerDao.addPlayer(player: testPlayer1);

      const newPlayerName = 'new player name';

      await database.playerDao.updatePlayerName(
        playerId: testPlayer1.id,
        newName: newPlayerName,
      );

      final result = await database.playerDao.getPlayerById(
        playerId: testPlayer1.id,
      );
      expect(result.name, newPlayerName);
    });

    // Verifies that getPlayerCount returns correct count through add/delete operations.
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

    // Verifies that getAllPlayers returns an empty list when no players exist.
    test('getAllPlayers returns empty list when no players exist', () async {
      final allPlayers = await database.playerDao.getAllPlayers();
      expect(allPlayers, isEmpty);
    });

    // Verifies that getPlayerById returns the correct player.
    test('getPlayerById returns correct player', () async {
      await database.playerDao.addPlayer(player: testPlayer1);
      await database.playerDao.addPlayer(player: testPlayer2);

      final fetchedPlayer = await database.playerDao.getPlayerById(
        playerId: testPlayer1.id,
      );

      expect(fetchedPlayer.id, testPlayer1.id);
      expect(fetchedPlayer.name, testPlayer1.name);
      expect(fetchedPlayer.createdAt, testPlayer1.createdAt);
      expect(fetchedPlayer.description, testPlayer1.description);
    });

    // Verifies that getPlayerById throws StateError for non-existent player ID.
    test('getPlayerById throws exception for non-existent player', () async {
      expect(
        () => database.playerDao.getPlayerById(playerId: 'non-existent-id'),
        throwsA(isA<StateError>()),
      );
    });

    // Verifies that addPlayer returns false when trying to add a duplicate player.
    test('addPlayer returns false when player already exists', () async {
      final firstAdd = await database.playerDao.addPlayer(player: testPlayer1);
      expect(firstAdd, true);

      final secondAdd = await database.playerDao.addPlayer(player: testPlayer1);
      expect(secondAdd, false);
    });

    // Verifies that addPlayersAsList handles empty list correctly.
    test('addPlayersAsList handles empty list correctly', () async {
      final result = await database.playerDao.addPlayersAsList(players: []);
      expect(result, false);

      final allPlayers = await database.playerDao.getAllPlayers();
      expect(allPlayers, isEmpty);
    });

    // Verifies that addPlayersAsList ignores duplicate player IDs.
    test('addPlayersAsList with duplicate IDs ignores duplicates', () async {
      await database.playerDao.addPlayersAsList(
        players: [testPlayer1, testPlayer1, testPlayer2],
      );

      final allPlayers = await database.playerDao.getAllPlayers();
      expect(allPlayers.length, 2);
    });

    // Verifies that deletePlayer returns false for non-existent player.
    test('deletePlayer returns false for non-existent player', () async {
      final result = await database.playerDao.deletePlayer(
        playerId: 'non-existent-id',
      );
      expect(result, false);
    });

    // Verifies that updatePlayerName does nothing for non-existent player (no exception).
    test('updatePlayerName does nothing for non-existent player', () async {
      // Should not throw, just do nothing
      await database.playerDao.updatePlayerName(
        playerId: 'non-existent-id',
        newName: 'New Name',
      );

      final allPlayers = await database.playerDao.getAllPlayers();
      expect(allPlayers, isEmpty);
    });

    // Verifies that deleteAllPlayers removes all players.
    test('deleteAllPlayers removes all players', () async {
      await database.playerDao.addPlayersAsList(
        players: [testPlayer1, testPlayer2, testPlayer3],
      );

      var playerCount = await database.playerDao.getPlayerCount();
      expect(playerCount, 3);

      final result = await database.playerDao.deleteAllPlayers();
      expect(result, true);

      playerCount = await database.playerDao.getPlayerCount();
      expect(playerCount, 0);
    });

    // Verifies that deleteAllPlayers returns false when no players exist.
    test('deleteAllPlayers returns false when no players exist', () async {
      final result = await database.playerDao.deleteAllPlayers();
      expect(result, false);
    });

    // Verifies that a player with special characters in name is stored correctly.
    test(
      'Player with special characters in name is stored correctly',
      () async {
        final specialPlayer = Player(
          name: 'Test!@#\$%^&*()_+-=[]{}|;\':",.<>?/`~',
          description: '',
        );

        await database.playerDao.addPlayer(player: specialPlayer);

        final fetchedPlayer = await database.playerDao.getPlayerById(
          playerId: specialPlayer.id,
        );
        expect(fetchedPlayer.name, specialPlayer.name);
      },
    );

    // Verifies that a player with description is stored correctly.
    test('Player with description is stored correctly', () async {
      final playerWithDescription = Player(
        name: 'Described Player',
        description: 'This is a test description',
      );

      await database.playerDao.addPlayer(player: playerWithDescription);

      final fetchedPlayer = await database.playerDao.getPlayerById(
        playerId: playerWithDescription.id,
      );
      expect(fetchedPlayer.name, playerWithDescription.name);
      expect(fetchedPlayer.description, playerWithDescription.description);
    });

    // Verifies that a player with null description is stored correctly.
    test('Player with null description is stored correctly', () async {
      final playerWithoutDescription = Player(
        name: 'No Description Player',
        description: '',
      );

      await database.playerDao.addPlayer(player: playerWithoutDescription);

      final fetchedPlayer = await database.playerDao.getPlayerById(
        playerId: playerWithoutDescription.id,
      );
      expect(fetchedPlayer.description, '');
    });

    // Verifies that multiple updates to the same player work correctly.
    test('Multiple updates to the same player work correctly', () async {
      await database.playerDao.addPlayer(player: testPlayer1);

      await database.playerDao.updatePlayerName(
        playerId: testPlayer1.id,
        newName: 'First Update',
      );

      var fetchedPlayer = await database.playerDao.getPlayerById(
        playerId: testPlayer1.id,
      );
      expect(fetchedPlayer.name, 'First Update');

      await database.playerDao.updatePlayerName(
        playerId: testPlayer1.id,
        newName: 'Second Update',
      );

      fetchedPlayer = await database.playerDao.getPlayerById(
        playerId: testPlayer1.id,
      );
      expect(fetchedPlayer.name, 'Second Update');

      await database.playerDao.updatePlayerName(
        playerId: testPlayer1.id,
        newName: 'Third Update',
      );

      fetchedPlayer = await database.playerDao.getPlayerById(
        playerId: testPlayer1.id,
      );
      expect(fetchedPlayer.name, 'Third Update');
    });

    // Verifies that a player with empty string name is stored correctly.
    test('Player with empty string name is stored correctly', () async {
      final emptyNamePlayer = Player(name: '', description: '');

      await database.playerDao.addPlayer(player: emptyNamePlayer);

      final fetchedPlayer = await database.playerDao.getPlayerById(
        playerId: emptyNamePlayer.id,
      );
      expect(fetchedPlayer.name, '');
    });

    // Verifies that a player with very long name is stored correctly.
    test('Player with very long name is stored correctly', () async {
      final longName = 'A' * 1000;
      final longNamePlayer = Player(name: longName, description: '');

      await database.playerDao.addPlayer(player: longNamePlayer);

      final fetchedPlayer = await database.playerDao.getPlayerById(
        playerId: longNamePlayer.id,
      );
      expect(fetchedPlayer.name, longName);
    });

    // Verifies that addPlayer returns true on first add.
    test('addPlayer returns true when player is added successfully', () async {
      final result = await database.playerDao.addPlayer(player: testPlayer1);
      expect(result, true);

      final playerExists = await database.playerDao.playerExists(
        playerId: testPlayer1.id,
      );
      expect(playerExists, true);
    });

    group('Name Count Tests', () {
      test('Single player gets initialized wih name count  0', () async {
        await database.playerDao.addPlayer(player: testPlayer1);

        final player = await database.playerDao.getPlayerById(
          playerId: testPlayer1.id,
        );
        expect(player.nameCount, 0);
      });

      test('Multiple players get initialized wih name count  0', () async {
        await database.playerDao.addPlayersAsList(
          players: [testPlayer1, testPlayer2],
        );

        final players = await database.playerDao.getAllPlayers();

        expect(players.length, 2);
        for (Player p in players) {
          expect(p.nameCount, 0);
        }
      });

      test(
        'Seperatly added players nameCount gets increased correctly',
        () async {
          await database.playerDao.addPlayer(player: testPlayer1);

          final player1 = Player(name: testPlayer1.name, description: '');
          await database.playerDao.addPlayer(player: player1);

          var players = await database.playerDao.getAllPlayers();

          expect(players.length, 2);
          players.sort((a, b) => a.nameCount.compareTo(b.nameCount));

          for (int i = 0; i < players.length - 1; i++) {
            expect(players[i].nameCount, i + 1);
          }
        },
      );

      test(
        'Together added players nameCount gets increased correctly',
        () async {
          final player1 = Player(name: testPlayer1.name, description: '');
          final player2 = Player(name: testPlayer1.name, description: '');
          final player3 = Player(name: testPlayer1.name, description: '');

          // addPlayersAsList() with multiple players and with one player
          await database.playerDao.addPlayersAsList(players: [testPlayer1]);
          await database.playerDao.addPlayersAsList(
            players: [player1, player2, player3],
          );

          var players = await database.playerDao.getAllPlayers();

          expect(players.length, 4);
          players.sort((a, b) => a.nameCount.compareTo(b.nameCount));

          for (int i = 0; i < players.length - 1; i++) {
            expect(players[i].nameCount, i + 1);
          }
        },
      );

      test('getNameCount works  correctly', () async {
        final player2 = Player(name: testPlayer1.name, description: '');
        final player3 = Player(name: testPlayer1.name, description: '');

        await database.playerDao.addPlayersAsList(
          players: [testPlayer1, player2, player3],
        );

        final nameCount = await database.playerDao.getNameCount(
          name: testPlayer1.name,
        );

        expect(nameCount, 2);
      });

      test('updateNameCount works correctly', () async {
        await database.playerDao.addPlayer(player: testPlayer1);

        final success = await database.playerDao.updateNameCount(
          playerId: testPlayer1.id,
          nameCount: 2,
        );

        expect(success, true);

        final nameCount = await database.playerDao.getNameCount(
          name: testPlayer1.name,
        );

        expect(nameCount, 2);
      });

      test('getPlayerWithHighestNameCount works correctly', () async {
        final player2 = Player(name: testPlayer1.name, description: '');
        final player3 = Player(name: testPlayer1.name, description: '');

        await database.playerDao.addPlayersAsList(
          players: [testPlayer1, player2, player3],
        );

        final player = await database.playerDao.getPlayerWithHighestNameCount(
          name: testPlayer1.name,
        );

        expect(player, isNotNull);
        expect(player!.nameCount, 3);
      });

      test('getPlayerWithHighestNameCount with non existing player', () async {
        final player = await database.playerDao.getPlayerWithHighestNameCount(
          name: 'non-existing-name',
        );
        expect(player, isNull);
      });

      test('calculateNameCount works correctly', () async {
        // Case 1: No existing players with the name
        var count = await database.playerDao.calculateNameCount(
          name: testPlayer1.name,
        );
        expect(count, 0);

        // Case 2: One existing player with the name. Should update that
        // player's nameCount to 1 and return 2 for the new player
        await database.playerDao.addPlayer(player: testPlayer1);

        count = await database.playerDao.calculateNameCount(
          name: testPlayer1.name,
        );
        expect(count, 2);

        // Case 3: Multiple existing players with the name.
        final player2 = Player(name: testPlayer1.name, nameCount: count);
        await database.playerDao.addPlayer(player: player2);

        count = await database.playerDao.calculateNameCount(
          name: testPlayer1.name,
        );
        expect(count, 3);
      });

      test('getPlayerWithHighestNameCount with non existing player', () async {
        await database.playerDao.addPlayer(player: testPlayer1);
        await database.playerDao.initializeNameCount(name: testPlayer1.name);
        final player = await database.playerDao.getPlayerById(
          playerId: testPlayer1.id,
        );
        expect(player.nameCount, 1);
      });
    });
  });
}
