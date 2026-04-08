import 'package:drift/drift.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/player_match_table.dart';
import 'package:tallee/data/db/tables/team_table.dart';
import 'package:tallee/data/models/player.dart';

part 'player_match_dao.g.dart';

@DriftAccessor(tables: [PlayerMatchTable, TeamTable])
class PlayerMatchDao extends DatabaseAccessor<AppDatabase>
    with _$PlayerMatchDaoMixin {
  PlayerMatchDao(super.db);

  /// Associates a player with a match by inserting a record into the
  /// [PlayerMatchTable]. Optionally associates with a team and sets initial score.
  Future<void> addPlayerToMatch({
    required String matchId,
    required String playerId,
    String? teamId,
  }) async {
    await into(playerMatchTable).insert(
      PlayerMatchTableCompanion.insert(
        playerId: playerId,
        matchId: matchId,
        teamId: Value(teamId),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// Retrieves a list of [Player]s associated with the given [matchId].
  /// Returns null if no players are found.
  Future<List<Player>?> getPlayersOfMatch({required String matchId}) async {
    final result = await (select(
      playerMatchTable,
    )..where((p) => p.matchId.equals(matchId))).get();

    if (result.isEmpty) return null;

    final futures = result.map(
      (row) => db.playerDao.getPlayerById(playerId: row.playerId),
    );
    final players = await Future.wait(futures);
    return players;
  }

  /// Updates the score for a player in a match.
  /// Returns `true` if the update was successful, otherwise `false`.
  Future<bool> updatePlayerScore({
    required String matchId,
    required String playerId,
    required int newScore,
  }) async {
    /* final rowsAffected =
        await (update(playerMatchTable)..where(
              (p) => p.matchId.equals(matchId) & p.playerId.equals(playerId),
            ))
            .write(PlayerMatchTableCompanion(score: Value(newScore)));
    return rowsAffected > 0;*/
    return false;
  }

  /// Updates the team for a player in a match.
  /// Returns `true` if the update was successful, otherwise `false`.
  Future<bool> updatePlayerTeam({
    required String matchId,
    required String playerId,
    required String? teamId,
  }) async {
    final rowsAffected =
        await (update(playerMatchTable)..where(
              (p) => p.matchId.equals(matchId) & p.playerId.equals(playerId),
            ))
            .write(PlayerMatchTableCompanion(teamId: Value(teamId)));
    return rowsAffected > 0;
  }

  /// Checks if there are any players associated with the given [matchId].
  /// Returns `true` if there are players, otherwise `false`.
  Future<bool> matchHasPlayers({required String matchId}) async {
    final count =
        await (selectOnly(playerMatchTable)
              ..where(playerMatchTable.matchId.equals(matchId))
              ..addColumns([playerMatchTable.playerId.count()]))
            .map((row) => row.read(playerMatchTable.playerId.count()))
            .getSingle();
    return (count ?? 0) > 0;
  }

  /// Checks if a specific player is associated with a specific match.
  /// Returns `true` if the player is in the match, otherwise `false`.
  Future<bool> isPlayerInMatch({
    required String matchId,
    required String playerId,
  }) async {
    final count =
        await (selectOnly(playerMatchTable)
              ..where(playerMatchTable.matchId.equals(matchId))
              ..where(playerMatchTable.playerId.equals(playerId))
              ..addColumns([playerMatchTable.playerId.count()]))
            .map((row) => row.read(playerMatchTable.playerId.count()))
            .getSingle();
    return (count ?? 0) > 0;
  }

  /// Removes the association of a player with a match by deleting the record
  /// from the [PlayerMatchTable].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> removePlayerFromMatch({
    required String matchId,
    required String playerId,
  }) async {
    final query = delete(playerMatchTable)
      ..where((pg) => pg.matchId.equals(matchId))
      ..where((pg) => pg.playerId.equals(playerId));
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Updates the players associated with a match based on the provided
  /// [newPlayer] list. It adds new players and removes players that are no
  /// longer associated with the match.
  Future<void> updatePlayersFromMatch({
    required String matchId,
    required List<Player> newPlayer,
  }) async {
    final currentPlayers = await getPlayersOfMatch(matchId: matchId);
    // Create sets of player IDs for easy comparison
    final currentPlayerIds = currentPlayers?.map((p) => p.id).toSet() ?? {};
    final newPlayerIdsSet = newPlayer.map((p) => p.id).toSet();

    // Determine players to add and remove
    final playersToAdd = newPlayerIdsSet.difference(currentPlayerIds);
    final playersToRemove = currentPlayerIds.difference(newPlayerIdsSet);

    await db.transaction(() async {
      // Remove old players
      if (playersToRemove.isNotEmpty) {
        await (delete(playerMatchTable)..where(
              (pg) =>
                  pg.matchId.equals(matchId) &
                  pg.playerId.isIn(playersToRemove.toList()),
            ))
            .go();
      }

      // Add new players
      if (playersToAdd.isNotEmpty) {
        final inserts = playersToAdd
            .map(
              (id) => PlayerMatchTableCompanion.insert(
                playerId: id,
                matchId: matchId,
              ),
            )
            .toList();
        await Future.wait(
          inserts.map(
            (c) => into(
              playerMatchTable,
            ).insert(c, mode: InsertMode.insertOrIgnore),
          ),
        );
      }
    });
  }

  /// Retrieves all players in a specific team for a match.
  Future<List<Player>> getPlayersInTeam({
    required String matchId,
    required String teamId,
  }) async {
    final result = await (select(
      playerMatchTable,
    )..where((p) => p.matchId.equals(matchId) & p.teamId.equals(teamId))).get();

    if (result.isEmpty) return [];

    final futures = result.map(
      (row) => db.playerDao.getPlayerById(playerId: row.playerId),
    );
    return Future.wait(futures);
  }
}
