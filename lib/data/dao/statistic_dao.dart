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
        createdAt: statistic.createdAt,
        type: statistic.type.name,
        timeframe: statistic.timeframe.name,
        color: statistic.color.name,
        displayCount: Value(statistic.displayCount),
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

  Future<bool> addStatisticsAsList({
    required List<Statistic> statistics,
  }) async {
    if (statistics.isEmpty) return false;
    await batch((b) {
      b.insertAllOnConflictUpdate(
        statisticTable,
        statistics
            .map(
              (s) => StatisticTableCompanion.insert(
                id: s.id,
                createdAt: s.createdAt,
                type: s.type.name,
                timeframe: s.timeframe.name,
                color: s.color.name,
                displayCount: Value(s.displayCount),
              ),
            )
            .toList(),
      );
    });

    for (final statistic in statistics) {
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
    }

    return true;
  }

  /* Read */

  Future<Statistic?> getStatisticById({required String statisticId}) async {
    final query = select(statisticTable)
      ..where((tbl) => tbl.id.equals(statisticId));
    final row = await query.getSingleOrNull();
    if (row != null) {
      final groups = await db.statisticGroupDao.getGroupsForStatistic(row.id);
      final games = await db.statisticGameDao.getGamesForStatistic(row.id);
      final scopes = await db.statisticScopeDao.getScopeForStatistic(row.id);

      return Statistic(
        type: StatisticType.values.firstWhere((type) => type.name == row.type),
        scopes: scopes,
        timeframe: Timeframe.values.firstWhere((t) => t.name == row.timeframe),
        selectedGroups: groups,
        selectedGames: games,
        displayCount: row.displayCount,
        id: row.id,
        createdAt: row.createdAt,
        color: AppColor.values.firstWhere((c) => c.name == row.color),
      );
    }
    return null;
  }

  /// Retrieves all statistics from the database, including their associated groups and games.
  Future<List<Statistic>> getAllStatistics() async {
    final query = select(statisticTable);
    final result = await query.get();
    return Future.wait(
      result.map((row) async {
        final groups = await db.statisticGroupDao.getGroupsForStatistic(row.id);
        final games = await db.statisticGameDao.getGamesForStatistic(row.id);
        final scopes = await db.statisticScopeDao.getScopeForStatistic(row.id);

        return Statistic(
          type: StatisticType.values.firstWhere(
            (type) => type.name == row.type,
          ),
          scopes: scopes,
          timeframe: Timeframe.values.firstWhere(
            (t) => t.name == row.timeframe,
          ),
          selectedGroups: groups,
          selectedGames: games,
          displayCount: row.displayCount,
          id: row.id,
          createdAt: row.createdAt,
          color: AppColor.values.firstWhere((c) => c.name == row.color),
        );
      }),
    );
  }

  /* Update */

  Future<bool> updateDisplayCount(String statisticId, int displayCount) async {
    final rowsUpdated =
        await (update(statisticTable)
              ..where((tbl) => tbl.id.equals(statisticId)))
            .write(StatisticTableCompanion(displayCount: Value(displayCount)));

    return rowsUpdated > 0;
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
