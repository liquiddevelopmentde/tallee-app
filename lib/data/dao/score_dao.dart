import 'package:drift/drift.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/score_table.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/score_entry.dart';

part 'score_dao.g.dart';

@DriftAccessor(tables: [ScoreTable])
class ScoreDao extends DatabaseAccessor<AppDatabase> with _$ScoreDaoMixin {
  ScoreDao(super.db);

  /// Adds a score entry to the database.
  Future<void> addScore({
    required String playerId,
    required String matchId,
    required int score,
    int change = 0,
    int roundNumber = 0,
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
      ..where((s) => s.playerId.equals(playerId) & s.matchId.equals(matchId))
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
    required int newScore,
    int newChange = 0,
    int roundNumber = 0,
  }) async {
    final rowsAffected =
        await (update(scoreTable)..where(
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
    int roundNumber = 0,
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

  Future<bool> hasWinner({required String matchId}) async {
    return await getWinner(matchId: matchId) != null;
  }

  // Setting the winner for a game and clearing previous winner if exists.
  Future<bool> setWinner({
    required String matchId,
    required String playerId,
  }) async {
    // Clear previous winner if exists
    deleteScoresForMatch(matchId: matchId);

    // Set the winner's score to 1
    final rowsAffected = await into(scoreTable).insert(
      ScoreTableCompanion.insert(
        playerId: playerId,
        matchId: matchId,
        roundNumber: 0,
        score: 1,
        change: 0,
      ),
      mode: InsertMode.insertOrReplace,
    );

    return rowsAffected > 0;
  }

  // Retrieves the winner of a match based on the highest score.
  Future<Player?> getWinner({required String matchId}) async {
    final query = select(scoreTable)
      ..where((s) => s.matchId.equals(matchId))
      ..orderBy([(s) => OrderingTerm.desc(s.score)])
      ..limit(1);
    final result = await query.getSingleOrNull();

    if (result == null) return null;

    final player = await db.playerDao.getPlayerById(playerId: result.playerId);
    return Player(
      id: player.id,
      name: player.name,
      createdAt: player.createdAt,
      description: player.description,
    );
  }

  /// Removes the winner of a match.
  ///
  /// Returns `true` if the winner was removed, `false` if there are multiple
  /// scores or if the winner cannot be removed.
  Future<bool> removeWinner({required String matchId}) async {
    final scores = await getScoresForMatch(matchId: matchId);

    if (scores.length > 1) {
      return false;
    } else {
      return await deleteScoresForMatch(matchId: matchId);
    }
  }

  Future<bool> hasLooser({required String matchId}) async {
    return await getLooser(matchId: matchId) != null;
  }

  // Setting the looser for a game and clearing previous looser if exists.
  Future<bool> setLooser({
    required String matchId,
    required String playerId,
  }) async {
    // Clear previous loosers if exists
    deleteScoresForMatch(matchId: matchId);

    // Set the loosers score to 0
    final rowsAffected = await into(scoreTable).insert(
      ScoreTableCompanion.insert(
        playerId: playerId,
        matchId: matchId,
        roundNumber: 0,
        score: 0,
        change: 0,
      ),
      mode: InsertMode.insertOrReplace,
    );

    return rowsAffected > 0;
  }

  /// Retrieves the looser of a match based on the score 0.
  Future<Player?> getLooser({required String matchId}) async {
    final query = select(scoreTable)
      ..where((s) => s.matchId.equals(matchId) & s.score.equals(0));
    final result = await query.getSingleOrNull();

    if (result == null) return null;

    final player = await db.playerDao.getPlayerById(playerId: result.playerId);
    return Player(
      id: player.id,
      name: player.name,
      createdAt: player.createdAt,
      description: player.description,
    );
  }

  /// Removes the looser of a match.
  ///
  /// Returns `true` if the looser was removed, `false` if there are multiple
  /// scores or if the looser cannot be removed.
  Future<bool> removeLooser({required String matchId}) async {
    final scores = await getScoresForMatch(matchId: matchId);

    if (scores.length > 1) {
      return false;
    } else {
      return await deleteScoresForMatch(matchId: matchId);
    }
  }
}
