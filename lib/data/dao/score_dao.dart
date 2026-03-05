import 'package:drift/drift.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/score_table.dart';

part 'score_dao.g.dart';

/// A data class representing a score entry.
class ScoreEntry {
  final String playerId;
  final String matchId;
  final int roundNumber;
  final int score;
  final int change;

  ScoreEntry({
    required this.playerId,
    required this.matchId,
    required this.roundNumber,
    required this.score,
    required this.change,
  });
}

@DriftAccessor(tables: [ScoreTable])
class ScoreDao extends DatabaseAccessor<AppDatabase> with _$ScoreDaoMixin {
  ScoreDao(super.db);

  /// Adds a score entry to the database.
  Future<void> addScore({
    required String playerId,
    required String matchId,
    required int roundNumber,
    required int score,
    required int change,
  }) async {
    await into(scoreTable).insert(
      ScoreTableCompanion.insert(
        playerId: playerId,
        matchId: matchId,
        roundNumber: roundNumber,
        score: score,
        change: change,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Retrieves all scores for a specific match.
  Future<List<ScoreEntry>> getScoresForMatch({required String matchId}) async {
    final query = select(scoreTable)..where((s) => s.matchId.equals(matchId));
    final result = await query.get();
    return result
        .map(
          (row) => ScoreEntry(
            playerId: row.playerId,
            matchId: row.matchId,
            roundNumber: row.roundNumber,
            score: row.score,
            change: row.change,
          ),
        )
        .toList();
  }

  /// Retrieves all scores for a specific player in a match.
  Future<List<ScoreEntry>> getPlayerScoresInMatch({
    required String playerId,
    required String matchId,
  }) async {
    final query = select(scoreTable)
      ..where(
        (s) => s.playerId.equals(playerId) & s.matchId.equals(matchId),
      )
      ..orderBy([(s) => OrderingTerm.asc(s.roundNumber)]);
    final result = await query.get();
    return result
        .map(
          (row) => ScoreEntry(
            playerId: row.playerId,
            matchId: row.matchId,
            roundNumber: row.roundNumber,
            score: row.score,
            change: row.change,
          ),
        )
        .toList();
  }

  /// Retrieves the score for a specific round.
  Future<ScoreEntry?> getScoreForRound({
    required String playerId,
    required String matchId,
    required int roundNumber,
  }) async {
    final query = select(scoreTable)
      ..where(
        (s) =>
            s.playerId.equals(playerId) &
            s.matchId.equals(matchId) &
            s.roundNumber.equals(roundNumber),
      );
    final result = await query.getSingleOrNull();
    if (result == null) return null;
    return ScoreEntry(
      playerId: result.playerId,
      matchId: result.matchId,
      roundNumber: result.roundNumber,
      score: result.score,
      change: result.change,
    );
  }

  /// Updates a score entry.
  Future<bool> updateScore({
    required String playerId,
    required String matchId,
    required int roundNumber,
    required int newScore,
    required int newChange,
  }) async {
    final rowsAffected = await (update(scoreTable)
          ..where(
            (s) =>
                s.playerId.equals(playerId) &
                s.matchId.equals(matchId) &
                s.roundNumber.equals(roundNumber),
          ))
        .write(
          ScoreTableCompanion(
            score: Value(newScore),
            change: Value(newChange),
          ),
        );
    return rowsAffected > 0;
  }

  /// Deletes a score entry.
  Future<bool> deleteScore({
    required String playerId,
    required String matchId,
    required int roundNumber,
  }) async {
    final query = delete(scoreTable)
      ..where(
        (s) =>
            s.playerId.equals(playerId) &
            s.matchId.equals(matchId) &
            s.roundNumber.equals(roundNumber),
      );
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Deletes all scores for a specific match.
  Future<bool> deleteScoresForMatch({required String matchId}) async {
    final query = delete(scoreTable)..where((s) => s.matchId.equals(matchId));
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Deletes all scores for a specific player.
  Future<bool> deleteScoresForPlayer({required String playerId}) async {
    final query = delete(scoreTable)..where((s) => s.playerId.equals(playerId));
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Gets the latest round number for a match.
  Future<int> getLatestRoundNumber({required String matchId}) async {
    final query = selectOnly(scoreTable)
      ..where(scoreTable.matchId.equals(matchId))
      ..addColumns([scoreTable.roundNumber.max()]);
    final result = await query.getSingle();
    return result.read(scoreTable.roundNumber.max()) ?? 0;
  }

  /// Gets the total score for a player in a match (sum of all changes).
  Future<int> getTotalScoreForPlayer({
    required String playerId,
    required String matchId,
  }) async {
    final scores = await getPlayerScoresInMatch(
      playerId: playerId,
      matchId: matchId,
    );
    if (scores.isEmpty) return 0;
    // Return the score from the latest round
    return scores.last.score;
  }
}

