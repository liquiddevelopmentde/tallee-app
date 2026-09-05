import 'dart:core' hide Match;

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';

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
      testPlayer1 = Player(name: 'Anna', description: 'First test player');
      testPlayer2 = Player(name: 'Bob', description: 'Second test player');
      testPlayer3 = Player(name: 'Charlie');
      testPlayer4 = Player(name: 'Diana');
    });
  });
  tearDown(() async {
    await database.close();
  });

  group('Player Tests', () {
    group('CREATE', () {
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
        expect(fetchedPlayer1.description, testPlayer1.description);

        final fetchedPlayer2 = allPlayers.firstWhere(
          (g) => g.id == testPlayer2.id,
        );
        expect(fetchedPlayer2.name, testPlayer2.name);
        expect(fetchedPlayer2.createdAt, testPlayer2.createdAt);
        expect(fetchedPlayer2.description, testPlayer2.description);
      });

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
          expect(player.description, testPlayer.description);
        }
      });

      test('Adding the same player twice does not create duplicates', () async {
        await database.playerDao.addPlayer(player: testPlayer1);
        await database.playerDao.addPlayer(player: testPlayer1);

        final allPlayers = await database.playerDao.getAllPlayers();
        expect(allPlayers.length, 1);
      });

      test('addPlayer() returns false when player already exists', () async {
        var added = await database.playerDao.addPlayer(player: testPlayer1);
        expect(added, isTrue);

        added = await database.playerDao.addPlayer(player: testPlayer1);
        expect(added, isFalse);
      });

      test('addPlayersAsList() handles empty list correctly', () async {
        final added = await database.playerDao.addPlayersAsList(players: []);
        expect(added, isFalse);

        final allPlayers = await database.playerDao.getAllPlayers();
        expect(allPlayers, isEmpty);
      });

      test(
        'addPlayersAsList() with duplicate IDs ignores duplicates',
        () async {
          await database.playerDao.addPlayersAsList(
            players: [testPlayer1, testPlayer1, testPlayer2],
          );

          final allPlayers = await database.playerDao.getAllPlayers();
          expect(allPlayers.length, 2);
        },
      );

      test(
        'Player with special characters in name is stored correctly',
        () async {
          final specialPlayer = Player(
            name: 'Test!@#\$%^&*()_+-=[]{}|;\':"😎,.<>?/`~',
          );

          await database.playerDao.addPlayer(player: specialPlayer);

          final fetchedPlayer = await database.playerDao.getPlayerById(
            playerId: specialPlayer.id,
          );
          expect(fetchedPlayer.name, specialPlayer.name);
        },
      );
    });

    group('READ', () {
      test('getPlayerCount() works correctly', () async {
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

      test('playerExists() works correctly', () async {
        var playerExists = await database.playerDao.playerExists(
          playerId: testPlayer1.id,
        );
        expect(playerExists, isFalse);

        await database.playerDao.addPlayer(player: testPlayer1);
        playerExists = await database.playerDao.playerExists(
          playerId: testPlayer1.id,
        );
        expect(playerExists, isTrue);
      });

      test(
        'getAllPlayers() returns empty list when no players exist',
        () async {
          final allPlayers = await database.playerDao.getAllPlayers();
          expect(allPlayers, isEmpty);
        },
      );

      test('getPlayerById() returns correct player', () async {
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

      test(
        'getPlayerById() throws exception for non-existent player',
        () async {
          expect(
            () => database.playerDao.getPlayerById(playerId: 'non-existent-id'),
            throwsA(isA<StateError>()),
          );
        },
      );

      test('getPlayersByIds() works correctly', () async {
        await database.playerDao.addPlayersAsList(
          players: [testPlayer1, testPlayer2, testPlayer3, testPlayer4],
        );

        final result = await database.playerDao.getPlayersByIds(
          playerIds: [testPlayer1.id, testPlayer3.id],
        );

        expect(result.length, 2);
        final ids = result.map((p) => p.id).toSet();
        expect(ids, containsAll([testPlayer1.id, testPlayer3.id]));
        expect(ids, isNot(contains(testPlayer2.id)));
      });

      test('getPlayersByIds() returns empty list for empty input', () async {
        final result = await database.playerDao.getPlayersByIds(playerIds: []);
        expect(result, isEmpty);
      });
    });

    group('UPDATE', () {
      test('updatePlayerName() works correctly', () async {
        await database.playerDao.addPlayer(player: testPlayer1);

        const newName = 'New name';

        await database.playerDao.updatePlayerName(
          playerId: testPlayer1.id,
          name: newName,
        );

        final player = await database.playerDao.getPlayerById(
          playerId: testPlayer1.id,
        );
        expect(player.name, newName);
      });

      test('updatePlayerName() does nothing for non-existent player', () async {
        final updated = await database.playerDao.updatePlayerName(
          playerId: 'non-existent-id',
          name: 'New name',
        );
        expect(updated, isFalse);

        final allPlayers = await database.playerDao.getAllPlayers();
        expect(allPlayers, isEmpty);
      });

      test('updatePlayerName() sets correct nameCount with 2 player', () async {
        await database.playerDao.addPlayer(player: testPlayer1);
        await database.playerDao.addPlayer(player: testPlayer2);

        final newName = testPlayer1.name;
        await database.playerDao.updatePlayerName(
          playerId: testPlayer2.id,
          name: newName,
        );

        var player = await database.playerDao.getPlayerById(
          playerId: testPlayer1.id,
        );
        expect(player.nameCount, 1);

        player = await database.playerDao.getPlayerById(
          playerId: testPlayer2.id,
        );
        expect(player.nameCount, 2);

        await database.playerDao.updatePlayerName(
          playerId: testPlayer1.id,
          name: 'different name',
        );

        player = await database.playerDao.getPlayerById(
          playerId: testPlayer1.id,
        );
        expect(player.nameCount, 0);

        player = await database.playerDao.getPlayerById(
          playerId: testPlayer2.id,
        );
        expect(player.nameCount, 0);
      });

      test('updatePlayerName() sets correct nameCount with 3 player', () async {
        await database.playerDao.addPlayersAsList(
          players: [testPlayer1, testPlayer2, testPlayer3],
        );

        // Changing both names to player 1's name
        final newName = testPlayer1.name;
        await database.playerDao.updatePlayerName(
          playerId: testPlayer2.id,
          name: newName,
        );
        await database.playerDao.updatePlayerName(
          playerId: testPlayer3.id,
          name: newName,
        );

        var player = await database.playerDao.getPlayerById(
          playerId: testPlayer1.id,
        );
        expect(player.nameCount, 1);

        player = await database.playerDao.getPlayerById(
          playerId: testPlayer2.id,
        );
        expect(player.nameCount, 2);

        player = await database.playerDao.getPlayerById(
          playerId: testPlayer3.id,
        );
        expect(player.nameCount, 3);

        // Changing the middle players name
        await database.playerDao.updatePlayerName(
          playerId: testPlayer2.id,
          name: 'different name',
        );

        player = await database.playerDao.getPlayerById(
          playerId: testPlayer1.id,
        );
        expect(player.nameCount, 1);

        player = await database.playerDao.getPlayerById(
          playerId: testPlayer2.id,
        );
        expect(player.nameCount, 0);

        player = await database.playerDao.getPlayerById(
          playerId: testPlayer3.id,
        );
        expect(player.nameCount, 2);
      });

      test('updatePlayerDescription() works correctly', () async {
        await database.playerDao.addPlayer(player: testPlayer1);

        const newDescription = 'New description';

        final updated = await database.playerDao.updatePlayerDescription(
          playerId: testPlayer1.id,
          description: newDescription,
        );
        expect(updated, isTrue);

        final player = await database.playerDao.getPlayerById(
          playerId: testPlayer1.id,
        );
        expect(player.description, newDescription);
      });

      test(
        'updatePlayerDescription() does nothing for non-existent player',
        () async {
          final updated = await database.playerDao.updatePlayerDescription(
            playerId: 'non-existent-id',
            description: 'New description',
          );
          expect(updated, isFalse);

          final allPlayers = await database.playerDao.getAllPlayers();
          expect(allPlayers, isEmpty);
        },
      );

      test('Multiple updates to the same player work correctly', () async {
        await database.playerDao.addPlayer(player: testPlayer1);

        await database.playerDao.updatePlayerName(
          playerId: testPlayer1.id,
          name: 'First Update',
        );

        var fetchedPlayer = await database.playerDao.getPlayerById(
          playerId: testPlayer1.id,
        );
        expect(fetchedPlayer.name, 'First Update');

        await database.playerDao.updatePlayerName(
          playerId: testPlayer1.id,
          name: 'Second Update',
        );

        fetchedPlayer = await database.playerDao.getPlayerById(
          playerId: testPlayer1.id,
        );
        expect(fetchedPlayer.name, 'Second Update');

        await database.playerDao.updatePlayerDescription(
          playerId: testPlayer1.id,
          description: 'Third Update',
        );

        fetchedPlayer = await database.playerDao.getPlayerById(
          playerId: testPlayer1.id,
        );
        expect(fetchedPlayer.description, 'Third Update');
      });
    });

    group('DELETE', () {
      test('deletePlayer() works correctly', () async {
        await database.playerDao.addPlayer(player: testPlayer1);
        final playerDeleted = await database.playerDao.deletePlayer(
          playerId: testPlayer1.id,
        );
        expect(playerDeleted, isTrue);

        final playerExists = await database.playerDao.playerExists(
          playerId: testPlayer1.id,
        );
        expect(playerExists, isFalse);
      });

      test('deletePlayer() returns false for non-existent player', () async {
        final deleted = await database.playerDao.deletePlayer(
          playerId: 'non-existent-id',
        );
        expect(deleted, isFalse);
      });

      test(
        'deletePlayer() true deletes only when player is not in a match',
        () async {
          await database.playerDao.addPlayersAsList(
            players: [testPlayer1, testPlayer2],
          );

          final game = Game(name: 'test-game', ruleset: Ruleset.highestScore);
          await database.gameDao.addGame(game: game);

          final match = Match(
            name: 'test-match',
            game: game,
            players: [testPlayer1, testPlayer2],
          );
          final added = await database.matchDao.addMatch(match: match);
          expect(added, isTrue);

          var deleted = await database.playerDao.deletePlayer(
            playerId: testPlayer1.id,
          );
          expect(deleted, isTrue);
          var exists = await database.playerDao.playerExists(
            playerId: testPlayer1.id,
          );
          expect(exists, isTrue);

          final removed = await database.playerMatchDao.removePlayerFromMatch(
            matchId: match.id,
            playerId: testPlayer1.id,
          );
          expect(removed, isTrue);

          deleted = await database.playerDao.deletePlayer(
            playerId: testPlayer1.id,
          );
          expect(deleted, isTrue);
          exists = await database.playerDao.playerExists(
            playerId: testPlayer1.id,
          );
          expect(exists, isFalse);
        },
      );

      test('deleteAllPlayers() removes all players', () async {
        await database.playerDao.addPlayersAsList(
          players: [testPlayer1, testPlayer2, testPlayer3],
        );

        var playerCount = await database.playerDao.getPlayerCount();
        expect(playerCount, 3);

        final deleted = await database.playerDao.deleteAllPlayers();
        expect(deleted, isTrue);

        playerCount = await database.playerDao.getPlayerCount();
        expect(playerCount, 0);
      });

      test('deleteAllPlayers() returns false when no players exist', () async {
        final deleted = await database.playerDao.deleteAllPlayers();
        expect(deleted, isFalse);
      });
    });

    group('NAME COUNT', () {
      test('Single player gets initialized wih name count 0', () async {
        await database.playerDao.addPlayer(player: testPlayer1);

        final player = await database.playerDao.getPlayerById(
          playerId: testPlayer1.id,
        );
        expect(player.nameCount, 0);
      });

      test('Multiple players get initialized wih name count 0', () async {
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

          final player2 = Player(name: testPlayer1.name, description: '');
          await database.playerDao.addPlayer(player: player2);

          var players = await database.playerDao.getAllPlayers();

          expect(players.length, 3);
          players.sort((a, b) => a.nameCount.compareTo(b.nameCount));

          for (int i = 0; i < players.length - 1; i++) {
            expect(players[i].nameCount, i + 1);
          }

          // ids are correct in the right order
          expect(players[0].id, testPlayer1.id);
          expect(players[1].id, player1.id);
          expect(players[2].id, player2.id);
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

          // ids are correct in the right order
          expect(players[0].id, testPlayer1.id);
          expect(players[1].id, player1.id);
          expect(players[2].id, player2.id);
          expect(players[3].id, player3.id);
        },
      );

      test('getNameCount works correctly', () async {
        final player1 = Player(name: testPlayer1.name);
        final player2 = Player(name: testPlayer1.name);

        await database.playerDao.addPlayer(player: testPlayer1);

        var nameCount = await database.playerDao.getNameCount(
          name: testPlayer1.name,
        );

        expect(nameCount, 1);

        await database.playerDao.addPlayersAsList(players: [player1, player2]);

        nameCount = await database.playerDao.getNameCount(
          name: testPlayer1.name,
        );

        expect(nameCount, 3);
      });

      test('calculateNameCount works correctly', () async {
        final player1 = Player(name: testPlayer1.name);
        final player2 = Player(name: testPlayer1.name);

        // Case 1: No existing players with the name
        var nameCount = await database.playerDao.calculateNameCount(
          name: testPlayer1.name,
        );
        expect(nameCount, 0);

        // Case 2: One existing player with the name. Should  return 2 for
        // the new player
        await database.playerDao.addPlayer(player: testPlayer1);
        nameCount = await database.playerDao.calculateNameCount(
          name: testPlayer1.name,
        );
        expect(nameCount, 2);

        // Case 3: Multiple existing players with the name. Should return count + 1
        await database.playerDao.addPlayersAsList(players: [player1, player2]);
        nameCount = await database.playerDao.calculateNameCount(
          name: testPlayer1.name,
        );
        expect(nameCount, 4);
      });

      test('updateNameCount works correctly', () async {
        await database.playerDao.addPlayer(player: testPlayer1);

        final success = await database.playerDao.updateNameCount(
          playerId: testPlayer1.id,
          nameCount: 2,
        );
        expect(success, isTrue);

        final player = await database.playerDao.getPlayerById(
          playerId: testPlayer1.id,
        );
        expect(player.nameCount, 2);
      });

      test('getPlayerWithHighestNameCount works correctly', () async {
        final player2 = Player(name: testPlayer1.name, description: '');
        final player3 = Player(name: testPlayer1.name, description: '');

        await database.playerDao.addPlayer(player: testPlayer1);
        var player = await database.playerDao.getPlayerWithHighestNameCount(
          name: testPlayer1.name,
        );
        expect(player, isNotNull);
        expect(player!.nameCount, 0);

        await database.playerDao.addPlayer(player: player2);
        player = await database.playerDao.getPlayerWithHighestNameCount(
          name: testPlayer1.name,
        );
        expect(player, isNotNull);
        expect(player!.nameCount, 2);

        await database.playerDao.addPlayer(player: player3);
        player = await database.playerDao.getPlayerWithHighestNameCount(
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
