import 'package:drift/drift.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/group_table.dart';
import 'package:tallee/data/db/tables/statistic_group_table.dart';
import 'package:tallee/data/models/group.dart';

part 'statistic_group_dao.g.dart';

@DriftAccessor(tables: [StatisticGroupTable, GroupTable])
class StatisticGroupDao extends DatabaseAccessor<AppDatabase>
    with _$StatisticGroupDaoMixin {
  StatisticGroupDao(super.db);

  /// Retrieves a list of groups associated with a specific statistic.
  Future<List<Group>> getGroupsForStatistic(String statisticId) async {
    final query = select(statisticGroupTable).join([
      innerJoin(
        groupTable,
        groupTable.id.equalsExp(statisticGroupTable.groupId),
      ),
    ])..where(statisticGroupTable.statisticId.equals(statisticId));

    final results = await query.map((row) => row.readTable(groupTable)).get();
    final groups = await Future.wait(
      results.map((result) async {
        final groupMembers = await db.playerGroupDao.getPlayersOfGroup(
          groupId: result.id,
        );
        return Group(
          id: result.id,
          createdAt: result.createdAt,
          name: result.name,
          description: result.description,
          members: groupMembers,
        );
      }),
    );

    return groups;
  }

  Future<bool> addStatisticGroups({
    required String statisticId,
    required List<Group> groups,
  }) async {
    final entries = groups
        .map(
          (group) => StatisticGroupTableCompanion.insert(
            statisticId: statisticId,
            groupId: group.id,
          ),
        )
        .toList();

    return batch((batch) {
      batch.insertAll(
        statisticGroupTable,
        entries,
        mode: InsertMode.insertOrReplace,
      );
    }).then((_) => true).catchError((error) {
      print('Error adding statistic groups: $error');
      return false;
    });
  }
}
