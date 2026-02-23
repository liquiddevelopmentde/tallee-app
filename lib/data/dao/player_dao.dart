import 'package:drift/drift.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/player_table.dart';
import 'package:tallee/data/dto/player.dart';

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
          (row) => Player(id: row.id, name: row.name, createdAt: row.createdAt),
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
      createdAt: result.createdAt,
    );
  }

  /// Adds a new [player] to the database.
  /// If a player with the same ID already exists, updates their name to
  /// the new one.
  Future<bool> addPlayer({required Player player}) async {
    if (!await playerExists(playerId: player.id)) {
      await into(playerTable).insert(
        PlayerTableCompanion.insert(
          id: player.id,
          name: player.name,
          createdAt: player.createdAt,
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

    await db.batch(
      (b) => b.insertAll(
        playerTable,
        players
            .map(
              (player) => PlayerTableCompanion.insert(
                id: player.id,
                name: player.name,
                createdAt: player.createdAt,
              ),
            )
            .toList(),
        mode: InsertMode.insertOrIgnore,
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
  Future<void> updatePlayername({
    required String playerId,
    required String newName,
  }) async {
    await (update(playerTable)..where((p) => p.id.equals(playerId))).write(
      PlayerTableCompanion(name: Value(newName)),
    );
  }

  /// Retrieves the total count of players in the database.
  Future<int> getPlayerCount() async {
    final count =
        await (selectOnly(playerTable)..addColumns([playerTable.id.count()]))
            .map((row) => row.read(playerTable.id.count()))
            .getSingle();
    return count ?? 0;
  }

  /// Deletes all players from the database.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> deleteAllPlayers() async {
    final query = delete(playerTable);
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }
}
