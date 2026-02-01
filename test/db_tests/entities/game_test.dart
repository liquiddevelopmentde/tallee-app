import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/dto/game.dart';

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

    // Verifies that getAllGames returns an empty list when the database has no games.
    test('getAllGames returns empty list when no games exist', () async {
      final allGames = await database.gameDao.getAllGames();
      expect(allGames, isEmpty);
    });

    // Verifies that a single game can be added and retrieved with all fields intact.
    test('Adding and fetching a single game works correctly', () async {
      await database.gameDao.addGame(game: testGame1);

      final allGames = await database.gameDao.getAllGames();
      expect(allGames.length, 1);
      expect(allGames.first.id, testGame1.id);
      expect(allGames.first.name, testGame1.name);
      expect(allGames.first.ruleset, testGame1.ruleset);
      expect(allGames.first.description, testGame1.description);
      expect(allGames.first.color, testGame1.color);
      expect(allGames.first.icon, testGame1.icon);
      expect(allGames.first.createdAt, testGame1.createdAt);
    });

    // Verifies that multiple games can be added and retrieved correctly.
    test('Adding and fetching multiple games works correctly', () async {
      await database.gameDao.addGame(game: testGame1);
      await database.gameDao.addGame(game: testGame2);
      await database.gameDao.addGame(game: testGame3);

      final allGames = await database.gameDao.getAllGames();
      expect(allGames.length, 3);

      final names = allGames.map((g) => g.name).toList();
      expect(names, containsAll(['Chess', 'Poker', 'Monopoly']));
    });

    // Verifies that getGameById returns the correct game with all properties.
    test('getGameById returns correct game', () async {
      await database.gameDao.addGame(game: testGame1);
      await database.gameDao.addGame(game: testGame2);

      final game = await database.gameDao.getGameById(gameId: testGame2.id);
      expect(game.id, testGame2.id);
      expect(game.name, testGame2.name);
      expect(game.ruleset, testGame2.ruleset);
      expect(game.description, testGame2.description);
      expect(game.color, testGame2.color);
      expect(game.icon, testGame2.icon);
    });

    // Verifies that getGameById throws a StateError when the game doesn't exist.
    test('getGameById throws exception for non-existent game', () async {
      expect(
            () => database.gameDao.getGameById(gameId: 'non-existent-id'),
        throwsA(isA<StateError>()),
      );
    });

    // Verifies that addGame returns true when a game is successfully added.
    test('addGame returns true when game is added successfully', () async {
      final result = await database.gameDao.addGame(game: testGame1);
      expect(result, true);

      final allGames = await database.gameDao.getAllGames();
      expect(allGames.length, 1);
    });

    // Verifies that addGame returns false when trying to add a duplicate game.
    test('addGame returns false when game already exists', () async {
      final firstAdd = await database.gameDao.addGame(game: testGame1);
      expect(firstAdd, true);

      final secondAdd = await database.gameDao.addGame(game: testGame1);
      expect(secondAdd, false);

      final allGames = await database.gameDao.getAllGames();
      expect(allGames.length, 1);
    });

    // Verifies that a game with null optional fields can be added and retrieved.
    test('addGame handles game with null optional fields', () async {
      final gameWithNulls = Game(name: 'Simple Game', ruleset: Ruleset.lowestScore, description: 'A simple game', color: GameColor.green, icon: '');
      final result = await database.gameDao.addGame(game: gameWithNulls);
      expect(result, true);

      final fetchedGame = await database.gameDao.getGameById(
        gameId: gameWithNulls.id,
      );
      expect(fetchedGame.name, 'Simple Game');
      expect(fetchedGame.description, 'A simple game');
      expect(fetchedGame.color, GameColor.green);
      expect(fetchedGame.icon, isNull);
    });

    // Verifies that multiple games can be added at once using addGamesAsList.
    test('addGamesAsList adds multiple games correctly', () async {
      final result = await database.gameDao.addGamesAsList(
        games: [testGame1, testGame2, testGame3],
      );
      expect(result, true);

      final allGames = await database.gameDao.getAllGames();
      expect(allGames.length, 3);
    });

    // Verifies that addGamesAsList returns false when given an empty list.
    test('addGamesAsList returns false for empty list', () async {
      final result = await database.gameDao.addGamesAsList(games: []);
      expect(result, false);

      final allGames = await database.gameDao.getAllGames();
      expect(allGames.length, 0);
    });

    // Verifies that addGamesAsList ignores duplicate games when adding.
    test('addGamesAsList ignores duplicate games', () async {
      await database.gameDao.addGame(game: testGame1);

      final result = await database.gameDao.addGamesAsList(
        games: [testGame1, testGame2],
      );
      expect(result, true);

      final allGames = await database.gameDao.getAllGames();
      expect(allGames.length, 2);
    });

    // Verifies that deleteGame returns true and removes the game from database.
    test('deleteGame returns true when game is deleted', () async {
      await database.gameDao.addGame(game: testGame1);

      final result = await database.gameDao.deleteGame(gameId: testGame1.id);
      expect(result, true);

      final allGames = await database.gameDao.getAllGames();
      expect(allGames, isEmpty);
    });

    // Verifies that deleteGame returns false for a non-existent game ID.
    test('deleteGame returns false for non-existent game', () async {
      final result = await database.gameDao.deleteGame(
        gameId: 'non-existent-id',
      );
      expect(result, false);
    });

    // Verifies that deleteGame only removes the specified game, leaving others intact.
    test('deleteGame only deletes the specified game', () async {
      await database.gameDao.addGamesAsList(
        games: [testGame1, testGame2, testGame3],
      );

      await database.gameDao.deleteGame(gameId: testGame2.id);

      final allGames = await database.gameDao.getAllGames();
      expect(allGames.length, 2);
      expect(allGames.any((g) => g.id == testGame2.id), false);
      expect(allGames.any((g) => g.id == testGame1.id), true);
      expect(allGames.any((g) => g.id == testGame3.id), true);
    });

    // Verifies that gameExists returns true when the game exists in database.
    test('gameExists returns true for existing game', () async {
      await database.gameDao.addGame(game: testGame1);

      final exists = await database.gameDao.gameExists(gameId: testGame1.id);
      expect(exists, true);
    });

    // Verifies that gameExists returns false for a non-existent game ID.
    test('gameExists returns false for non-existent game', () async {
      final exists = await database.gameDao.gameExists(
        gameId: 'non-existent-id',
      );
      expect(exists, false);
    });

    // Verifies that gameExists returns false after a game has been deleted.
    test('gameExists returns false after game is deleted', () async {
      await database.gameDao.addGame(game: testGame1);
      await database.gameDao.deleteGame(gameId: testGame1.id);

      final exists = await database.gameDao.gameExists(gameId: testGame1.id);
      expect(exists, false);
    });

    // Verifies that updateGameName correctly updates only the name field.
    test('updateGameName updates the name correctly', () async {
      await database.gameDao.addGame(game: testGame1);

      await database.gameDao.updateGameName(
        gameId: testGame1.id,
        newName: 'Updated Chess',
      );

      final updatedGame = await database.gameDao.getGameById(
        gameId: testGame1.id,
      );
      expect(updatedGame.name, 'Updated Chess');
      expect(updatedGame.ruleset, testGame1.ruleset);
    });

    // Verifies that updateGameName does nothing when game doesn't exist.
    test('updateGameName does nothing for non-existent game', () async {
      await database.gameDao.updateGameName(
        gameId: 'non-existent-id',
        newName: 'New Name',
      );

      final allGames = await database.gameDao.getAllGames();
      expect(allGames, isEmpty);
    });

    // Verifies that updateGameRuleset correctly updates only the ruleset field.
    test('updateGameRuleset updates the ruleset correctly', () async {
      await database.gameDao.addGame(game: testGame1);

      await database.gameDao.updateGameRuleset(
        gameId: testGame1.id,
        newRuleset: Ruleset.highestScore,
      );

      final updatedGame = await database.gameDao.getGameById(
        gameId: testGame1.id,
      );
      expect(updatedGame.ruleset, Ruleset.highestScore);
      expect(updatedGame.name, testGame1.name);
    });

    // Verifies that updateGameRuleset does nothing when game doesn't exist.
    test('updateGameRuleset does nothing for non-existent game', () async {
      await database.gameDao.updateGameRuleset(
        gameId: 'non-existent-id',
        newRuleset: Ruleset.lowestScore,
      );

      final allGames = await database.gameDao.getAllGames();
      expect(allGames, isEmpty);
    });

    // Verifies that updateGameDescription correctly updates the description.
    test('updateGameDescription updates the description correctly', () async {
      await database.gameDao.addGame(game: testGame1);

      await database.gameDao.updateGameDescription(
        gameId: testGame1.id,
        newDescription: 'An updated description',
      );

      final updatedGame = await database.gameDao.getGameById(
        gameId: testGame1.id,
      );
      expect(updatedGame.description, 'An updated description');
    });

    // Verifies that updateGameDescription can set the description to an empty string.
    test('updateGameDescription can set description to empty string', () async {
      await database.gameDao.addGame(game: testGame1);

      await database.gameDao.updateGameDescription(
        gameId: testGame1.id,
        newDescription: '',
      );

      final updatedGame = await database.gameDao.getGameById(
        gameId: testGame1.id,
      );
      expect(updatedGame.description, '');
    });

    // Verifies that updateGameDescription does nothing when game doesn't exist.
    test('updateGameDescription does nothing for non-existent game', () async {
      await database.gameDao.updateGameDescription(
        gameId: 'non-existent-id',
        newDescription: 'New Description',
      );

      final allGames = await database.gameDao.getAllGames();
      expect(allGames, isEmpty);
    });

    // Verifies that updateGameColor correctly updates the color value.
    test('updateGameColor updates the color correctly', () async {
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

    // Verifies that updateGameColor does nothing when game doesn't exist.
    test('updateGameColor does nothing for non-existent game', () async {
      await database.gameDao.updateGameColor(
        gameId: 'non-existent-id',
        newColor: GameColor.green,
      );

      final allGames = await database.gameDao.getAllGames();
      expect(allGames, isEmpty);
    });

    // Verifies that updateGameIcon correctly updates the icon value.
    test('updateGameIcon updates the icon correctly', () async {
      await database.gameDao.addGame(game: testGame1);

      await database.gameDao.updateGameIcon(
        gameId: testGame1.id,
        newIcon: 'new_chess_icon',
      );

      final updatedGame = await database.gameDao.getGameById(
        gameId: testGame1.id,
      );
      expect(updatedGame.icon, 'new_chess_icon');
    });

    // Verifies that updateGameIcon can update the icon.
    test('updateGameIcon updates icon correctly', () async {
      await database.gameDao.addGame(game: testGame1);

      await database.gameDao.updateGameIcon(
        gameId: testGame1.id,
        newIcon: 'new_icon',
      );

      final updatedGame = await database.gameDao.getGameById(
        gameId: testGame1.id,
      );
      expect(updatedGame.icon, 'new_icon');
    });

    // Verifies that updateGameIcon does nothing when game doesn't exist.
    test('updateGameIcon does nothing for non-existent game', () async {
      await database.gameDao.updateGameIcon(
        gameId: 'non-existent-id',
        newIcon: 'some_icon',
      );

      final allGames = await database.gameDao.getAllGames();
      expect(allGames, isEmpty);
    });

    // Verifies that getGameCount returns 0 when no games exist.
    test('getGameCount returns 0 when no games exist', () async {
      final count = await database.gameDao.getGameCount();
      expect(count, 0);
    });

    // Verifies that getGameCount returns the correct count after adding games.
    test('getGameCount returns correct count after adding games', () async {
      await database.gameDao.addGamesAsList(
        games: [testGame1, testGame2, testGame3],
      );

      final count = await database.gameDao.getGameCount();
      expect(count, 3);
    });

    // Verifies that getGameCount updates correctly after deleting a game.
    test('getGameCount updates correctly after deletion', () async {
      await database.gameDao.addGamesAsList(
        games: [testGame1, testGame2],
      );

      final countBefore = await database.gameDao.getGameCount();
      expect(countBefore, 2);

      await database.gameDao.deleteGame(gameId: testGame1.id);

      final countAfter = await database.gameDao.getGameCount();
      expect(countAfter, 1);
    });

    // Verifies that deleteAllGames removes all games from the database.
    test('deleteAllGames removes all games', () async {
      await database.gameDao.addGamesAsList(
        games: [testGame1, testGame2, testGame3],
      );

      final countBefore = await database.gameDao.getGameCount();
      expect(countBefore, 3);

      final result = await database.gameDao.deleteAllGames();
      expect(result, true);

      final countAfter = await database.gameDao.getGameCount();
      expect(countAfter, 0);
    });

    // Verifies that deleteAllGames returns false when no games exist.
    test('deleteAllGames returns false when no games exist', () async {
      final result = await database.gameDao.deleteAllGames();
      expect(result, false);
    });

    // Verifies that games with special characters (quotes, emojis) are stored correctly.
    test('Game with special characters in name is stored correctly', () async {
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
    });

    // Verifies that games with empty string fields are stored and retrieved correctly.
    test('Game with empty string fields is stored correctly', () async {
      final emptyGame = Game(
        name: '',
        ruleset: Ruleset.singleWinner,
        description: '',
        icon: '',
        color: GameColor.red,
      );
      await database.gameDao.addGame(game: emptyGame);

      final fetchedGame = await database.gameDao.getGameById(
        gameId: emptyGame.id,
      );
      expect(fetchedGame.name, '');
      expect(fetchedGame.ruleset, Ruleset.singleWinner);
      expect(fetchedGame.description, '');
      expect(fetchedGame.icon, '');
    });

    // Verifies that games with very long strings (10000 chars) are handled correctly.
    test('Game with very long strings is stored correctly', () async {
      final longString = 'A' * 10000;
      final longGame = Game(
        name: longString,
        description: longString,
        ruleset: Ruleset.multipleWinners,
        color: GameColor.yellow,
        icon: '',
      );
      await database.gameDao.addGame(game: longGame);

      final fetchedGame = await database.gameDao.getGameById(
        gameId: longGame.id,
      );
      expect(fetchedGame.name.length, 10000);
      expect(fetchedGame.description.length, 10000);
      expect(fetchedGame.ruleset, Ruleset.multipleWinners);
    });

    // Verifies that multiple sequential updates to the same game work correctly.
    test('Multiple updates to the same game work correctly', () async {
      await database.gameDao.addGame(game: testGame1);

      await database.gameDao.updateGameName(
        gameId: testGame1.id,
        newName: 'Updated Name',
      );
      await database.gameDao.updateGameColor(
        gameId: testGame1.id,
        newColor: GameColor.teal,
      );
      await database.gameDao.updateGameDescription(
        gameId: testGame1.id,
        newDescription: 'Updated Description',
      );

      final updatedGame = await database.gameDao.getGameById(
        gameId: testGame1.id,
      );
      expect(updatedGame.name, 'Updated Name');
      expect(updatedGame.color, GameColor.teal);
      expect(updatedGame.description, 'Updated Description');
      expect(updatedGame.ruleset, testGame1.ruleset);
      expect(updatedGame.icon, testGame1.icon);
    });
  });
}
