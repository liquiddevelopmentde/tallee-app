import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/statistic_table.dart';
import 'package:tallee/data/models/statistic.dart';

part 'statistic_dao.g.dart';

@DriftAccessor(tables: [StatisticTable])
class StatisticDao extends DatabaseAccessor<AppDatabase>
    with _$StatisticDaoMixin {
  StatisticDao(super.db);

  /* Create */

  Future<bool> addStatistic({required Statistic statistic}) async {
    await into(statisticTable).insert(
      StatisticTableCompanion.insert(
        id: statistic.id,
        type: statistic.type.name,
        timeframe: Value(statistic.timeframe?.name),
      ),
      mode: InsertMode.insertOrReplace,
    );

    await db.statisticScopeDao.addStatisticScopes(
      statisticId: statistic.id,
      scopes: statistic.scopes,
    );

    if (statistic.selectedGroups != null) {
      await db.statisticGroupDao.addStatisticGroups(
        statisticId: statistic.id,
        groups: statistic.selectedGroups!,
      );
    }

    if (statistic.selectedGames != null) {
      await db.statisticGameDao.addStatisticGames(
        statisticId: statistic.id,
        games: statistic.selectedGames!,
      );
    }

    return true;
  }

  /* Read */

  Future<Statistic?> getStatisticById(String statisticId) async {
    final query = select(statisticTable);
    final row = await query.getSingleOrNull();
    if (row != null) {
      final groups = await db.statisticGroupDao.getGroupsForStatistic(row.id);
      final games = await db.statisticGameDao.getGamesForStatistic(row.id);
      final scopes = await db.statisticScopeDao.getScopeForStatistic(row.id);

      return Statistic(
        type: StatisticType.values.firstWhere((type) => type.name == row.type),
        scopes: scopes,
        id: row.id,
        timeframe: Timeframe.values.firstWhereOrNull(
          (t) => t.name == row.timeframe,
        ),
        selectedGroups: groups,
        selectedGames: games,
      );
    }
    return null;
  }

  /// Retrieves all statistics from the database, including their associated groups and games.
  Future<List<Statistic>> getAllStatistics() async {
    final query = select(statisticTable);
    final rows = await query.get();
    return Future.wait(
      rows.map((row) async {
        final groups = await db.statisticGroupDao.getGroupsForStatistic(row.id);
        final games = await db.statisticGameDao.getGamesForStatistic(row.id);

        return Statistic(
          type: StatisticType.values.firstWhere(
            (type) => type.name == row.type,
          ),
          scopes: [],
          id: row.id,
          timeframe: Timeframe.values.firstWhereOrNull(
            (t) => t.name == row.timeframe,
          ),
          selectedGroups: groups,
          selectedGames: games,
        );
      }),
    );
  }

  /* Delete */

  Future<bool> deleteStatistic(String statisticId) async {
    final rowsDeleted = await (delete(
      statisticTable,
    )..where((tbl) => tbl.id.equals(statisticId))).go();

    return rowsDeleted > 0;
  }

  Future<bool> deleteAllStatistics() async {
    final rowsDeleted = await delete(statisticTable).go();
    return rowsDeleted > 0;
  }
}
