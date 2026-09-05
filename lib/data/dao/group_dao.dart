import 'package:drift/drift.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/group_table.dart';
import 'package:tallee/data/db/tables/match_table.dart';
import 'package:tallee/data/db/tables/player_group_table.dart';
import 'package:tallee/data/models/group.dart';
import 'package:tallee/data/models/player.dart';

part 'group_dao.g.dart';

@DriftAccessor(tables: [GroupTable, PlayerGroupTable, MatchTable])
class GroupDao extends DatabaseAccessor<AppDatabase> with _$GroupDaoMixin {
  GroupDao(super.db);

  /* Create */

  /// Adds a new group with the given [id] and [name] to the database.
  /// This method also adds the group's members to the [PlayerGroupTable].
  Future<bool> addGroup({required Group group}) async {
    if (!await groupExists(groupId: group.id)) {
      await db.transaction(() async {
        await into(groupTable).insert(
          GroupTableCompanion.insert(
            id: group.id,
            name: group.name,
            description: group.description,
            createdAt: group.createdAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
        await Future.wait(
          group.members.map((player) => db.playerDao.addPlayer(player: player)),
        );
        await db.batch(
          (b) => b.insertAll(
            db.playerGroupTable,
            group.members
                .map(
                  (member) => PlayerGroupTableCompanion.insert(
                    playerId: member.id,
                    groupId: group.id,
                  ),
                )
                .toList(),
            mode: InsertMode.insertOrReplace,
          ),
        );
      });
      return true;
    }
    return false;
  }

  /// Adds multiple groups to the database.
  /// Also adds the group's members to the [PlayerGroupTable].
  Future<void> addGroupsAsList({required List<Group> groups}) async {
    if (groups.isEmpty) return;
    await db.transaction(() async {
      // Deduplicate groups by id - keep first occurrence
      final Map<String, Group> uniqueGroups = {};
      for (final g in groups) {
        uniqueGroups.putIfAbsent(g.id, () => g);
      }

      // Insert unique groups in batch
      // Using insertOrIgnore to avoid triggering cascade deletes on
      // player_group associations when groups already exist
      await db.batch(
        (b) => b.insertAll(
          groupTable,
          uniqueGroups.values
              .map(
                (group) => GroupTableCompanion.insert(
                  id: group.id,
                  name: group.name,
                  description: group.description,
                  createdAt: group.createdAt,
                ),
              )
              .toList(),
          mode: InsertMode.insertOrIgnore,
        ),
      );

      // Collect unique players from all groups
      final uniquePlayers = <String, Player>{};
      for (final g in uniqueGroups.values) {
        for (final m in g.members) {
          uniquePlayers[m.id] = m;
        }
      }

      if (uniquePlayers.isNotEmpty) {
        // Using insertOrIgnore to avoid triggering cascade deletes on
        // player_group associations when players already exist
        await db.batch(
          (b) => b.insertAll(
            db.playerTable,
            uniquePlayers.values
                .map(
                  (p) => PlayerTableCompanion.insert(
                    id: p.id,
                    name: p.name,
                    description: p.description,
                    createdAt: p.createdAt,
                  ),
                )
                .toList(),
            mode: InsertMode.insertOrIgnore,
          ),
        );
      }

      // Prepare all player-group associations in one list (unique pairs)
      final Set<String> seenPairs = {};
      final List<PlayerGroupTableCompanion> pgRows = [];
      for (final g in uniqueGroups.values) {
        for (final m in g.members) {
          final key = '${m.id}|${g.id}';
          if (!seenPairs.contains(key)) {
            seenPairs.add(key);
            pgRows.add(
              PlayerGroupTableCompanion.insert(playerId: m.id, groupId: g.id),
            );
          }
        }
      }

      if (pgRows.isNotEmpty) {
        await db.batch((b) {
          for (final pg in pgRows) {
            b.insert(db.playerGroupTable, pg, mode: InsertMode.insertOrReplace);
          }
        });
      }
    });
  }

  /* Read */

  /// Retrieves all groups from the database.
  Future<List<Group>> getAllGroups() async {
    final query = select(groupTable);
    final result = await query.get();
    return Future.wait(
      result.map((row) async {
        final members = await db.playerGroupDao.getPlayersOfGroup(
          groupId: row.id,
        );
        return Group(
          id: row.id,
          name: row.name,
          description: row.description,
          members: members,
          createdAt: row.createdAt,
        );
      }),
    );
  }

  /// Retrieves a [Group] by its [groupId], including its members.
  Future<Group> getGroupById({required String groupId}) async {
    final query = select(groupTable)..where((g) => g.id.equals(groupId));
    final row = await query.getSingle();

    List<Player> members = await db.playerGroupDao.getPlayersOfGroup(
      groupId: groupId,
    );

    return Group(
      id: row.id,
      name: row.name,
      description: row.description,
      members: members,
      createdAt: row.createdAt,
    );
  }

  /// Retrieves multiple [Group]s by their [groupIds], including their members.
  Future<List<Group>> getGroupsByIds({required List<String> groupIds}) async {
    if (groupIds.isEmpty) return [];
    final query = select(groupTable)..where((g) => g.id.isIn(groupIds));
    final result = await query.get();

    return Future.wait(
      result.map((row) async {
        final members = await db.playerGroupDao.getPlayersOfGroup(
          groupId: row.id,
        );
        return Group(
          id: row.id,
          name: row.name,
          description: row.description,
          members: members,
          createdAt: row.createdAt,
        );
      }),
    );
  }

  /// Retrieves the number of groups in the database.
  Future<int> getGroupCount() async {
    final count =
        await (selectOnly(groupTable)..addColumns([groupTable.id.count()]))
            .map((tbl) => tbl.read(groupTable.id.count()))
            .getSingle();
    return count ?? 0;
  }

  /// Retrieves all groups a specific player belongs to.
  /// Returns an empty list if the player is not part of any group.
  Future<List<Group>> getGroupsByPlayer({required String playerId}) async {
    final playerGroups = await (select(
      playerGroupTable,
    )..where((tbl) => tbl.playerId.equals(playerId))).get();

    if (playerGroups.isEmpty) return [];

    final groupIds = playerGroups.map((pg) => pg.groupId).toSet().toList();
    final result =
        await (select(groupTable)
              ..where((tbl) => tbl.id.isIn(groupIds))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
            .get();

    return Future.wait(
      result.map((row) async {
        final members = await db.playerGroupDao.getPlayersOfGroup(
          groupId: row.id,
        );
        return Group(
          id: row.id,
          name: row.name,
          description: row.description,
          members: members,
          createdAt: row.createdAt,
        );
      }),
    );
  }

  /// Checks if a group with the given [groupId] exists in the database.
  /// Returns `true` if the group exists, `false` otherwise.
  Future<bool> groupExists({required String groupId}) async {
    final query = select(groupTable)..where((g) => g.id.equals(groupId));
    final row = await query.getSingleOrNull();
    return row != null;
  }

  /* Delete */

  /// Deletes the group with the given [id] from the database.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> deleteGroup({required String groupId}) async {
    final query = (delete(groupTable)..where((g) => g.id.equals(groupId)));
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Deletes all groups from the database.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> deleteAllGroups() async {
    final query = delete(groupTable);
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /* Update */

  /// Updates the name of the group with the given [id] to [name].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateGroupName({
    required String groupId,
    required String name,
  }) async {
    final rowsAffected =
        await (update(groupTable)..where((tbl) => tbl.id.equals(groupId)))
            .write(GroupTableCompanion(name: Value(name)));
    return rowsAffected > 0;
  }

  /// Updates the description of the group with the given [groupId] to [description].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateGroupDescription({
    required String groupId,
    required String description,
  }) async {
    final rowsAffected =
        await (update(groupTable)..where((tbl) => tbl.id.equals(groupId)))
            .write(GroupTableCompanion(description: Value(description)));
    return rowsAffected > 0;
  }
}
