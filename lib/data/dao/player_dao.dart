import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/player_table.dart';
import 'package:tallee/data/models/player.dart';

part 'player_dao.g.dart';

@DriftAccessor(tables: [PlayerTable])
class PlayerDao extends DatabaseAccessor<AppDatabase> with _$PlayerDaoMixin {
  PlayerDao(super.db);

  /* Create */

  /// Adds a new [player] to the database.
  /// If a player with the same ID already exists, updates their name to
  /// the new one.
  Future<bool> addPlayer({required Player player}) async {
    if (!await playerExists(playerId: player.id)) {
      final int nameCount = await _processNameCount(name: player.name);

      await into(playerTable).insert(
        PlayerTableCompanion.insert(
          id: player.id,
          name: player.name,
          description: player.description,
          createdAt: player.createdAt,
          nameCount: Value(nameCount),
        ),
      );

      return true;
    }
    return false;
  }

  /// Adds multiple [players] to the database in a batch operation.
  /// Uses insertOrIgnore to avoid triggering cascade deletes on
  /// player_group associations when players already exist.
  Future<bool> addPlayersAsList({required List<Player> players}) async {
    if (players.isEmpty) return false;

    // Filter out players that already exist
    final newPlayers = <Player>[];
    for (final player in players) {
      if (!await playerExists(playerId: player.id)) {
        newPlayers.add(player);
      }
    }

    if (newPlayers.isEmpty) return false;

    // Group players by name
    final nameGroups = <String, List<Player>>{};
    for (final player in newPlayers) {
      nameGroups.putIfAbsent(player.name, () => []).add(player);
    }

    final playersToInsert = <PlayerTableCompanion>[];

    // Process each group of players with the same name
    for (final entry in nameGroups.entries) {
      final name = entry.key;
      final playersWithName = entry.value;

      // Get the current nameCount
      var nameCount = await _processNameCount(name: name);

      // One player with the same name
      if (playersWithName.length == 1) {
        final player = playersWithName[0];
        playersToInsert.add(
          PlayerTableCompanion.insert(
            id: player.id,
            name: player.name,
            description: player.description,
            createdAt: player.createdAt,
            nameCount: Value(nameCount),
          ),
        );
      } else {
        if (nameCount == 0) nameCount++;
        // Multiple players with the same name
        for (var i = 0; i < playersWithName.length; i++) {
          final player = playersWithName[i];
          playersToInsert.add(
            PlayerTableCompanion.insert(
              id: player.id,
              name: player.name,
              description: player.description,
              createdAt: player.createdAt,
              nameCount: Value(nameCount + i),
            ),
          );
        }
      }
    }

    await db.batch(
      (b) => b.insertAll(
        playerTable,
        playersToInsert,
        mode: InsertMode.insertOrReplace,
      ),
    );

    return true;
  }

  /* Read */

  /// Retrieves the total count of players in the database.
  Future<int> getPlayerCount() async {
    final count =
        await (selectOnly(playerTable)..addColumns([playerTable.id.count()]))
            .map((tbl) => tbl.read(playerTable.id.count()))
            .getSingle();
    return count ?? 0;
  }

  /// Checks if a player with the given [playerId] exists in the database.
  /// Ignores the `deleted` flag, so it returns `true` even for players marked as deleted.
  /// Returns `true` if the player exists, `false` otherwise.
  Future<bool> playerExists({required String playerId}) async {
    final query = select(playerTable)..where((p) => p.id.equals(playerId));
    final row = await query.getSingleOrNull();
    return row != null;
  }

  /// Retrieves all players from the database.
  /// If [includeDeletedPlayer] is `false`, players marked as deleted will be filtered out from the result.
  /// Returns empty list if no players are found.
  Future<List<Player>> getAllPlayers({
    bool includeDeletedPlayer = false,
  }) async {
    var query = select(playerTable);
    if (!includeDeletedPlayer) {
      query = query..where((p) => p.deleted.equals(false));
    }
    final result = await query.get();
    return result
        .map(
          (row) => Player(
            id: row.id,
            name: row.name,
            description: row.description,
            createdAt: row.createdAt,
            nameCount: row.nameCount,
            deleted: row.deleted,
          ),
        )
        .toList();
  }

