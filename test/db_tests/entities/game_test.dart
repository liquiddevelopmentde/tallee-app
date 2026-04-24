import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';

void main() {
  late AppDatabase database;
  late Game testGame1;
  late Game testGame2;
  late Game testGame3;
  final fixedDate = DateTime(2025, 11, 19, 00, 11, 23);
  final fakeClock = Clock(() => fixedDate);

  setUp(() {
    database = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );

    withClock(fakeClock, () {
      testGame1 = Game(
        id: 'game1',
        name: 'Chess',
        ruleset: Ruleset.singleWinner,
        description: 'A classic strategy game',
        color: GameColor.blue,
        icon: 'chess_icon',
      );
      testGame2 = Game(
        id: 'game2',
        name: 'Poker',
        ruleset: Ruleset.multipleWinners,
        description: 'Card game with multiple winners',
        color: GameColor.red,
        icon: 'poker_icon',
      );
      testGame3 = Game(
        id: 'game3',
        name: 'Monopoly',
        ruleset: Ruleset.highestScore,
        description: 'A board game about real estate',
        color: GameColor.orange,
        icon: '',
      );
    });
  });

  tearDown(() async {
    await database.close();
  });

  group('Game Tests', () {
    group('CREATE', () {
      test('Adding and fetching a single game works correctly', () async {
        final added = await database.gameDao.addGame(game: testGame1);
        expect(added, true);

        final game = await database.gameDao.getGameById(gameId: testGame1.id);
        expect(game.id, testGame1.id);
        expect(game.name, testGame1.name);
        expect(game.ruleset, testGame1.ruleset);
        expect(game.description, testGame1.description);
        expect(game.color, testGame1.color);
        expect(game.icon, testGame1.icon);
        expect(game.createdAt, testGame1.createdAt);
      });

      test('Adding and fetching multiple games works correctly', () async {
        final added = await database.gameDao.addGamesAsList(
          games: [testGame1, testGame2, testGame3],
        );
        expect(added, true);

        final allGames = await database.gameDao.getAllGames();
        expect(allGames.length, 3);

        // Map for connecting fetched games with expected games
        final testGames = {
          testGame1.id: testGame1,
          testGame2.id: testGame2,
          testGame3.id: testGame3,
        };

        for (final game in allGames) {
          final testGame = testGames[game.id]!;

          expect(game.id, testGame.id);
          expect(game.name, testGame.name);
          expect(game.createdAt, testGame.createdAt);
          expect(game.description, testGame.description);
          expect(game.ruleset, testGame.ruleset);
          expect(game.color, testGame.color);
          expect(game.icon, testGame.icon);
        }
      });

      test('addGamesAsList() returns false for empty list', () async {
        final result = await database.gameDao.addGamesAsList(games: []);
        expect(result, false);

        final allGames = await database.gameDao.getAllGames();
        expect(allGames.length, 0);
      });

      test('addGamesAsList() ignores duplicate games', () async {
        final added = await database.gameDao.addGamesAsList(
          games: [testGame1, testGame2, testGame1],
        );
        expect(added, true);

        final allGames = await database.gameDao.getAllGames();
        expect(allGames.length, 2);
      });

      test(
        'Game with special characters in name is stored correctly',
        () async {
          final specialGame = Game(
            name: 'Game\'s & "Special" <Name>',
            ruleset: Ruleset.multipleWinners,
            description: 'Description with émojis 🎮🎲',
            color: GameColor.purple,
            icon: '',
          );
          await database.gameDao.addGame(game: specialGame);

          final fetchedGame = await database.gameDao.getGameById(
            gameId: specialGame.id,
          );
          expect(fetchedGame.name, 'Game\'s & "Special" <Name>');
          expect(fetchedGame.description, 'Description with émojis 🎮🎲');
        },
      );
    });

    group('READ', () {
      test('getGameById() works correctly', () async {
        await database.gameDao.addGame(game: testGame1);

        final game = await database.gameDao.getGameById(gameId: testGame1.id);
        expect(game.id, testGame1.id);
        expect(game.name, testGame1.name);
        expect(game.ruleset, testGame1.ruleset);
        expect(game.description, testGame1.description);
        expect(game.color, testGame1.color);
        expect(game.icon, testGame1.icon);
      });

      test('getGameById() throws exception for non-existent game', () async {
        expect(
          () => database.gameDao.getGameById(gameId: 'non-existent-id'),
          throwsA(isA<StateError>()),
        );
      });

      test('gameExists() works correctly', () async {
        var exists = await database.gameDao.gameExists(gameId: testGame1.id);
        expect(exists, false);

        await database.gameDao.addGame(game: testGame1);
        exists = await database.gameDao.gameExists(gameId: testGame1.id);
        expect(exists, true);
      });

      test('getAllGames() returns empty list when no games exist', () async {
        final allGames = await database.gameDao.getAllGames();
        expect(allGames, isEmpty);
      });

      test('getGameCount() works correctly', () async {
        var count = await database.gameDao.getGameCount();
        expect(count, 0);

        await database.gameDao.addGame(game: testGame1);
        count = await database.gameDao.getGameCount();
        expect(count, 1);

        await database.gameDao.addGame(game: testGame2);
        count = await database.gameDao.getGameCount();
        expect(count, 2);

        await database.gameDao.deleteGame(gameId: testGame1.id);
        count = await database.gameDao.getGameCount();
        expect(count, 1);
      });
    });

    group('UPDATE', () {
      test('updateGameName() works correctly', () async {
        await database.gameDao.addGame(game: testGame1);
        const newName = 'New name';

        final updated = await database.gameDao.updateGameName(
          gameId: testGame1.id,
          newName: newName,
        );
        expect(updated, true);

        final updatedGame = await database.gameDao.getGameById(
          gameId: testGame1.id,
        );
        expect(updatedGame.name, newName);
      });

      test('updateGameName() does nothing for non-existent game', () async {
        final updated = await database.gameDao.updateGameName(
          gameId: 'non-existent-id',
          newName: 'New name',
        );
        expect(updated, false);

        final allGames = await database.gameDao.getAllGames();
        expect(allGames, isEmpty);
      });

      test('updateGameRuleset() works correctly', () async {
        await database.gameDao.addGame(game: testGame1);
        const ruleset = Ruleset.highestScore;

        final updated = await database.gameDao.updateGameRuleset(
          gameId: testGame1.id,
          newRuleset: ruleset,
        );
        expect(updated, true);

        final updatedGame = await database.gameDao.getGameById(
          gameId: testGame1.id,
        );
        expect(updatedGame.ruleset, ruleset);
      });

      test('updateGameRuleset() does nothing for non-existent game', () async {
        final updated = await database.gameDao.updateGameRuleset(
          gameId: 'non-existent-id',
          newRuleset: Ruleset.lowestScore,
        );
        expect(updated, false);

        final allGames = await database.gameDao.getAllGames();
        expect(allGames, isEmpty);
      });

      test('updateGameDescription() works correctly', () async {
        await database.gameDao.addGame(game: testGame1);
        const newDescription = 'New description';

        final updated = await database.gameDao.updateGameDescription(
          gameId: testGame1.id,
          newDescription: newDescription,
        );
        expect(updated, true);

        final updatedGame = await database.gameDao.getGameById(
          gameId: testGame1.id,
        );
        expect(updatedGame.description, newDescription);
      });

      test(
        'updateGameDescription() does nothing for non-existent game',
        () async {
          final updated = await database.gameDao.updateGameDescription(
            gameId: 'non-existent-id',
            newDescription: 'New description',
          );
          expect(updated, false);

          final allGames = await database.gameDao.getAllGames();
          expect(allGames, isEmpty);
        },
      );

      test('updateGameColor() works correctly', () async {
        await database.gameDao.addGame(game: testGame1);

        await database.gameDao.updateGameColor(
          gameId: testGame1.id,
          newColor: GameColor.green,
        );

        final updatedGame = await database.gameDao.getGameById(
          gameId: testGame1.id,
        );
        expect(updatedGame.color, GameColor.green);
      });

      test('updateGameColor() does nothing for non-existent game', () async {
        final updated = await database.gameDao.updateGameColor(
          gameId: 'non-existent-id',
          newColor: GameColor.green,
        );
        expect(updated, false);

        final allGames = await database.gameDao.getAllGames();
        expect(allGames, isEmpty);
      });

      test('updateGameIcon() works correctly', () async {
        await database.gameDao.addGame(game: testGame1);
        const newIcon = 'new_chess_icon';

        final updated = await database.gameDao.updateGameIcon(
          gameId: testGame1.id,
          newIcon: newIcon,
        );
        expect(updated, true);

        final updatedGame = await database.gameDao.getGameById(
          gameId: testGame1.id,
        );
        expect(updatedGame.icon, newIcon);
      });

      test('updateGameIcon() does nothing for non-existent game', () async {
        final updated = await database.gameDao.updateGameIcon(
          gameId: 'non-existent-id',
          newIcon: 'New icon',
        );
        expect(updated, false);

        final allGames = await database.gameDao.getAllGames();
        expect(allGames, isEmpty);
      });

      test('Multiple updates to the same game work correctly', () async {
        await database.gameDao.addGame(game: testGame1);

        const newName = 'New name';
        await database.gameDao.updateGameName(
          gameId: testGame1.id,
          newName: newName,
        );

        const newGameColor = GameColor.teal;
        await database.gameDao.updateGameColor(
          gameId: testGame1.id,
          newColor: newGameColor,
        );

        const newDescription = 'New description';
        await database.gameDao.updateGameDescription(
          gameId: testGame1.id,
          newDescription: newDescription,
        );

        final updatedGame = await database.gameDao.getGameById(
          gameId: testGame1.id,
        );

        // Changed values
        expect(updatedGame.name, newName);
        expect(updatedGame.color, newGameColor);
        expect(updatedGame.description, newDescription);

        // Staying the same
        expect(updatedGame.ruleset, testGame1.ruleset);
        expect(updatedGame.icon, testGame1.icon);
      });
    });
    group('DELETE', () {
      test('deleteGame() works correctly', () async {
        await database.gameDao.addGame(game: testGame1);

        final deleted = await database.gameDao.deleteGame(gameId: testGame1.id);
        expect(deleted, true);

        final allGames = await database.gameDao.getAllGames();
        expect(allGames, isEmpty);
      });

      test('deleteGame() returns false for non-existent game', () async {
        final deleted = await database.gameDao.deleteGame(
          gameId: 'non-existent-id',
        );
        expect(deleted, false);
      });

      test('deleteAllGames() removes all games', () async {
        await database.gameDao.addGamesAsList(
          games: [testGame1, testGame2, testGame3],
        );

        var count = await database.gameDao.getGameCount();
        expect(count, 3);

        final deleted = await database.gameDao.deleteAllGames();
        expect(deleted, true);

        count = await database.gameDao.getGameCount();
        expect(count, 0);
      });

      test('deleteAllGames() returns false when no games exist', () async {
        final deleted = await database.gameDao.deleteAllGames();
        expect(deleted, false);
      });
    });
  });
}
