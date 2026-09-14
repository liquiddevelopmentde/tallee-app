import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';

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
        ruleset: Ruleset.lives,
        description: 'A classic strategy game',
        color: AppColor.blue,
      );
      testGame2 = Game(
        id: 'game2',
        name: 'Poker',
        ruleset: Ruleset.winner,
        description: 'Card game with multiple winners',
        color: AppColor.red,
      );
      testGame3 = Game(
        id: 'game3',
        name: 'Monopoly',
        ruleset: Ruleset.highestScore,
        description: 'A board game about real estate',
        color: AppColor.orange,
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
        expect(added, isTrue);

        final game = await database.gameDao.getGameById(gameId: testGame1.id);
        expect(game.id, testGame1.id);
        expect(game.name, testGame1.name);
        expect(game.ruleset, testGame1.ruleset);
        expect(game.description, testGame1.description);
        expect(game.color, testGame1.color);
        expect(game.createdAt, testGame1.createdAt);
      });

      test('Adding and fetching multiple games works correctly', () async {
        final added = await database.gameDao.addGamesAsList(
          games: [testGame1, testGame2, testGame3],
        );
        expect(added, isTrue);

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
        }
      });

      test('addGamesAsList() returns false for empty list', () async {
        final result = await database.gameDao.addGamesAsList(games: []);
        expect(result, isFalse);

        final allGames = await database.gameDao.getAllGames();
        expect(allGames.length, 0);
      });

      test('addGamesAsList() ignores duplicate games', () async {
        final added = await database.gameDao.addGamesAsList(
          games: [testGame1, testGame2, testGame1],
        );
        expect(added, isTrue);

        final allGames = await database.gameDao.getAllGames();
        expect(allGames.length, 2);
      });

      test(
        'Game with special characters in name is stored correctly',
        () async {
          final specialGame = Game(
            name: 'Game\'s & "Special" <Name>',
            ruleset: Ruleset.winner,
            description: 'Description with émojis 🎮🎲',
            color: AppColor.purple,
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
      });

      test('getGameById() throws exception for non-existent game', () async {
        expect(
          () => database.gameDao.getGameById(gameId: 'non-existent-id'),
          throwsA(isA<StateError>()),
        );
      });

      test('gameExists() works correctly', () async {
        var exists = await database.gameDao.gameExists(gameId: testGame1.id);
        expect(exists, isFalse);

        await database.gameDao.addGame(game: testGame1);
        exists = await database.gameDao.gameExists(gameId: testGame1.id);
        expect(exists, isTrue);
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

      test('getAllGameCounts() works correctly', () async {
        var counts = await database.gameDao.getAllGameCounts();
        expect(counts, isEmpty);

        await database.gameDao.addGame(game: testGame1);
        await database.gameDao.addGame(game: testGame2);
        await database.matchDao.addMatch(
          match: Match(game: testGame1, name: '', players: []),
        );
        await database.matchDao.addMatch(
          match: Match(game: testGame2, name: '', players: []),
        );

        counts = await database.gameDao.getAllGameCounts();

        expect(counts, hasLength(2));
        expect(counts.contains((testGame1, 1)), isTrue);
        expect(counts.contains((testGame2, 1)), isTrue);
      });

      test('getGamesByIds() works correctly', () async {
        await database.gameDao.addGamesAsList(
          games: [testGame1, testGame2, testGame3],
        );

        final result = await database.gameDao.getGamesByIds(
          gameIds: [testGame1.id, testGame3.id],
        );

        expect(result.length, 2);
        final ids = result.map((g) => g.id).toSet();
        expect(ids, containsAll([testGame1.id, testGame3.id]));
        expect(ids, isNot(contains(testGame2.id)));
      });

      test('getGamesByIds() returns empty list for empty input', () async {
        final result = await database.gameDao.getGamesByIds(gameIds: []);
        expect(result, isEmpty);
      });
    });

    group('UPDATE', () {
      test('updateGameName() works correctly', () async {
        await database.gameDao.addGame(game: testGame1);
        const newName = 'New name';

        final updated = await database.gameDao.updateGameName(
          gameId: testGame1.id,
          name: newName,
        );
        expect(updated, isTrue);

        final updatedGame = await database.gameDao.getGameById(
          gameId: testGame1.id,
        );
        expect(updatedGame.name, newName);
      });

      test('updateGameName() does nothing for non-existent game', () async {
        final updated = await database.gameDao.updateGameName(
          gameId: 'non-existent-id',
          name: 'New name',
        );
        expect(updated, isFalse);

        final allGames = await database.gameDao.getAllGames();
        expect(allGames, isEmpty);
      });

      test('updateGameRuleset() works correctly', () async {
        await database.gameDao.addGame(game: testGame1);
        const ruleset = Ruleset.highestScore;

        final updated = await database.gameDao.updateGameRuleset(
          gameId: testGame1.id,
          ruleset: ruleset,
        );
        expect(updated, isTrue);

        final updatedGame = await database.gameDao.getGameById(
          gameId: testGame1.id,
        );
        expect(updatedGame.ruleset, ruleset);
      });

      test('updateGameRuleset() does nothing for non-existent game', () async {
        final updated = await database.gameDao.updateGameRuleset(
          gameId: 'non-existent-id',
          ruleset: Ruleset.lowestScore,
        );
        expect(updated, isFalse);

        final allGames = await database.gameDao.getAllGames();
        expect(allGames, isEmpty);
      });

      test('updateGameDescription() works correctly', () async {
        await database.gameDao.addGame(game: testGame1);
        const newDescription = 'New description';

        final updated = await database.gameDao.updateGameDescription(
          gameId: testGame1.id,
          description: newDescription,
        );
        expect(updated, isTrue);

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
            description: 'New description',
          );
          expect(updated, isFalse);

          final allGames = await database.gameDao.getAllGames();
          expect(allGames, isEmpty);
        },
      );

      test('updateGameColor() works correctly', () async {
        await database.gameDao.addGame(game: testGame1);

        await database.gameDao.updateGameColor(
          gameId: testGame1.id,
          color: AppColor.green,
        );

        final updatedGame = await database.gameDao.getGameById(
          gameId: testGame1.id,
        );
        expect(updatedGame.color, AppColor.green);
      });

      test('updateGameColor() does nothing for non-existent game', () async {
        final updated = await database.gameDao.updateGameColor(
          gameId: 'non-existent-id',
          color: AppColor.green,
        );
        expect(updated, isFalse);

        final allGames = await database.gameDao.getAllGames();
        expect(allGames, isEmpty);
      });

      test('Multiple updates to the same game work correctly', () async {
        await database.gameDao.addGame(game: testGame1);

        const newName = 'New name';
        await database.gameDao.updateGameName(
          gameId: testGame1.id,
          name: newName,
        );

        const newGameColor = AppColor.teal;
        await database.gameDao.updateGameColor(
          gameId: testGame1.id,
          color: newGameColor,
        );

        const newDescription = 'New description';
        await database.gameDao.updateGameDescription(
          gameId: testGame1.id,
          description: newDescription,
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
      });
    });
    group('DELETE', () {
      test('deleteGame() works correctly', () async {
        await database.gameDao.addGame(game: testGame1);

        final deleted = await database.gameDao.deleteGame(gameId: testGame1.id);
        expect(deleted, isTrue);

        final allGames = await database.gameDao.getAllGames();
        expect(allGames, isEmpty);
      });

      test('deleteGame() returns false for non-existent game', () async {
        final deleted = await database.gameDao.deleteGame(
          gameId: 'non-existent-id',
        );
        expect(deleted, isFalse);
      });

      test('deleteAllGames() removes all games', () async {
        await database.gameDao.addGamesAsList(
          games: [testGame1, testGame2, testGame3],
        );

        var count = await database.gameDao.getGameCount();
        expect(count, 3);

        final deleted = await database.gameDao.deleteAllGames();
        expect(deleted, isTrue);

        count = await database.gameDao.getGameCount();
        expect(count, 0);
      });

      test('deleteAllGames() returns false when no games exist', () async {
        final deleted = await database.gameDao.deleteAllGames();
        expect(deleted, isFalse);
      });
    });
  });
}
