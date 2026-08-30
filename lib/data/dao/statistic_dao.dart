import 'package:drift/drift.dart';
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
        type: statistic.type,
        timeframe: statistic.timeframe,
        startDate: Value(statistic.startDate),
        endDate: Value(statistic.endDate),
        color: statistic.color,
        displayCount: Value(statistic.displayCount),
        isFavourite: Value(statistic.isFavourite),
        position: Value(statistic.position),
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
                type: s.type,
                timeframe: s.timeframe,
                startDate: Value(s.startDate),
                endDate: Value(s.endDate),
                color: s.color,
                displayCount: Value(s.displayCount),
                isFavourite: Value(s.isFavourite),
                position: Value(s.position),
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
        type: row.type,
        scopes: scopes,
        timeframe: row.timeframe,
        startDate: row.startDate,
        endDate: row.endDate,
        selectedGroups: groups,
        selectedGames: games,
        displayCount: row.displayCount,
        id: row.id,
        createdAt: row.createdAt,
        color: row.color,
        isFavourite: row.isFavourite,
        position: row.position,
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
          type: row.type,
          scopes: scopes,
          timeframe: row.timeframe,
          startDate: row.startDate,
          endDate: row.endDate,
          selectedGroups: groups,
          selectedGames: games,
          displayCount: row.displayCount,
          id: row.id,
          createdAt: row.createdAt,
          color: row.color,
          isFavourite: row.isFavourite,
          position: row.position,
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

  Future<bool> updateIsFavourite(String statisticId, bool isFavourite) async {
    final rowsUpdated =
        await (update(statisticTable)
              ..where((tbl) => tbl.id.equals(statisticId)))
            .write(StatisticTableCompanion(isFavourite: Value(isFavourite)));

    return rowsUpdated > 0;
  }

  Future<void> updatePosition({required List<Statistic> statistics}) async {
    await db.transaction(() async {
      for (int i = 0; i < statistics.length; i++) {
        final stat = statistics[i];
        await (update(statisticTable)..where((tbl) => tbl.id.equals(stat.id)))
            .write(StatisticTableCompanion(position: Value(i)));
      }
    });
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
