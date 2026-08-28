import 'dart:async';

import 'package:drift/drift.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/score_entry_table.dart';
import 'package:tallee/data/models/player.dart';
import 'package:tallee/data/models/score_entry.dart';

part 'score_entry_dao.g.dart';

@DriftAccessor(tables: [ScoreEntryTable])
class ScoreEntryDao extends DatabaseAccessor<AppDatabase>
    with _$ScoreEntryDaoMixin {
  ScoreEntryDao(super.db);

  /* Create */

  /// Adds a score entry to the database.
  Future<bool> addScore({
    required String playerId,
    required String matchId,
    required ScoreEntry entry,
  }) async {
    final rowsAffected = await into(scoreEntryTable).insert(
      ScoreEntryTableCompanion.insert(
        playerId: playerId,
        matchId: matchId,
        roundNumber: entry.roundNumber,
        score: entry.score,
        change: entry.change,
      ),
      mode: InsertMode.insertOrReplace,
    );

    return rowsAffected > 0;
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

  /* Read */

  /// Retrieves the score for a specific round.
  Future<ScoreEntry?> getScore({
    required String playerId,
    required String matchId,
    int roundNumber = 0,
  }) async {
    final query = select(scoreEntryTable)
      ..where(
        (tbl) =>
            tbl.playerId.equals(playerId) &
            tbl.matchId.equals(matchId) &
            tbl.roundNumber.equals(roundNumber),
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
  Future<Map<String, ScoreEntry?>> getAllMatchScores({
    required String matchId,
  }) async {
    final query = select(scoreEntryTable)
      ..where((tbl) => tbl.matchId.equals(matchId));
    final result = await query.get();

    final Map<String, ScoreEntry?> scoresByPlayer = {};
    for (final row in result) {
      final score = ScoreEntry(
        roundNumber: row.roundNumber,
        score: row.score,
        change: row.change,
      );
      scoresByPlayer[row.playerId] = score;
    }

    return scoresByPlayer;
  }

  /// Retrieves scores for multiple matches in a single operation.
  /// Returns a map where the key is the matchId and the value is a map of playerId -> ScoreEntry.
  Future<Map<String, Map<String, ScoreEntry?>>> getScoresForMatches({
    required List<String> matchIds,
  }) async {
    if (matchIds.isEmpty) return {};

    final query = select(scoreEntryTable)
      ..where((tbl) => tbl.matchId.isIn(matchIds));
    final rows = await query.get();

    final Map<String, Map<String, ScoreEntry?>> resultMap = {};
    for (final id in matchIds) {
      resultMap[id] = {};
    }

    for (final row in rows) {
      final score = ScoreEntry(
        roundNumber: row.roundNumber,
        score: row.score,
        change: row.change,
      );
      resultMap.putIfAbsent(row.matchId, () => {})[row.playerId] = score;
    }

    return resultMap;
  }

  /// Retrieves all scores for a specific player in a match.
  Future<List<ScoreEntry>> getAllPlayerScoresInMatch({
    required String playerId,
    required String matchId,
  }) async {
    final query = select(scoreEntryTable)
      ..where(
        (tbl) => tbl.playerId.equals(playerId) & tbl.matchId.equals(matchId),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.roundNumber)]);
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

  /// Gets the highest (latest) round number for a match.
  /// Returns `null` if there are no scores for the match.
  Future<int?> getLatestRoundNumber({required String matchId}) async {
    final query = selectOnly(scoreEntryTable)
      ..where(scoreEntryTable.matchId.equals(matchId))
      ..addColumns([scoreEntryTable.roundNumber.max()]);
    final row = await query.getSingle();
    return row.read(scoreEntryTable.roundNumber.max());
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

  /* Update */

  /// Updates a score entry.
  Future<bool> updateScore({
    required String playerId,
    required String matchId,
    required ScoreEntry entry,
  }) async {
    final rowsAffected =
        await (update(scoreEntryTable)..where(
              (tbl) =>
                  tbl.playerId.equals(playerId) &
                  tbl.matchId.equals(matchId) &
                  tbl.roundNumber.equals(entry.roundNumber),
            ))
            .write(
              ScoreEntryTableCompanion(
                score: Value(entry.score),
                change: Value(entry.change),
              ),
            );
    return rowsAffected > 0;
  }

  /* Delete */

  /// Deletes a score entry.
  Future<bool> deleteScore({
    required String playerId,
    required String matchId,
    int roundNumber = 0,
  }) async {
    final query = delete(scoreEntryTable)
      ..where(
        (tbl) =>
            tbl.playerId.equals(playerId) &
            tbl.matchId.equals(matchId) &
            tbl.roundNumber.equals(roundNumber),
      );
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Deletes all score entries for a match.
  Future<bool> deleteAllScoresForMatch({required String matchId}) async {
    final query = delete(scoreEntryTable)
      ..where((tbl) => tbl.matchId.equals(matchId));
    var rowsAffected = await query.go();

    final success = await db.matchDao.removeMatchEndedAt(matchId: matchId);

    return rowsAffected > 0 && success;
  }

  Future<bool> deleteAllScoresForPlayerInMatch({
    required String matchId,
    required String playerId,
  }) async {
    final query = delete(scoreEntryTable)
      ..where(
        (tbl) => tbl.playerId.equals(playerId) & tbl.matchId.equals(matchId),
      );
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /* Winner handling */

  Future<bool> hasWinner({required String matchId}) async {
    return await getWinner(matchId: matchId) != null;
  }

  // Setting the winner for a game and clearing previous winner if exists.
  Future<bool> setWinner({
    required String matchId,
    required String playerId,
  }) async {
    // Clear previous winner if exists
    await deleteAllScoresForMatch(matchId: matchId);

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

  /// Retrieves the winner of a match by looking for a score entry where score
  /// is 1. Returns `null` if no player found, else the first with the score.
  Future<Player?> getWinner({required String matchId}) async {
    final query =
        select(scoreEntryTable).join([
          innerJoin(
            db.playerTable,
            db.playerTable.id.equalsExp(scoreEntryTable.playerId),
          ),
        ])..where(
          scoreEntryTable.matchId.equals(matchId) &
              scoreEntryTable.score.equals(1),
        );

    final result = await query.get();
    if (result.isEmpty) return null;

    final playerData = result.first.readTable(db.playerTable);
    return Player(
      id: playerData.id,
      name: playerData.name,
      createdAt: playerData.createdAt,
      description: playerData.description,
    );
  }

  /// Removes the winner of a match.
  ///
  /// Returns `true` if the winner was removed, `false` if there are multiple
  /// scores or if the winner cannot be removed.
  Future<bool> removeWinner({required String matchId}) async {
    return await deleteAllScoresForMatch(matchId: matchId);
  }

  /* multiple winners handling */

  /// Sets the winners for a match.
  ///
  /// Returns `true` if more than 0 rows were affected
  Future<bool> setWinners({
    required List<Player> winners,
    required String matchId,
  }) async {
    // Clear previous winners if exists
    await deleteAllScoresForMatch(matchId: matchId);

    if (winners.isEmpty) return false;

    await batch((batch) {
      batch.insertAll(
        scoreEntryTable,
        winners
            .map(
              (player) => ScoreEntryTableCompanion.insert(
                playerId: player.id,
                matchId: matchId,
                roundNumber: 0,
                score: 1,
                change: 0,
              ),
            )
            .toList(),
        mode: InsertMode.insertOrReplace,
      );
    });

    return true;
  }

  /* Loser handling */

  Future<bool> hasLoser({required String matchId}) async {
    return await getLoser(matchId: matchId) != null;
  }

  // Setting the loser for a game and clearing previous loser if exists.
  Future<bool> setLoser({
    required String matchId,
    required String playerId,
  }) async {
    // Clear previous losers if exists
    await deleteAllScoresForMatch(matchId: matchId);

    // Set the losers score to 0
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

  /// Retrieves the loser of a match by looking for a score entry where score
  /// is 0. Returns `null` if no player found, else the first with the score.
  Future<Player?> getLoser({required String matchId}) async {
    final query =
        select(scoreEntryTable).join([
          innerJoin(
            db.playerTable,
            db.playerTable.id.equalsExp(scoreEntryTable.playerId),
          ),
        ])..where(
          scoreEntryTable.matchId.equals(matchId) &
              scoreEntryTable.score.equals(0),
        );

    final result = await query.get();
    if (result.isEmpty) return null;

    final playerData = result.first.readTable(db.playerTable);
    return Player(
      id: playerData.id,
      name: playerData.name,
      createdAt: playerData.createdAt,
      description: playerData.description,
    );
  }

  /// Removes the loser of a match.
  ///
  /// Returns `true` if the loser was removed, `false` if there are multiple
  /// scores or if the loser cannot be removed.
  Future<bool> removeLoser({required String matchId}) async {
    return await deleteAllScoresForMatch(matchId: matchId);
  }

  /// Sets the losers for a match.
  ///
  /// Returns `true` if more than 0 rows were affected
  Future<bool> setLosers({
    required List<Player> losers,
    required String matchId,
  }) async {
    // Clear previous losers if exists
    await deleteAllScoresForMatch(matchId: matchId);

    if (losers.isEmpty) return false;

    await batch((batch) {
      batch.insertAll(
        scoreEntryTable,
        losers
            .map(
              (player) => ScoreEntryTableCompanion.insert(
                playerId: player.id,
                matchId: matchId,
                roundNumber: 0,
                score: 0,
                change: 0,
              ),
            )
            .toList(),
        mode: InsertMode.insertOrReplace,
      );
    });

    return true;
  }

  /* placement handling */

  /// Sets the placement for each player in a match.
  /// The highest score is assigned to the first player, the second highest to the second player, and so on.
  Future<void> setPlacements({
    required String matchId,
    required List<Player> players,
  }) async {
    for (int i = 0; i < players.length; i++) {
      await db.scoreEntryDao.addScore(
        matchId: matchId,
        playerId: players[i].id,
        entry: ScoreEntry(roundNumber: 0, score: players.length - i, change: 0),
      );
    }
  }
}
