import 'package:drift/drift.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/player_group_table.dart';
import 'package:tallee/data/db/tables/player_table.dart';
import 'package:tallee/data/models/player.dart';

part 'player_group_dao.g.dart';

@DriftAccessor(tables: [PlayerGroupTable, PlayerTable])
class PlayerGroupDao extends DatabaseAccessor<AppDatabase>
    with _$PlayerGroupDaoMixin {
  PlayerGroupDao(super.db);

  /* Create */

  /// Adds a [player] to a group with the given [groupId].
  /// If the player is already in the group, no action is taken.
  /// If the player does not exist in the player table, they are added.
  /// Returns `true` if the player was added, otherwise `false`.
  Future<bool> addPlayerToGroup({
    required Player player,
    required String groupId,
  }) async {
    if (await isPlayerInGroup(playerId: player.id, groupId: groupId)) {
      return false;
    }

    if (!await db.playerDao.playerExists(playerId: player.id)) {
      await db.playerDao.addPlayer(player: player);
    }

    await into(playerGroupTable).insert(
      PlayerGroupTableCompanion.insert(playerId: player.id, groupId: groupId),
    );
    return true;
  }

  /* Read */

  /// Retrieves all players belonging to a specific group by [groupId].
  Future<List<Player>> getPlayersOfGroup({required String groupId}) async {
    final query = select(playerGroupTable)
      ..where((pG) => pG.groupId.equals(groupId));
    final result = await query.get();

    List<Player> groupMembers = List.empty(growable: true);

    for (var entry in result) {
      final player = await db.playerDao.getPlayerById(playerId: entry.playerId);
      groupMembers.add(player);
    }

    return groupMembers;
  }

  /// Checks if a player with [playerId] is in the group with [groupId].
  /// Returns `true` if the player is in the group, otherwise `false`.
  Future<bool> isPlayerInGroup({
    required String playerId,
    required String groupId,
  }) async {
    final query = select(playerGroupTable)
      ..where((p) => p.playerId.equals(playerId) & p.groupId.equals(groupId));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  /* Update */

  /// Replaces all players in a group with the provided list of players.
  /// Removes all existing players from the group and adds the new players.
  /// Also adds any new players to the player table if they don't exist.
  /// Returns `true` if the group exists and players were replaced, `false` otherwise.
  Future<bool> replaceGroupPlayers({
    required String groupId,
    required List<Player> newPlayers,
  }) async {
    if (!await db.groupDao.groupExists(groupId: groupId)) return false;
    if (newPlayers.isEmpty) return false;

    await db.transaction(() async {
      // Remove all existing players from the group
      final deleteQuery = delete(db.playerGroupTable)
        ..where((p) => p.groupId.equals(groupId));
      await deleteQuery.go();

      // Add new players to the player table if they don't exist
      await Future.wait(
        newPlayers.map((player) async {
          if (!await db.playerDao.playerExists(playerId: player.id)) {
            await db.playerDao.addPlayer(player: player);
          }
        }),
      );

      // Add the new players to the group
      await db.batch(
        (b) => b.insertAll(
          db.playerGroupTable,
          newPlayers
              .map(
                (player) => PlayerGroupTableCompanion.insert(
                  playerId: player.id,
                  groupId: groupId,
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        ),
      );
    });
    return true;
  }

  /* Delete */

  /// Removes a player from a group based on [playerId] and [groupId].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> removePlayerFromGroup({
    required String playerId,
    required String groupId,
  }) async {
    final query = delete(playerGroupTable)
      ..where((p) => p.playerId.equals(playerId) & p.groupId.equals(groupId));
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }
}
