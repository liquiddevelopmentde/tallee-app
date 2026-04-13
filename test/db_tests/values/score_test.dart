import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/game.dart';
import 'package:tallee/data/models/match.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/score_entry.dart';

void main() {
  late AppDatabase database;
  late Player testPlayer1;
  late Player testPlayer2;
  late Player testPlayer3;
  late Game testGame;
  late Match testMatch1;
  late Match testMatch2;
  final fixedDate = DateTime(2025, 11, 19, 00, 11, 23);
  final fakeClock = Clock(() => fixedDate);

  setUp(() async {
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
      testGame = Game(
        name: 'Test Game',
        ruleset: Ruleset.singleWinner,
        description: 'A test game',
        color: GameColor.blue,
        icon: '',
      );
      testMatch1 = Match(
        name: 'Test Match 1',
        game: testGame,
        players: [testPlayer1, testPlayer2],
        notes: '',
      );
      testMatch2 = Match(
        name: 'Test Match 2',
        game: testGame,
        players: [testPlayer2, testPlayer3],
        notes: '',
      );
    });

    await database.playerDao.addPlayersAsList(
      players: [testPlayer1, testPlayer2, testPlayer3],
    );
    await database.gameDao.addGame(game: testGame);
    await database.matchDao.addMatch(match: testMatch1);
    await database.matchDao.addMatch(match: testMatch2);
  });

  tearDown(() async {
    await database.close();
  });

  group('Score Tests', () {
    group('Adding and Fetching scores', () {
      test('Single Score', () async {
        ScoreEntry entry = ScoreEntry(roundNumber: 1, score: 10, change: 10);
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: entry,
        );

        final score = await database.scoreEntryDao.getScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          roundNumber: 1,
        );

        expect(score, isNotNull);
        expect(score!.roundNumber, 1);
        expect(score.score, 10);
        expect(score.change, 10);
      });

      test('Multiple Scores', () async {
        final entryList = [
          ScoreEntry(roundNumber: 1, score: 5, change: 5),
          ScoreEntry(roundNumber: 2, score: 12, change: 7),
          ScoreEntry(roundNumber: 3, score: 18, change: 6),
        ];

        await database.scoreEntryDao.addScoresAsList(
          entrys: entryList,
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
        );

        final scores = await database.scoreEntryDao.getAllPlayerScoresInMatch(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
        );

        expect(scores, isNotNull);

        // Scores should be returned in order of round number
        for (int i = 0; i < entryList.length; i++) {
          expect(scores[i].roundNumber, entryList[i].roundNumber);
          expect(scores[i].score, entryList[i].score);
          expect(scores[i].change, entryList[i].change);
        }
      });
    });

    group('Undesirable values', () {
      test('Score & Round can have negative values', () async {
        ScoreEntry entry = ScoreEntry(roundNumber: -2, score: -10, change: -10);
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: entry,
        );

        final score = await database.scoreEntryDao.getScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          roundNumber: -2,
        );

        expect(score, isNotNull);
        expect(score!.roundNumber, -2);
        expect(score.score, -10);
        expect(score.change, -10);
      });

      test('Score & Round can have zero values', () async {
        ScoreEntry entry = ScoreEntry(roundNumber: 0, score: 0, change: 0);
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: entry,
        );

        final score = await database.scoreEntryDao.getScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          roundNumber: 0,
        );

        expect(score, isNotNull);
        expect(score!.score, 0);
        expect(score.change, 0);
      });

      test('Getting score for a non-existent entities returns null', () async {
        var score = await database.scoreEntryDao.getScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          roundNumber: -1,
        );

        expect(score, isNull);

        score = await database.scoreEntryDao.getScore(
          playerId: 'non-existin-player',
          matchId: testMatch1.id,
        );

        expect(score, isNull);

        score = await database.scoreEntryDao.getScore(
          playerId: testPlayer1.id,
          matchId: 'non-existing-match',
        );

        expect(score, isNull);
      });

      test('Getting score for a non-match player returns null', () async {
        ScoreEntry entry = ScoreEntry(roundNumber: 1, score: 10, change: 10);
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: entry,
        );

        await database.scoreEntryDao.addScore(
          playerId: testPlayer3.id,
          matchId: testMatch2.id,
          entry: entry,
        );

        var score = await database.scoreEntryDao.getScore(
          playerId: testPlayer1.id,
          matchId: testMatch2.id,
          roundNumber: 1,
        );

        expect(score, isNull);
      });
    });

    group('Scores in matches', () {
      test('getAllMatchScores()', () async {
        ScoreEntry entry1 = ScoreEntry(roundNumber: 1, score: 10, change: 10);
        ScoreEntry entry2 = ScoreEntry(roundNumber: 1, score: 20, change: 20);
        ScoreEntry entry3 = ScoreEntry(roundNumber: 2, score: 25, change: 15);
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: entry1,
        );
        await database.scoreEntryDao.addScore(
          playerId: testPlayer2.id,
          matchId: testMatch1.id,
          entry: entry2,
        );
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: entry3,
        );

        final scores = await database.scoreEntryDao.getAllMatchScores(
          matchId: testMatch1.id,
        );

        expect(scores.length, 2);
        expect(scores[testPlayer1.id]!.length, 2);
        expect(scores[testPlayer2.id]!.length, 1);
      });

      test('getAllMatchScores() with no scores saved', () async {
        final scores = await database.scoreEntryDao.getAllMatchScores(
          matchId: testMatch1.id,
        );

        expect(scores.isEmpty, true);
      });

      test('getAllPlayerScoresInMatch()', () async {
        ScoreEntry entry1 = ScoreEntry(roundNumber: 1, score: 10, change: 10);
        ScoreEntry entry2 = ScoreEntry(roundNumber: 2, score: 25, change: 15);
        ScoreEntry entry3 = ScoreEntry(roundNumber: 1, score: 30, change: 30);
        await database.scoreEntryDao.addScoresAsList(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entrys: [entry1, entry2],
        );
        await database.scoreEntryDao.addScore(
          playerId: testPlayer2.id,
          matchId: testMatch1.id,
          entry: entry3,
        );

        final playerScores = await database.scoreEntryDao
            .getAllPlayerScoresInMatch(
              playerId: testPlayer1.id,
              matchId: testMatch1.id,
            );

        expect(playerScores.length, 2);
        expect(playerScores[0].roundNumber, 1);
        expect(playerScores[1].roundNumber, 2);
        expect(playerScores[0].score, 10);
        expect(playerScores[1].score, 25);
        expect(playerScores[0].change, 10);
        expect(playerScores[1].change, 15);
      });

      test('getAllPlayerScoresInMatch() with no scores saved', () async {
        final playerScores = await database.scoreEntryDao
            .getAllPlayerScoresInMatch(
              playerId: testPlayer1.id,
              matchId: testMatch1.id,
            );

        expect(playerScores.isEmpty, true);
      });

      test('Scores are isolated across different matches', () async {
        ScoreEntry entry1 = ScoreEntry(roundNumber: 1, score: 10, change: 10);
        ScoreEntry entry2 = ScoreEntry(roundNumber: 1, score: 50, change: 50);
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: entry1,
        );
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch2.id,
          entry: entry2,
        );

        final match1Scores = await database.scoreEntryDao
            .getAllPlayerScoresInMatch(
              playerId: testPlayer1.id,
              matchId: testMatch1.id,
            );

        expect(match1Scores.length, 1);
        expect(match1Scores[0].score, 10);
        expect(match1Scores[0].change, 10);

        final match2Scores = await database.scoreEntryDao
            .getAllPlayerScoresInMatch(
              playerId: testPlayer1.id,
              matchId: testMatch2.id,
            );

        expect(match2Scores.length, 1);
        expect(match2Scores[0].score, 50);
        expect(match2Scores[0].change, 50);
      });
    });

    group('Updating scores', () {
      test('updateScore()', () async {
        ScoreEntry entry1 = ScoreEntry(roundNumber: 1, score: 10, change: 10);
        ScoreEntry entry2 = ScoreEntry(roundNumber: 2, score: 15, change: 5);
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: entry1,
        );

        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: entry2,
        );

        final updated = await database.scoreEntryDao.updateScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          newEntry: ScoreEntry(roundNumber: 2, score: 50, change: 40),
        );

        expect(updated, true);

        final score = await database.scoreEntryDao.getScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          roundNumber: 2,
        );

        expect(score, isNotNull);
        expect(score!.score, 50);
        expect(score.change, 40);
      });

      test('Updating a non-existent score returns false', () async {
        final updated = await database.scoreEntryDao.updateScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          newEntry: ScoreEntry(roundNumber: 1, score: 20, change: 20),
        );

        expect(updated, false);
      });
    });

    group('Deleting scores', () {
      test('deleteScore() ', () async {
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 1, score: 10, change: 10),
        );

        final deleted = await database.scoreEntryDao.deleteScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          roundNumber: 1,
        );

        expect(deleted, true);

        final score = await database.scoreEntryDao.getScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          roundNumber: 1,
        );

        expect(score, isNull);
      });

      test('Deleting a non-existent score returns false', () async {
        final deleted = await database.scoreEntryDao.deleteScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          roundNumber: 1,
        );

        expect(deleted, false);
      });

      test('deleteAllScoresForMatch() works correctly', () async {
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 1, score: 10, change: 10),
        );
        await database.scoreEntryDao.addScore(
          playerId: testPlayer2.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 1, score: 20, change: 20),
        );
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch2.id,
          entry: ScoreEntry(roundNumber: 1, score: 15, change: 15),
        );

        final deleted = await database.scoreEntryDao.deleteAllScoresForMatch(
          matchId: testMatch1.id,
        );

        expect(deleted, true);

        final match1Scores = await database.scoreEntryDao.getAllMatchScores(
          matchId: testMatch1.id,
        );
        expect(match1Scores.length, 0);

        final match2Scores = await database.scoreEntryDao.getAllMatchScores(
          matchId: testMatch2.id,
        );
        expect(match2Scores.length, 1);
      });

      test('deleteAllScoresForPlayerInMatch() works correctly', () async {
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 1, score: 10, change: 10),
        );

        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 2, score: 15, change: 5),
        );

        await database.scoreEntryDao.addScore(
          playerId: testPlayer2.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 1, score: 6, change: 6),
        );

        final deleted = await database.scoreEntryDao
            .deleteAllScoresForPlayerInMatch(
              playerId: testPlayer1.id,
              matchId: testMatch1.id,
            );

        expect(deleted, true);

        final player1Scores = await database.scoreEntryDao
            .getAllPlayerScoresInMatch(
              playerId: testPlayer1.id,
              matchId: testMatch1.id,
            );
        expect(player1Scores.length, 0);

        final player2Scores = await database.scoreEntryDao
            .getAllPlayerScoresInMatch(
              playerId: testPlayer2.id,
              matchId: testMatch1.id,
            );
        expect(player2Scores.length, 1);
      });
    });

    group('Score Aggregations & Edge Cases', () {
      test('getLatestRoundNumber()', () async {
        var latestRound = await database.scoreEntryDao.getLatestRoundNumber(
          matchId: testMatch1.id,
        );
        expect(latestRound, isNull);

        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 1, score: 10, change: 10),
        );

        latestRound = await database.scoreEntryDao.getLatestRoundNumber(
          matchId: testMatch1.id,
        );
        expect(latestRound, 1);

        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 5, score: 50, change: 40),
        );

        latestRound = await database.scoreEntryDao.getLatestRoundNumber(
          matchId: testMatch1.id,
        );
        expect(latestRound, 5);
      });

      test('getLatestRoundNumber() with non-consecutive rounds', () async {
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 1, score: 10, change: 10),
        );
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 5, score: 50, change: 40),
        );
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 3, score: 30, change: 20),
        );

        final latestRound = await database.scoreEntryDao.getLatestRoundNumber(
          matchId: testMatch1.id,
        );

        expect(latestRound, 5);
      });

      test('getTotalScoreForPlayer()', () async {
        var totalScore = await database.scoreEntryDao.getTotalScoreForPlayer(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
        );
        expect(totalScore, 0);

        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 1, score: 10, change: 10),
        );
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 2, score: 25, change: 15),
        );
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 3, score: 40, change: 15),
        );

        totalScore = await database.scoreEntryDao.getTotalScoreForPlayer(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
        );
        expect(totalScore, 40);
      });

      test('getTotalScoreForPlayer() ignores round score', () async {
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 2, score: 25, change: 25),
        );
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 1, score: 25, change: 10),
        );
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 3, score: 25, change: 25),
        );

        final totalScore = await database.scoreEntryDao.getTotalScoreForPlayer(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
        );

        // Should return the sum of all changes
        expect(totalScore, 60);
      });

      test('Adding the same score twice replaces the existing one', () async {
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 1, score: 10, change: 10),
        );
        await database.scoreEntryDao.addScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          entry: ScoreEntry(roundNumber: 1, score: 20, change: 20),
        );

        final score = await database.scoreEntryDao.getScore(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
          roundNumber: 1,
        );

        expect(score, isNotNull);
        expect(score!.score, 20);
        expect(score.change, 20);
      });
    });

    group('Handling Winner', () {
      test('hasWinner() works correctly', () async {
        var hasWinner = await database.scoreEntryDao.hasWinner(
          matchId: testMatch1.id,
        );
        expect(hasWinner, false);

        await database.scoreEntryDao.setWinner(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
        );

        hasWinner = await database.scoreEntryDao.hasWinner(
          matchId: testMatch1.id,
        );
        expect(hasWinner, true);
      });

      test('getWinnersForMatch() returns correct winner', () async {
        var winner = await database.scoreEntryDao.getWinner(
          matchId: testMatch1.id,
        );
        expect(winner, isNull);

        await database.scoreEntryDao.setWinner(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
        );

        winner = await database.scoreEntryDao.getWinner(matchId: testMatch1.id);

        expect(winner, isNotNull);
        expect(winner!.id, testPlayer1.id);
      });

      test('removeWinner() works correctly', () async {
        var removed = await database.scoreEntryDao.removeWinner(
          matchId: testMatch1.id,
        );
        expect(removed, false);

        await database.scoreEntryDao.setWinner(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
        );

        removed = await database.scoreEntryDao.removeWinner(
          matchId: testMatch1.id,
        );
        expect(removed, true);

        var winner = await database.scoreEntryDao.getWinner(
          matchId: testMatch1.id,
        );
        expect(winner, isNull);
      });
    });

    group('Handling Looser', () {
      test('hasLooser() works correctly', () async {
        var hasLooser = await database.scoreEntryDao.hasLooser(
          matchId: testMatch1.id,
        );
        expect(hasLooser, false);

        await database.scoreEntryDao.setLooser(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
        );

        hasLooser = await database.scoreEntryDao.hasLooser(
          matchId: testMatch1.id,
        );
        expect(hasLooser, true);
      });

      test('getLooser() returns correct winner', () async {
        var looser = await database.scoreEntryDao.getLooser(
          matchId: testMatch1.id,
        );
        expect(looser, isNull);

        await database.scoreEntryDao.setLooser(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
        );

        looser = await database.scoreEntryDao.getLooser(matchId: testMatch1.id);

        expect(looser, isNotNull);
        expect(looser!.id, testPlayer1.id);
      });

      test('removeLooser() works correctly', () async {
        var removed = await database.scoreEntryDao.removeLooser(
          matchId: testMatch1.id,
        );
        expect(removed, false);

        await database.scoreEntryDao.setLooser(
          playerId: testPlayer1.id,
          matchId: testMatch1.id,
        );

        removed = await database.scoreEntryDao.removeLooser(
          matchId: testMatch1.id,
        );
        expect(removed, true);

        var looser = await database.scoreEntryDao.getLooser(
          matchId: testMatch1.id,
        );
        expect(looser, isNull);
      });
    });
  });
}
