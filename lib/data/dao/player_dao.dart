import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/player_table.dart';
import 'package:tallee/data/models/player.dart';

part 'player_dao.g.dart';

@DriftAccessor(tables: [PlayerTable])
class PlayerDao extends DatabaseAccessor<AppDatabase> with _$PlayerDaoMixin {
  PlayerDao(super.db);

  /// Retrieves all players from the database.
  Future<List<Player>> getAllPlayers() async {
    final query = select(playerTable);
    final result = await query.get();
    return result
        .map(
          (row) => Player(
            id: row.id,
            name: row.name,
            description: row.description,
            createdAt: row.createdAt,
            nameCount: row.nameCount,
          ),
        )
        .toList();
  }

  /// Retrieves a [Player] by their [id].
  Future<Player> getPlayerById({required String playerId}) async {
    final query = select(playerTable)..where((p) => p.id.equals(playerId));
    final result = await query.getSingle();
    return Player(
      id: result.id,
      name: result.name,
      description: result.description,
      createdAt: result.createdAt,
      nameCount: result.nameCount,
    );
  }

  /// Adds a new [player] to the database.
  /// If a player with the same ID already exists, updates their name to
  /// the new one.
  Future<bool> addPlayer({required Player player}) async {
    if (!await playerExists(playerId: player.id)) {
      final int nameCount = await calculateNameCount(name: player.name);

      await into(playerTable).insert(
        PlayerTableCompanion.insert(
          id: player.id,
          name: player.name,
          description: player.description,
          createdAt: player.createdAt,
          nameCount: Value(nameCount),
        ),
        mode: InsertMode.insertOrReplace,
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
      var nameCount = await calculateNameCount(name: name);
      if (nameCount == 0) nameCount++;

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

  /// Deletes the player with the given [id] from the database.
  /// Returns `true` if the player was deleted, `false` if the player did not exist.
  Future<bool> deletePlayer({required String playerId}) async {
    final query = delete(playerTable)..where((p) => p.id.equals(playerId));
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Checks if a player with the given [id] exists in the database.
  /// Returns `true` if the player exists, `false` otherwise.
  Future<bool> playerExists({required String playerId}) async {
    final query = select(playerTable)..where((p) => p.id.equals(playerId));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// Updates the name of the player with the given [playerId] to [newName].
  Future<void> updatePlayerName({
    required String playerId,
    required String newName,
  }) async {
    // Get previous name and name count for the player before updating
    final previousPlayerName = await (select(
      playerTable,
    )..where((p) => p.id.equals(playerId))).map((row) => row.name).getSingle();
    final previousNameCount = await getNameCount(name: previousPlayerName);

    await (update(playerTable)..where((p) => p.id.equals(playerId))).write(
      PlayerTableCompanion(name: Value(newName)),
    );

    // Update name count for the new name
    final count = await calculateNameCount(name: newName);
    if (count > 0) {
      await (update(playerTable)..where((p) => p.name.equals(newName))).write(
        PlayerTableCompanion(nameCount: Value(count)),
      );
    }

    if (previousNameCount > 0) {
      // Get the player with that name and the hightest nameCount, and update their nameCount to previousNameCount
      final player = await getPlayerWithHighestNameCount(
        name: previousPlayerName,
      );
      if (player != null) {
        await updateNameCount(
          playerId: player.id,
          nameCount: previousNameCount,
        );
      }
    }
  }

  /// Retrieves the total count of players in the database.
  Future<int> getPlayerCount() async {
    final count =
        await (selectOnly(playerTable)..addColumns([playerTable.id.count()]))
            .map((row) => row.read(playerTable.id.count()))
            .getSingle();
    return count ?? 0;
  }

  /// Retrieves the count of players with the given [name] in the database.
  Future<int> getNameCount({required String name}) async {
    final query = select(playerTable)..where((p) => p.name.equals(name));
    final result = await query.get();
    return result.length;
  }

  /// Updates the nameCount for the player with the given [playerId] to [nameCount].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateNameCount({
    required String playerId,
    required int nameCount,
  }) async {
    final query = update(playerTable)..where((p) => p.id.equals(playerId));
    final rowsAffected = await query.write(
      PlayerTableCompanion(nameCount: Value(nameCount)),
    );
    return rowsAffected > 0;
  }

  @visibleForTesting
  Future<Player?> getPlayerWithHighestNameCount({required String name}) async {
    final query = select(playerTable)
      ..where((p) => p.name.equals(name))
      ..orderBy([(p) => OrderingTerm.desc(p.nameCount)])
      ..limit(1);
    final result = await query.getSingleOrNull();
    if (result != null) {
      return Player(
        id: result.id,
        name: result.name,
        description: result.description,
        createdAt: result.createdAt,
        nameCount: result.nameCount,
      );
    }
    return null;
  }

  @visibleForTesting
  Future<int> calculateNameCount({required String name}) async {
    final count = await getNameCount(name: name);
    final int nameCount;

    if (count == 1) {
      // If one other player exists with the same name, initialize the nameCount
      await initializeNameCount(name: name);
      // And for the new player, set nameCount to 2
      nameCount = 2;
    } else if (count > 1) {
      // If more than one player exists with the same name, just increment
      // the nameCount for the new player
      nameCount = count + 1;
    } else {
      // If no other players exist with the same name, set nameCount to 0
      nameCount = 0;
    }

    return nameCount;
  }

  @visibleForTesting
  Future<bool> initializeNameCount({required String name}) async {
    final rowsAffected =
        await (update(playerTable)..where((p) => p.name.equals(name))).write(
          const PlayerTableCompanion(nameCount: Value(1)),
        );
    return rowsAffected > 0;
  }

  /// Deletes all players from the database.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> deleteAllPlayers() async {
    final query = delete(playerTable);
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }
}
