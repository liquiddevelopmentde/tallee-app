import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/dto/game.dart';
import 'package:tallee/data/dto/match.dart';
import 'package:tallee/data/dto/player.dart';
import 'package:tallee/core/enums.dart';

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
      testGame = Game(name: 'Test Game', ruleset: Ruleset.singleWinner, description: 'A test game', color: '0xFF000000', icon: '');
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

    // Verifies that a score can be added and retrieved with all fields intact.
    test('Adding and fetching a score works correctly', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 10,
        change: 10,
      );

      final score = await database.scoreDao.getScoreForRound(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
      );

      expect(score, isNotNull);
      expect(score!.playerId, testPlayer1.id);
      expect(score.matchId, testMatch1.id);
      expect(score.roundNumber, 1);
      expect(score.score, 10);
      expect(score.change, 10);
    });

    // Verifies that getScoresForMatch returns all scores for a given match.
    test('Getting scores for a match works correctly', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 10,
        change: 10,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer2.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 20,
        change: 20,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 2,
        score: 25,
        change: 15,
      );

      final scores = await database.scoreDao.getScoresForMatch(
        matchId: testMatch1.id,
      );

      expect(scores.length, 3);
    });

    // Verifies that getPlayerScoresInMatch returns all scores for a player in a match, ordered by round.
    test('Getting player scores in a match works correctly', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 10,
        change: 10,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 2,
        score: 25,
        change: 15,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 3,
        score: 30,
        change: 5,
      );

      final playerScores = await database.scoreDao.getPlayerScoresInMatch(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
      );

      expect(playerScores.length, 3);
      expect(playerScores[0].roundNumber, 1);
      expect(playerScores[1].roundNumber, 2);
      expect(playerScores[2].roundNumber, 3);
      expect(playerScores[0].score, 10);
      expect(playerScores[1].score, 25);
      expect(playerScores[2].score, 30);
    });

    // Verifies that getScoreForRound returns null for a non-existent round number.
    test('Getting score for a non-existent round returns null', () async {
      final score = await database.scoreDao.getScoreForRound(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 999,
      );

      expect(score, isNull);
    });

    // Verifies that updateScore correctly updates the score and change values.
    test('Updating a score works correctly', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 10,
        change: 10,
      );

      final updated = await database.scoreDao.updateScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        newScore: 50,
        newChange: 40,
      );

      expect(updated, true);

      final score = await database.scoreDao.getScoreForRound(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
      );

      expect(score, isNotNull);
      expect(score!.score, 50);
      expect(score.change, 40);
    });

    // Verifies that updateScore returns false for a non-existent score entry.
    test('Updating a non-existent score returns false', () async {
      final updated = await database.scoreDao.updateScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 999,
        newScore: 50,
        newChange: 40,
      );

      expect(updated, false);
    });

    // Verifies that deleteScore removes the score entry and returns true.
    test('Deleting a score works correctly', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 10,
        change: 10,
      );

      final deleted = await database.scoreDao.deleteScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
      );

      expect(deleted, true);

      final score = await database.scoreDao.getScoreForRound(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
      );

      expect(score, isNull);
    });

    // Verifies that deleteScore returns false for a non-existent score entry.
    test('Deleting a non-existent score returns false', () async {
      final deleted = await database.scoreDao.deleteScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 999,
      );

      expect(deleted, false);
    });

    // Verifies that deleteScoresForMatch removes all scores for a match but keeps other match scores.
    test('Deleting scores for a match works correctly', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 10,
        change: 10,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer2.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 20,
        change: 20,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch2.id,
        roundNumber: 1,
        score: 15,
        change: 15,
      );

      final deleted = await database.scoreDao.deleteScoresForMatch(
        matchId: testMatch1.id,
      );

      expect(deleted, true);

      final match1Scores = await database.scoreDao.getScoresForMatch(
        matchId: testMatch1.id,
      );
      expect(match1Scores.length, 0);

      final match2Scores = await database.scoreDao.getScoresForMatch(
        matchId: testMatch2.id,
      );
      expect(match2Scores.length, 1);
    });

    // Verifies that deleteScoresForPlayer removes all scores for a player across all matches.
    test('Deleting scores for a player works correctly', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 10,
        change: 10,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch2.id,
        roundNumber: 1,
        score: 15,
        change: 15,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer2.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 20,
        change: 20,
      );

      final deleted = await database.scoreDao.deleteScoresForPlayer(
        playerId: testPlayer1.id,
      );

      expect(deleted, true);

      final player1Scores = await database.scoreDao.getPlayerScoresInMatch(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
      );
      expect(player1Scores.length, 0);

      final player2Scores = await database.scoreDao.getPlayerScoresInMatch(
        playerId: testPlayer2.id,
        matchId: testMatch1.id,
      );
      expect(player2Scores.length, 1);
    });

    // Verifies that getLatestRoundNumber returns the highest round number for a match.
    test('Getting latest round number works correctly', () async {
      var latestRound = await database.scoreDao.getLatestRoundNumber(
        matchId: testMatch1.id,
      );
      expect(latestRound, 0);

      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 10,
        change: 10,
      );

      latestRound = await database.scoreDao.getLatestRoundNumber(
        matchId: testMatch1.id,
      );
      expect(latestRound, 1);

      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 5,
        score: 50,
        change: 40,
      );

      latestRound = await database.scoreDao.getLatestRoundNumber(
        matchId: testMatch1.id,
      );
      expect(latestRound, 5);
    });

    // Verifies that getTotalScoreForPlayer returns the latest score (cumulative) for a player.
    test('Getting total score for a player works correctly', () async {
      var totalScore = await database.scoreDao.getTotalScoreForPlayer(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
      );
      expect(totalScore, 0);

      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 10,
        change: 10,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 2,
        score: 25,
        change: 15,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 3,
        score: 40,
        change: 15,
      );

      totalScore = await database.scoreDao.getTotalScoreForPlayer(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
      );
      expect(totalScore, 40);
    });

    // Verifies that adding a score with the same player/match/round replaces the existing one.
    test('Adding the same score twice replaces the existing one', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 10,
        change: 10,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 99,
        change: 99,
      );

      final score = await database.scoreDao.getScoreForRound(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
      );

      expect(score, isNotNull);
      expect(score!.score, 99);
      expect(score.change, 99);
    });

    // Verifies that getScoresForMatch returns empty list for match with no scores.
    test('Getting scores for match with no scores returns empty list', () async {
      final scores = await database.scoreDao.getScoresForMatch(
        matchId: testMatch1.id,
      );

      expect(scores.isEmpty, true);
    });

    // Verifies that getPlayerScoresInMatch returns empty list when player has no scores.
    test('Getting player scores with no scores returns empty list', () async {
      final playerScores = await database.scoreDao.getPlayerScoresInMatch(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
      );

      expect(playerScores.isEmpty, true);
    });

    // Verifies that scores can have negative values.
    test('Score can have negative values', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: -10,
        change: -10,
      );

      final score = await database.scoreDao.getScoreForRound(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
      );

      expect(score, isNotNull);
      expect(score!.score, -10);
      expect(score.change, -10);
    });

    // Verifies that scores can have zero values.
    test('Score can have zero values', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 0,
        change: 0,
      );

      final score = await database.scoreDao.getScoreForRound(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
      );

      expect(score, isNotNull);
      expect(score!.score, 0);
      expect(score.change, 0);
    });

    // Verifies that very large round numbers are supported.
    test('Score supports very large round numbers', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 999999,
        score: 100,
        change: 100,
      );

      final score = await database.scoreDao.getScoreForRound(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 999999,
      );

      expect(score, isNotNull);
      expect(score!.roundNumber, 999999);
    });

    // Verifies that getLatestRoundNumber returns max correctly for non-consecutive rounds.
    test('Getting latest round number with non-consecutive rounds', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 10,
        change: 10,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 5,
        score: 50,
        change: 40,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 3,
        score: 30,
        change: 20,
      );

      final latestRound = await database.scoreDao.getLatestRoundNumber(
        matchId: testMatch1.id,
      );

      expect(latestRound, 5);
    });

    // Verifies that deleteScoresForMatch returns false when no scores exist.
    test('Deleting scores for empty match returns false', () async {
      final deleted = await database.scoreDao.deleteScoresForMatch(
        matchId: testMatch1.id,
      );

      expect(deleted, false);
    });

    // Verifies that deleteScoresForPlayer returns false when player has no scores.
    test('Deleting scores for player with no scores returns false', () async {
      final deleted = await database.scoreDao.deleteScoresForPlayer(
        playerId: testPlayer1.id,
      );

      expect(deleted, false);
    });

    // Verifies that multiple players in same match can have independent score updates.
    test('Multiple players in same match have independent scores', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 10,
        change: 10,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer2.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 20,
        change: 20,
      );

      await database.scoreDao.updateScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        newScore: 100,
        newChange: 90,
      );

      final player1Score = await database.scoreDao.getScoreForRound(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
      );
      final player2Score = await database.scoreDao.getScoreForRound(
        playerId: testPlayer2.id,
        matchId: testMatch1.id,
        roundNumber: 1,
      );

      expect(player1Score!.score, 100);
      expect(player2Score!.score, 20);
    });

    // Verifies that scores are isolated across different matches.
    test('Scores are isolated across different matches', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 10,
        change: 10,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch2.id,
        roundNumber: 1,
        score: 50,
        change: 50,
      );

      final match1Scores = await database.scoreDao.getPlayerScoresInMatch(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
      );
      final match2Scores = await database.scoreDao.getPlayerScoresInMatch(
        playerId: testPlayer1.id,
        matchId: testMatch2.id,
      );

      expect(match1Scores.length, 1);
      expect(match2Scores.length, 1);
      expect(match1Scores[0].score, 10);
      expect(match2Scores[0].score, 50);
    });

    // Verifies that getTotalScoreForPlayer returns latest score across multiple rounds.
    test('Total score for player returns latest cumulative score', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 2,
        score: 25,
        change: 25,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 10,
        change: 10,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 3,
        score: 50,
        change: 25,
      );

      final totalScore = await database.scoreDao.getTotalScoreForPlayer(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
      );

      // Should return the highest round's score
      expect(totalScore, 50);
    });

    // Verifies that updating one player's score doesn't affect another player's score in same round.
    test('Updating one player score does not affect other players in same round', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 10,
        change: 10,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer2.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 20,
        change: 20,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer3.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 30,
        change: 30,
      );

      await database.scoreDao.updateScore(
        playerId: testPlayer2.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        newScore: 99,
        newChange: 89,
      );

      final scores = await database.scoreDao.getScoresForMatch(
        matchId: testMatch1.id,
      );

      expect(scores.length, 3);
      expect(scores.where((s) => s.playerId == testPlayer1.id).first.score, 10);
      expect(scores.where((s) => s.playerId == testPlayer2.id).first.score, 99);
      expect(scores.where((s) => s.playerId == testPlayer3.id).first.score, 30);
    });

    // Verifies that deleting a player's scores only affects that specific player.
    test('Deleting player scores only affects target player', () async {
      await database.scoreDao.addScore(
        playerId: testPlayer1.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 10,
        change: 10,
      );
      await database.scoreDao.addScore(
        playerId: testPlayer2.id,
        matchId: testMatch1.id,
        roundNumber: 1,
        score: 20,
        change: 20,
      );

      await database.scoreDao.deleteScoresForPlayer(
        playerId: testPlayer1.id,
      );

      final match1Scores = await database.scoreDao.getScoresForMatch(
        matchId: testMatch1.id,
      );

      expect(match1Scores.length, 1);
      expect(match1Scores[0].playerId, testPlayer2.id);
    });
  });
}
