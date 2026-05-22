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
            .map((row) => row.read(playerTable.id.count()))
            .getSingle();
    return count ?? 0;
  }

  /// Checks if a player with the given [playerId] exists in the database.
  /// Returns `true` if the player exists, `false` otherwise.
  Future<bool> playerExists({required String playerId}) async {
    final query = select(playerTable)..where((p) => p.id.equals(playerId));
    final result = await query.getSingleOrNull();
    return result != null;
  }

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

  /* Update */

  /// Updates the name of the player with the given [playerId] to [name].
  Future<bool> updatePlayerName({
    required String playerId,
    required String name,
  }) async {
    // Get previous name and name count for the player before updating
    final previousPlayerName =
        await (select(playerTable)..where((p) => p.id.equals(playerId)))
            .map((row) => row.name)
            .getSingleOrNull() ??
        '';

    // Update name count for the new name
    final newNameCount = await _processNameCount(name: name);

    // Update name and nameCount
    final rowsAffected =
        await (update(playerTable)..where((p) => p.id.equals(playerId))).write(
          PlayerTableCompanion(
            name: Value(name),
            nameCount: Value(newNameCount),
          ),
        );

    // Updating name count for the previous name
    final previousNameCount = await getNameCount(name: previousPlayerName);
    if (previousNameCount > 0) {
      // At least one more player with the previous name

      // Get the player with the highest count
      final player = await getPlayerWithHighestNameCount(
        name: previousPlayerName,
      );

      if (previousNameCount > 1) {
        // Multiple players
        final nameCount = await getNameCount(name: previousPlayerName);
        await updateNameCount(playerId: player!.id, nameCount: nameCount);
      } else {
        // Only one player
        await updateNameCount(playerId: player!.id, nameCount: 0);
      }
    }
    return rowsAffected > 0;
  }

  /// Updates the description of the player with the given [playerId] to
  /// [description].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updatePlayerDescription({
    required String playerId,
    required String description,
  }) async {
    final rowsAffected =
        await (update(playerTable)..where((g) => g.id.equals(playerId))).write(
          PlayerTableCompanion(description: Value(description)),
        );
    return rowsAffected > 0;
  }

  /* Delete */

  /// Deletes the player with the given [id] from the database.
  /// Returns `true` if the player was deleted, `false` if the player did not exist.
  Future<bool> deletePlayer({required String playerId}) async {
    final query = delete(playerTable)..where((p) => p.id.equals(playerId));
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /* Name count management */

  /// Retrieves the count of players with the given [name].
  /// Returns the highest name count if players with the same name exist,
  /// otherwise `null`.
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
