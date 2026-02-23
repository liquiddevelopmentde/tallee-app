import 'package:drift/drift.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/group_table.dart';
import 'package:tallee/data/db/tables/player_group_table.dart';
import 'package:tallee/data/dto/group.dart';
import 'package:tallee/data/dto/player.dart';

part 'group_dao.g.dart';

@DriftAccessor(tables: [GroupTable, PlayerGroupTable])
class GroupDao extends DatabaseAccessor<AppDatabase> with _$GroupDaoMixin {
  GroupDao(super.db);

  /// Retrieves all groups from the database.
  Future<List<Group>> getAllGroups() async {
    final query = select(groupTable);
    final result = await query.get();
    return Future.wait(
      result.map((groupData) async {
        final members = await db.playerGroupDao.getPlayersOfGroup(
          groupId: groupData.id,
        );
        return Group(
          id: groupData.id,
          name: groupData.name,
          members: members,
          createdAt: groupData.createdAt,
        );
      }),
    );
  }

  /// Retrieves a [Group] by its [groupId], including its members.
  Future<Group> getGroupById({required String groupId}) async {
    final query = select(groupTable)..where((g) => g.id.equals(groupId));
    final result = await query.getSingle();

    List<Player> members = await db.playerGroupDao.getPlayersOfGroup(
      groupId: groupId,
    );

    return Group(
      id: result.id,
      name: result.name,
      members: members,
      createdAt: result.createdAt,
    );
  }

  /// Adds a new group with the given [id] and [name] to the database.
  /// This method also adds the group's members to the [PlayerGroupTable].
  Future<bool> addGroup({required Group group}) async {
    if (!await groupExists(groupId: group.id)) {
      await db.transaction(() async {
        await into(groupTable).insert(
          GroupTableCompanion.insert(
            id: group.id,
            name: group.name,
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

  /// Deletes the group with the given [id] from the database.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> deleteGroup({required String groupId}) async {
    final query = (delete(groupTable)..where((g) => g.id.equals(groupId)));
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Updates the name of the group with the given [id] to [newName].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateGroupname({
    required String groupId,
    required String newName,
  }) async {
    final rowsAffected =
        await (update(groupTable)..where((g) => g.id.equals(groupId))).write(
          GroupTableCompanion(name: Value(newName)),
        );
    return rowsAffected > 0;
  }

  /// Retrieves the number of groups in the database.
  Future<int> getGroupCount() async {
    final count =
        await (selectOnly(groupTable)..addColumns([groupTable.id.count()]))
            .map((row) => row.read(groupTable.id.count()))
            .getSingle();
    return count ?? 0;
  }

  /// Checks if a group with the given [groupId] exists in the database.
  /// Returns `true` if the group exists, `false` otherwise.
  Future<bool> groupExists({required String groupId}) async {
    final query = select(groupTable)..where((g) => g.id.equals(groupId));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// Deletes all groups from the database.
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> deleteAllGroups() async {
    final query = delete(groupTable);
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }
}