  /// Retrieves a [Player] by their [id].
  Future<Player> getPlayerById({required String playerId}) async {
    final query = select(playerTable)..where((p) => p.id.equals(playerId));
    final row = await query.getSingle();
    return Player(
      id: row.id,
      name: row.name,
      description: row.description,
      createdAt: row.createdAt,
      nameCount: row.nameCount,
      deleted: row.deleted,
    );
  }

  /// Retrieves multiple [Player]s by their [playerIds].
  Future<List<Player>> getPlayersByIds({
    required List<String> playerIds,
  }) async {
    if (playerIds.isEmpty) return [];
    final query = select(playerTable)..where((p) => p.id.isIn(playerIds));
    final result = await query.get();
    return result
        .map(
          (row) => Player(
            id: row.id,
            name: row.name,
            description: row.description,
            createdAt: row.createdAt,
            nameCount: row.nameCount,
            deleted: row.deleted,
          ),
        )
        .toList();
  }

  /// Checks, if a player can be safely deleted.
  /// Returns `false`, if a player is in at least one match, else `true`.
  Future<bool> canTrueDelete({required String playerId}) async {
    final query =
        (selectOnly(db.playerMatchTable)
              ..where(db.playerMatchTable.playerId.equals(playerId))
              ..addColumns([db.playerMatchTable.playerId.count()]))
            .map((row) => row.read(db.playerMatchTable.playerId.count()));
    final count = await query.getSingle();
    return (count ?? 0) == 0;
  }

  /* Update */

  /// Updates the name of the player with the given [playerId] to [name].
  ///
  /// Keeps the `nameCount` values of the affected name groups consistent:
  /// - The renamed player gets a fresh `nameCount` for the new name group.
  /// - All players in the previous name group whose `nameCount` was greater
  ///   than the removed one get decremented by 1, so the numbering stays
  ///   contiguous (1..N) in `createdAt` order.
  /// - If only one player remains in the previous name group, their
  ///   `nameCount` is reset to 0.
  Future<bool> updatePlayerName({
    required String playerId,
    required String name,
  }) async {
    return transaction(() async {
      final previousPlayer = await (select(
        playerTable,
      )..where((tbl) => tbl.id.equals(playerId))).getSingleOrNull();
      if (previousPlayer == null) return false;

      final previousName = previousPlayer.name;
      final previousCount = previousPlayer.nameCount;

      // Determine the nameCount for the renamed player in the new group.
      final newNameCount = await _processNameCount(name: name);

      final rowsAffected =
          await (update(
            playerTable,
          )..where((tbl) => tbl.id.equals(playerId))).write(
            PlayerTableCompanion(
              name: Value(name),
              nameCount: Value(newNameCount),
            ),
          );

      // Consolidate the previous name group.
      final remainingCount = await getNameCount(name: previousName);

      if (remainingCount == 1) {
        // Only one player left
        await (update(playerTable)..where((p) => p.name.equals(previousName)))
            .write(const PlayerTableCompanion(nameCount: Value(0)));
      } else if (remainingCount > 1 && previousCount > 0) {
        // Shift every player above the gap down by one to keep numbering in order.
        await (update(playerTable)..where(
              (tbl) =>
                  tbl.name.equals(previousName) &
                  tbl.nameCount.isBiggerThanValue(previousCount),
            ))
            .write(
              PlayerTableCompanion.custom(
                nameCount: playerTable.nameCount - const Constant(1),
              ),
            );
      }

      return rowsAffected > 0;
    });
  }

