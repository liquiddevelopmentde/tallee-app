import 'dart:async';

import 'package:drift/drift.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/score_entry_table.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/score_entry.dart';

part 'score_dao.g.dart';

@DriftAccessor(tables: [ScoreEntryTable])
class ScoreDao extends DatabaseAccessor<AppDatabase> with _$ScoreDaoMixin {
  ScoreDao(super.db);

  /// Adds a score entry to the database.
  Future<void> addScore({
    required String playerId,
    required String matchId,
    required ScoreEntry entry,
  }) async {
    await into(scoreEntryTable).insert(
      ScoreEntryTableCompanion.insert(
        playerId: playerId,
        matchId: matchId,
        roundNumber: entry.roundNumber,
        score: entry.score,
        change: entry.change,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> addScoresAsList({
    required List<ScoreEntry> entrys,
    required String playerId,
    required String matchId,
  }) async {
    if (entrys.isEmpty) return;
    final entries = entrys
        .map(
          (score) => ScoreEntryTableCompanion.insert(
            playerId: playerId,
            matchId: matchId,
            roundNumber: score.roundNumber,
            score: score.score,
            change: score.change,
          ),
        )
        .toList();

    await batch((batch) {
      batch.insertAll(
        scoreEntryTable,
        entries,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  /// Retrieves the score for a specific round.
  Future<ScoreEntry?> getScore({
    required String playerId,
    required String matchId,
    int roundNumber = 0,
  }) async {
    final query = select(scoreEntryTable)
      ..where(
        (s) =>
            s.playerId.equals(playerId) &
            s.matchId.equals(matchId) &
            s.roundNumber.equals(roundNumber),
      );

    final result = await query.getSingleOrNull();
    if (result == null) return null;

    return ScoreEntry(
      roundNumber: result.roundNumber,
      score: result.score,
      change: result.change,
    );
  }

  /// Retrieves all scores for a specific match.
  Future<Map<String, List<ScoreEntry>>> getAllMatchScores({
    required String matchId,
  }) async {
    final query = select(scoreEntryTable)
      ..where((s) => s.matchId.equals(matchId));
    final result = await query.get();

    final Map<String, List<ScoreEntry>> scoresByPlayer = {};
    for (final row in result) {
      final score = ScoreEntry(
        roundNumber: row.roundNumber,
        score: row.score,
        change: row.change,
      );
      scoresByPlayer.putIfAbsent(row.playerId, () => []).add(score);
    }

    return scoresByPlayer;
  }

  /// Retrieves all scores for a specific player in a match.
  Future<List<ScoreEntry>> getAllPlayerScoresInMatch({
    required String playerId,
    required String matchId,
  }) async {
    final query = select(scoreEntryTable)
      ..where((s) => s.playerId.equals(playerId) & s.matchId.equals(matchId))
      ..orderBy([(s) => OrderingTerm.asc(s.roundNumber)]);
    final result = await query.get();
    return result
        .map(
          (row) => ScoreEntry(
            roundNumber: row.roundNumber,
            score: row.score,
            change: row.change,
          ),
        )
        .toList()
      ..sort(
        (scoreA, scoreB) => scoreA.roundNumber.compareTo(scoreB.roundNumber),
      );
  }

  /// Updates a score entry.
  Future<bool> updateScore({
    required String playerId,
    required String matchId,
    required ScoreEntry newEntry,
  }) async {
    final rowsAffected =
        await (update(scoreEntryTable)..where(
              (s) =>
                  s.playerId.equals(playerId) &
                  s.matchId.equals(matchId) &
                  s.roundNumber.equals(newEntry.roundNumber),
            ))
            .write(
              ScoreEntryTableCompanion(
                score: Value(newEntry.score),
                change: Value(newEntry.change),
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
    final query = delete(scoreEntryTable)
      ..where(
        (s) =>
            s.playerId.equals(playerId) &
            s.matchId.equals(matchId) &
            s.roundNumber.equals(roundNumber),
      );
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  Future<bool> deleteAllScoresForMatch({required String matchId}) async {
    final query = delete(scoreEntryTable)
      ..where((s) => s.matchId.equals(matchId));
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  Future<bool> deleteAllScoresForPlayerInMatch({
    required String matchId,
    required String playerId,
  }) async {
    final query = delete(scoreEntryTable)
      ..where((s) => s.playerId.equals(playerId) & s.matchId.equals(matchId));
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Gets the highest (latest) round number for a match.
  /// Returns `null` if there are no scores for the match.
  Future<int?> getLatestRoundNumber({required String matchId}) async {
    final query = selectOnly(scoreEntryTable)
      ..where(scoreEntryTable.matchId.equals(matchId))
      ..addColumns([scoreEntryTable.roundNumber.max()]);
    final result = await query.getSingle();
    return result.read(scoreEntryTable.roundNumber.max());
  }

  /// Aggregates the total score for a player in a match by summing all their
  /// score entry changes. Returns `0` if there are no scores for the player
  /// in the match.
  Future<int> getTotalScoreForPlayer({
    required String playerId,
    required String matchId,
  }) async {
    final scores = await getAllPlayerScoresInMatch(
      playerId: playerId,
      matchId: matchId,
    );
    if (scores.isEmpty) return 0;
    // Return the sum of all score changes
    return scores.fold<int>(0, (sum, element) => sum + element.change);
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
    deleteAllScoresForMatch(matchId: matchId);

    // Set the winner's score to 1
    final rowsAffected = await into(scoreEntryTable).insert(
      ScoreEntryTableCompanion.insert(
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
    final query = select(scoreEntryTable)
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
    final scores = await getAllMatchScores(matchId: matchId);

    if (scores.length > 1) {
      return false;
    } else {
      return await deleteAllScoresForMatch(matchId: matchId);
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
    deleteAllScoresForMatch(matchId: matchId);

    // Set the loosers score to 0
    final rowsAffected = await into(scoreEntryTable).insert(
      ScoreEntryTableCompanion.insert(
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
    final query = select(scoreEntryTable)
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
    final scores = await getAllMatchScores(matchId: matchId);

    if (scores.length > 1) {
      return false;
    } else {
      return await deleteAllScoresForMatch(matchId: matchId);
    }
  }
}
