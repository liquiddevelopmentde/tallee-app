import 'package:drift/drift.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/group_match_table.dart';
import 'package:tallee/data/dto/group.dart';

part 'group_match_dao.g.dart';

@DriftAccessor(tables: [GroupMatchTable])
class GroupMatchDao extends DatabaseAccessor<AppDatabase>
    with _$GroupMatchDaoMixin {
  GroupMatchDao(super.db);

  /// Associates a group with a match by inserting a record into the
  /// [GroupMatchTable].
  Future<void> addGroupToMatch({
    required String matchId,
    required String groupId,
  }) async {
    if (await matchHasGroup(matchId: matchId)) {
      throw Exception('Match already has a group');
    }
    await into(groupMatchTable).insert(
      GroupMatchTableCompanion.insert(groupId: groupId, matchId: matchId),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// Retrieves the [Group] associated with the given [matchId].
  /// Returns `null` if no group is found.
  Future<Group?> getGroupOfMatch({required String matchId}) async {
    final result = await (select(
      groupMatchTable,
    )..where((g) => g.matchId.equals(matchId))).getSingleOrNull();

    if (result == null) {
      return null;
    }

    final group = await db.groupDao.getGroupById(groupId: result.groupId);
    return group;
  }

  /// Checks if there is a group associated with the given [matchId].
  /// Returns `true` if there is a group, otherwise `false`.
  Future<bool> matchHasGroup({required String matchId}) async {
    final count =
        await (selectOnly(groupMatchTable)
              ..where(groupMatchTable.matchId.equals(matchId))
              ..addColumns([groupMatchTable.groupId.count()]))
            .map((row) => row.read(groupMatchTable.groupId.count()))
            .getSingle();
    return (count ?? 0) > 0;
  }

  /// Checks if a specific group is associated with a specific match.
  /// Returns `true` if the group is in the match, otherwise `false`.
  Future<bool> isGroupInMatch({
    required String matchId,
    required String groupId,
  }) async {
    final count =
        await (selectOnly(groupMatchTable)
              ..where(
                groupMatchTable.matchId.equals(matchId) &
                    groupMatchTable.groupId.equals(groupId),
              )
              ..addColumns([groupMatchTable.groupId.count()]))
            .map((row) => row.read(groupMatchTable.groupId.count()))
            .getSingle();
    return (count ?? 0) > 0;
  }

  /// Removes the association of a group from a match based on [groupId] and
  /// [matchId].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> removeGroupFromMatch({
    required String matchId,
    required String groupId,
  }) async {
    final query = delete(groupMatchTable)
      ..where((g) => g.matchId.equals(matchId) & g.groupId.equals(groupId));
    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Updates the group associated with a match to [newGroupId] based on
  /// [matchId].
  /// Returns `true` if more than 0 rows were affected, otherwise `false`.
  Future<bool> updateGroupOfMatch({
    required String matchId,
    required String newGroupId,
  }) async {
    final updatedRows =
        await (update(groupMatchTable)..where((g) => g.matchId.equals(matchId)))
            .write(GroupMatchTableCompanion(groupId: Value(newGroupId)));
    return updatedRows > 0;
  }
}