  /// Updates the description of the player with the given [playerId] to
  /// [description].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updatePlayerDescription({
    required String playerId,
    required String description,
  }) async {
    final rowsAffected =
        await (update(playerTable)..where((tbl) => tbl.id.equals(playerId)))
            .write(PlayerTableCompanion(description: Value(description)));
    return rowsAffected > 0;
  }

  /* Delete */

  /// Deletes the player with the given [playerId] from the database.
  /// - [canTrueDelete] == `false`: Set deleted flag
  /// - [canTrueDelete] == `true`: Delete from database
  ///
  /// Returns `true` if the player was deleted/marked, `false` if the player did
  /// not exist.
  Future<bool> deletePlayer({required String playerId}) async {
    if (!await canTrueDelete(playerId: playerId)) {
      final rowsAffected =
          await (update(playerTable)..where((tbl) => tbl.id.equals(playerId)))
              .write(const PlayerTableCompanion(deleted: Value(true)));
      await db.playerGroupDao.removePlayerFromAllGroups(playerId: playerId);
      return rowsAffected > 0;
    } else {
      final rowsAffected = await (delete(
        playerTable,
      )..where((tbl) => tbl.id.equals(playerId))).go();
      return rowsAffected > 0;
    }
  }

  /// Deletes all players from the database.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> deleteAllPlayers() async {
    final query = delete(playerTable);
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Deletes all players marked as deleted from the database, if they are not associated with any match.
  /// Returns the number of players that were deleted.
  Future<int> purgeSoftDeletedPlayer() async {
    final deletedPlayers = await (select(
      playerTable,
    )..where((tbl) => tbl.deleted.equals(true))).get();

    if (deletedPlayers.isEmpty) return 0;

    var removedPlayer = 0;
    await transaction(() async {
      for (final player in deletedPlayers) {
        if (await canTrueDelete(playerId: player.id)) {
          final rowsAffected = await (delete(
            playerTable,
          )..where((tbl) => tbl.id.equals(player.id))).go();
          removedPlayer += rowsAffected;
        }
      }
    });

    return removedPlayer;
  }

  /* Name count management */

  /// Retrieves the count of players with the given [name].
  /// Returns the highest name count if players with the same name exist,
  /// otherwise `null`.
  Future<int> getNameCount({required String name}) async {
    final query = select(playerTable)..where((tbl) => tbl.name.equals(name));
    final result = await query.get();
    return result.length;
  }

  /// Updates the nameCount for the player with the given [playerId] to [nameCount].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateNameCount({
    required String playerId,
    required int nameCount,
  }) async {
    final query = update(playerTable)..where((tbl) => tbl.id.equals(playerId));
    final rowsAffected = await query.write(
      PlayerTableCompanion(nameCount: Value(nameCount)),
    );
    return rowsAffected > 0;
  }

  @visibleForTesting
  Future<Player?> getPlayerWithHighestNameCount({required String name}) async {
    final query = select(playerTable)
      ..where((tbl) => tbl.name.equals(name))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.nameCount)])
      ..limit(1);
    final result = await query.getSingleOrNull();
    if (result != null) {
      return Player(
        id: result.id,
        name: result.name,
        description: result.description,
        createdAt: result.createdAt,
        nameCount: result.nameCount,
        deleted: result.deleted,
      );
    }
    return null;
  }

  /// Processes the name count for a new player with the given [name].
  ///- 0 Player: returning 0
  ///- 1 Player: returning 2, and initializes the nameCount for the existing player to 1
  ///- Other: returning the existing count + 1
  Future<int> _processNameCount({required String name}) async {
    final nameCount = await calculateNameCount(name: name);
    if (nameCount == 2) {
      // If one other player exists with the same name, initialize the nameCount
      await initializeNameCount(name: name);
    }
    return nameCount;
  }

  @visibleForTesting
  /// Calculates the name count for a new player with the given [name].
  /// - 0 Players: Name count is 0
  /// - 1 Player: Name count is 2 (since the existing player will be 1)
  /// - Other: Name count is the existing count + 1
  Future<int> calculateNameCount({required String name}) async {
    final count = await getNameCount(name: name);
    final int nameCount;

    if (count == 0) {
      // If no other players exist with the same name, the returned nameCount is 0
      nameCount = 0;
    } else if (count == 1) {
      // If one other player with the name count exists, the returned name count is 2
      nameCount = 2;
    } else {
      // If more than one player exists with the same name, just increment
      // the nameCount for the new player
      nameCount = count + 1;
    }
    return nameCount;
  }

  @visibleForTesting
  Future<bool> initializeNameCount({required String name}) async {
    final rowsAffected =
        await (update(playerTable)..where((tbl) => tbl.name.equals(name)))
            .write(const PlayerTableCompanion(nameCount: Value(1)));
    return rowsAffected > 0;
  }
}
